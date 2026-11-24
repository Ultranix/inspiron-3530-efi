#!/bin/bash
set -euo pipefail
DISK_EFI=disk4s1
TASK_SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
SRC="$TASK_SCRIPT_DIR/EFI/OC/config.plist"
echo "Patching boot-args (-btlfxallowanyaddr) on $DISK_EFI"
diskutil unmount force "$DISK_EFI" 2>/dev/null || true
sudo diskutil mount "$DISK_EFI"
MP=$(diskutil info "$DISK_EFI" | awk -F': *' '/Mount Point/{print $2; exit}')
CFG="$MP/EFI/OC/config.plist"
test -f "$CFG"
cp -f "$CFG" "$CFG.bak-pre-btlfx-$(date +%Y%m%d%H%M%S)"
# Prefer copying prepared config (already has Front + new boot-arg)
ditto --norsrc --noextattr --noqtn "$SRC" "$CFG"
sync
plutil -lint "$CFG"
plutil -extract NVRAM.Add.7C436110-AB2A-4BBB-A880-FE41995C9F82.boot-args raw "$CFG"
echo
echo "BTLFX_BOOTARG_DONE"
