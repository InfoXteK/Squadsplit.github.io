#!/bin/bash
# iFiNeX — push ONLY the updated files (or convert an old-layout repo) to an EXISTING GitHub repo. Hidden files included, no 100-file limit.
# usage:  bash update-github-repo.sh "/path/to/folder-with-the-files" https://github.com/YOU/YOUR-REPO.git [--replace-all]
#   (no flag)      files in the folder are copied over the repo; everything else in the repo stays.
#   --replace-all  the repo content is REPLACED by the folder (use the full `ifinex-app` folder to convert the old v8.6 layout). Releases + secrets stay.
set -e
DIR="${1:?folder with the files}"; URL="${2:?existing GitHub repo URL}"; MODE="${3:-}"
command -v git >/dev/null || { echo "Install Git first: https://git-scm.com/downloads"; exit 1; }
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
git clone "$URL" "$T/r"; cd "$T/r"
git config user.name  >/dev/null || git config user.name  "iFiNeX"
git config user.email >/dev/null || git config user.email "ifinex@users.noreply.github.com"
BR=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
if [ "$MODE" = "--replace-all" ]; then git rm -rq --ignore-unmatch . ; find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} + ; fi
cp -a "$DIR"/. .
rm -f CHANGED_FILES.txt README_UPDATE.md
git add -A
if git diff --cached --quiet; then echo "Nothing changed - repo already up to date."; exit 0; fi
git commit -m "iFiNeX update" >/dev/null
git push origin "$BR"
echo "DONE. Open $URL - the changes are there."
