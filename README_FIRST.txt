iFiNeX Web v8.9 & Mobile App v2.5.0 — Complete Project
Start with docs/ "... Signing Key & Auto-Update Guide.md" FIRST, then "... v8.9 ... Setup Guide.md". Give docs/"... Claude Reference.md" to Claude in any new chat.
web/                 the website (GitHub Pages: SquadSplit/Squadsplit.github.io)  — preview: cd web && python3 -m http.server 8140
mobile/              Capacitor project source (package.json, www, android, ios)
github-apk-repos/ifinex-app/   READY-TO-UPLOAD app repo (standard layout: works with GitHub Actions AND Android Studio)
sql/                 UPGRADE (run once on live), FULL no data / with data, Emergency Rollback, migrations, tests   (with-data file = real data: NEVER on GitHub)
tools/               make-apk-repos.sh, make-upload-packs.py, make-update-pack.py, upload-scripts/, bump-version.sh, signing-key tool (SIGNING_KEY_create.bat), web-repo-template/ (optional instant notify)
tests/ brand/ store/ docs/ archive_v8.6/
Android Studio: run  tools/build-android-local.bat  inside the repo folder (or: npm install && npx cap sync android in the folder that contains package.json), then File > Open > the android folder.
