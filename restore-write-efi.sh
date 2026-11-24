#!/bin/bash
# Restore broken disk4s1 EFI, then write prepared OpenCore (with AirPortRTW89Front).
# Must run in Terminal.app (Removable Volumes TCC).
set -euo pipefail
TASK_SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
SRC="$TASK_SCRIPT_DIR/EFI"
DISK_EFI=disk4s1

echo "Restoring + writing OpenCore to $DISK_EFI (includes AirPortRTW89Front)"
diskutil unmount force "$DISK_EFI" 2>/dev/null || true
sudo diskutil mount "$DISK_EFI"
MP=$(diskutil info "$DISK_EFI" | awk -F': *' '/Mount Point/{print $2; exit}')
test -d "$MP"
echo "Mounted at: $MP"

# Nuke broken EFI tree (FAT can leave undeletable junk names; delete via Python)
sudo python3 - <<PY
import os, shutil, stat
from pathlib import Path
mp = Path("$MP")
for name in ("EFI",):
    p = mp / name
    if not p.exists():
        continue
    def onerror(func, path, exc):
        try:
            os.chmod(path, stat.S_IWUSR | stat.S_IRUSR | stat.S_IXUSR)
            func(path)
        except Exception as e:
            print("warn", path, e)
    print("removing", p)
    shutil.rmtree(p, onerror=onerror)
# if stub remains, try unlink children by fd
efi = mp / "EFI"
if efi.exists():
    for root, dirs, files in os.walk(efi, topdown=False):
        for f in files:
            fp = os.path.join(root, f)
            try:
                os.chmod(fp, 0o777); os.unlink(fp)
            except Exception as e:
                print("unlink fail", repr(fp), e)
        for d in dirs:
            dp = os.path.join(root, d)
            try:
                os.chmod(dp, 0o777); os.rmdir(dp)
            except Exception as e:
                print("rmdir fail", repr(dp), e)
    try:
        os.rmdir(efi)
    except Exception as e:
        print("rmdir EFI fail", e)
print("clean done, EFI exists=", efi.exists())
PY

echo "Copying $SRC -> $MP/EFI"
sudo ditto --norsrc --noextattr --noqtn "$SRC" "$MP/EFI"
sudo find "$MP/EFI" -name '._*' -delete 2>/dev/null || true
sync

test -f "$MP/EFI/BOOT/BOOTx64.efi"
test -f "$MP/EFI/OC/OpenCore.efi"
test -f "$MP/EFI/OC/Kexts/AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext/Contents/MacOS/AirPortRTW89Front"

python3 - <<PY
import plistlib
from pathlib import Path
c=plistlib.loads(Path("$MP/EFI/OC/config.plist").read_bytes())
paths=[e.get("BundlePath") for e in c["Kernel"]["Add"]]
front="AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext"
assert front in paths, paths[:10]
i=paths.index(front)
assert c["Kernel"]["Add"][i]["Enabled"]
print("Front entry OK at index", i)
print("Kexts:", sorted(p.name for p in Path("$MP/EFI/OC/Kexts").iterdir() if p.suffix==".kext")[:12], "...")
print("EFI_WRITE_DONE")
PY
