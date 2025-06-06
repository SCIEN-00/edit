#!/usr/bin/env bash
set -euo pipefail

# 1. Paths (adjust if your distro differs)
BINDIR=/usr/local/bin
DESKTOPDIR="${HOME}/.local/share/applications"
ICONDIR="${HOME}/.local/share/icons/hicolor/scalable/apps"
MAN1DIR=/usr/local/share/man/man1

# 2. Build (optional – if you already built, you can comment this out)
cargo build --release

# 3. Install binary (install -D will create parent dirs if needed)
echo "→ Installing: $BINDIR/edit"
sudo install -Dm755 target/release/edit "$BINDIR/edit"

# 4. Install .desktop (always works on XDG systems; create if missing)
echo "→ Installing: $DESKTOPDIR/com.microsoft.edit.desktop"
mkdir -p "$DESKTOPDIR"
install -Dm644 assets/com.microsoft.edit.desktop \
          "$DESKTOPDIR/com.microsoft.edit.desktop"

# 5. (Optional) Fix Exec line if you ever shipped a relative path
# sed -i 's|^Exec=.*|Exec=/usr/local/bin/edit %U|' \
#        "$DESKTOPDIR/com.microsoft.edit.desktop"

# 6. Install icon (create folder if needed)
echo "→ Installing icon: $ICONDIR/edit.svg"
mkdir -p "$ICONDIR"
install -Dm644 assets/edit.svg "$ICONDIR/edit.svg"

# 7. Refresh icon cache (only if gtk-update-icon-cache exists)
if command -v gtk-update-icon-cache &>/dev/null; then
  echo "→ Updating icon cache…"
  gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" &>/dev/null || true
else
  echo "→ Skipping icon‐cache update (gtk-update-icon-cache not found)."
fi

# 8. Refresh desktop database (only if update-desktop-database exists)
if command -v update-desktop-database &>/dev/null; then
  echo "→ Updating desktop‐database…"
  update-desktop-database "$DESKTOPDIR" &>/dev/null || true
else
  echo "→ Skipping desktop‐database update (update-desktop-database not found)."
fi

# 9. Install manpage if possible
if command -v mandb &>/dev/null; then
  echo "→ Installing manpage to $MAN1DIR/edit.1.gz"
  sudo install -Dm644 assets/manpage/edit.1 "$MAN1DIR/edit.1"
  sudo gzip -f "$MAN1DIR/edit.1"
  sudo mandb &>/dev/null || true
else
  echo "→ Skipping manpage indexing (mandb not found)."
  # Still install the file (even if index won’t refresh):
  sudo install -Dm644 assets/manpage/edit.1 "$MAN1DIR/edit.1"
  sudo gzip -f "$MAN1DIR/edit.1"
fi

echo -e "\n✅ All done. You can now run 'edit' and see “Microsoft Edit” in your app menu."