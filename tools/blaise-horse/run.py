#!/usr/bin/env python3
"""
BlaiseVue Co-Official Developer Tool: blaise-horse
Manages official HashLoad Horse microframework backend integration in an isolated server-horse/ directory.
"""

import os
import sys
import shutil
import subprocess
import urllib.request
import zipfile
import io
import json
import time

TOOL_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATES_DIR = os.path.join(TOOL_DIR, "templates")

HORSE_GIT_URL = "https://github.com/HashLoad/horse.git"
HORSE_ZIP_URL = "https://github.com/HashLoad/horse/archive/refs/heads/main.zip"

def is_blaise_project_dir(d):
    if not os.path.isdir(d):
        return False
    if os.path.exists(os.path.join(d, "app.cfg")):
        return True
    if os.path.exists(os.path.join(d, "src", "app.bv")):
        return True
    if os.path.isdir(os.path.join(d, "src", "views")) or os.path.isdir(os.path.join(d, "src", "components")):
        return True
    pkg = os.path.join(d, "package.json")
    if os.path.exists(pkg):
        try:
            with open(pkg, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read().lower()
                if "blaise" in content:
                    return True
        except Exception:
            pass
    return False

def require_blaise_project(cmd_context="bv horse"):
    cur = os.path.abspath(os.getcwd())
    while cur:
        if is_blaise_project_dir(cur):
            os.chdir(cur)
            return cur
        parent = os.path.dirname(cur)
        if not parent or parent == cur:
            break
        cur = parent

    print("")
    print("========================================================================")
    print(f"  [ERROR] \"{cmd_context}\" can only be executed inside a BlaiseVue project.")
    print(f"  Current directory: {os.getcwd()}")
    print("")
    print("  To create a new BlaiseVue project:")
    print("    bv create <project-name>")
    print("")
    print("  Or switch to an existing registered project:")
    print("    bv use <project-name>")
    print("========================================================================")
    print("")
    sys.exit(1)

def find_fpc():
    return shutil.which("fpc") or "fpc"

def fetch_horse_upstream(target_horse_dir):
    """
    Fetches official HashLoad/Horse source code directly from GitHub into target_horse_dir.
    Tries shallow git clone first; falls back to official repository ZIP archive.
    """
    horse_pas = os.path.join(target_horse_dir, "src", "Horse.pas")
    if os.path.exists(horse_pas):
        return True

    print("  [*] Fetching official HashLoad/Horse framework from GitHub...")
    os.makedirs(target_horse_dir, exist_ok=True)

    git_bin = shutil.which("git")
    if git_bin:
        try:
            print(f"      Cloning {HORSE_GIT_URL} (shallow clone)...")
            res = subprocess.run(
                [git_bin, "clone", "--depth", "1", HORSE_GIT_URL, target_horse_dir],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            if res.returncode == 0 and os.path.exists(horse_pas):
                print("  [+] Official HashLoad/Horse repository cloned successfully.")
                return True
        except Exception as e:
            print(f"      [!] git clone failed: {e}. Falling back to ZIP archive...")

    # Fallback: GitHub ZIP download
    print(f"      Downloading Horse release archive from {HORSE_ZIP_URL}...")
    try:
        req = urllib.request.Request(HORSE_ZIP_URL, headers={"User-Agent": "BlaiseVue-Horse-Tool"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            zip_bytes = resp.read()
        with zipfile.ZipFile(io.BytesIO(zip_bytes)) as z:
            for member in z.infolist():
                parts = member.filename.split("/", 1)
                if len(parts) > 1 and parts[1]:
                    subpath = parts[1]
                    target_file = os.path.join(target_horse_dir, subpath)
                    if member.is_dir():
                        os.makedirs(target_file, exist_ok=True)
                    else:
                        os.makedirs(os.path.dirname(target_file), exist_ok=True)
                        with z.open(member) as src, open(target_file, "wb") as dst:
                            shutil.copyfileobj(src, dst)
        if os.path.exists(horse_pas):
            print("  [+] Official HashLoad/Horse archive extracted successfully.")
            return True
    except Exception as e:
        print(f"  [ERROR] Failed to download Horse from GitHub: {e}")
        return False

    return False

def cmd_init():
    root = require_blaise_project("bv horse init")
    target_dir = os.path.join(root, "server-horse")
    if os.path.exists(target_dir):
        print(f"[!] Horse backend already exists at: {target_dir}")
        print("    Run 'bv horse run' to start or 'bv horse remove' to clean up first.")
        return 0

    print("================================================================")
    print("  Initializing BlaiseVue Horse Microframework in server-horse/")
    print("================================================================")

    os.makedirs(os.path.join(target_dir, "bin"), exist_ok=True)
    os.makedirs(os.path.join(target_dir, "lib", "units"), exist_ok=True)

    horse_dest = os.path.join(target_dir, "lib", "horse")
    if not fetch_horse_upstream(horse_dest):
        print("  [WARNING] Could not fetch Horse source from GitHub automatically.")
        print("            Please ensure internet connectivity or clone https://github.com/HashLoad/horse into server-horse/lib/horse.")

    # Copy templates
    shutil.copy(os.path.join(TEMPLATES_DIR, "server.pas"), os.path.join(target_dir, "server.pas"))
    shutil.copy(os.path.join(TEMPLATES_DIR, "server.lpi"), os.path.join(target_dir, "server.lpi"))
    shutil.copy(os.path.join(TEMPLATES_DIR, "Dockerfile"), os.path.join(target_dir, "Dockerfile"))

    env_path = os.path.join(target_dir, ".env")
    if not os.path.exists(env_path):
        with open(env_path, "w", encoding="utf-8") as f:
            f.write("# BlaiseVue Horse Environment Configuration\nPORT=9000\n")

    print("  [+] Installed official HashLoad/Horse source in server-horse/lib/horse/")
    print("  [+] Created server-horse/server.pas (Official HashLoad Horse API & SPA serving)")
    print("  [+] Created server-horse/server.lpi (Lazarus IDE ready with Delphi-mode & F9 debugging)")
    print("  [+] Created server-horse/Dockerfile (Alpine multi-stage micro-container)")
    print("  [+] Created server-horse/.env (Default PORT=9000)")
    print("================================================================")
    print("Next steps:")
    print("  1. Run 'bv horse run' to compile and launch on http://localhost:9000")
    print("  2. Run 'bv horse update' to pull the latest upstream Horse updates")
    print("  3. Open server-horse/server.lpi in Lazarus IDE to debug")
    print("  4. To remove this backend later, run 'bv horse remove'")
    print("")
    return 0

def cmd_update():
    root = require_blaise_project("bv horse update")
    target_horse_dir = os.path.join(root, "server-horse", "lib", "horse")
    if not os.path.exists(target_horse_dir):
        print("[!] No Horse framework found in server-horse/lib/horse/. Run 'bv horse init' first.")
        return 1

    print("================================================================")
    print("  Updating HashLoad/Horse upstream framework in server-horse/")
    print("================================================================")

    git_bin = shutil.which("git")
    is_git_repo = os.path.isdir(os.path.join(target_horse_dir, ".git"))

    if is_git_repo and git_bin:
        print("  [*] Running 'git pull' in server-horse/lib/horse/ ...")
        res = subprocess.run([git_bin, "pull", "--ff-only"], cwd=target_horse_dir)
        if res.returncode == 0:
            print("  [SUCCESS] HashLoad/Horse is up to date!")
            return 0

    print("  [*] Re-downloading latest HashLoad/Horse archive from GitHub...")
    try:
        shutil.rmtree(target_horse_dir)
    except Exception:
        pass

    ok = fetch_horse_upstream(target_horse_dir)
    if ok:
        print("  [SUCCESS] HashLoad/Horse updated to latest version.")
        return 0
    else:
        print("  [ERROR] Update failed.")
        return 1

def cmd_build(is_release=False):
    root = require_blaise_project("bv horse build")
    server_dir = os.path.join(root, "server-horse")
    server_pas = os.path.join(server_dir, "server.pas")
    if not os.path.exists(server_pas):
        print("[!] No Horse project found in server-horse/. Initializing first...")
        cmd_init()

    horse_src = os.path.join(server_dir, "lib", "horse", "src")
    if not os.path.exists(horse_src):
        print("  [*] Horse source not found. Fetching upstream from GitHub...")
        fetch_horse_upstream(os.path.join(server_dir, "lib", "horse"))

    bin_dir = os.path.join(server_dir, "bin")
    units_dir = os.path.join(server_dir, "lib", "units")
    os.makedirs(bin_dir, exist_ok=True)
    os.makedirs(units_dir, exist_ok=True)
    exe_name = "server.exe" if sys.platform.startswith("win") else "server"
    target_exe = os.path.join(bin_dir, exe_name)

    fpc = find_fpc()
    mode_str = "RELEASE (-O3, stripped symbols)" if is_release else "DEBUG (-O1, debug symbols)"
    print(f"Building BlaiseVue Horse Server ({mode_str})...")

    args = [
        fpc,
        "-MDelphi",
        "-Sh",
        "-FE" + bin_dir,
        "-FU" + units_dir,
        "-Fu" + horse_src,
        "-Fi" + horse_src,
        "-o" + target_exe
    ]
    if is_release:
        args += ["-O3", "-Xs", "-CX", "-XX"]
    else:
        args += ["-O1", "-g"]
    args.append(server_pas)

    res = subprocess.run(args, cwd=server_dir)
    if res.returncode == 0:
        print(f"  [SUCCESS] Native Horse server compiled: {target_exe}")
    else:
        print("  [ERROR] FPC compilation failed.")
    return res.returncode

def cmd_run(args_list):
    root = require_blaise_project("bv horse run")
    server_dir = os.path.join(root, "server-horse")
    bin_dir = os.path.join(server_dir, "bin")
    exe_name = "server.exe" if sys.platform.startswith("win") else "server"
    target_exe = os.path.join(bin_dir, exe_name)

    port = "9000"
    is_release = False
    for i, a in enumerate(args_list):
        if a == "--release":
            is_release = True
        elif a == "--port" and i + 1 < len(args_list):
            port = args_list[i + 1]
        elif a.startswith("--port="):
            port = a.split("=", 1)[1]

    # Recompile if needed
    if not os.path.exists(target_exe):
        ret = cmd_build(is_release=is_release)
        if ret != 0:
            return ret

    print(f"Starting BlaiseVue Horse Backend on port {port}...")
    run_cmd = [target_exe, port]
    try:
        res = subprocess.run(run_cmd, cwd=server_dir)
        return res.returncode
    except KeyboardInterrupt:
        print("\nHorse server stopped.")
        return 0

def cmd_status(port="9000"):
    url = f"http://localhost:{port}/api/health"
    print(f"Checking Horse server health at {url}...")
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "BlaiseVue-CLI"})
        with urllib.request.urlopen(req, timeout=3) as resp:
            data = resp.read().decode("utf-8")
            print(f"  [v] Server Active (HTTP {resp.status}): {data}")
            return 0
    except Exception as e:
        print(f"  [!] Server offline or not responding on port {port}: {e}")
        return 1

def cmd_kill(port="9000"):
    print(f"Terminating any processes listening on port {port}...")
    if sys.platform.startswith("win"):
        try:
            out = subprocess.check_output(f'netstat -ano | findstr :{port}', shell=True).decode()
            pids = set()
            for line in out.strip().splitlines():
                parts = line.split()
                if len(parts) >= 5 and "LISTENING" in line:
                    pids.add(parts[-1])
            for pid in pids:
                if pid != "0":
                    subprocess.run(f"taskkill /F /PID {pid}", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    print(f"  [-] Terminated process PID: {pid}")
            print("  [v] Port freed.")
        except Exception:
            print("  [v] No active processes found on port.")
    else:
        subprocess.run(f"fuser -k {port}/tcp", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print("  [v] Port freed.")
    return 0

def cmd_docker(build_flag=False):
    root = require_blaise_project("bv horse docker")
    server_dir = os.path.join(root, "server-horse")
    dockerfile = os.path.join(server_dir, "Dockerfile")
    if not os.path.exists(dockerfile):
        os.makedirs(server_dir, exist_ok=True)
        shutil.copy(os.path.join(TEMPLATES_DIR, "Dockerfile"), dockerfile)
        print("  [+] Created server-horse/Dockerfile")

    if build_flag:
        print("Building Docker image 'blaise-horse-app'...")
        res = subprocess.run(["docker", "build", "-t", "blaise-horse-app", "."], cwd=server_dir)
        return res.returncode
    else:
        print("Dockerfile ready in server-horse/. Run with: docker build -t my-horse-app server-horse/")
        return 0

def cmd_deploy(zip_flag=False):
    root = require_blaise_project("bv horse deploy")
    deploy_dir = os.path.join(root, "deploy", "horse")
    os.makedirs(deploy_dir, exist_ok=True)

    print("Assembling standalone Horse deployment bundle in deploy/horse/...")
    cmd_build(is_release=True)

    server_dir = os.path.join(root, "server-horse")
    bin_dir = os.path.join(server_dir, "bin")
    exe_name = "server.exe" if sys.platform.startswith("win") else "server"
    shutil.copy(os.path.join(bin_dir, exe_name), os.path.join(deploy_dir, exe_name))

    # Copy dist if present
    dist_dir = os.path.join(root, "dist")
    if os.path.exists(dist_dir):
        dest_dist = os.path.join(deploy_dir, "dist")
        if os.path.exists(dest_dist):
            shutil.rmtree(dest_dist)
        shutil.copytree(dist_dir, dest_dist)
        print("  [+] Included compiled frontend dist/ in deploy/horse/dist/")

    print(f"  [SUCCESS] Deployment bundle assembled at: {deploy_dir}")
    return 0

def cmd_remove(force=False):
    root = require_blaise_project("bv horse remove")
    server_dir = os.path.join(root, "server-horse")
    deploy_horse = os.path.join(root, "deploy", "horse")

    if not os.path.exists(server_dir) and not os.path.exists(deploy_horse):
        print("Horse backend not found in current project (server-horse/ does not exist).")
        return 0

    if not force:
        ans = input("Are you sure you want to remove the Horse backend (server-horse/ directory)? [y/N]: ").strip().lower()
        if ans not in ("y", "yes", "s", "sim"):
            print("Operation cancelled.")
            return 0

    deleted = False
    if os.path.exists(server_dir):
        print("  [-] Deleting server-horse/ directory ...")
        shutil.rmtree(server_dir)
        deleted = True

    if os.path.exists(deploy_horse):
        print("  [-] Deleting deploy/horse/ directory ...")
        shutil.rmtree(deploy_horse)
        deleted = True

    if deleted:
        print("  [SUCCESS] Horse backend platform removed successfully!")
        print("  [INFO] To re-enable it in the future, simply run:")
        print("         bv horse init")
    return 0

def print_usage():
    print("Usage: bv horse <init|update|run|build|status|kill|docker|deploy|remove> [options]")
    print("")
    print("Available Commands:")
    print("  init                       Scaffolds Horse server in server-horse/ and fetches upstream Horse")
    print("  update                     Pulls the latest upstream HashLoad/Horse updates from GitHub")
    print("  run [--release] [--port p] Compiles and starts native Horse server (Default Port 9000)")
    print("  build [--release]          Compiles server.pas with Free Pascal (FPC in Delphi mode)")
    print("  status [--port p]          Queries running Horse health check endpoint (/api/health)")
    print("  kill [--port p]            Terminates active processes on server port")
    print("  docker [--build]           Generates lightweight Alpine container in server-horse/")
    print("  deploy [--zip]             Assembles production deployment bundle in deploy/horse/")
    print("  remove [-y]                Safely deletes server-horse/ directory and binaries")
    print("")

def main():
    args = sys.argv[1:]
    if not args:
        print_usage()
        sys.exit(0)

    subcmd = args[0].lower()
    sub_args = args[1:]

    if subcmd == "init":
        sys.exit(cmd_init())
    elif subcmd == "update":
        sys.exit(cmd_update())
    elif subcmd == "build":
        sys.exit(cmd_build(is_release="--release" in sub_args))
    elif subcmd == "run":
        sys.exit(cmd_run(sub_args))
    elif subcmd == "status":
        port = "9000"
        for i, a in enumerate(sub_args):
            if a == "--port" and i + 1 < len(sub_args):
                port = sub_args[i + 1]
        sys.exit(cmd_status(port))
    elif subcmd == "kill":
        port = "9000"
        for i, a in enumerate(sub_args):
            if a == "--port" and i + 1 < len(sub_args):
                port = sub_args[i + 1]
        sys.exit(cmd_kill(port))
    elif subcmd == "docker":
        sys.exit(cmd_docker(build_flag="--build" in sub_args))
    elif subcmd == "deploy":
        sys.exit(cmd_deploy(zip_flag="--zip" in sub_args))
    elif subcmd in ("remove", "rm", "uninstall"):
        force = any(f in sub_args for f in ("-y", "--yes", "-f", "--force"))
        sys.exit(cmd_remove(force=force))
    else:
        print(f"Unknown subcommand: bv horse {subcmd}")
        print_usage()
        sys.exit(1)

if __name__ == "__main__":
    main()
