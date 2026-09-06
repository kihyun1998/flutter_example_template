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
