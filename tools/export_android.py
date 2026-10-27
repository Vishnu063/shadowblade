#!/usr/bin/env python3
"""Export a test APK with local signing outside Git. Never print credentials."""
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
CLOUD = str(ROOT).startswith('/workspace/')
sdk = Path(os.environ.get('ANDROID_HOME', '/workspace/tooling/android-sdk' if CLOUD else ''))
if not (sdk / 'build-tools/36.0.0/apksigner').exists():
    raise SystemExit('Install Android build-tools 36.0.0, platform-tools and platforms;android-36; set ANDROID_HOME.')
java = Path(os.environ.get('JAVA_HOME', str(Path(shutil.which('java') or '/missing/java').resolve().parents[1])))
config = Path(os.environ.get('XDG_CONFIG_HOME', '/workspace/.config' if CLOUD else str(Path.home() / '.config')))
# Initialize settings through Godot first if the wrapper has not created them yet.
env = os.environ.copy()
if CLOUD:
    env.setdefault('XDG_DATA_HOME', '/workspace/.local/share')
    env.setdefault('XDG_CONFIG_HOME', '/workspace/.config')
    env.setdefault('XDG_CACHE_HOME', '/workspace/.cache')
env['JAVA_HOME'] = str(java)
env['ANDROID_HOME'] = str(sdk)
env['ANDROID_USER_HOME'] = '/workspace/tooling/android-user' if CLOUD else str(Path.home() / '.android')
subprocess.run([str(ROOT / 'tools/godot.sh'), '--headless', '--editor', '--import', '--quit'], env=env, check=True)
settings = config / 'godot/editor_settings-4.6.tres'
if not settings.exists():
    raise SystemExit('Expected Godot 4.6 EditorSettings file is missing: ' + str(settings))
text = settings.read_text()
for key, value in {'export/android/android_sdk_path': str(sdk), 'export/android/java_sdk_path': str(java)}.items():
    line = key + ' = ' + json.dumps(value)
    expression = r'^' + re.escape(key) + r'\s*=.*$'
    if re.search(expression, text, re.MULTILINE):
        text = re.sub(expression, lambda _: line, text, flags=re.MULTILINE)
    else:
        text += '\n' + line + '\n'
settings.write_text(text)
# A private local test key; release signing is a separate workflow.
signing = Path('/workspace/tooling/signing' if CLOUD else str(Path.home() / '.local/share/shadowblade-signing'))
signing.mkdir(parents=True, exist_ok=True, mode=0o700)
credentials = signing / 'debug.json'
if not credentials.exists():
    key = {'password': secrets.token_urlsafe(32), 'alias': 'androiddebugkey'}
    signing_env = env.copy()
    signing_env['SHADOWBLADE_DEBUG_PASSWORD'] = key['password']
    subprocess.run([str(java / 'bin/keytool'), '-genkeypair', '-keystore', str(signing / 'debug.keystore'),
                    '-storepass:env', 'SHADOWBLADE_DEBUG_PASSWORD', '-keypass:env', 'SHADOWBLADE_DEBUG_PASSWORD',
                    '-alias', key['alias'], '-dname', 'CN=Shadowblade Test,O=Shadowblade,C=IN',
                    '-keyalg', 'RSA', '-keysize', '2048', '-validity', '3650'], env=signing_env, check=True)
    credentials.write_text(json.dumps(key))
    credentials.chmod(0o600)
    (signing / 'debug.keystore').chmod(0o600)
key = json.loads(credentials.read_text())
env['GODOT_ANDROID_KEYSTORE_DEBUG_PATH'] = str(signing / 'debug.keystore')
env['GODOT_ANDROID_KEYSTORE_DEBUG_USER'] = key['alias']
env['GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD'] = key['password']
output = ROOT / 'build/Shadowblade-Campaign-debug.apk'
output.parent.mkdir(exist_ok=True)
subprocess.run([str(ROOT / 'tools/godot.sh'), '--headless', '--export-debug', 'Android', str(output)], env=env, check=True)
subprocess.run([str(sdk / 'build-tools/36.0.0/apksigner'), 'verify', '--verbose', str(output)], env=env, check=True)
subprocess.run([str(sdk / 'build-tools/36.0.0/zipalign'), '-c', '-P', '16', '-v', '4', str(output)], env=env, check=True, stdout=subprocess.DEVNULL)
print('Verified test APK:', output)
