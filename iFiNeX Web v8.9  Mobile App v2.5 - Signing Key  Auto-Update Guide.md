# iFiNeX — Signing Key & Auto-Update Guide (Android Studio + GitHub)
**Web v8.9 · App v2.5.0** — for a person who has never built an app. Every step says WHERE to click and WHAT you should see.

Your two repositories:

| What | Repository |
|---|---|
| Website (GitHub Pages) | https://github.com/SquadSplit/Squadsplit.github.io |
| Android app (builds the APK) | https://github.com/SquadSplit/iFiNeX-V2.4.0-Mobile  (**must stay Public**) |

---

## 0 · How it works — read once (2 minutes)

**The problem you had:** Android only installs a new APK *over* the old app (an **update**, data kept) when
1. the new APK is signed with the **same key** as the installed app, **and**
2. its **build number** is higher.

If either is wrong, Android says "App not installed" and forces you to uninstall first.

**The fix in this version (both parts are now automatic):**

| Part | How it is solved |
|---|---|
| Build number | Every build (Android Studio **or** GitHub) uses *minutes since 1970* as its build number, so every new build is automatically higher. You never type it. |
| Key | **One key file** on your PC (`C:\Users\<you>\ifinex-keys\`). Android Studio finds it by itself. The same key is stored once in GitHub as two **secrets**, so GitHub signs with the identical key. |

**The update chain you asked for:**

```
 you upload changes to the WEBSITE repo ─┐
                                         ├─►  app repo syncs/receives it  ─►  GitHub Action builds + signs the APK
 you upload changes to the APP repo ─────┘                                    ─►  publishes a GitHub Release (APK inside)
                                                                              ─►  phone: banner "Update available" / ☰ → Settings → Check for updates
                                                                              ─►  you tap Download ─► Install now ─► Android asks ─► you confirm
```
Nothing is installed without your tap. Nothing is downloaded until you tap **Download**.

---

## 1 · Create the key — ONCE (Windows, 5 minutes)

**You need** (both are "Next, Next, Finish" installers):
* **Node.js LTS** — https://nodejs.org
* **Android Studio** — https://developer.android.com/studio (it contains Java, which the key tool needs)

**Steps**
1. Open the project folder `ifinex-app` (the folder that contains `package.json`) → open the folder **`tools`**.
2. **Double-click `SIGNING_KEY_create.bat`.** A black window opens.
   * Windows may say "Windows protected your PC" → **More info → Run anyway** (it is a plain text script you can open in Notepad).
3. The window prints something like:
   ```
   NEW key created in C:\Users\abu\ifinex-keys
   SHA-256    : 3cf36a26190e9258…        <- your key's fingerprint
   ```
   and then walks you through the GitHub secrets (Part 2). **Do not close it yet.**
4. **BACK UP the folder `C:\Users\<you>\ifinex-keys`** — copy it to a USB stick **and** a private cloud drive. This folder IS your app's identity.
   * Never upload it to GitHub, never e-mail it.
   * Lost key = the next update cannot install over the old app (one more uninstall). With the backup you are safe forever.

The tool **never overwrites** an existing key: running it again just reuses it and shows the secrets again.

**Mac/Linux:** `bash tools/SIGNING_KEY_create.sh` (same steps).

> **Option B — only if** the iFiNeX currently on your phone was installed from an APK you built with **Android Studio on this same PC**: run `tools\SIGNING_KEY_create.bat --use-android-studio-key` instead. It reuses Android Studio's own debug key, so your first new APK may install over the existing app **without any uninstall**. It then shows a **third** secret (`IFX_KEY_ALIAS`). If you are not sure, use the normal way (Option A) — it needs at most one uninstall (Part 6), once.

---

## 2 · Put the key into GitHub — ONCE (3 minutes)

The same black window continues:

1. Open https://github.com/SquadSplit/iFiNeX-V2.4.0-Mobile/settings/secrets/actions (log in first).
2. Click the green **New repository secret**.
3. The window says **SECRET 1 of 2 — Name: `IFX_KEYSTORE_B64`**.
   * In GitHub, **Name** box: type `IFX_KEYSTORE_B64` exactly.
   * In the black window press **Enter** → the value is copied to your clipboard.
   * In GitHub click the **Secret** box → **Ctrl+V** → **Add secret**.
4. Press Enter in the window for **SECRET 2 of 2 — Name: `IFX_KEYSTORE_PASSWORD`** → same procedure.
5. You now see two secrets in the list. (GitHub never shows their values again — that is normal.)

If the clipboard fails, open the file named in the window (e.g. `C:\Users\<you>\ifinex-keys\GITHUB_SECRET_1_IFX_KEYSTORE_B64.txt`) in Notepad → Ctrl+A → Ctrl+C → paste into GitHub.

**Old secret `IFX_DEBUG_KEYSTORE_B64` from the previous guide?** It still works as a fallback, but delete it once the two new secrets exist so there is only one way.

---

## 3 · Build in Android Studio

1. Double-click `tools\build-android-local.bat`. It does 3 things and tells you each: `[1/3] npm ci` → `[2/3] cap sync` → `[3/3] signing key check` (must say *Key OK*).
2. Android Studio → **File → Open** → choose the folder **`ifinex-app\android`** (not `ifinex-app`) → wait for **Gradle sync** (first time 5–15 min, needs internet).
3. **Build → Build Bundle(s)/APK(s) → Build APK(s)** → when "APK(s) generated" appears click **locate**.
   File: `android\app\build\outputs\apk\debug\app-debug.apk`.
4. In the **Build** tab (bottom of Android Studio) you can see the line
   `iFiNeX signing key: C:\Users\<you>\ifinex-keys\ifinex.keystore` — that is the proof it used your key.
5. Install: connect the phone by USB and press the green ▶ **Run** button, **or** copy the APK to the phone and open it.

**If you forgot Part 1:** the build stops with a big message *"NO SIGNING KEY FOUND - build stopped on purpose"*. That is intentional (an APK with a random key could never update your phone). Do Part 1, build again.

---

## 4 · Build on GitHub

1. Repo → **Actions** tab → **Build iFiNeX APK** → **Run workflow** → green **Run workflow**.
2. Wait ≈ 8–12 minutes. Click the run to watch. Expected result: **green ✔** with the summary *"Published v2.5.0-b29…"*.
3. Repo front page → **Releases** (right side) → newest release → **Assets** → `iFiNeX-app-v2.5.0-b….apk`.
4. **Check the key (important, 30 seconds):** the release text contains `Signing certificate SHA-256: …`. Double-click `tools\SIGNING_KEY_show.bat` → the **SHA-256** it prints must be **identical**. Identical = GitHub and Android Studio produce APKs that update each other.

A **red ✘** with *"No usable signing key"* = Part 2 not done or a secret was pasted wrongly (see Part 8).

---

## 5 · Automatic updates — day-to-day

### 5.1 What you do → what happens by itself

| You change… | You upload to… | Automatically | Delay |
|---|---|---|---|
| Website files (bug fix, new feature) | **Squadsplit.github.io** | Website goes live (GitHub Pages). The app repo copies it into the app, raises the version (2.5.0 → 2.5.1), builds, signs, publishes a Release. | ≤ 30 min to notice (or seconds with Part 5.3) + ≈ 10 min build |
| App files (Android code, plugins, icons) | **iFiNeX-V2.4.0-Mobile** | The build starts on upload, publishes a Release. | ≈ 10 min |
| Nothing (just rebuild) | Actions → *Build iFiNeX APK* → Run workflow | New build number → new Release. | ≈ 10 min |

How to upload: use the "UPDATED FILES ONLY" pack and the `update-github-repo` script (or GitHub → Add file → Upload files). Always upload to **`main`**.

### 5.2 What the phone shows
* The app checks quietly when it opens and when you come back to it (at most every 3 hours). If a newer build exists a **banner "⬆️ Update available"** appears at the bottom. Tap **View**.
* Or any time: ☰ → **Settings** → **⬆️ Check for updates**.
* The dialog shows: installed version/date, available version/date, size, release notes.
* Tap **Download update** → progress bar → the app verifies the file (same app, newer build, **same signing key**) → tap **Install now** → Android shows its own screen → tap **Install**. The app restarts. Your data stays.
* First time only: Android asks "Allow from this source" → switch ON → come back → tap **Install now** again.

### 5.3 OPTIONAL: instant mode (website push → build within seconds)
Without it everything still works — the app repo looks at the website every 30 minutes. For instant start:

1. GitHub → your **profile picture → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token**.
   * Name `ifinex-notify`, Expiration 1 year (set a calendar reminder; when it expires the 30-minute check still works).
   * **Repository access → Only select repositories → `iFiNeX-V2.4.0-Mobile`**.
   * **Permissions → Repository permissions → Actions → Read and write.**
   * Generate → **copy the token now** (shown once).
2. Website repo (`Squadsplit.github.io`) → **Settings → Secrets and variables → Actions → New repository secret** → Name `APP_REPO_TOKEN` → Secret = the token → Add.
3. Website repo → **Add file → Create new file** → in the name box type `.github/workflows/notify-app.yml` → open the supplied file `WEB_REPO_extra\.github\workflows\notify-app.yml` in Notepad, copy everything, paste → **Commit changes**.
4. Test: change any website file and commit. Website repo → Actions shows *"Tell the app repository that the website changed"* ✔, and the app repo → Actions shows *Sync website into the app* starting.

### 5.4 Test the whole chain once (recommended)
**Test A (no code change):**
1. Install any 2.5.0 APK on the phone (Part 3 or 4).
2. App repo → Actions → *Build iFiNeX APK* → Run workflow. Wait for the green tick.
3. On the phone: ☰ → Settings → ⬆️ Check for updates → you should see **"Update available: v2.5.0 (built …)"** with a newer build time → Download → Install now → Install.
4. Check again: **"You have the newest version"**.

**Test B (real website change):** edit any text in a website file in `Squadsplit.github.io`, commit, then watch the app repo's Actions (*Sync website into the app* → *Build iFiNeX APK*), then check on the phone.

---

## 6 · The ONE-TIME uninstall (only if the phone has an app signed with another key)

**When:** Android refuses with *"App not installed"* / *"conflicts with an existing package"*, or the in-app dialog says *"signed with a DIFFERENT key"*. It means the app installed on the phone was built with some other key (older GitHub builds got a random key each time).

**Do it once:**
1. **Server mode** (data lives on the server): nothing to save.
   **Standalone (offline) mode:** open the old app → ☰ → **Settings → Backup & Restore** → create the backup file → save it to Downloads/Drive.
2. Phone → Settings → Apps → iFiNeX → **Uninstall**.
3. Install the newest APK from the GitHub Release (Part 4) — or your Android Studio APK.
4. Standalone: ☰ → Settings → Backup & Restore → **Restore** → pick the file.
5. **From now on** every APK from Android Studio and from GitHub installs over the previous one. Done for good.

How to be sure the key matches later: ☰ → Settings → ⬆️ Check for updates shows **"signed with key 3CF3 6A26 190E 9258…"**; the first 16 characters must equal the start of the SHA-256 printed by `SIGNING_KEY_show.bat` and in the Release text.

---

## 7 · New PC, lost key, changing the key

* **New PC:** install Node + Android Studio, copy your backup folder to `C:\Users\<new user>\ifinex-keys\` (same name). Everything works; **no new GitHub secrets needed**.
* **Key lost, no backup:** run `SIGNING_KEY_create.bat` again (new key), replace the two GitHub secrets, run the workflow with **accept_new_key** ticked (Actions → Run workflow → tick the box). Every phone needs the one-time uninstall (Part 6).
* **Never** change the secrets "to fix something" — a different key is exactly what breaks updates. The workflow refuses to publish a release signed with a different key than the previous release (you will see a red run saying *"Signing key changed"*).

---

## 8 · Troubleshooting

| Message / symptom | Meaning → fix |
|---|---|
| `Java "keytool" was not found` | Install Android Studio (it contains Java) and run again. Unusual location: `node tools\signing-key.js --keytool "C:\path\keytool.exe"`. |
| `'node' is not recognized` / "Node.js is not installed" | Install Node.js LTS from nodejs.org, close the window, double-click again. |
| Build message **NO SIGNING KEY FOUND - build stopped on purpose** | Part 1 not done on this PC. Double-click `SIGNING_KEY_create.bat`. If you did it on another PC: copy the `ifinex-keys` folder here (Part 7). |
| Build message *signing key found … password is missing* | `signing.properties` is damaged → restore the backup folder or re-create (Part 7). |
| GitHub run red: **No usable signing key** | The two secrets are missing/misspelled. Names must be exactly `IFX_KEYSTORE_B64` and `IFX_KEYSTORE_PASSWORD`. |
| GitHub run red: **Secret IFX_KEYSTORE_B64 is damaged** | Pasted partly. Paste the **whole** file content again (Ctrl+A in Notepad first). |
| GitHub run red: **Signing key does not open** | Password secret does not belong to the key secret. Re-create **both** from the same `ifinex-keys` folder. |
| GitHub run red: **Signing key changed** | Someone put another key into the secrets. Put the original back (backup), or follow Part 7 "changing the key". |
| Release job "Waiting for review" | You enabled *Required reviewers* on the environment `ifinex-release`. Click **Review deployments → Approve**, or remove the reviewer in repo Settings → Environments. Default: no approval needed. |
| Phone: *App not installed* | Part 6 (one-time uninstall). |
| In-app: *"signed with a DIFFERENT key"* | Part 6. The app protected you: it never offers an APK that Android would refuse. |
| In-app: *"No release found"* | The app repo has no Release yet (run Part 4) or it is not Public. |
| In-app: *"Updates are not set up in this build"* | Only possible with a very old APK. Install a build from this version. |
| In-app: *"GitHub is limiting requests"* | Wait an hour (GitHub allows 60 anonymous checks/hour/IP). |
| Website changed, but no new Release | Check app repo → Actions → *Sync website into the app*: (a) log says *"NOT syncing an older website"* → the website repo is older than the app's copy; upload the newer website files; (b) *"Website unchanged"* → the file you changed is not one the app uses (README, notes). (c) No run at all for >1 h → Actions are paused: repo → Actions → enable; it also pauses after 60 days of silence (the workflow keeps itself alive). |
| Run is red at `cap sync` / Gradle | Open the red step, copy the last 30 lines and send them to me. |
| PowerShell/`.bat` window flashes and closes | Open `cmd`, `cd` to the `tools` folder and run the `.bat` by name to see the message. |

---

## 9 · Honest limits (not testable on my side)
Tested here: the key tool (create/reuse/wrong password/half key/secret decode/sign test with `jarsigner`), the Gradle key lookup (no key → build stops, key from home folder, key from GitHub env, escape hatch), the Java updater compiled against stubs (build-number parsing), the update dialog and banner in a headless browser with a mocked plugin, the website→app sync script (junk folders excluded, hot-fix without version bump, refuses older website, refuses non-iFiNeX content), both workflow files (YAML + shell syntax).
**Not testable here:** a real Android build, a real GitHub Actions run, a real phone install, GitHub Release/API responses. If anything fails there, send me the exact red text — the guide's table above covers the expected ones.

**Known limitation:** the APK is a *debug-type* build (needed for the simple one-key flow). It is signed with your key and works as an update chain, but it is "debuggable". Moving to a *release* build is a small follow-up after the first successful update cycle.
