# Getting iFiNeX onto GitHub (v8.9) — no "too big / hidden / too many files" errors

GitHub's website upload: max **100 files per drop**, hidden files (`.github`, `.gitignore`) are silently skipped, and an **empty folder cannot exist** (a folder only exists if a file is inside; `.gitkeep` is that file).

## What is in this pack
| Folder | For |
|---|---|
| `1_EMPTY_FOLDERS_skeleton/ifinex-app` | Only the folder tree (each folder holds one `.gitkeep`). Upload this FIRST if you want "empty folders first, then files". |
| `2_BATCHES_browser_upload/ifinex-app` | The real files, in `batch_01`, `batch_02` (≤ 80 files each) + `batch_00_hidden_files`. Drag each batch into the same repo. Paths inside the batches are already the real repo paths. |
| `3_ONE_SHOT_upload_script` | `upload-to-github` (NEW empty repo) and `update-github-repo` (EXISTING repo: updated files only, or convert the old layout). Uploads everything incl. hidden files in one push. Best option. |

## The project is now ONE standard Capacitor folder
`ifinex-app/` = `package.json`, `package-lock.json`, `capacitor.config.json`, `www/`, `android/`, `ios/`, `tools/`, `.github/`. One repo for Android AND iOS. `npm install` works in `ifinex-app` (the old layout had no package.json at the top — that was your error).

## Way 1 — one script (recommended)
**New repo:** create an empty PUBLIC repo → run `upload-to-github.ps1` (Windows: right-click → Run with PowerShell; Mac/Linux `bash upload-to-github.sh "<path>/ifinex-app" <repo-url>`) → drag the folder `ifinex-app` in → paste the repo URL → sign in.
**Existing v8.6 repo (keeps Releases and your secret):** `update-github-repo.ps1` → folder `ifinex-app` (the FULL one) → repo URL → answer **yes** to "replace everything". Old-layout files disappear, new layout arrives.
**Later updates:** use the `UPDATED_FILES_ONLY` pack with `update-github-repo.ps1`, answer nothing (Enter) at the "replace" question → only those files are copied over the repo.

## Way 2 — empty folders first, then files, in the browser
1. New empty public repo → **Add file → Upload files** → drag the CONTENT of `1_EMPTY_FOLDERS_skeleton/ifinex-app` (the browser skips the hidden `.gitkeep`, so folders may not appear — that is why Way 1 is better) …
2. Then `batch_01` → Commit, `batch_02` → Commit, `batch_00_hidden_files` last (if `.github/workflows/build-apk.yml` is missing: **Add file → Create new file**, type that name, paste the text, commit; same for `sync-web.yml`).

## After upload
Your repos: app = https://github.com/SquadSplit/iFiNeX-V2.4.0-Mobile , website = https://github.com/SquadSplit/Squadsplit.github.io
1. Create the signing key and the two GitHub secrets: **Signing Key & Auto-Update Guide, Parts 1–2** (double-click `tools\SIGNING_KEY_create.bat`).
2. Actions → **Build iFiNeX APK** → Run workflow → Releases. Android Studio: Guide Part 3.
The upload itself starts a build that turns RED until the secrets exist — that is expected on the very first upload.
⚠️ Never upload the `sql` folder with the "with data" file to a public repo — it contains real e-mails and money.
