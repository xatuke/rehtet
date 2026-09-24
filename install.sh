#!/bin/bash
# rehtet installer. Usage:
#   curl -fsSL https://xatuke.github.io/rehtet/install.sh | bash
# Installs rehtet (and tinyproxy via Homebrew), then starts "rehtet setup".
# Set REHTET_NO_SETUP=1 to only install.
set -e
REPO="${REHTET_REPO:-https://xatuke.github.io/rehtet}"
[ "$(uname)" = Darwin ] || { echo "rehtet is macOS only."; exit 1; }
if [ -w /opt/homebrew/bin ]; then DEST=/opt/homebrew/bin; elif [ -w /usr/local/bin ]; then DEST=/usr/local/bin; else DEST="$HOME/.local/bin"; mkdir -p "$DEST"; fi
if [ -f "$(dirname "$0")/rehtet" ] && [ "${1:-}" != "--remote" ]; then
  cp "$(dirname "$0")/rehtet" "$DEST/rehtet"
else
  curl -fsSL "$REPO/rehtet?$(date +%s)" -o "$DEST/rehtet"   # query string sidesteps the raw CDN cache
fi
chmod +x "$DEST/rehtet"
echo "Installed to $DEST/rehtet"
case ":$PATH:" in *":$DEST:"*) ;; *) echo "Add $DEST to your PATH, e.g.:  export PATH=\"$DEST:\$PATH\"";; esac
if ! command -v tinyproxy >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then echo "Installing tinyproxy (the proxy rehtet runs)..."; brew install tinyproxy
  else echo "Install Homebrew from https://brew.sh, then: brew install tinyproxy"; fi
fi
echo
# When run from a terminal, go straight into the guided setup. Reads from
# /dev/tty because under "curl | bash" stdin is the script itself.
if [ "${REHTET_NO_SETUP:-}" != 1 ] && [ -t 1 ] && [ -r /dev/tty ]; then
  echo "Starting the guided setup..."; echo
  exec "$DEST/rehtet" setup < /dev/tty
fi
echo "Next: run   rehtet setup"
