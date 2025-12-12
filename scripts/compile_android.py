import shutil
from pathlib import Path
import subprocess


current_path = Path.cwd()
build_apk_path = current_path / "build" / "app" / "outputs" / "flutter-apk"

ouput_path = current_path / "output"
ouput_path.mkdir(exist_ok=True)
ouput_apk_path = ouput_path / "apk"

try:
    result = subprocess.Popen(
        ["flutter", "build", "apk", "--release","--split-per-abi" , "--dart-define-from-file","secrets.json"],
        stdout = subprocess.PIPE,
        stderr = subprocess.STDOUT,
        text=True,
        shell=True,
    )

    while True:
        output = result.stdout.readline()
        if output == "" and result.poll() is not None:
            break
        if output:
            print(output.strip())

    shutil.move(build_apk_path, ouput_apk_path)

    arm64_apk_path = ouput_apk_path / "app-arm64-v8a-release.apk"
    armAbi_apk_path = ouput_apk_path / "app-armeabi-v7a-release.apk"
    
    renamed = arm64_apk_path.with_name("neptuno-arm64-v8a.apk")
    arm64_apk_path.rename(renamed)

    renamed = armAbi_apk_path.with_name("neptuno-armeabi-v7a.apk")
    armAbi_apk_path.rename(renamed)
    
except Exception as e:
    print(e)