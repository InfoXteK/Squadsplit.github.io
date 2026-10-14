# iFiNeX Web v8.9 / App v2.5 — Setup & User Guide

Written for a person who has never built an app. Follow the steps in order. Every step says WHERE to click.

---

## 0 · What changed in this version (read once)

| You asked | Now |
|---|---|
| Android Studio APK and GitHub APK must update each other (no uninstall/install), key guide was unclear | **New: one signing key, one tool, two places.** Double-click `tools\SIGNING_KEY_create.bat` once → Android Studio and GitHub both sign with it. Build numbers are automatic. Full guide: **`iFiNeX Web v8.9 & Mobile App v2.5 - Signing Key & Auto-Update Guide.md`** (read it before building). |
| Push to the web/app repo → GitHub builds APK → app shows update, waits for my confirmation | **Done.** Repos: website `SquadSplit/Squadsplit.github.io`, app `SquadSplit/iFiNeX-V2.4.0-Mobile`. Website changes are picked up every 30 min (instant with an optional token), app changes build on upload; the app shows a banner and Settings → Check for updates → Download → Install now → Android confirms. |
| `npm install` → "Could not read package.json" in Android Studio | **Cause: my fault.** The old repo had the Android project at the top level with no `package.json`. Now it is ONE standard Capacitor project: `package.json`, `www`, `android`, `ios` all in one folder. Works with GitHub **and** Android Studio. See section 2 and 3. |
| Web/app opened Squad Split instead of the iFiNeX Hub | **Fixed.** The website address and the app always open the **iFiNeX Hub**. Squad Split is a separate page (`squad.html`) that you enter *from* the Hub. Old bookmarks of `index.html` are redirected to the Hub. |
| Could not tap the logo/name to go back | **Fixed.** On every page (all modules and Squad Split) tapping the **iFiNeX logo or name** (or your name pill) opens the Hub. Tapping your name no longer logs you out; **Log out** is in ☰ → Account. |
| After login it showed Squad Split / asked which user | **Fixed.** After login you land in **your own account's Hub**. No picker. If you manage other accounts (delegation), use the **🔀 Switch** button when you want to swap. After a restart it opens your own account again. |
| Backup & Restore only in standalone | **Now in every mode** (website, app on a server, standalone), for admins **and** members. |
| Theme / Notifications / Backup / Updates scattered | **All under ☰ → Settings**, same order everywhere: 🎨 Theme & background · 🔔 Alerts & notifications · 💾 Backup & Restore · ⇅ Import / Export · ⬆️ Check for updates · 🔌 Connection (app only). Then **Account**: Admin, Log out. Google Drive backup is inside Backup & Restore. |
| "eX" of the iFiNeX name cut off | **Fixed** (checked at 320, 360, 390, 412 px widths). |

---

## 1 · What is in the download

| File | Use |
|---|---|
| `iFiNeX_v8.9_REPO_ifinex-app.zip` | The whole app project (ONE folder `ifinex-app`). |
| `iFiNeX_v8.9_UPLOAD_PACKS.zip` | `1_EMPTY_FOLDERS_skeleton`, `2_BATCHES_browser_upload`, `3_ONE_SHOT_upload_script`. For getting the project onto GitHub without "too many files / hidden files" errors. |
| `iFiNeX_v8.9_UPDATED_FILES_ONLY.zip` | Only the files that changed since v8.8 (see its own README). Plus the "update" script. |
| `iFiNeX_v8.9_Website_files.zip` + `iFiNeX_v8.9_Website_UPDATED_FILES_ONLY.zip` | Website for GitHub Pages (`SquadSplit/Squadsplit.github.io`), full and changed-only. |
| `sql/` (4 files) | Database: UPGRADE (live), FULL no data, FULL with data, Emergency Rollback. |
| docs | This guide, Self-Hosting guide, Claude Reference. |

---

## 2 · Route A — GitHub builds the APK (no Android Studio needed)

### 2.1 Put the project on GitHub
1. github.com → **+ → New repository** → name `ifinex-app` → **Public** (the app downloads updates without a password; **never put secrets in it**) → do **not** tick README → **Create**. Copy the address `https://github.com/YOU/ifinex-app.git`.
2. Install **Git** (git-scm.com/downloads → Next, Next, Finish).
3. Unzip `iFiNeX_v8.9_REPO_ifinex-app.zip` → you get the folder `ifinex-app`. Inside you must see `package.json`, `www`, `android`, `ios`, `tools`, and a hidden `.github` folder.
4. Unzip the upload packs. Windows: right-click `3_ONE_SHOT_upload_script\upload-to-github.ps1` → **Run with PowerShell** → drag the folder **`ifinex-app`** into the window → Enter → paste the repo address → Enter → sign in to GitHub when the window opens. Mac/Linux: `bash upload-to-github.sh "/path/ifinex-app" https://github.com/YOU/ifinex-app.git`.
5. Open the repo page: you must see `android`, `ios`, `www`, `tools`, `.github`, `package.json`.

**You already have a repo from v8.6 (old layout)?** Keep it (your Releases and secret stay) and convert it in one go: run `update-github-repo.ps1` (or `.sh`) from `3_ONE_SHOT_upload_script`, choose the folder `ifinex-app`, give your existing repo address and answer **yes** to "replace everything". It removes the old files and puts the new layout in. (A repo with the old layout cannot take "updated files only" — the folder structure moved.)

**Browser-only way (no Git):** create the repo → **Add file → Upload files**. First `1_EMPTY_FOLDERS_skeleton` is NOT needed for the browser; use `2_BATCHES_browser_upload/ifinex-app/batch_01`, drag everything inside, **Commit**; repeat `batch_02`… Each batch has ≤ 80 files (GitHub allows 100). Last: `batch_00_hidden_files` (browsers often skip dot-folders: if `.github/workflows/build-apk.yml` is missing after commit, **Add file → Create new file**, type the name `.github/workflows/build-apk.yml`, paste the file's text, commit; same for `sync-web.yml`).

### 2.2 The signing key (once, 5 minutes) — makes every update install over the old app
**Follow Part 1 and Part 2 of `iFiNeX Web v8.9 & Mobile App v2.5 - Signing Key & Auto-Update Guide.md`.** In short: double-click `tools\SIGNING_KEY_create.bat`, follow the window (it copies the two GitHub secrets for you: `IFX_KEYSTORE_B64`, `IFX_KEYSTORE_PASSWORD`), back up the folder `C:\Users\<you>\ifinex-keys`. Android Studio needs no setting: it finds that folder by itself.

### 2.3 Build
Repo → **Actions → Build iFiNeX APK → Run workflow** (≈ 10 min). Green tick → **Releases** → download `iFiNeX-app-v2.5.0-b….apk` → open on the phone → allow "install from this source" → Install.
Red run "No usable signing key" = step 2.2 not done. After this, every upload to the repo builds and publishes automatically.

---

## 3 · Route B — Android Studio

You need: **Node.js LTS** (nodejs.org), **Android Studio** (developer.android.com/studio). Both: Next, Next, Finish.

1. Unzip `iFiNeX_v8.9_REPO_ifinex-app.zip` somewhere without spaces/odd characters if possible, e.g. `D:\ifinex-app`.
2. **Easy way (Windows):** double-click `tools\build-android-local.bat`. It finds the right folder itself, runs `npm ci` and `npx cap sync android`, then offers to open Android Studio.
   **Manual way:** open PowerShell **in the folder that contains `package.json`** (the folder `ifinex-app`, NOT the `android` subfolder) and run:
   ```
   npm install
   npx cap sync android
   ```
   > This is exactly the error you had: `npm install` run in a folder without `package.json` (the Android folder of the old layout). In the new layout `package.json` is in `ifinex-app`. Never run npm inside `android`.
3. Android Studio → **File → Open** → choose the folder **`ifinex-app\android`** → wait until "Gradle sync" finishes (first time 5–15 minutes, needs internet).
4. **Build → Build Bundle(s) / APK(s) → Build APK(s)** → click "locate" in the pop-up. File: `android\app\build\outputs\apk\debug\app-debug.apk`.
5. After ANY change of the website files (`www`) run `npx cap sync android` again.
6. **Signing:** the build uses the key in `C:\Users\<you>\ifinex-keys` (created once by `tools\SIGNING_KEY_create.bat`). GitHub uses the same key via the two secrets, so an APK from either route installs over the other. If no key exists the build stops with a clear message (on purpose).

---

## 4 · Using the app

**First start:** "How do you want to use iFiNeX?" → ☁️ **Connect to a server** (type the web address, e.g. `https://squadsplit.github.io` → Check server → Use this server) or 📱 **Standalone** (everything stays on the phone). Change later: ☰ → Settings → 🔌 Connection.

**Login (server mode):** type your e-mail → 6-digit code from your mail → you land in **your own iFiNeX Hub**. Gmail works like any e-mail (the admin must have added it: ☰ → Account → Admin).

**Hub-first:** the Hub is the front page. Tap a tile to open a module. From any module, tap the **iFiNeX logo/name** to go back. Squad Split is a tile (visible if you are a squad member).

**Delegation:** if someone gave you access to their account, a **🔀 Switch** button appears in the header. You always start in your own account.

### Settings (☰ menu) — everything in one place
* 🎨 **Theme & background** · 🔔 **Alerts & notifications** · 💾 **Backup & Restore** · ⇅ **Import / Export** (Excel/PDF) · ⬆️ **Check for updates** · 🔌 **Connection** (app).
* **Account:** ⚙️ Admin (admins), 🚪 Log out.

### 💾 Backup & Restore
*Server mode (website or app):*
* **Create backup file** — one `.json` with everything of the account you are viewing (bills, cards, party ledger, plans, trackers, budget, theme…). It reads in pages, so big accounts are complete.
* **Back up everything I can access** — admins: all accounts and the squad; delegates: own + managed accounts.
* **Restore from a backup file** — puts back what is **missing**. It never overwrites and never deletes existing data. A member can restore their own data, an admin everything. A report shows added / already there / not allowed.
* **Google Drive backup** (app only, optional) — see section 6.
* Needs the **v8.8 UPGRADE SQL** on the server once (section 5). Without it the screen tells you so.
* A backup file from another server is detected and you are warned.
*Standalone:* backup, restore (replaces everything on the phone), erase, Google Drive — as before.

*Honest limits:* restore cannot "undo an edit" (existing rows win) and cannot restore rows you have no right to write. It restores records, not the Supabase login accounts.

---

## 5 · Database (server owners)
1. Supabase → **SQL Editor → New query** → open **`... Database UPGRADE (run once on live).sql`** → paste → **Run**. It is safe to run again. It adds the v8.5 features (custom tracker types, 12 design styles, settlement edit) **and** the v8.8 restore functions (`ifx_restore_rows`, `ifx_seq_bump`).
2. New server from nothing: run `... FULL (no data).sql` (or `FULL (with data).sql` to clone existing data — **contains real e-mails and money: never put it on GitHub**), then `SELF-HOST - first admin`.
3. Emergency Rollback only if the upgrade must be undone.

**Status of the live project:** I verified read-only (2026-10-11) that your live database is still at v8.3. The approval prompt for applying changes was cancelled twice, so **nothing was changed on live**. Until you run the UPGRADE file, new features that need it (custom tracker types, server restore) show a "database upgrade needed" message. Tell me "apply it" and approve the prompt if you want me to run it.

---

## 6 · Google Drive backup (optional, app only)
Saves backups into a hidden folder of **your own** Google Drive that only this app sees. Server mode now supports **backup and restore** too (restore = missing rows only). Setup by the app owner: Google Cloud project → enable Google Drive API → OAuth consent screen (External, scope `drive.appdata`, publish to production) → Credentials → OAuth client type **TVs and Limited Input devices** → put `"google": {"clientId":"…","clientSecret":"…"}` into `ifinex-config.json` in the website repo. Then ☰ → Settings → Backup & Restore → ☁️ Google Drive backup → Connect.
Gmail cannot be a database; Drive is the Google place for files. "Sign in with Google" is **not built** (needs native code I cannot test here).

---

## 7 · Updates (details in the Signing Key & Auto-Update Guide, Part 5)
* **In the app:** a banner "⬆️ Update available" appears when a newer build exists (checked when the app opens / returns to the front, at most every 3 h); or ☰ → Settings → ⬆️ Check for updates → **Download update** → **Install now** → confirm on Android's screen. The file is verified first (same app, newer build number, same signing key). Nothing downloads or installs without your tap.
* **Website → app sync:** `.github/workflows/sync-web.yml` runs every 30 minutes (and instantly if you add the optional token + `notify-app.yml` to the website repo): copies the newest website from `SquadSplit/Squadsplit.github.io` (only the real site files; never an older website than the app already has), raises the app's patch version, starts the build → new Release.
* **App-only changes** (Android code etc.): upload to `SquadSplit/iFiNeX-V2.4.0-Mobile` → build starts by itself → new Release. Every build has its own build number, so even a fix with the same version name is offered.
* **Updating the website:** upload website files to the Pages repo (full zip or "UPDATED_FILES_ONLY"). Hard-refresh the site once.

## 8 · Troubleshooting
| Symptom | Fix |
|---|---|
| `npm error ENOENT … package.json` | You ran npm in the wrong folder. Run it in the folder that contains `package.json` (`ifinex-app`), or use `tools\build-android-local.bat`. |
| `Could not find installation of TypeScript` (cap sync) | Old build had `capacitor.config.ts`, which needs TypeScript. Fixed in the corrected pack: the file is now `capacitor.config.json`. Quick fix on an old copy: delete `capacitor.config.ts`, create `capacitor.config.json` (from the fix pack), run `npx cap sync android` again. |
| `npx cap sync android` → `could not determine executable to run` (npm tries to download a package called "cap") | You ran it inside the `android` folder. Go UP one level: run it in the folder that contains `package.json` (check with `dir package.json`). Or just use `tools\build-android-local.bat`. |
| Android Studio: "Plugin/Project ':capacitor-…' not found" | `npx cap sync android` was not run (needs `node_modules`). Run it, then File → Sync Project with Gradle Files. |
| "App not installed / conflicts" | The installed app has another key → ONE final uninstall (back up first; Guide Part 6). Then every build from Android Studio and GitHub updates it. |
| Login says "not registered" | Admin must add your e-mail (☰ → Account → Admin). |
| Restore says server lacks the function | Run the UPGRADE SQL (section 5). |
| Restore: "Not allowed: N" | Those rows belong to someone else and your login may not write them (security working as designed). Ask an admin. |
| Website still opens Squad Split | Browser cache: hard refresh (Ctrl+F5) / clear site data once. |


## 8b · "App not installed" / "uninstall first" — the real reasons and the permanent fix
Android installs an APK as an UPDATE (data kept) only if **both** are true: (1) same signing key, (2) higher build number.
* **Build number — automatic:** `android/app/build.gradle` uses *minutes since 1970* for every build (Android Studio and GitHub). Never edit it.
* **Signing key — one tool:** `tools\SIGNING_KEY_create.bat` makes ONE key in `C:\Users\<you>\ifinex-keys`; Android Studio reads it automatically, GitHub gets it as two secrets. Check at any time: `tools\SIGNING_KEY_show.bat` (fingerprint) must equal the "Signing certificate SHA-256" in the Release text and the key shown in the app (Check for updates).
* **The one-time uninstall** is needed only if the app already on the phone was signed with a different key (see Guide Part 6 — includes how to back up standalone data first).

## 9 · NOT tested here (honest)
No real APK build, no GitHub Actions run, no real phone/Android installer, no real Google account, no iOS, no real e-mail code. Tested: headless-browser suites with a mock database (hub-first navigation 28 checks, header at 4 widths, settings order, backup/restore incl. 2,503-row paging, standalone, Drive against a mock Google, updater, sync script), the repo layout with `npm ci` + `npx cap sync android`, and the SQL on PostgreSQL 16 (security suite + restore suite, FULL builds, UPGRADE run twice). Anything on real devices/GitHub: tell me the exact message.
