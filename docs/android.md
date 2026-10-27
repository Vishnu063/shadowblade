# Android campaign test build

Current artifact: `build/Shadowblade-Campaign-debug.apk`, version `0.4.0-campaign` (code 4), ARM64, package `com.shadowblade.lastguardian`. A downloadable copy was provided in chat. It is not committed as a large source file.

The APK includes all six villages/powers, final fortress/ending, separate regional saving and return travel. It was exported with Godot 4.6.3 and passed signature and 16 KiB alignment checks. It has **not** been installed or run on an Android phone/emulator. [Export evidence](campaign-export.txt) · [SHA-256](campaign-apk-sha256.txt).

## Install

Download the APK onto an ARM64 Android phone and open it in the system installer. Android may ask you to authorize that installer to install the file. This is a test build, not a store release.

The local test signing key is different from the key in the earlier Codex environment. An older installed test build may reject an in-place update. Uninstalling can delete its local progress; preserve any existing save before removing an older installation. No cloud backup is provided.

## Rebuild

Install standard Godot 4.6.3 and matching Android export templates, JDK 17, official Android build-tools 36.0.0, platform-tools and platform android-36. Set `GODOT_BIN`, `JAVA_HOME` and `ANDROID_HOME` as appropriate. Run `python3 tools/export_android.py`.

The exporter imports the project, generates/reuses a private local test key outside Git, exports and verifies the APK. Retain that private key securely if later test builds must update the same installation. Never commit signing credentials.

SDK ZIPs were checksum-verified against Google's repository metadata. The official Godot export-template ZIP was CRC-checked during Android-template extraction. No SDK or signing key is checked into the game repository.

## Required phone verification

Test simultaneous movement/jump/attack, tap-versus-hold power selection, all powers, route completion, travel, save/restart, death, app switching, safe areas and both quality/frame-limit settings. Record the phone model, Android version, frame times, memory use and thermal behavior. No phone performance or 60 FPS claim is made.
