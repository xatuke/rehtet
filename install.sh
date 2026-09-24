#!/bin/bash
# usbshare installer. Usage:
#   curl -fsSL https://raw.githubusercontent.com/xatuke/usbshare/main/install.sh | bash
set -e
REPO="${USBSHARE_REPO:-https://raw.githubusercontent.com/xatuke/usbshare/main}"
[ "$(uname)" = Darwin ] || { echo "usbshare is macOS only."; exit 1; }
if [ -w /usr/local/bin ]; then DEST=/usr/local/bin; else DEST="$HOME/.local/bin"; mkdir -p "$DEST"; fi
if [ -f "$(dirname "$0")/usbshare" ] && [ "${1:-}" != "--remote" ]; then
  cp "$(dirname "$0")/usbshare" "$DEST/usbshare"
else
  curl -fsSL "$REPO/usbshare" -o "$DEST/usbshare"
fi
chmod +x "$DEST/usbshare"
echo "Installed to $DEST/usbshare"
case ":$PATH:" in *":$DEST:"*) ;; *) echo "Add $DEST to your PATH, e.g.:  export PATH=\"$DEST:\$PATH\"";; esac
if ! command -v tinyproxy >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then echo "Installing tinyproxy (the proxy usbshare runs)..."; brew install tinyproxy
  else echo "Install Homebrew from https://brew.sh, then: brew install tinyproxy"; fi
fi
echo
echo "Next: run   usbshare setup"
