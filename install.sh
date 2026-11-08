#!/usr/bin/env bash
# Installs swanctl-tray for the current user (no root needed).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin="$HOME/.local/bin"
apps="$HOME/.local/share/applications"
autostart="$HOME/.config/autostart"
cfgdir="$HOME/.config/swanctl-tray"

missing=()
python3 -c "import gi; gi.require_version('AyatanaAppIndicator3','0.1')" 2>/dev/null \
  || missing+=(gir1.2-ayatanaappindicator3-0.1)
python3 -c "import gi; gi.require_version('Gtk','3.0')" 2>/dev/null || missing+=(gir1.2-gtk-3.0)
command -v notify-send >/dev/null || missing+=(libnotify-bin)
if ((${#missing[@]})); then
  echo "Missing packages. Run: sudo apt install ${missing[*]}" >&2
  exit 1
fi

mkdir -p "$bin" "$apps" "$autostart" "$cfgdir"
install -m 755 "$here/swanctl-tray" "$bin/swanctl-tray"
[ -e "$cfgdir/config.ini" ] || install -m 644 "$here/examples/config.ini" "$cfgdir/config.ini"

desktop="[Desktop Entry]
Type=Application
Name=swanctl tray
Comment=Connect/disconnect a strongSwan tunnel from the top bar
Exec=$bin/swanctl-tray
Icon=network-vpn-symbolic
Terminal=false
Categories=Network;
X-GNOME-Autostart-enabled=true"
printf '%s\n' "$desktop" > "$apps/swanctl-tray.desktop"
printf '%s\n' "$desktop" > "$autostart/swanctl-tray.desktop"

echo "Installed. Edit $cfgdir/config.ini if your connection is not UPVNET/net."
echo "Needs passwordless sudo for swanctl: see examples/sudoers.d/swanctl-tray"
echo "Start now with: swanctl-tray &   (it also autostarts on next login)"
