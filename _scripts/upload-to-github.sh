#!/bin/bash
# iFiNeX — push a WHOLE folder to GitHub in ONE shot (no 100-file limit, hidden files included).
# usage:  bash upload-to-github.sh  "/path/to/android-cloud"  https://github.com/YOU/YOUR-EMPTY-REPO.git
set -e
DIR="${1:?folder to upload}"; URL="${2:?GitHub repo URL (https://github.com/you/repo.git)}"
command -v git >/dev/null || { echo "Install Git first: https://git-scm.com/downloads"; exit 1; }
cd "$DIR"
[ -d .git ] || git init -b main >/dev/null
git config user.name  >/dev/null || git config user.name  "iFiNeX"
git config user.email >/dev/null || git config user.email "ifinex@users.noreply.github.com"
git remote remove origin 2>/dev/null || true; git remote add origin "$URL"
git add -A
git commit -m "iFiNeX upload" >/dev/null 2>&1 || echo "(nothing new to commit)"
git push -u origin main
echo "DONE. Open $URL — all files are there."
