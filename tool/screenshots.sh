#!/usr/bin/env bash
# Regenerates the README images from the example app.
#
# Run it after any change to the example or the shell. The images are captures
# of a build made here, right now — a hand-cropped screenshot of a UI that has
# since moved is a citation that no longer says anything.
#
#   tool/screenshots.sh              # all of them
#   tool/screenshots.sh device-wall  # one
#
# Needs Google Chrome and Node. No npm install: the driver speaks the DevTools
# protocol over Node's own WebSocket, because a tool that needs a dependency
# tree is a tool that stops being rerun.
#
# **The committed images are macOS captures, and only macOS reproduces them.**
# Flutter web reads `defaultTargetPlatform` off the user agent, and Material
# reads that for its adaptive defaults — `AppBar.centerTitle` among them. So the
# app bar title sits centred in a capture made on a Mac and hard left in one
# made anywhere else, and that is a layout difference, not a rendering one: it
# survives any zoom, any encoder, any amount of squinting at the picture.
#
# Measured on `code-pane.png` (#14). Of 7129 pixels differing from the committed
# capture, 7093 — 99.5% — lie in the top 100 rows, which is the app bar and
# nothing else; the remaining 36 are scattered antialiasing. The guess before
# the measurement was fonts, and fonts are not it. The Code pane's own text
# renders the same on both.
#
# That is how this was found. `code-pane.png` was recaptured on its own, off a
# Mac, while the other three stayed macOS, and from then on every run on every
# machine moved some subset of the four. A reviewer who sees files move on every
# run stops reading them, which is the one thing
# `.github/workflows/screenshots.yml` exists to preserve.
#
# Capturing on another platform is fine — that is what CI does, on Linux, and it
# is looking for a shot it cannot reach rather than for a picture. What is not
# fine is committing the result. The notice below says so where it matters.
#
# It exits non-zero when a shot could not be reached. That is the point of it:
# the driver presses controls by their semantics label and checks what is on
# screen before it captures, so a moved menu row fails the run instead of
# producing a confidently wrong picture.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/docs/images"
PROFILE="$(mktemp -d)"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"

[ -x "$CHROME" ] || { echo "Chrome not found at: $CHROME" >&2; exit 1; }
command -v node >/dev/null || { echo "node not found" >&2; exit 1; }

# A notice, not a failure. CI runs this on Linux on purpose and has to stay
# green; the person who needs telling is the one about to `git add` four files
# that will look like a UI change and are not one.
if [ "$(uname -s)" != "Darwin" ]; then
  echo "note: the committed images are macOS captures. These will differ from" >&2
  echo "      them wherever an app bar is in shot — Material centres the title" >&2
  echo "      on a Mac and left-aligns it everywhere else — rather than for" >&2
  echo "      anything you changed. Look at them, but do not commit them from" >&2
  echo "      here. See the header, and #14." >&2
fi

# Ports are taken, not assumed. A fixed debugger port attaches to whatever
# Chrome already had one open — someone's own browser, photographed instead of
# ours, and nothing about the picture would say so.
free_port() { python3 -c 'import socket;s=socket.socket();s.bind(("",0));print(s.getsockname()[1]);s.close()'; }
PORT="$(free_port)"
DEBUG_PORT="$(free_port)"

mkdir -p "$OUT"

echo "==> building the example for web"
# No service worker: it caches hard enough to photograph the previous build,
# and the picture would not say so.
(cd "$ROOT/example" && flutter build web --no-tree-shake-icons --pwa-strategy=none >/dev/null)

echo "==> serving build/web on :$PORT"
(cd "$ROOT/example/build/web" && python3 -m http.server "$PORT" >/dev/null 2>&1) &
SERVER=$!

echo "==> starting headless Chrome (debugger on :$DEBUG_PORT)"
"$CHROME" --headless=new --disable-gpu --enable-unsafe-swiftshader --no-sandbox \
  --hide-scrollbars --remote-debugging-port="$DEBUG_PORT" \
  --user-data-dir="$PROFILE" about:blank >/dev/null 2>&1 &
BROWSER=$!

# Nothing in here may change the verdict. Chrome is still writing to its
# profile as it dies, so removing the directory races it and fails — and that
# failure became the exit status, reporting a clean four-shot run as a
# failure three times running. A red that means nothing is worth no more than
# a green that means nothing; `docs/agents/lessons.md` says so about both.
cleanup() {
  local status=$?
  kill "$SERVER" "$BROWSER" 2>/dev/null || true
  wait "$BROWSER" 2>/dev/null || true
  rm -rf "$PROFILE" 2>/dev/null || true
  exit "$status"
}
trap cleanup EXIT

for _ in $(seq 1 40); do
  curl -sf "http://localhost:$DEBUG_PORT/json/version" >/dev/null && break
  sleep 0.25
done

echo "==> capturing"
node "$ROOT/tool/shots.mjs" "http://localhost:$PORT/" "$DEBUG_PORT" "$OUT" "$@"

echo "==> done; look at them before committing"
