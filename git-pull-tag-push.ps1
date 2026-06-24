# git-pull-tag-push.ps1
# Pulls latest, creates tag, creates branch from tag, and pushes all
# Preview mode is ON by default - use -Execute to run for real

param(
    [switch]$Execute
)

# ============================================
# CONFIGURATION - Update these each sprint
# ============================================
$tagName = "master-sprint-26.2.6-end"
$branchName = "sprint-testing/sprint-26.2.7"
$baseDir = "C:\Users\jsyed2\TFcode"

$repos = @(
    "mynorthwell-web",
    "NWH-dpx-messaging-service",
    "northwell-dpx-service"
)

# ============================================
# SCRIPT - No changes needed below
# ============================================

if ($Execute) {
    Write-Host "`n*** EXECUTE MODE - Changes will be made ***" -ForegroundColor Red
} else {
    Write-Host "`n*** PREVIEW MODE - No changes will be made ***" -ForegroundColor Magenta
    Write-Host "*** Run with -Execute flag to apply changes ***" -ForegroundColor Magenta
}

Write-Host "`nTag: $tagName" -ForegroundColor Yellow
Write-Host "Branch: $branchName" -ForegroundColor Yellow
Write-Host "Repos: $($repos -join ', ')" -ForegroundColor Yellow

foreach ($repo in $repos) {
    $repoPath = Join-Path $baseDir $repo

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $repo" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    if (Test-Path $repoPath) {
        Set-Location $repoPath

        # Auto-detect default branch
        $defaultBranch = git symbolic-ref refs/remotes/origin/HEAD 2>$null | ForEach-Object {
            $_ -replace 'refs/remotes/origin/', ''
        }

        if (-not $defaultBranch) {
            $mainExists = git show-ref --verify --quiet refs/remotes/origin/main 2>$null

            if ($LASTEXITCODE -eq 0) {
                $defaultBranch = "main"
            } else {
                $defaultBranch = "master"
            }
        }

        Write-Host "Default branch: $defaultBranch" -ForegroundColor Gray

        if ($Execute) {
            Write-Host "Pulling..." -ForegroundColor Gray
            git pull --all

            Write-Host "Creating tag: $tagName from origin/$defaultBranch" -ForegroundColor Gray
            git tag $tagName origin/$defaultBranch

            Write-Host "Creating branch: $branchName from tag: $tagName" -ForegroundColor Gray
            git branch $branchName $tagName

            Write-Host "Pushing all..." -ForegroundColor Gray
            git push --all
            git push origin $tagName
        } else {
            Write-Host "[PREVIEW] Would run: git pull --all" -ForegroundColor Magenta
            Write-Host "[PREVIEW] Would run: git tag $tagName origin/$defaultBranch" -ForegroundColor Magenta
            Write-Host "[PREVIEW] Would run: git branch $branchName $tagName" -ForegroundColor Magenta
            Write-Host "[PREVIEW] Would run: git push --all" -ForegroundColor Magenta
            Write-Host "[PREVIEW] Would run: git push origin $tagName" -ForegroundColor Magenta
        }

        Write-Host "`nCurrent branch:" -ForegroundColor Gray
        git branch --show-current

        Write-Host "Recent tags:" -ForegroundColor Gray
        git tag --sort=-creatordate | Select-Object -First 5

        Write-Host "Recent branches:" -ForegroundColor Gray
        git branch -a --sort=-committerdate | Select-Object -First 5
    } else {
        Write-Host "Directory not found: $repoPath" -ForegroundColor Red
    }
}

Set-Location $baseDir

if ($Execute) {
    Write-Host "`nDone! All changes applied." -ForegroundColor Green
} else {
    Write-Host "`n*** PREVIEW COMPLETE - No changes were made ***" -ForegroundColor Magenta
    Write-Host "*** Run with -Execute flag to apply changes ***" -ForegroundColor Magenta
}