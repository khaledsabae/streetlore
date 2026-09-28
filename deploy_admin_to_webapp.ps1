#!/usr/bin/env pwsh
# Deploys the freshly-built streetlore_admin web build into the
# streetlore-web-app/admin/ subtree, then commits + pushes the result.
#
# Source: D:\codes\streetlore_admin\build\web\  (built locally)
# Target: D:\codes\streetlore-web-app\admin\      (deployed repo on GitHub)
#
# Run this from an elevated / same-user PowerShell so the Git push can use
# the stored PAT in Windows Credential Manager (git:https://github.com).

$ErrorActionPreference = 'Stop'

$src = 'D:\codes\streetlore_admin\build\web'
$dst = 'D:\codes\streetlore-web-app\admin'

if (-not (Test-Path $src)) {
    throw "Source build not found at $src. Run 'flutter build web --release --base-href /streetlore-web-app/admin/' first."
}
if (-not (Test-Path $dst)) {
    throw "Target directory not found at $dst. Clone streetlore-web-app there first."
}

Write-Host "=== Wiping old admin/ contents (except .git) ==="
Get-ChildItem -LiteralPath $dst -Force | Where-Object { $_.Name -ne '.git' } | ForEach-Object {
    Write-Host "  removing $($_.Name)"
    Remove-Item -LiteralPath $_.FullName -Recurse -Force
}

Write-Host "=== Copying fresh build -> $dst ==="
Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force

Write-Host "=== Git add + commit + push ==="
# Switch to the parent repo (D:\codes\streetlore-web-app), NOT into admin/
# itself, because admin/ sometimes has its own .git/ (gh-pages worktree
# leftover from the older deploy_ghpages.ps1 script).
$repoRoot = Split-Path -Parent $dst
Set-Location $repoRoot
git rev-parse --is-inside-work-tree 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "$repoRoot is not a git work tree"
}
# Avoid CRLF warnings breaking the script under $ErrorActionPreference='Stop'
git config core.autocrlf false 2>&1 | Out-Null
git add -A 2>&1 | Out-Null
$diff = git status --porcelain
if (-not $diff) {
    Write-Host "Nothing to commit (working tree clean)."
    exit 0
}
$msg = "deploy: admin web v1.0.43-sync - Best Time / AR-EN split / base-href fix`n`nBuilt from streetlore_admin @ ff922a9 (admin: fix base-href placeholder + add gh-pages deploy script)`nBase-href: /streetlore-web-app/admin/"
git commit -m $msg 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "git commit failed (exit $LASTEXITCODE)"
}
git push origin main --force-with-lease 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "git push failed (exit $LASTEXITCODE)"
}

Write-Host "=== Done ==="
Write-Host "Live URL: https://mohamedsabae50-prog.github.io/streetlore-web-app/admin/"
git log -1 --pretty=format:'%h %s' | Write-Host