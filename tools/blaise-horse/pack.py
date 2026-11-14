#!/usr/bin/env python3
import os
import sys
import zipfile
import hashlib

def main():
    tool_dir = os.path.dirname(os.path.abspath(__file__))
    dist_dir = os.path.join(tool_dir, "dist")
    os.makedirs(dist_dir, exist_ok=True)

    zip_name = "blaise-horse-1.0.0.zip"
    zip_path = os.path.join(dist_dir, zip_name)
    checksum_path = zip_path + ".sha256"

    ignored = {".git", "dist", "__pycache__", "backup"}

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(tool_dir):
            dirs[:] = [d for d in dirs if d not in ignored and not d.startswith(".")]
            for file in files:
                if file.endswith((".pyc", ".tmp", ".bak", ".sha256")) or file == zip_name:
                    continue
                file_path = os.path.join(root, file)
                rel_path = os.path.relpath(file_path, tool_dir)
                zf.write(file_path, os.path.join("blaise-horse", rel_path))

    hasher = hashlib.sha256()
    with open(zip_path, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    digest = hasher.hexdigest()

    with open(checksum_path, "w", encoding="utf-8") as f:
        f.write(f"{digest} *{zip_name}\n")

    print(f"[blaise-horse] Successfully packaged release: {zip_path}")
    print(f"[blaise-horse] SHA-256: {digest}")

if __name__ == "__main__":
    main()
