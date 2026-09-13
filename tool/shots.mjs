// Drives the built example in headless Chrome and captures the README images.
//
// The app is driven the way a reader drives it — navigate, click, screenshot —
// rather than by composing the widgets separately. A picture of `DeviceWall`
// built on its own would be a picture of something no reader ever sees; this is
// the shell in wall mode, chrome and all.
//
// Chrome DevTools Protocol over a raw WebSocket, because Node ships one. A
// screenshot tool that needs an npm install is a screenshot tool nobody reruns,
// and a stale image is a stale citation.
//
// **Clicks are found, not measured, and every shot is checked.** The first
// version of this file carried a table of CSS coordinates — the wall segment at
// [1076, 84], the Crowded chip at [1185, 85] — which is a roster of the app's
// own layout kept in step by hand, in a repository whose `docs/agents/lessons.md`
// says never to keep one. Worse, it could not fail: a click landing on nothing
// produced a confidently wrong picture and an exit code of 0. Both are gone.
// Flutter's semantics tree gives every control a label, so a step names what it
// presses and a shot names what must be true once it has.

import { writeFileSync } from 'node:fs';

const [, , base, debugPort, outDir, ...only] = process.argv;
const DPR = 2;
const VIEW = { width: 1440, height: 900 };

/// A frame's caption under the preview: "1440 × 900 · 0.59×", or "· 1:1" once
/// a frame is at real size. Three of them exist only in the wall, which is the
/// cheapest true statement about it.
///
/// Both forms, because `PreviewFrame` prints the factor only when there is one
/// — and at 1920 the phone frame reaches 1:1, which this check caught while the
/// pattern still knew about one of them.
const FRAME_CAPTION = /^\d+ × \d+ · ([\d.]+×|1:1)$/;

const shots = [
  {
    name: 'shell',
    caption: 'the whole shell at desktop width',
    steps: ['Editor toolbar'],
    // The knob region carries the settings panel only for this destination; a
    // recipe puts a note there instead.
    expect: ['Crowded'],
    absent: ['A recipe has no knobs of its own'],
  },
  {
    name: 'device-wall',
    caption: 'every viewport at once, live, over one set of knobs',
    // Crowded, not Icons only: with labels off the actions are narrow enough
    // that all three frames hold all ten, and three identical frames are a
    // picture of nothing. The wall is worth a screenshot exactly when the
    // widths disagree.
    steps: ['Editor toolbar', 'Crowded', 'All · side by side'],
    // A wider window than the others: at 1440 the stage gives each column ~296
    // px and the desktop frame renders at 0.19×, which is ten labelled actions
    // no reader can read. The wall is the one shot that has to be *seen*.
    view: { width: 1920, height: 1000 },
    expectCount: [[FRAME_CAPTION, 3]],
    // "7 more" is the phone frame's overflow menu, and it is the same claim the
    // Crowded preset's guidance makes in words — "keeps three and menus the
    // other seven". The picture and the sentence now stand or fall together.
    expect: ['7 more'],
  },
  {
    name: 'code-pane',
    caption: "a recipe's own source, read out of the bundle",
    steps: ['Basic bar', 'Code'],
    // The path bar, which says the pane is pointed at the right file.
    expect: ['lib/recipes/basic_action_bar.dart'],
    // And the file itself, which the path bar does not imply. See `isBlank`.
    // `ink` is where the first lines of this recipe fall; `paper` is empty
    // space below its last one. Equal captures mean the body drew nothing.
    notBlank: {
      what: "the recipe's source",
      ink: { x: 250, y: 165, width: 300, height: 90 },
      paper: { x: 250, y: 800, width: 300, height: 90 },
    },
  },
  {
    name: 'settings-panel',
    caption: 'a preset applied, and the line that earns it its name',
    steps: ['Editor toolbar', 'Icons only'],
    // The guidance line appears only while a preset is the active one.
    expect: ['The same ten actions, no labels'],
    // Cropped to the knob region: the panel is 320 wide, and a full-window
    // shot of it is mostly the thing it is not about.
    clip: { x: 1120, y: 56, width: 320, height: 700 },
  },
];

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/// Polls until `probe()` returns something truthy, or gives up saying what it
/// was waiting for.
///
/// **Every wait in this file goes through here.** The first version leaned on
/// fixed sleeps — 1500ms after boot, 700ms after each press — while its own
/// comment argued that a fixed wait is either flaky or slow. It was flaky: one
/// clean run in four failed on a control that had not been built yet, which is
/// the tool crying wolf, and a tool that cries wolf stops being rerun.
async function until(probe, describe, timeoutMs = 20000) {
  const deadline = Date.now() + timeoutMs;
  let last;
  while (Date.now() < deadline) {
    last = await probe();
    if (last) return last;
    await sleep(150);
  }
  throw new Error(`timed out waiting for ${describe}`);
}

async function connect(port) {
  const list = await (await fetch(`http://localhost:${port}/json/list`)).json();
  const page = list.find((t) => t.type === 'page');
  if (!page) throw new Error(`no page target on :${port}`);
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise((res, rej) => {
    ws.addEventListener('open', res, { once: true });
    ws.addEventListener('error', rej, { once: true });
  });

  let next = 1;
  const pending = new Map();
  ws.addEventListener('message', (event) => {
    const msg = JSON.parse(event.data);
    if (msg.id && pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      msg.error ? reject(new Error(JSON.stringify(msg.error))) : resolve(msg.result);
    }
  });

  const send = (method, params = {}) =>
    new Promise((resolve, reject) => {
      const id = next++;
      pending.set(id, { resolve, reject });
      ws.send(JSON.stringify({ id, method, params }));
    });

  return { send, close: () => ws.close() };
}

const evaluate = async (send, expression) =>
  (await send('Runtime.evaluate', { expression, returnByValue: true })).result.value;

/// How a semantics node says what it is. An element with children carries its
/// whole subtree's text, so only leaves are taken by text — otherwise the root
/// "matches" every label on screen at once.
const LABEL_OF = `(el) =>
  el.getAttribute('aria-label') ??
  (el.children.length === 0 ? el.textContent.trim() : null)`;

/// How a claim reads one. Non-leaf nodes carry their whole subtree's text, and
/// some things worth checking live only there — a preview frame's caption is
/// merged into the frame's node rather than standing alone. Distinct, so the
/// nesting cannot inflate a count.
const TEXT_OF = `(el) => el.getAttribute('aria-label') ?? el.textContent.trim()`;

/// Resolves once Flutter has put its view in the document.
async function waitForFlutter(send) {
  await until(
    () => evaluate(send, `!!document.querySelector('flutter-view, flt-glass-pane')`),
    'Flutter to boot',
  );
}

/// Turns the semantics tree on, which is what makes this tool able to find a
/// control and to check a claim. Flutter builds it only when something asks.
async function enableSemantics(send) {
  await until(async () => {
    await evaluate(send, `document.querySelector('flt-semantics-placeholder')?.click()`);
    return evaluate(send, `document.querySelectorAll('flt-semantics').length > 0`);
  }, 'the semantics tree, without which nothing can be found or checked');
}

const labels = (send) =>
  evaluate(send, `Array.from(new Set(
    Array.from(document.querySelectorAll('flt-semantics'))
      .map(${TEXT_OF}).filter((l) => l)))`);

/// Presses the smallest node carrying this label.
///
/// A DOM `click` on the semantics element rather than a synthetic mouse event
/// at its centre. Flutter's semantics nodes are real elements that listen for
/// `click` and turn it into a tap action; once the tree is on they also sit
/// over the canvas, so a coordinate event lands on the overlay and reaches the
/// framework as nothing at all. That was measured here — every shot failed its
/// own check, which is the tool working.
///
/// Smallest because semantics nest: an ancestor can repeat a child's label, and
/// pressing the ancestor does something else or nothing.
async function press(send, label) {
  const find = `(() => {
    const hits = Array.from(document.querySelectorAll('flt-semantics'))
      .filter((el) => (${LABEL_OF})(el) === ${JSON.stringify(label)})
      .filter((el) => {
        const r = el.getBoundingClientRect();
        return r.width > 0 && r.height > 0;
      })
      .sort((a, b) => {
        const x = a.getBoundingClientRect(), y = b.getBoundingClientRect();
        return x.width * x.height - y.width * y.height;
      });
    return hits.length ? hits[0] : null;
  })()`;

  // Wait for the control rather than assuming the frame that draws it has
  // landed. A press is only meaningful once there is something to press.
  await until(
    () => evaluate(send, `!!${find}`),
    `a control labelled ${JSON.stringify(label)}`,
  ).catch(() => {
    throw new Error(`no control labelled ${JSON.stringify(label)}`);
  });
  await evaluate(send, `${find}.click()`);
}

/// Whether the region that should be carrying content is empty.
///
/// Two clips of the same size: one where the content must fall, one from a part
/// of the same pane that must stay empty. A flat colour encodes to the same PNG
/// bytes wherever it is taken from, so identical captures mean nothing was
/// drawn — and one glyph in the first is enough to break the equality. No image
/// library, which matters for a tool whose own comment says that a dependency
/// tree is what stops a tool being rerun.
///
/// **This is the only check here that reads the picture, and the Code pane is
/// why.** Its content is painted to a canvas that never reaches the DOM or the
/// semantics tree, so no string check can see it — and a `Semantics` label added
/// to make one possible would be present whether or not the paint succeeded.
/// The first version of this tool checked the path bar above the pane instead,
/// which is drawn before the file arrives and stays drawn if it never does;
/// `docs/images/code-pane.png` was empty from the commit that added the tool
/// until the one that added this.
async function isBlank(send, { ink, paper }) {
  const grab = async (clip) =>
    (
      await send('Page.captureScreenshot', {
        format: 'png',
        clip: { ...clip, scale: 1 },
      })
    ).data;
  return (await grab(ink)) === (await grab(paper));
}

/// Captures once the picture has stopped moving, not once the labels are right.
///
/// [check] polls the semantics tree, so it returns on the first frame where the
/// app *says* it is in the right state. Saying so and having finished drawing
/// it are different moments: a chip pressed two steps ago can still be running
/// its selection tint, and the capture lands at whatever phase that animation
/// happened to be in. Nothing about the picture says so, and the tool's exit
/// code stays 0.
///
/// Measured on `device-wall.png`, which was the one shot of the four that
/// reproduced on neither platform: 5890 pixels (0.077%) differing from the
/// committed capture, all inside a 109x60 box around the Crowded chip, at a
/// maximum channel delta of 18. Small enough to be invisible, large enough to
/// make the file move — which is the combination that trains a reviewer to skim
/// a gate, and the reason `screenshots.yml` uploads these for a human at all.
///
/// Two identical consecutive frames rather than a fixed wait, for the reason
/// [until] already gives: a fixed wait is either flaky or slow. Comparing the
/// encoded PNG is enough — this is the same trick [isBlank] uses, and a
/// dependency-free one, which the header of this file says is why the tool
/// still gets rerun.
async function settled(send, shot) {
  const grab = async () =>
    (
      await send('Page.captureScreenshot', {
        format: 'png',
        // `deviceScaleFactor` already renders at DPR. A scale here would
        // multiply on top of it — the first run of this produced 4x files.
        ...(shot.clip ? { clip: { ...shot.clip, scale: 1 } } : {}),
      })
    ).data;

  let previous = await grab();
  return until(
    async () => {
      const current = await grab();
      const same = current === previous;
      previous = current;
      return same ? current : null;
    },
    'the picture to stop moving',
  );
}

/// What makes this tool able to be wrong out loud.
///
/// Every claim is checked against the labels actually on screen at the moment
/// of capture, so a step that pressed nothing, or pressed the wrong thing,
/// stops the run instead of writing a picture of some other state.
async function check(send, shot) {
  // Polled, not sampled once: the last press may still be settling, and a
  // claim that becomes true a frame later was never false. What a timeout
  // means here is that it never became true at all.
  let missing = [];
  const unmet = async () => {
    const found = await labels(send);
    const has = (needle) => found.some((l) => l.includes(needle));
    const blank = shot.notBlank ? await isBlank(send, shot.notBlank) : false;
    missing = [
      ...(shot.expect ?? [])
        .filter((n) => !has(n))
        .map((n) => `nothing on screen says ${JSON.stringify(n)}`),
      ...(shot.absent ?? [])
        .filter((n) => has(n))
        .map((n) => `${JSON.stringify(n)} is on screen and should not be`),
      ...(shot.expectCount ?? [])
        .map(([pattern, want]) => [pattern, want, found.filter((l) => pattern.test(l)).length])
        .filter(([, want, got]) => got !== want)
        .map(([pattern, want, got]) => `expected ${want} labels matching ${pattern}, found ${got}`),
      ...(blank ? [`the region that should hold ${shot.notBlank.what} is blank`] : []),
    ];
    return missing.length === 0;
  };

  try {
    await until(unmet, 'the shot to reach the state it claims');
  } catch {
    throw new Error(
      `${shot.name}: the steps did not reach the state this shot claims to show\n  ` +
        missing.join('\n  '),
    );
  }
}

const { send, close } = await connect(debugPort);
await send('Page.enable');
await send('Runtime.enable');
await send('Network.enable');
// A screenshot of a build that is one edit behind is the stale citation this
// tool exists to avoid, and nothing about the picture says which build it is.
// Flutter's service worker caches hard enough to do exactly that, so the cache
// is off here and `screenshots.sh` builds with --pwa-strategy=none.
await send('Network.setCacheDisabled', { cacheDisabled: true });

let failures = 0;
for (const shot of shots) {
  if (only.length && !only.includes(shot.name)) continue;

  const view = shot.view ?? VIEW;
  await send('Emulation.setDeviceMetricsOverride', {
    ...view, deviceScaleFactor: DPR, mobile: false,
  });
  // The README is read on a light page far more often than a dark one, and
  // headless Chrome reports dark by default.
  await send('Emulation.setEmulatedMedia', {
    features: [{ name: 'prefers-color-scheme', value: 'light' }],
  });

  // A fresh document each time, so one shot's clicks cannot leak into the next.
  await send('Page.navigate', { url: base });
  await waitForFlutter(send);
  await enableSemantics(send);

  try {
    for (const label of shot.steps) await press(send, label);
    await check(send, shot);
  } catch (error) {
    console.error(`FAIL ${shot.name}: ${error.message}`);
    failures++;
    continue;
  }

  let data;
  try {
    data = await settled(send, shot);
  } catch (error) {
    console.error(`FAIL ${shot.name}: ${error.message}`);
    failures++;
    continue;
  }
  const path = `${outDir}/${shot.name}.png`;
  writeFileSync(path, Buffer.from(data, 'base64'));
  const size = shot.clip ?? view;
  console.log(`${path}  ${size.width}×${size.height} @${DPR}x  — ${shot.caption}`);
}

close();
if (failures) process.exit(1);
