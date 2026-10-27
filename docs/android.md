# Android export and device validation

No APK has been generated or tested. This cloud instance provides Godot 4.6.3 and Java, but no Android SDK, adb, export templates, device or emulator. Desktop scene correctness does not establish Android readiness.

On a development machine:

1. Install Godot **4.6.3** standard and its matching export templates through Editor → Manage Export Templates. Keep downloads and checksum/TLS verification enabled. Use the corresponding engine and template versions.
2. Follow the official [Godot 4.6 Android export prerequisites](https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html): OpenJDK 17 and the documented Android SDK platform/build tools, command-line tools and platform tools. Set the Java SDK and Android SDK paths in Editor Settings → Export → Android. Accept the SDK licenses normally.
3. In Project → Export add an **Android** preset. Use an original package identifier such as `com.shadowblade.lastguardian`, enable arm64, and export a **debug APK** to `build/shadowblade-debug.apk`. The project uses Compatibility rendering and landscape orientation. The initial scene has no external addons or C# dependencies.
4. Use Godot's locally generated debug keystore for local testing. Never commit keystores/passwords or add them to setup instructions. Release signing and store submission need separate configuration.
5. With a connected, authorized test phone, install using `adb install -r build/shadowblade-debug.apk`. Record the phone model, chipset, Android version, game commit, resolution, quality and 30/60 frame-limit setting.
6. Test a complete journey: simultaneous move/jump/sword; slide-off input; magic tap versus hold; locked power cancellation; ledge/coyote/buffer jumps; pit damage; puzzle; boss telegraph/hitboxes/rewards; repeated death; checkpoint/save/restart; corrupt-save recovery; background/resume; audio interruption; safe areas; both control sizes and quality settings. Confirm the app never resumes with movement stuck.
7. Use Godot's profiler and Android tools for frame-time, memory and thermal measurements during sustained play. Report named hardware and measured results before describing any performance target as met.

After saving a reviewed Android preset, CLI exports can use:

```bash
mkdir -p build
godot --headless --path . --export-debug Android build/shadowblade-debug.apk
```

This command is an instruction for a machine with the prerequisites above; it was not run in this environment. The Android preset is intentionally left for the export machine, where SDK paths and debug signing can be configured and validated.
