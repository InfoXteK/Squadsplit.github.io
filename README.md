# iFiNeX · Squad Split — Website (GitHub Pages)

Bills, expenses, plans, budget and Squad Split in one static web app. Backend = **Supabase**. Hosting = **GitHub Pages**.
The Android app is built from a second repository and re-uses this website.

| What | Official value |
|---|---|
| Live website | https://squadsplit.github.io |
| This repo (website) | https://github.com/SquadSplit/Squadsplit.github.io |
| App repo (Android/iOS wrapper, APK releases) | https://github.com/SquadSplit/iFiNeX-Mobile |

---

## Forking / cloning? Change these things (and only these)

| # | What | File | What to change |
|---|---|---|---|
| 1 | **Your website address** | `ifinex-config.json` → `"site"` | `https://YOURUSER.github.io` (or your custom domain) |
| 2 | **Your Supabase URL** | `ifinex-config.json` → `"supabaseUrl"` | `https://YOURPROJECT.supabase.co` (Supabase → Project Settings → API) |
| 3 | **Your Supabase key** | `ifinex-config.json` → `"supabaseKey"` | the **anon / publishable** key. **NEVER the `service_role` key** — that one is a master key and must never be in a public repo |
| 4 | App name shown in the UI | `ifinex-config.json` → `"name"` | any text |
| 5 | Web-push key (optional) | `bill-tracker.html` → `const VAPID_PUBLIC_KEY = '…'` (search for it, around line 1123) | your own VAPID **public** key |
| 6 | Link to the Android app repo (optional instant sync) | `.github/workflows/notify-app.yml` → `--repo SquadSplit/iFiNeX-Mobile` | `--repo YOURUSER/YOUR-APP-REPO` |

`ifinex-config.json` looks like this:

```json
{
  "format": "ifinex-server",
  "version": 1,
  "name": "My Hub",
  "site": "https://YOURUSER.github.io",
  "supabaseUrl": "https://YOURPROJECT.supabase.co",
  "supabaseKey": "YOUR-ANON-OR-PUBLISHABLE-KEY"
}
```

The website reads this file when it starts. Nothing else in the HTML/JS needs the Supabase address.

### Setup in 8 steps
1. **Fork** this repo (or upload the files to a new **public** repo named `YOURUSER.github.io`).
2. Edit `ifinex-config.json` (table above, rows 1–4). Commit.
3. Repo → **Settings → Pages** → Source: *Deploy from a branch* → `main` / `(root)` → Save. Wait ~1 minute.
4. Create a Supabase project. **SQL Editor** → run `Database FULL (no data).sql` (from the project's `sql/` folder). Never publish a *with data* SQL file on GitHub.
5. Create the first admin: run the *SELF-HOST first-admin* SQL (same folder) with your e-mail.
6. Supabase → **Authentication → URL Configuration**: *Site URL* = your website address. **Authentication → Email Templates → Magic Link / Confirm**: the mail must contain the 6-digit code `{{ .Token }}` (login is by e-mail code).
7. Supabase → **Authentication → SMTP**: set your own SMTP, otherwise the free mail limit is very low.
8. Open your website, log in with the admin e-mail.

### Optional: web push
Generate a VAPID key pair, put the **public** key in `bill-tracker.html` (row 5), and set these **Edge Function secrets** in Supabase: `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_CONTACT_EMAIL`, `CRON_SECRET`. Deploy the `send-push` function. Never commit the private key.

### Optional: instant app sync
Without it the app repo checks this website every 30 minutes by itself. For instant sync: copy `.github/workflows/notify-app.yml` (row 6), then create a fine-grained token (only your app repo, *Actions: Read and write*) and save it here as the secret `APP_REPO_TOKEN`.

### Security rules
* Only the **anon/publishable** key belongs in this repo. Security is enforced by Supabase Row Level Security, not by hiding the key.
* Turn on **2FA** for your GitHub account and **branch protection** for `main`: whoever can push here can ship code to every phone.
