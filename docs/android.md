# Android test APK

Built file: `build/Shadowblade-Willowbrook-debug.apk` (57,226,274 bytes, about 55 MiB). SHA-256: `1a35d51aec44165b6318bcf7c0063949286781a8d001c4269fe43d1eec43809c`.

Built with Godot 4.6.3, OpenJDK 21.0.12.1 and Android build-tools 36.0.0. Signature schemes v2/v3 verify; zip alignment passes including 16 KiB native-library alignment. Manifest: `com.shadowblade.lastguardian`, version `0.2.0-willowbrook` / code 2, minimum API 24 (Android 7.0), target API 36 (Android 16), arm64-v8a and x86_64. Compatibility/OpenGL ES is configured; its actual Android renderer has not been observed. No permissions are requested. Concept, docs, test scenes and signing files are excluded.

**Not installed or run on Android.** ADB 37.0.1 reported no attached device. No emulator is installed. Device name, Android version, actual renderer and measured performance are unavailable. APK verification does not establish runtime compatibility.

## Install on a test phone

1. Copy the APK to a compatible 64-bit phone and open it. Allow installation from that file source when Android asks, then open Shadowblade. Alternatively, enable USB debugging, authorize the computer and run `adb install -r build/Shadowblade-Willowbrook-debug.apk`.
2. Use landscape orientation. Start a journey, talk to Lyra, cross the forest, open the crystal seal and defeat the Warden. Try simultaneous movement, jump, sword and magic; slide/release fingers; switch apps; resume; reload a save.
3. Record phone model/chipset, Android version, renderer and measured frame times/memory/temperature under both quality settings. No FPS promise has been made.

If an older test app was signed with a different key, Android may reject the update. Uninstalling removes local progress; preserve saves before choosing that action. The generated private test key stays outside Git and should be retained privately for future updates.

## Rebuild

See [environment prerequisites](environment.md), then run `python tools/export_android.py`. The committed Android preset has no signing credentials. The tool uses matching installed templates and local SDK/JDK settings, with a private test key outside the repository. Build output is ignored by Git; the APK is an artifact in this workspace, not a binary claimed to be committed or uploaded to GitHub. It is not a store release.
