#!/usr/bin/env node
// Checks one map note, or the whole map. Seconds, not minutes — the write-then-verify
// cadence in grill-map only survives if the check is cheap enough to run per note.
//
// SCOPE, written next to the gate because a gate reports success over its scope and
// not over the repository: it reads `docs/map/**.md` and resolves links and symbols
// against the repository root. It is re-derived from `ls`, never from a hand list —
// a new note or a new territory directory is visible the moment it exists.
//
// Usage:  node docs/map/mapcheck.mjs [file ...]     (no args = every note)

import { readFileSync, readdirSync, existsSync, statSync } from 'node:fs'
import { join, dirname, resolve, relative } from 'node:path'
import { execFileSync } from 'node:child_process'

const ROOT = resolve(dirname(new URL(import.meta.url).pathname), '../..')
const MAP = join(ROOT, 'docs/map')

const TERRITORY_SECTIONS = [
  'What it is',
  'Governing decisions',
  'Design model',
  'Code',
  'Reference behaviour',
  'Cross-cutting invariants',
  'Blast radius',
  'Known holes / open',
]
const INVARIANT_SECTIONS = [
  'The fact',
  'Why it is cross-cutting',
  'Territories it holds in',
  'What a violation looks like',
  'Discovery history',
  'Where it will recur',
]

// A tool that checks documentation must skip code spans and fenced blocks: a doc about
// links contains link-shaped text. Blank the regions with spaces so byte offsets — and
// therefore line numbers — survive.
function blankFences(src) {
  return src.replace(/```[\s\S]*?(?:```|$)/g, (m) => m.replace(/[^\n]/g, ' '))
}

function blankCode(src) {
  return blankFences(src).replace(/`[^`\n]*`/g, (m) => ' '.repeat(m.length))
}

// GitHub's anchor rule: lowercase, drop anything but word chars / spaces / hyphens,
// spaces to hyphens. Backticks and em-dashes vanish, which is why `a -- b` collapses.
function anchorOf(heading) {
  return heading
    .trim()
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
}

// Headings are read with fences blanked but inline code spans intact: GitHub strips the
// backticks from `sleep` and keeps the word, so blanking the span would compute an anchor
// for a heading that does not exist and report every correct link to it as broken.
function headingsOf(file) {
  const src = blankFences(readFileSync(file, 'utf8'))
  return [...src.matchAll(/^#{1,6}\s+(.+?)\s*$/gm)].map((m) => m[1])
}

function mdFiles(dir) {
  if (!existsSync(dir)) return []
  return readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const p = join(dir, e.name)
    if (e.isDirectory()) return mdFiles(p)
    return e.isFile() && e.name.endsWith('.md') ? [p] : []
  })
}

let tracked = null
function inTree(symbol) {
  if (tracked === null) {
    tracked = execFileSync('git', ['-C', ROOT, 'ls-files', '*.dart', '*.mjs', '*.sh'], {
      encoding: 'utf8',
    })
      .split('\n')
      .filter(Boolean)
  }
  // Word-boundary grep over tracked sources only — build/ and .dart_tool/ hold copies
  // that would make a deleted symbol look alive.
  for (const f of tracked) {
    const src = readFileSync(join(ROOT, f), 'utf8')
    if (new RegExp(`\\b${symbol.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`).test(src)) return f
  }
  return null
}

function check(file) {
  const problems = []
  const raw = readFileSync(file, 'utf8')
  const src = blankCode(raw)
  const heads = blankFences(raw) // section names may legitimately contain code spans
  const rel = relative(ROOT, file)
  const lineOf = (idx) => src.slice(0, idx).split('\n').length

  const kind = rel.includes('/territory/')
    ? 'territory'
    : rel.includes('/invariant/')
      ? 'invariant'
      : 'hub'

  // 1. The section set is complete and exactly spelled. One note spelling a heading
  //    differently is a node that silently drops out of every hub count.
  if (kind !== 'hub') {
    const want = kind === 'territory' ? TERRITORY_SECTIONS : INVARIANT_SECTIONS
    const got = [...heads.matchAll(/^##\s+(.+?)\s*$/gm)].map((m) => m[1])
    for (const w of want) if (!got.includes(w)) problems.push(`missing section "## ${w}"`)
    for (const g of got) if (!want.includes(g)) problems.push(`unknown section "## ${g}"`)
  }

  // 2. Every link and #anchor resolves. A missing anchor falls back silently to the top
  //    of the target, which is why this half matters more than the 404 half.
  for (const m of src.matchAll(/\[[^\]\n]*\]\(([^)\s]+)\)/g)) {
    const href = m[1]
    if (/^(https?:|mailto:)/.test(href)) continue
    const [path, frag] = href.split('#')
    const target = path === '' ? file : resolve(dirname(file), path)
    if (!existsSync(target)) {
      problems.push(`${lineOf(m.index)}: link target missing — ${href}`)
      continue
    }
    if (frag && statSync(target).isFile()) {
      const anchors = new Set(headingsOf(target).map(anchorOf))
      if (!anchors.has(frag)) problems.push(`${lineOf(m.index)}: anchor missing — ${href}`)
    }
  }

  // 3. Every symbol named under `## Code` resolves somewhere in the tracked tree.
  //    `**None.**` stands the check down: a territory can be recorded and not built.
  const code = src.match(/^## Code\s*$([\s\S]*?)(?=^## |\Z)/m)
  if (code && !/\*\*None\.\*\*/.test(code[1])) {
    const body = raw.slice(code.index, code.index + code[0].length)
    for (const m of body.matchAll(/`([A-Za-z_][\w./]*(?:\s*—\s*)?)`/g)) {
      const tokens = m[1].split(/\s*—\s*/).filter(Boolean)
      for (const t of tokens) {
        if (/^[a-z_]+[\w]*\.(dart|mjs|sh|md|yaml)$/.test(t)) continue // a filename, checked below
        if (!/^[A-Z]/.test(t)) continue // only public types are claimed here
        if (!inTree(t)) problems.push(`symbol not found in tree — ${t}`)
      }
    }
    for (const m of body.matchAll(/`([\w/]+\.(?:dart|mjs|sh))`/g)) {
      if (!tracked) inTree('__prime__')
      if (!tracked.some((f) => f.endsWith(m[1]))) problems.push(`file not in tree — ${m[1]}`)
    }
    if (/:\d+\b/.test(body.replace(/\d{4}-\d{2}-\d{2}/g, ''))) {
      problems.push('line number under ## Code — use `file — Symbol`, never a line number')
    }
  }

  return problems
}

// 4. Reciprocity: every territory an invariant claims must claim it back. The reading
//    protocol sends a reader to their territory and tells them to follow that section
//    as a checklist, so an invariant the territory omits is invisible exactly when needed.
function reciprocity() {
  const problems = []
  // Select by path shape over the whole map tree, not by a hardcoded directory: a gate
  // handed a fixed root reports success over that root and not over the map, and the
  // first draft of this function scanned an empty directory and exited 0.
  const invariants = mdFiles(MAP).filter((f) => f.includes('/invariant/'))
  for (const inv of invariants) {
    const src = blankCode(readFileSync(inv, 'utf8'))
    const sec = src.match(/^## Territories it holds in\s*$([\s\S]*?)(?=^## |\Z)/m)
    if (!sec) continue
    for (const m of sec[1].matchAll(/\[[^\]\n]*\]\(([^)#\s]+)\)/g)) {
      const terr = resolve(dirname(inv), m[1])
      if (!existsSync(terr)) continue
      const back = blankCode(readFileSync(terr, 'utf8')).match(
        /^## Cross-cutting invariants\s*$([\s\S]*?)(?=^## |\Z)/m,
      )
      const name = relative(ROOT, inv).split('/').pop()
      if (!back || !back[1].includes(name)) {
        problems.push(
          `${relative(ROOT, terr)}: does not claim back ${name} (one-way edge, invisible from the territory)`,
        )
      }
    }
  }
  return problems
}

const args = process.argv.slice(2)
const files = args.length ? args.map((a) => resolve(a)) : mdFiles(MAP)
let bad = 0
for (const f of files) {
  const p = check(f)
  if (p.length) {
    bad += p.length
    console.log(`\n${relative(ROOT, f)}`)
    for (const x of p) console.log(`  ${x}`)
  }
}
if (!args.length) {
  const r = reciprocity()
  if (r.length) {
    bad += r.length
    console.log('\nreciprocity')
    for (const x of r) console.log(`  ${x}`)
  }
}
console.log(bad ? `\n${bad} problem(s) in ${files.length} file(s)` : `ok — ${files.length} file(s)`)
process.exit(bad ? 1 : 0)
