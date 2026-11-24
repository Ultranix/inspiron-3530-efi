#!/bin/bash
set -e
TASK_SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
SRC="$TASK_SCRIPT_DIR/EFI/OC/Kexts/UTBDefault.kext"
DISK_EFI=disk4s1
echo "Updating UTBDefault USB map on $DISK_EFI"
diskutil unmount force "$DISK_EFI" 2>/dev/null || true
sudo diskutil mount "$DISK_EFI"
MP=$(diskutil info "$DISK_EFI" | awk -F': *' '/Mount Point/{print $2; exit}')
test -d "$MP/EFI/OC/Kexts"
ditto --norsrc --noextattr --noqtn "$SRC" "$MP/EFI/OC/Kexts/UTBDefault.kext"
find "$MP/EFI" -name '._*' -delete 2>/dev/null || true
sync
plutil -lint "$MP/EFI/OC/Kexts/UTBDefault.kext/Contents/Info.plist"
python3 - <<PY
import plistlib
from pathlib import Path
d=plistlib.loads(Path("$MP/EFI/OC/Kexts/UTBDefault.kext/Contents/Info.plist").read_bytes())
pers=d["IOKitPersonalities"]["XHC"]
ports=pers["IOProviderMergeProperties"]["ports"]
print("ports", sorted(ports))
print("match", pers["IOPCIPrimaryMatch"])
print("USB_MAP_DONE")
PY
