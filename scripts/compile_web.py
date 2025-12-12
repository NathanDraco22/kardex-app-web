import shutil
from pathlib import Path
import subprocess


current_path = Path.cwd()
build_web_path = current_path / "build" / "web"

ouput_path = current_path / "output"
ouput_path.mkdir(exist_ok=True)
ouput_web_path = ouput_path / "web"

try:
    result = subprocess.Popen(
        ["flutter", "build", "web", "--release" , "--dart-define-from-file","secrets.json"],
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

    shutil.move(build_web_path, ouput_web_path)

except Exception as e:
    print(e)