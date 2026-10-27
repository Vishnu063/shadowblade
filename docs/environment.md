# Environment and setup draft

The draft was inspected before updates: its old install script only refreshed Godot imports/tests; startup notes still described the 56-check prototype and unavailable Android tooling. Those notes needed revision. Saving a draft does not publish a snapshot or prove new-task restoration.

Required for game development: Godot 4.6.3 standard, Compatibility renderer. No package manager dependencies, backend, login or secrets. In this cloud machine `tools/godot.sh` redirects data/config/cache into writable `/workspace` folders. `./tools/check.sh` validates the project. Model scenes are checked in; rebuilding the art is optional and overwrites those generated scenes.

Optional rendered checks: live X server. This instance has `/workspace/tooling/xvfb/usr/bin/Xvfb`; a new task must start its own process, for example `Xvfb :99 -screen 0 1280x720x24 -nolisten tcp`. Do not assume a process survives a snapshot. Mesa llvmpipe is software rendering, not phone hardware.

Android build prerequisites prepared here:

- Matching official 4.6.3 templates, downloaded from `godotengine/godot-builds` and SHA-512 verified against its release `SHA512-SUMS.txt`. Android templates installed in `/workspace/.local/share/godot/export_templates/4.6.3.stable/`.
- Google command-line tools archive `commandlinetools-linux-13114758_latest.zip`, verified against Google's repository metadata checksum. SDK root `/workspace/tooling/android-sdk`; SDK manager state `/workspace/tooling/android-user`.
- `platforms;android-36`, `build-tools;36.0.0`, platform-tools 37.0.1. Earlier API 35 tools remain installed but the final exporter uses 36.0.0. Official Godot 4.6.3 source confirms minimum API 24 and default target API 36 for the non-Gradle template.
- OpenJDK 21.0.12.1 at `/usr/lib/jvm/java-21-openjdk-amd64` was used successfully. Godot's recommended JDK 17 is another documented option; this report records the actually used version.
- Android texture import enabled in `project.godot`, required by the exporter. SDK overrides remain blank for the non-Gradle preset; inspect the APK rather than assuming SDK levels.

For a fresh SDK install, obtain the official tools and verify them, then run SDK manager with the desired SDK root and writable `ANDROID_USER_HOME`; accept the SDK licenses. In this cloud network Java tools require explicit `--proxy=http --proxy_host=proxy --proxy_port=8080`; retain TLS verification. Install `platform-tools`, `platforms;android-36`, and `build-tools;36.0.0`. Godot templates require github.com and release-assets.githubusercontent.com; SDK packages require dl.google.com. These were reachable through the existing package-manager preset; no broader domains were added.

Run `python tools/export_android.py` to import, configure the local editor's SDK/JDK paths, generate or reuse a private local test key outside Git, export, verify signatures and check alignment. It never prints passwords or stores them in tracked presets. Local test signing files are under `/workspace/tooling/signing/`; preserve them privately to update an installed test app with the same signature. Release signing/store publication is separate.

ADB 37 insists on `/home/agent/.android` for its profile; creating/initializing that directory needed the sandbox's narrow approval. SDK manager's `ANDROID_USER_HOME` did not redirect ADB. A new task may need that same allowed local initialization for device queries. It is not needed to claim a connected device: this instance's list was empty. No emulator or KVM acceleration is available.
