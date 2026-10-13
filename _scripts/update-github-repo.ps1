# iFiNeX - push ONLY the updated files (or convert an old-layout repo) to an EXISTING GitHub repo. Windows PowerShell. Right-click -> Run with PowerShell.
$dir = (Read-Host "Folder with the files (drag the folder into this window, press Enter)").Trim('"')
$url = (Read-Host "Your EXISTING GitHub repo URL (https://github.com/YOU/REPO.git)").Trim()
$rep = Read-Host "Replace EVERYTHING in the repo with this folder? (type yes ONLY when converting the old v8.6 layout with the full 'ifinex-app' folder; otherwise just press Enter)"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "Install Git first: https://git-scm.com/downloads  (then run this again)"; pause; exit }
$t = Join-Path $env:TEMP ("ifx_" + [guid]::NewGuid().ToString("N")); New-Item -ItemType Directory $t | Out-Null
git clone $url "$t\r"; if ($LASTEXITCODE -ne 0) { Write-Host "Clone failed - check the address and sign in."; pause; exit }
Set-Location "$t\r"
if (-not (git config user.name))  { git config user.name "iFiNeX" }
if (-not (git config user.email)) { git config user.email "ifinex@users.noreply.github.com" }
$br = (git rev-parse --abbrev-ref HEAD); if (-not $br) { $br = "main" }
if ($rep -eq "yes") { git rm -rq --ignore-unmatch . ; Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force }
Copy-Item -Path (Join-Path $dir "*") -Destination . -Recurse -Force
Get-ChildItem -Force -Path $dir | Where-Object { $_.Name.StartsWith(".") -and $_.Name -ne ".git" } | ForEach-Object { Copy-Item $_.FullName -Destination . -Recurse -Force }
Remove-Item CHANGED_FILES.txt, README_UPDATE.md -ErrorAction SilentlyContinue
git add -A
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host "Nothing changed - repo already up to date."; pause; exit }
git commit -m "iFiNeX update" | Out-Null
git push origin $br
Write-Host "`nDONE. Open $url - the changes are there."; pause
