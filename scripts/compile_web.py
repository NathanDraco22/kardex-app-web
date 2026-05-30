import shutil
from pathlib import Path
import subprocess
import requests

current_path = Path.cwd()
build_web_path = current_path / "build" / "web"

ouput_path = current_path / "output"
ouput_path.mkdir(exist_ok=True)
ouput_web_path = ouput_path / "web"

netlify = "nfp_a1LFtkrKcc8BqusstHnYFKKm1kBmTFuXc5e9"

try:
    result = subprocess.Popen(
        [
            "flutter",
            "build",
            "web",
            "--release",
            "--dart-define-from-file",
            "secrets.json",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        shell=True,
    )

    while True:
        tunnel_stdout = result.stdout
        if tunnel_stdout is None:
            print("No stdout available.")
            break
        output = tunnel_stdout.readline()
        if output == "" and result.poll() is not None:
            break
        if output:
            print(output.strip())

    if ouput_web_path.exists():
        shutil.rmtree(ouput_web_path)

    shutil.move(build_web_path, ouput_web_path)

    if (ouput_path / "deploy.zip").exists():
        (ouput_path / "deploy.zip").unlink()

    shutil.make_archive(str(ouput_path / "deploy"), "zip", ouput_web_path)

    response = requests.post(
        "https://api.netlify.com/api/v1/sites/96321453-ae5b-48b6-919e-0e10ece5e2bf/deploys",
        headers={
            "Authorization": f"Bearer {netlify}",
            "Content-Type": "application/zip",
        },
        data=open(ouput_path / "deploy.zip", "rb").read(),
    )
    print(response.status_code)
    print(response.text)


except Exception as e:
    print(e)
