#!/bin/bash
# Same pattern as macos-installer/write-sequoia-usb.sh:
# must run inside Terminal.app (Removable Volumes TCC). osascript root cannot write FAT EFI.
set -e
TASK_SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
OUT="$TASK_SCRIPT_DIR"
DISK_EFI="disk4s1"

echo "Writing OpenCore + Realtek Wi-Fi/BT to the 256 GB Sequoia disk EFI ($DISK_EFI)."
echo "If macOS asks to allow Terminal to access removable volumes, click Allow."

# unmount any stale mount of this EFI
diskutil unmount force "$DISK_EFI" 2>/dev/null || true
sudo diskutil mount "$DISK_EFI"

MP=$(diskutil info "$DISK_EFI" | awk -F': *' '/Mount Point/{print $2; exit}')
if [[ -z "$MP" || ! -d "$MP" ]]; then
  echo "ERROR: EFI did not mount"
  diskutil info "$DISK_EFI"
  exit 1
fi
echo "Mounted at: $MP"

# backup existing
if [[ -d "$MP/EFI" ]]; then
  TS=$(date +%Y%m%d%H%M%S)
  echo "Backing up existing EFI -> EFI.bak.$TS"
  ditto --norsrc --noextattr --noqtn "$MP/EFI" "$MP/EFI.bak.$TS" || true
fi

echo "Copying $OUT/EFI -> $MP/EFI"
rm -rf "$MP/EFI"
ditto --norsrc --noextattr --noqtn "$OUT/EFI" "$MP/EFI"
sync

echo "==== Kexts ===="
ls "$MP/EFI/OC/Kexts"
echo "==== boot-args ===="
plutil -extract NVRAM.Add.7C436110-AB2A-4BBB-A880-FE41995C9F82.boot-args raw "$MP/EFI/OC/config.plist"
echo
test -f "$MP/EFI/BOOT/BOOTx64.efi"
test -f "$MP/EFI/OC/OpenCore.efi"
df -h "$MP"
echo "EFI_WRITE_DONE"
echo "BIOS: boot this 256 GB disk (OpenCore). NootedGreen is off; Wi-Fi is AirPort_RTW89."
