#!/bin/bash
# On the Sequoia machine (or with the 256 GB disk plugged in): add AirPortRTW89Front
# to OpenCore Kernel->Add in the correct order. Requires Terminal + sudo.
set -euo pipefail

# Prefer an already-mounted OC EFI that already has AirPort_RTW89.
pick_mp() {
  local v mp
  for v in /Volumes/*; do
    [[ -f "$v/EFI/OC/config.plist" ]] || continue
    [[ -d "$v/EFI/OC/Kexts/AirPort_RTW89.kext" ]] || continue
    [[ -f "$v/EFI/OC/Kexts/AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext/Contents/MacOS/AirPortRTW89Front" ]] || continue
    echo "$v"
    return 0
  done
  return 1
}

MP="$(pick_mp || true)"
if [[ -z "${MP}" ]]; then
  echo "No mounted EFI with AirPort_RTW89 found. Mount the 256 GB disk EFI first, e.g.:"
  echo "  diskutil list   # find the EFI of the Sequoia system disk"
  echo "  sudo diskutil mount diskXs1"
  exit 1
fi

CFG="$MP/EFI/OC/config.plist"
echo "Patching $CFG"
cp -f "$CFG" "$CFG.bak-pre-front-$(date +%Y%m%d%H%M%S)"

python3 - "$CFG" <<'PY'
import plistlib, sys
from pathlib import Path
cfg_path = Path(sys.argv[1])
cfg = plistlib.loads(cfg_path.read_bytes())
add = cfg["Kernel"]["Add"]
FRONT = "AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext"
ORDER = [
    "IOSkywalkFamily.kext",
    "IO80211FamilyLegacy.kext",
    "AMFIPass.kext",
    "AirPort_RTW89.kext",
    FRONT,
]

def make_front():
    return {
        "Arch": "x86_64",
        "BundlePath": FRONT,
        "Comment": "Wi-Fi: rtw89 front (AirPort_RTW89)",
        "Enabled": True,
        "ExecutablePath": "Contents/MacOS/AirPortRTW89Front",
        "MaxKernel": "",
        "MinKernel": "23.0.0",
        "PlistPath": "Contents/Info.plist",
    }

by = {}
for e in add:
    bp = e.get("BundlePath")
    if bp and bp not in by:
        by[bp] = e
if FRONT not in by:
    by[FRONT] = make_front()
else:
    by[FRONT]["Enabled"] = True
    by[FRONT]["ExecutablePath"] = "Contents/MacOS/AirPortRTW89Front"
    by[FRONT]["PlistPath"] = "Contents/Info.plist"

for bp in ORDER:
    e = by[bp]
    e["Enabled"] = True
    if not e.get("MinKernel"):
        e["MinKernel"] = "23.0.0"
    if e.get("Arch") in (None, "", "Any"):
        e["Arch"] = "x86_64"

lilu_idx = next(i for i, e in enumerate(add) if e.get("BundlePath") == "Lilu.kext")
prefix = add[: lilu_idx + 1]
seen = set()
new_add = []
for e in prefix:
    new_add.append(e)
    seen.add(e.get("BundlePath"))
for bp in ORDER:
    new_add.append(by[bp])
    seen.add(bp)
for e in add:
    bp = e.get("BundlePath")
    if bp in seen:
        continue
    new_add.append(e)
    seen.add(bp)
cfg["Kernel"]["Add"] = new_add

block = cfg["Kernel"]["Block"]
if not any(b.get("Identifier") == "com.apple.iokit.IOSkywalkFamily" and b.get("Enabled") for b in block):
    block.append({
        "Arch": "x86_64",
        "Comment": "Wi-Fi: Apple's IOSkywalkFamily makes way for Ventura's",
        "Enabled": True,
        "Identifier": "com.apple.iokit.IOSkywalkFamily",
        "MaxKernel": "",
        "MinKernel": "23.0.0",
        "Strategy": "Exclude",
    })

cfg_path.write_bytes(plistlib.dumps(cfg, sort_keys=False))
print("FRONT_PATCH_DONE")
for i, e in enumerate(cfg["Kernel"]["Add"][:8]):
    print(f"  [{i}] {'ON' if e.get('Enabled') else 'OFF'} {e.get('BundlePath')}")
PY

plutil -lint "$CFG"
echo "Reboot from the 256 GB disk OpenCore, then:"
echo "  networksetup -listallhardwareports"
echo "  kmutil showloaded | grep -iE '80211|RTW89Front|rtw89'"
