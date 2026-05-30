import os
import shutil
from pathlib import Path
import subprocess

current_path = Path.cwd()
build_apk_path = current_path / "build" / "app" / "outputs" / "flutter-apk"

my_env = os.environ.copy()
my_env["PYTHONUNBUFFERED"] = "1"
my_env["TERM"] = "xterm-256color"

ouput_path = current_path / "output"
ouput_path.mkdir(exist_ok=True)
ouput_apk_path = ouput_path / "apk"

try:
    result = subprocess.Popen(
        [
            "flutter",
            "build",
            "apk",
            "--release",
            "--split-per-abi",
            "--dart-define-from-file",
            "secrets.json",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
        shell=True,
        env=my_env,
    )

    tunnel_stdout = result.stdout
    if tunnel_stdout is None:
        print("No stdout available.")
        os._exit(1)

    with tunnel_stdout:
        for line in iter(tunnel_stdout.readline, ""):
            print(line.strip())

    if ouput_apk_path.exists():
        shutil.rmtree(ouput_apk_path)

    shutil.move(build_apk_path, ouput_apk_path)

    arm64_apk_path = ouput_apk_path / "app-arm64-v8a-release.apk"
    armAbi_apk_path = ouput_apk_path / "app-armeabi-v7a-release.apk"

    renamed = arm64_apk_path.with_name("neptuno-arm64-v8a.apk")
    arm64_apk_path.rename(renamed)

    renamed = armAbi_apk_path.with_name("neptuno-armeabi-v7a.apk")
    armAbi_apk_path.rename(renamed)

except Exception as e:
    print(e)
