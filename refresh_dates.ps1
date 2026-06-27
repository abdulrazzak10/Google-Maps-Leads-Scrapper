# refresh_dates.ps1
#
# This script "touches" every tracked file in the current git repo by adding
# a small harmless comment/blank line at the end of each file. This makes git
# see them as changed, so after you commit + push, GitHub will show today's
# date for all of them instead of old historical dates.
#
# Run this from INSIDE the repo folder you want to refresh.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\refresh_dates.ps1

Write-Host "Finding all git-tracked files in this repo..."

# Get list of files tracked by git (respects .gitignore automatically)
$files = git ls-files

if (-not $files) {
    Write-Host "No tracked files found. Are you inside a git repo folder?"
    exit
}

Write-Host "Found $($files.Count) tracked files. Touching each one..."

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        continue
    }

    $ext = [System.IO.Path]::GetExtension($file).ToLower()

    # Choose a comment style appropriate to the file type so we don't break anything
    $comment = $null
    switch ($ext) {
        ".py"   { $comment = "# updated" }
        ".md"   { $comment = "<!-- updated -->" }
        ".ps1"  { $comment = "# updated" }
        ".txt"  { $comment = "" }   # just ensure trailing newline, no visible text
        ".gitignore" { $comment = "" }
        default { $comment = "" }
    }

    try {
        Add-Content -Path $file -Value $comment -ErrorAction Stop
        Write-Host "  Touched: $file"
    } catch {
        Write-Host "  Skipped (binary or locked): $file"
    }
}

Write-Host ""
Write-Host "Done touching files."
Write-Host ""
Write-Host "Now run these commands to commit and push:"
Write-Host "  git add ."
Write-Host "  git commit -m `"Refresh project files`""
Write-Host "  git push"
