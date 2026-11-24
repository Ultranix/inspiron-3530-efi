# Dell Inspiron 15 3530 EFI

Hardware-specific OpenCore EFI snapshot maintained by Ultranix. This is an
experimental configuration archive, not a generic EFI or a claim of validated
support for every bundled feature or macOS version.

## Hardware and current operating system

| Item | Recorded configuration |
| --- | --- |
| Laptop | Dell Inspiron 15 3530 |
| CPU | Intel Core i5-1335U |
| GPU | Iris Xe, 80 EU, PCI 8086:A7A1 |
| Wi-Fi | Realtek RTL8852BE |
| Bluetooth | Realtek USB 0bda:887b |
| USB controller | Raptor Lake-U XHCI 8086:51ED |
| SMBIOS model | MacBookPro16,2 |
| Current OS | macOS Tahoe 26.7.1 |
| Storage setting | VMD disabled in the recorded setup |

## Working features

Current setup: macOS Tahoe 26.7.1 on the Dell Inspiron 15 3530.

| Feature | Status |
| --- | --- |
| Graphics | Metal acceleration working |
| Camera | Working |
| Bluetooth | Bluetooth mouse working |
| Audio | Sound card working |
| Sleep | Working |

## Actual configuration state

OpenCore reads EFI/OC/config.plist. The other profiles require manual selection
by copying the desired profile to that filename in a prepared local EFI.

| Profile in EFI/OC | Stored state |
| --- | --- |
| config.plist | NootedGreen ON, WhateverGreen ON, BTSmpFixup ON; experimental current profile. |
| config-debug-ng.plist | NootedGreen ON, WhateverGreen OFF; AppleDebug/ApplePanic enabled, Debug Target 65. BTSmpFixup is not listed. |
| config-accelerated.plist | XPS-derived reference; both graphics kexts ON. IntelBluetoothFirmware.kext, IntelBTPatcher.kext and AirportItlwm.kext are enabled but missing from this collection. HfsPlus is disabled. |

The current config.plist is the reference for the active profile.

All four profiles use SecureBootModel Disabled, DmgLoading Signed and Vault
Optional. Current-profile AppleDebug/ApplePanic are disabled and Debug Target is 0.
The existing graphics and AMFI compatibility arguments are preserved. The current
boot arguments contain alcid=13; AppleALC is not bundled in this snapshot.

## Prepare your own EFI

1. Clone the repository and prepare a local working copy.
2. Generate your own SMBIOS identity, for example using GenSMBIOS. Replace
   SystemSerialNumber, MLB, SystemUUID and ROM under PlatformInfo -> Generic in
   every profile you intend to use. Published values are placeholders or zeros.
3. Validate the configuration with ocvalidate from the matching OpenCore release.
   An OpenCore version has not been inferred from the bundled executable.
4. Review ACPI, GPU parameters, kext compatibility and the USB map for your hardware.
5. Back up the existing EFI to another disk and retain a known-working bootable USB.
6. Identify the actual EFI partition with diskutil list, mount it, verify the
   destination and copy your prepared EFI tree.

The five scripts are historical machine-local helpers. Four hardcode disk4s1; source paths are resolved relative to the script directory.
The Front patch script picks the first matching mounted EFI. Review and adapt
targets before using them. The full-tree
installers delete the destination EFI. restore-write-efi.sh creates no backup;
the normal writer continues even if its attempted backup fails. No disk-writing
script was executed to prepare this repository.

## Graphics and input

Recorded GPU properties at PciRoot(0x0)/Pci(0x2,0x0) spoof Tiger Lake with device-id
9A49 and AAPL,ig-platform-id 0000499A. Current NootedGreen/WhateverGreen behavior
is preserved; the debug profile disables WhateverGreen to isolate NootedGreen.

The I2C input stack uses VoodooI2C, its Services/GPIO/Input plugins and VoodooI2CHID.
PS/2 keyboard, mouse and trackpad plugins are also present. The VoodooInput copy
inside VoodooPS2Controller is disabled to avoid duplicate loading. The XPS-named
ACPI helper requires review for the Inspiron hardware.

## Wireless stack

Current and debug profiles order these immediately after Lilu:

1. IOSkywalkFamily.kext
2. IO80211FamilyLegacy.kext
3. AMFIPass.kext
4. AirPort_RTW89.kext
5. AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext

The system com.apple.iokit.IOSkywalkFamily is blocked with strategy Exclude.
The Intel wireless entries in the accelerated reference are not this Realtek setup.
Bluetooth uses RealtekBluetoothFirmware and BlueToolFixup, plus custom BTSmpFixup
in the current profile. Current arguments include -btlfxallowanyaddr,
-btlfxboardid and -btsmpforce; exact custom-build provenance is unverified.

## USB map

USBToolBox precedes UTBDefault. The map matches 8086:51ED and enables eight ports;
the controller port-count field is 16. Connector 3 is USB 3; 255 is internal.

| Port | Number | Connector | Recorded role |
| --- | --- | --- | --- |
| HS01 | 1 | 3 | USB 2 companion to SS01 |
| HS03 | 3 | 3 | USB 2 companion to SS03 |
| HS04 | 4 | 3 | USB 2 companion to SS04 |
| HS07 | 7 | 255 | Internal |
| HS10 | 10 | 255 | Internal Realtek Bluetooth |
| SS01 | 13 | 3 | USB 3 companion to HS01 |
| SS03 | 15 | 3 | USB 3 companion to HS03 |
| SS04 | 16 | 3 | USB 3 companion to HS04 |

## Picker resources

Font, GoldenGate Image and Label files are optional OpenCanopy resources.
OpenCanopy.efi is not bundled or enabled, so these assets alone do not activate a
graphical picker. Label .lbl/.l2x pairs are standard/high-density artwork;
font .bin/.png pairs are font tables and glyph atlases.

## Publication and licensing

Initially private: this collection includes Apple-origin binaries and local
builds with incomplete redistribution provenance. See [NOTICE.md](NOTICE.md).
No blanket license is applied. Existing third-party notices and signatures remain.

All original EFI payloads and historical backups are retained. Finder/AppleDouble
metadata is omitted. SMBIOS serial, MLB, UUID and ROM are replaced in all four
configurations, including the backup. The original local EFI is unchanged. Machine-local source paths are removed
from the published scripts and notes. Published commits use a GitHub noreply
address instead of a personal email address.

## Complete file inventory

Every published file is listed below. Kext versions come from their plists, not
independent build verification. ACPI purposes are inferred from filenames and
have not been freshly decompiled.

### Repository root

| File | Purpose |
| --- | --- |
| [.gitignore](.gitignore) | Excludes Finder/AppleDouble metadata and generated logs. |
| [NOTICE.md](NOTICE.md) | Third-party attribution and redistribution/provenance notes. |
| [README.md](README.md) | English setup guide and complete file-purpose inventory. |
| [patch-btlfx-bootarg.sh](patch-btlfx-bootarg.sh) | Legacy config installer: backs up and replaces the entire target config.plist, including Bluetooth arguments. |
| [patch-<br>rtw89-<br>front-<br>on-<br>efi.sh](patch-rtw89-front-on-efi.sh) | Backs up and patches the first matching mounted EFI: orders Wi-Fi entries and blocks the system IOSkywalkFamily. |
| [restore-write-efi.sh](restore-write-efi.sh) | Legacy repair installer: deletes the target EFI, copies the prepared tree and verifies RTW89 Front; creates no backup. |
| [write-<br>efi-<br>to-<br>untitled2.sh](write-efi-to-untitled2.sh) | Legacy full EFI installer targeting disk4s1: attempts a timestamped backup, deletes the destination EFI and copies the prepared tree. |
| [write-usb-map-to-efi.sh](write-usb-map-to-efi.sh) | Legacy updater: replaces only UTBDefault.kext on disk4s1 and prints the USB map. |

### EFI / BOOT

| File | Purpose |
| --- | --- |
| [BOOTx64.efi](EFI/BOOT/BOOTx64.efi) | Fallback x86-64 UEFI boot entry for OpenCore. |

### EFI / OC / ACPI

| File | Purpose |
| --- | --- |
| [SSDT-ALS0.aml](EFI/OC/ACPI/SSDT-ALS0.aml) | Ambient light sensor device. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-EC.aml](EFI/OC/ACPI/SSDT-EC.aml) | Embedded-controller compatibility. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-GPI0.aml](EFI/OC/ACPI/SSDT-GPI0.aml) | GPIO/I2C compatibility. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-MCHC.aml](EFI/OC/ACPI/SSDT-MCHC.aml) | Memory-controller-hub device. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-PLUG-ALT.aml](EFI/OC/ACPI/SSDT-PLUG-ALT.aml) | CPU plugin/power-management attachment. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-PNLF.aml](EFI/OC/ACPI/SSDT-PNLF.aml) | Panel backlight device. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-RTCAWAC.aml](EFI/OC/ACPI/SSDT-RTCAWAC.aml) | RTC/AWAC compatibility. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-SBUS.aml](EFI/OC/ACPI/SSDT-SBUS.aml) | SMBus device support. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-USB-Reset.aml](EFI/OC/ACPI/SSDT-USB-Reset.aml) | USB controller reset/compatibility. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-USBX.aml](EFI/OC/ACPI/SSDT-USBX.aml) | USB power properties. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-XOSI.aml](EFI/OC/ACPI/SSDT-XOSI.aml) | Operating-system interface compatibility. Compiled AML; purpose inferred from name, not freshly decompiled. |
| [SSDT-XPS-I2C.aml](EFI/OC/ACPI/SSDT-XPS-I2C.aml) | XPS-derived I2C compatibility; verify applicability to Inspiron. Compiled AML; purpose inferred from name, not freshly decompiled. |

### EFI / OC / Drivers

| File | Purpose |
| --- | --- |
| [HfsPlus.efi](EFI/OC/Drivers/HfsPlus.efi) | UEFI HFS+ filesystem driver; present despite stale comments saying it is not shipped. |
| [OpenRuntime.efi](EFI/OC/Drivers/OpenRuntime.efi) | OpenCore runtime services driver. |
| [ResetNvramEntry.efi](EFI/OC/Drivers/ResetNvramEntry.efi) | Adds an NVRAM reset boot-picker entry. |

### AMFIPass.kext

Directory: EFI / OC / Kexts / AMFIPass.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/AMFIPass.kext/Contents/Info.plist) | Metadata and matching rules, v1.4.1: AMFI compatibility patches. |
| [Contents/<br>MacOS/<br>AMFIPass](EFI/OC/Kexts/AMFIPass.kext/Contents/MacOS/AMFIPass) | Loadable executable: AMFI compatibility patches. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/AMFIPass.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### AirPort_RTW89.kext

Directory: EFI / OC / Kexts / AirPort_RTW89.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/Info.plist) | Metadata and matching rules, v0.4.0: Realtek RTL8852BE Wi-Fi driver. |
| [Contents/<br>MacOS/<br>AirPort_RTW89](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/MacOS/AirPort_RTW89) | Loadable executable: Realtek RTL8852BE Wi-Fi driver. |
| [Contents/<br>Resources/<br>COMMIT](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/Resources/COMMIT) | Bundled RTW89 source-revision marker. |
| [Contents/<br>Resources/<br>CREDITS.md](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/Resources/CREDITS.md) | Original RTW89 upstream/contributor attribution. |
| [Contents/<br>Resources/<br>LICENCE.rtlwifi_<br>firmware.txt](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/Resources/LICENCE.rtlwifi_firmware.txt) | Realtek firmware redistribution terms. |
| [Contents/<br>Resources/<br>LICENSE](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/Resources/LICENSE) | Bundled RTW89 GPL license text. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### AirPortRTW89Front.kext

Directory: EFI / OC / Kexts / AirPort_RTW89.kext / Contents / PlugIns / AirPortRTW89Front.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext/Contents/Info.plist) | Metadata and matching rules, v0.4.0: IO80211 legacy front-end for RTW89. |
| [Contents/<br>MacOS/<br>AirPortRTW89Front](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext/Contents/MacOS/AirPortRTW89Front) | Loadable executable: IO80211 legacy front-end for RTW89. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/AirPort_RTW89.kext/Contents/PlugIns/AirPortRTW89Front.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### BTSmpFixup.kext

Directory: EFI / OC / Kexts / BTSmpFixup.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/BTSmpFixup.kext/Contents/Info.plist) | Metadata and matching rules, v2.7.3: Custom local Bluetooth SMP/PHY patches; exact source provenance unverified. |
| [Contents/<br>MacOS/<br>BTSmpFixup](EFI/OC/Kexts/BTSmpFixup.kext/Contents/MacOS/BTSmpFixup) | Loadable executable: Custom local Bluetooth SMP/PHY patches; exact source provenance unverified. |


### BlueToolFixup.kext

Directory: EFI / OC / Kexts / BlueToolFixup.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/BlueToolFixup.kext/Contents/Info.plist) | Metadata and matching rules, v2.7.3: BlueTool Bluetooth compatibility patches. |
| [Contents/<br>MacOS/<br>BlueToolFixup](EFI/OC/Kexts/BlueToolFixup.kext/Contents/MacOS/BlueToolFixup) | Loadable executable: BlueTool Bluetooth compatibility patches. |

### BrightnessKeys.kext

Directory: EFI / OC / Kexts / BrightnessKeys.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/BrightnessKeys.kext/Contents/Info.plist) | Metadata and matching rules, v1.0.4: Brightness key support. |
| [Contents/<br>MacOS/<br>BrightnessKeys](EFI/OC/Kexts/BrightnessKeys.kext/Contents/MacOS/BrightnessKeys) | Loadable executable: Brightness key support. |

### CpuTopologyRebuild.kext

Directory: EFI / OC / Kexts / CpuTopologyRebuild.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/CpuTopologyRebuild.kext/Contents/Info.plist) | Metadata and matching rules, v2.0.2: CPU topology compatibility. |
| [Contents/<br>MacOS/<br>CpuTopologyRebuild](EFI/OC/Kexts/CpuTopologyRebuild.kext/Contents/MacOS/CpuTopologyRebuild) | Loadable executable: CPU topology compatibility. |

### IO80211FamilyLegacy.kext

Directory: EFI / OC / Kexts / IO80211FamilyLegacy.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/IO80211FamilyLegacy.kext/Contents/Info.plist) | Metadata and matching rules, v12.0: Apple legacy Wi-Fi family. |
| [Contents/<br>MacOS/<br>IO80211FamilyLegacy](EFI/OC/Kexts/IO80211FamilyLegacy.kext/Contents/MacOS/IO80211FamilyLegacy) | Loadable executable: Apple legacy Wi-Fi family. |

### IOSkywalkFamily.kext

Directory: EFI / OC / Kexts / IOSkywalkFamily.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/IOSkywalkFamily.kext/Contents/Info.plist) | Metadata and matching rules, v1.0: Apple legacy networking family. |
| [Contents/<br>MacOS/<br>IOSkywalkFamily](EFI/OC/Kexts/IOSkywalkFamily.kext/Contents/MacOS/IOSkywalkFamily) | Loadable executable: Apple legacy networking family. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/IOSkywalkFamily.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### Lilu.kext

Directory: EFI / OC / Kexts / Lilu.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/Lilu.kext/Contents/Info.plist) | Metadata and matching rules, v1.7.3: Kernel patch/plugin framework. |
| [Contents/<br>MacOS/<br>Lilu](EFI/OC/Kexts/Lilu.kext/Contents/MacOS/Lilu) | Loadable executable: Kernel patch/plugin framework. |

### NVMeFix.kext

Directory: EFI / OC / Kexts / NVMeFix.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/NVMeFix.kext/Contents/Info.plist) | Metadata and matching rules, v1.1.4: NVMe compatibility and power management. |
| [Contents/<br>MacOS/<br>NVMeFix](EFI/OC/Kexts/NVMeFix.kext/Contents/MacOS/NVMeFix) | Loadable executable: NVMe compatibility and power management. |

### NootedGreen.kext

Directory: EFI / OC / Kexts / NootedGreen.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/NootedGreen.kext/Contents/Info.plist) | Metadata and matching rules, v1.0.0: Experimental Iris Xe graphics patches. |
| [Contents/<br>MacOS/<br>NootedGreen](EFI/OC/Kexts/NootedGreen.kext/Contents/MacOS/NootedGreen) | Loadable executable: Experimental Iris Xe graphics patches. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/NootedGreen.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### RealtekBluetoothFirmware.kext

Directory: EFI / OC / Kexts / RealtekBluetoothFirmware.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/RealtekBluetoothFirmware.kext/Contents/Info.plist) | Metadata and matching rules, v1.0.2: Realtek USB Bluetooth firmware uploader. |
| [Contents/<br>MacOS/<br>RealtekBluetoothFirmware](EFI/OC/Kexts/RealtekBluetoothFirmware.kext/Contents/MacOS/RealtekBluetoothFirmware) | Loadable executable: Realtek USB Bluetooth firmware uploader. |

### RestrictEvents.kext

Directory: EFI / OC / Kexts / RestrictEvents.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/RestrictEvents.kext/Contents/Info.plist) | Metadata and matching rules, v1.1.7: Selected macOS event compatibility patches. |
| [Contents/<br>MacOS/<br>RestrictEvents](EFI/OC/Kexts/RestrictEvents.kext/Contents/MacOS/RestrictEvents) | Loadable executable: Selected macOS event compatibility patches. |

### SMCBatteryManager.kext

Directory: EFI / OC / Kexts / SMCBatteryManager.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/SMCBatteryManager.kext/Contents/Info.plist) | Metadata and matching rules, v1.3.9: Battery status for VirtualSMC. |
| [Contents/<br>MacOS/<br>SMCBatteryManager](EFI/OC/Kexts/SMCBatteryManager.kext/Contents/MacOS/SMCBatteryManager) | Loadable executable: Battery status for VirtualSMC. |
| [Contents/<br>Resources/<br>SSDT-BATC.dsl](EFI/OC/Kexts/SMCBatteryManager.kext/Contents/Resources/SSDT-BATC.dsl) | Optional ACPI battery companion source; not automatically loaded as AML. |

### SMCDellSensors.kext

Directory: EFI / OC / Kexts / SMCDellSensors.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/SMCDellSensors.kext/Contents/Info.plist) | Metadata and matching rules, v1.3.9: Dell sensors for VirtualSMC. |
| [Contents/<br>MacOS/<br>SMCDellSensors](EFI/OC/Kexts/SMCDellSensors.kext/Contents/MacOS/SMCDellSensors) | Loadable executable: Dell sensors for VirtualSMC. |

### SMCLightSensor.kext

Directory: EFI / OC / Kexts / SMCLightSensor.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/SMCLightSensor.kext/Contents/Info.plist) | Metadata and matching rules, v1.3.9: Light sensor for VirtualSMC. |
| [Contents/<br>MacOS/<br>SMCLightSensor](EFI/OC/Kexts/SMCLightSensor.kext/Contents/MacOS/SMCLightSensor) | Loadable executable: Light sensor for VirtualSMC. |

### SMCProcessor.kext

Directory: EFI / OC / Kexts / SMCProcessor.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/SMCProcessor.kext/Contents/Info.plist) | Metadata and matching rules, v1.3.9: CPU sensors for VirtualSMC. |
| [Contents/<br>MacOS/<br>SMCProcessor](EFI/OC/Kexts/SMCProcessor.kext/Contents/MacOS/SMCProcessor) | Loadable executable: CPU sensors for VirtualSMC. |

### SMCSuperIO.kext

Directory: EFI / OC / Kexts / SMCSuperIO.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/SMCSuperIO.kext/Contents/Info.plist) | Metadata and matching rules, v1.3.9: Super I/O sensors for VirtualSMC. |
| [Contents/<br>MacOS/<br>SMCSuperIO](EFI/OC/Kexts/SMCSuperIO.kext/Contents/MacOS/SMCSuperIO) | Loadable executable: Super I/O sensors for VirtualSMC. |

### USBToolBox.kext

Directory: EFI / OC / Kexts / USBToolBox.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/USBToolBox.kext/Contents/Info.plist) | Metadata and matching rules, v1.2.0: USB mapping framework. |
| [Contents/<br>MacOS/<br>USBToolBox](EFI/OC/Kexts/USBToolBox.kext/Contents/MacOS/USBToolBox) | Loadable executable: USB mapping framework. |

### UTBDefault.kext

Directory: EFI / OC / Kexts / UTBDefault.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/UTBDefault.kext/Contents/Info.plist) | Metadata and matching rules, v1.0: Codeless eight-port hardware-specific USB map. |

### VirtualSMC.kext

Directory: EFI / OC / Kexts / VirtualSMC.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VirtualSMC.kext/Contents/Info.plist) | Metadata and matching rules, v1.3.9: SMC emulation. |
| [Contents/<br>MacOS/<br>VirtualSMC](EFI/OC/Kexts/VirtualSMC.kext/Contents/MacOS/VirtualSMC) | Loadable executable: SMC emulation. |

### VoodooI2C.kext

Directory: EFI / OC / Kexts / VoodooI2C.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooI2C.kext/Contents/Info.plist) | Metadata and matching rules, v2.9.1: I2C input-device controller support. |
| [Contents/<br>MacOS/<br>VoodooI2C](EFI/OC/Kexts/VoodooI2C.kext/Contents/MacOS/VoodooI2C) | Loadable executable: I2C input-device controller support. |

### VoodooGPIO.kext

Directory: EFI / OC / Kexts / VoodooI2C.kext / Contents / PlugIns / VoodooGPIO.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooGPIO.kext/Contents/Info.plist) | Metadata and matching rules, v1.2: GPIO service for VoodooI2C. |
| [Contents/<br>MacOS/<br>VoodooGPIO](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooGPIO.kext/Contents/MacOS/VoodooGPIO) | Loadable executable: GPIO service for VoodooI2C. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooGPIO.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### VoodooI2CServices.kext

Directory: EFI / OC / Kexts / VoodooI2C.kext / Contents / PlugIns / VoodooI2CServices.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooI2CServices.kext/Contents/Info.plist) | Metadata and matching rules, v1.0: Shared services for VoodooI2C. |
| [Contents/<br>MacOS/<br>VoodooI2CServices](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooI2CServices.kext/Contents/MacOS/VoodooI2CServices) | Loadable executable: Shared services for VoodooI2C. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooI2CServices.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### VoodooInput.kext

Directory: EFI / OC / Kexts / VoodooI2C.kext / Contents / PlugIns / VoodooInput.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooInput.kext/Contents/Info.plist) | Metadata and matching rules, v1.1.7: Input-event service; PS/2 copy disabled to avoid duplicate loading. |
| [Contents/<br>MacOS/<br>VoodooInput](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooInput.kext/Contents/MacOS/VoodooInput) | Loadable executable: Input-event service; PS/2 copy disabled to avoid duplicate loading. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/VoodooI2C.kext/Contents/PlugIns/VoodooInput.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### VoodooI2CHID.kext

Directory: EFI / OC / Kexts / VoodooI2CHID.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooI2CHID.kext/Contents/Info.plist) | Metadata and matching rules, v1.0: I2C HID touchpad support. |
| [Contents/<br>MacOS/<br>VoodooI2CHID](EFI/OC/Kexts/VoodooI2CHID.kext/Contents/MacOS/VoodooI2CHID) | Loadable executable: I2C HID touchpad support. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/VoodooI2CHID.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### VoodooPS2Controller.kext

Directory: EFI / OC / Kexts / VoodooPS2Controller.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/Info.plist) | Metadata and matching rules, v2.3.8: PS/2 controller support. |
| [Contents/<br>MacOS/<br>VoodooPS2Controller](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/MacOS/VoodooPS2Controller) | Loadable executable: PS/2 controller support. |

### VoodooInput.kext

Directory: EFI / OC / Kexts / VoodooPS2Controller.kext / Contents / PlugIns / VoodooInput.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext/Contents/Info.plist) | Metadata and matching rules, v1.1.7: Input-event service; PS/2 copy disabled to avoid duplicate loading. |
| [Contents/<br>MacOS/<br>VoodooInput](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext/Contents/MacOS/VoodooInput) | Loadable executable: Input-event service; PS/2 copy disabled to avoid duplicate loading. |
| [Contents/<br>_CodeSignature/<br>CodeResources](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooInput.kext/Contents/_CodeSignature/CodeResources) | Code-signing resource manifest; unchanged. |

### VoodooPS2Keyboard.kext

Directory: EFI / OC / Kexts / VoodooPS2Controller.kext / Contents / PlugIns / VoodooPS2Keyboard.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext/Contents/Info.plist) | Metadata and matching rules, v2.3.8: PS/2 keyboard plugin. |
| [Contents/<br>MacOS/<br>VoodooPS2Keyboard](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext/Contents/MacOS/VoodooPS2Keyboard) | Loadable executable: PS/2 keyboard plugin. |

### VoodooPS2Mouse.kext

Directory: EFI / OC / Kexts / VoodooPS2Controller.kext / Contents / PlugIns / VoodooPS2Mouse.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Mouse.kext/Contents/Info.plist) | Metadata and matching rules, v2.3.8: PS/2 mouse plugin. |
| [Contents/<br>MacOS/<br>VoodooPS2Mouse](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Mouse.kext/Contents/MacOS/VoodooPS2Mouse) | Loadable executable: PS/2 mouse plugin. |

### VoodooPS2Trackpad.kext

Directory: EFI / OC / Kexts / VoodooPS2Controller.kext / Contents / PlugIns / VoodooPS2Trackpad.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext/Contents/Info.plist) | Metadata and matching rules, v2.3.8: PS/2 trackpad plugin. |
| [Contents/<br>MacOS/<br>VoodooPS2Trackpad](EFI/OC/Kexts/VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Trackpad.kext/Contents/MacOS/VoodooPS2Trackpad) | Loadable executable: PS/2 trackpad plugin. |

### WhateverGreen.kext

Directory: EFI / OC / Kexts / WhateverGreen.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/WhateverGreen.kext/Contents/Info.plist) | Metadata and matching rules, v1.7.2: Graphics compatibility patches. |
| [Contents/<br>MacOS/<br>WhateverGreen](EFI/OC/Kexts/WhateverGreen.kext/Contents/MacOS/WhateverGreen) | Loadable executable: Graphics compatibility patches. |

### XHCI-unsupported.kext

Directory: EFI / OC / Kexts / XHCI-unsupported.kext.

| File | Purpose |
| --- | --- |
| [Contents/<br>Info.plist](EFI/OC/Kexts/XHCI-unsupported.kext/Contents/Info.plist) | Metadata and matching rules, v0.9.2: Codeless XHCI injector including local 8086:51ED match. |

### EFI / OC

| File | Purpose |
| --- | --- |
| [OpenCore.efi](EFI/OC/OpenCore.efi) | OpenCore boot manager. |
| [config-accelerated.plist](EFI/OC/config-accelerated.plist) | XPS-derived reference, with three enabled Intel kexts absent from the collection; not a complete Inspiron profile. Identities replaced. |
| [config-debug-ng.plist](EFI/OC/config-debug-ng.plist) | Debug profile: NootedGreen enabled, WhateverGreen disabled; AppleDebug/ApplePanic enabled, Debug Target 65. SMBIOS identities replaced. |
| [config.plist](EFI/OC/config.plist) | Current experimental profile: NootedGreen, WhateverGreen and BTSmpFixup enabled. SMBIOS identities replaced. |

### EFI / OC / Resources / Font

| File | Purpose |
| --- | --- |
| [Font_1x.bin](EFI/OC/Resources/Font/Font_1x.bin) | Standard-density binary font table. |
| [Font_1x.png](EFI/OC/Resources/Font/Font_1x.png) | Standard-density font atlas. |
| [Font_2x.bin](EFI/OC/Resources/Font/Font_2x.bin) | High-density binary font table. |
| [Font_2x.png](EFI/OC/Resources/Font/Font_2x.png) | High-density font atlas. |
| [Terminus.hex](EFI/OC/Resources/Font/Terminus.hex) | Terminus glyph definitions for picker font generation. |
| [TerminusCore.hex](EFI/OC/Resources/Font/TerminusCore.hex) | Terminus glyph definitions for picker font generation. |

### EFI / OC / Resources / Image / Acidanthera / GoldenGate

| File | Purpose |
| --- | --- |
| [AppleRecv.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/AppleRecv.icns) | Apple recovery entry. OpenCanopy image. |
| [AppleTM.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/AppleTM.icns) | Time Machine entry. OpenCanopy image. |
| [Background.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Background.icns) | Picker background. OpenCanopy image. |
| [BtnFocus.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/BtnFocus.icns) | Focused-button artwork. OpenCanopy image. |
| [Cursor.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Cursor.icns) | Pointer artwork. OpenCanopy image. |
| [Dot.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Dot.icns) | Selection/page indicator. OpenCanopy image. |
| [Enter.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Enter.icns) | Confirm action. OpenCanopy image. |
| [ExtAppleRecv.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/ExtAppleRecv.icns) | External-media variant: Apple recovery entry. OpenCanopy image. |
| [ExtAppleTM.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/ExtAppleTM.icns) | External-media variant: Time Machine entry. OpenCanopy image. |
| [ExtHardDrive.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/ExtHardDrive.icns) | External-media variant: Disk entry. OpenCanopy image. |
| [FirmwareSettings.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/FirmwareSettings.icns) | Firmware setup action. OpenCanopy image. |
| [HardDrive.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/HardDrive.icns) | Disk entry. OpenCanopy image. |
| [Left.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Left.icns) | Previous-item arrow. OpenCanopy image. |
| [Lock.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Lock.icns) | Locked-entry artwork. OpenCanopy image. |
| [NetworkBoot.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/NetworkBoot.icns) | Network boot entry. OpenCanopy image. |
| [OpticalDrive.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/OpticalDrive.icns) | Optical boot entry. OpenCanopy image. |
| [Password.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Password.icns) | Password artwork. OpenCanopy image. |
| [Restart.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Restart.icns) | Restart action. OpenCanopy image. |
| [Right.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Right.icns) | Next-item arrow. OpenCanopy image. |
| [Selected.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Selected.icns) | Selected-entry overlay. OpenCanopy image. |
| [Selector.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Selector.icns) | Selection outline. OpenCanopy image. |
| [SetDefault.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/SetDefault.icns) | Set-default action. OpenCanopy image. |
| [Shell.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Shell.icns) | UEFI shell entry. OpenCanopy image. |
| [ShutDown.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/ShutDown.icns) | Shutdown action. OpenCanopy image. |
| [Tool.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Tool.icns) | Utility entry. OpenCanopy image. |
| [Windows.icns](EFI/OC/Resources/Image/Acidanthera/GoldenGate/Windows.icns) | Windows entry. OpenCanopy image. |

### EFI / OC / Resources / Label

| File | Purpose |
| --- | --- |
| [Apple.l2x](EFI/OC/Resources/Label/Apple.l2x) | High-density picker label for macOS. |
| [Apple.lbl](EFI/OC/Resources/Label/Apple.lbl) | Standard-density picker label for macOS. |
| [AppleRecv.l2x](EFI/OC/Resources/Label/AppleRecv.l2x) | High-density picker label for Apple recovery. |
| [AppleRecv.lbl](EFI/OC/Resources/Label/AppleRecv.lbl) | Standard-density picker label for Apple recovery. |
| [AppleTM.l2x](EFI/OC/Resources/Label/AppleTM.l2x) | High-density picker label for Time Machine. |
| [AppleTM.lbl](EFI/OC/Resources/Label/AppleTM.lbl) | Standard-density picker label for Time Machine. |
| [EFIBoot.l2x](EFI/OC/Resources/Label/EFIBoot.l2x) | High-density picker label for EFI boot. |
| [EFIBoot.lbl](EFI/OC/Resources/Label/EFIBoot.lbl) | Standard-density picker label for EFI boot. |
| [FirmwareSettings.l2x](EFI/OC/Resources/Label/FirmwareSettings.l2x) | High-density picker label for firmware setup. |
| [FirmwareSettings.lbl](EFI/OC/Resources/Label/FirmwareSettings.lbl) | Standard-density picker label for firmware setup. |
| [NetworkBoot.l2x](EFI/OC/Resources/Label/NetworkBoot.l2x) | High-density picker label for network boot. |
| [NetworkBoot.lbl](EFI/OC/Resources/Label/NetworkBoot.lbl) | Standard-density picker label for network boot. |
| [Other.l2x](EFI/OC/Resources/Label/Other.l2x) | High-density picker label for other operating systems. |
| [Other.lbl](EFI/OC/Resources/Label/Other.lbl) | Standard-density picker label for other operating systems. |
| [ResetNVRAM.l2x](EFI/OC/Resources/Label/ResetNVRAM.l2x) | High-density picker label for NVRAM reset. |
| [ResetNVRAM.lbl](EFI/OC/Resources/Label/ResetNVRAM.lbl) | Standard-density picker label for NVRAM reset. |
| [SIPDisabled.l2x](EFI/OC/Resources/Label/SIPDisabled.l2x) | High-density picker label for SIP disabled. |
| [SIPDisabled.lbl](EFI/OC/Resources/Label/SIPDisabled.lbl) | Standard-density picker label for SIP disabled. |
| [SIPEnabled.l2x](EFI/OC/Resources/Label/SIPEnabled.l2x) | High-density picker label for SIP enabled. |
| [SIPEnabled.lbl](EFI/OC/Resources/Label/SIPEnabled.lbl) | Standard-density picker label for SIP enabled. |
| [Shell.l2x](EFI/OC/Resources/Label/Shell.l2x) | High-density picker label for UEFI shell. |
| [Shell.lbl](EFI/OC/Resources/Label/Shell.lbl) | Standard-density picker label for UEFI shell. |
| [Tool.l2x](EFI/OC/Resources/Label/Tool.l2x) | High-density picker label for utility. |
| [Tool.lbl](EFI/OC/Resources/Label/Tool.lbl) | Standard-density picker label for utility. |
| [Windows.l2x](EFI/OC/Resources/Label/Windows.l2x) | High-density picker label for Windows. |
| [Windows.lbl](EFI/OC/Resources/Label/Windows.lbl) | Standard-density picker label for Windows. |
