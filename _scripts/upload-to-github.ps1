# iFiNeX — push a WHOLE folder to GitHub in ONE shot (no 100-file limit, hidden files included). Windows PowerShell.
# Right-click -> Run with PowerShell, then answer the two questions.
$dir = Read-Host "Folder to upload (drag the folder into this window, press Enter)"
$url = Read-Host "Your EMPTY GitHub repo URL (https://github.com/YOU/REPO.git)"
$dir = $dir.Trim('"')
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Host "Install Git first: https://git-scm.com/downloads  (then run this again)"; pause; exit }
Set-Location $dir
if (-not (Test-Path .git)) { git init -b main | Out-Null }
if (-not (git config user.name))  { git config user.name "iFiNeX" }
if (-not (git config user.email)) { git config user.email "ifinex@users.noreply.github.com" }
git remote remove origin 2>$null; git remote add origin $url
git add -A; git commit -m "iFiNeX upload" 2>$null | Out-Null
git push -u origin main
Write-Host "`nDONE. Open $url - all files are there."; pause
