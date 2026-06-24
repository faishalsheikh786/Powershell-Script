# git-pull-all.ps1
# Pulls latest changes for all repos in the github directory

$baseDir = "C:\Users\raiello1\Documents\github"

$repos = @(
    "repo1",
    "repo2",
    "repo3"
)

foreach ($repo in $repos) {
    $repoPath = Join-Path $baseDir $repo

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Pulling: $repo" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    if (Test-Path $repoPath) {
        Set-Location $repoPath
        git pull --all
    } else {
        Write-Host "Directory not found: $repoPath" -ForegroundColor Red
    }
}

# Return to base directory
Set-Location $baseDir
Write-Host "`nDone!" -ForegroundColor Green