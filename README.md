# Git Repository Automation Scripts

This document explains two PowerShell scripts used for Git repository maintenance and sprint/release preparation.

## Scripts Covered

1. `git-pull.ps1`
2. `git-pull-tag-push.ps1`

---

# 1. git-pull.ps1

## Purpose

The `git-pull.ps1` script is used to pull the latest changes for multiple Git repositories stored under one base directory.

Instead of manually going into each repository and running `git pull --all`, this script automatically loops through the configured repositories and pulls the latest changes.

---

## What This Script Does

For each repository listed in the script, it performs the following actions:

1. Builds the full repository path.
2. Checks whether the repository folder exists.
3. If the folder exists, it moves into that repository.
4. Runs `git pull --all`.
5. If the folder does not exist, it prints an error message.
6. After all repositories are processed, it returns to the base directory.
7. Prints `Done!` after completion.

---

## Script Configuration

```powershell
$baseDir = "C:\Users\Documents\github"
```

This is the main folder where all Git repositories are stored.

Example:

```text
C:\Users\Documents\github
```

The repositories are listed here:

```powershell
$repos = @(
    "repo1",
    "repo2",
    "repo3"
)
```

Each name should match the folder name of the repository inside the base directory.

Example full paths:

```text
C:\Users\Documents\github\repo1
C:\Users\Documents\github\repo2
C:\Users\Documents\github\repo3
```

---

## Command Used by the Script

```powershell
git pull --all
```

This command pulls updates from all remotes configured in the repository.

Usually, this means it pulls the latest changes from `origin`.

---

## How to Run

Open PowerShell in the folder where the script is saved and run:

```powershell
.\git-pull.ps1
```

---

## Example Output

```text
========================================
Pulling: repo1
========================================

Already up to date.

========================================
Pulling: repo2
========================================

Updating files...

========================================
Pulling: repo3
========================================

Already up to date.

Done!
```

---

## Important Notes

* This script only pulls latest changes.
* It does not create branches.
* It does not create tags.
* It does not push anything to remote.
* It only works if the repository folders already exist locally.
* Git must be installed and available in the PowerShell terminal.
* You should have access to the remote repositories.

---

# 2. git-pull-tag-push.ps1

## Purpose

The `git-pull-tag-push.ps1` script is used for sprint/release Git automation across multiple repositories.

It is mainly used when a sprint is ending and a new sprint branch needs to be created from a tag.

This script can:

1. Pull the latest code.
2. Create a sprint-end tag.
3. Create a new sprint branch from that tag.
4. Push the new branch and tag to remote.

---

## Important Safety Feature

This script runs in preview mode by default.

That means if you run the script normally, it will not make any real changes.

It only shows what commands would be executed.

To actually apply the changes, you must run the script with the `-Execute` flag.

---

## Preview Mode

Run:

```powershell
.\git-pull-tag-push.ps1
```

In preview mode, the script only displays what it would do.

No Git changes are made.

Example:

```text
*** PREVIEW MODE - No changes will be made ***
*** Run with -Execute flag to apply changes ***
```

---

## Execute Mode

Run:

```powershell
.\git-pull-tag-push.ps1 -Execute
```

In execute mode, the script actually performs Git operations.

It will pull code, create tags, create branches, and push changes to remote.

---

## Script Parameters

```powershell
param(
    [switch]$Execute
)
```

The script accepts one optional parameter:

| Parameter  | Description                                      |
| ---------- | ------------------------------------------------ |
| `-Execute` | Runs the script for real and applies Git changes |

If `-Execute` is not passed, the script runs in preview mode.

---

## Main Configuration

```powershell
$tagName = "master-sprint-26.2.6-end"
$branchName = "sprint-testing/sprint-26.2.7"
$baseDir = "C:\Users"
```

---

## Configuration Explanation

### Tag Name

```powershell
$tagName = "master-sprint-26.2.6-end"
```

This is the Git tag that will be created.

Example:

```text
master-sprint-26.2.6-end
```

This usually represents the end of a sprint.

---

### Branch Name

```powershell
$branchName = "sprint-testing/sprint-26.2.7"
```

This is the new branch that will be created from the tag.

Example:

```text
sprint-testing/sprint-26.2.7
```

This usually represents the next sprint testing branch.

---

### Base Directory

```powershell
$baseDir = "C:\Users"
```

This is the main folder where all repositories are stored.

Example:

```text
C:\Users
```

---

### Repository List

```powershell
$repos = @(
    "repo1",
    "repo2",
    "repo3"
)
```

The script processes each repository listed here.

Each repository should exist as a folder inside the base directory.

Example full paths:

```text
C:\Users\repo1
C:\Users\repo2
C:\Users\repo3
```

---

## What This Script Does Step by Step

For each repository, the script performs the following steps:

1. Creates the full repository path.
2. Checks whether the repository folder exists.
3. Moves into the repository folder.
4. Detects the default branch.
5. Pulls the latest code.
6. Creates a tag from the default branch.
7. Creates a new branch from the tag.
8. Pushes all branches.
9. Pushes the new tag.
10. Shows current branch, recent tags, and recent branches.
11. Moves back to the base directory at the end.

---

## Default Branch Detection

The script tries to detect the default branch using:

```powershell
git symbolic-ref refs/remotes/origin/HEAD
```

If that does not return a value, it checks whether `origin/main` exists.

If `origin/main` exists, it uses:

```text
main
```

Otherwise, it uses:

```text
master
```

So the script can work with repositories that use either:

```text
main
```

or:

```text
master
```

as the default branch.

---

## Commands Run in Execute Mode

When the script is run with `-Execute`, it runs the following Git commands.

### 1. Pull Latest Code

```powershell
git pull --all
```

This pulls the latest changes from all configured remotes.

---

### 2. Create Tag

```powershell
git tag $tagName origin/$defaultBranch
```

Example:

```powershell
git tag master-sprint-26.2.6-end origin/master
```

or:

```powershell
git tag master-sprint-26.2.6-end origin/main
```

This creates a tag from the latest remote default branch.

---

### 3. Create Branch from Tag

```powershell
git branch $branchName $tagName
```

Example:

```powershell
git branch sprint-testing/sprint-26.2.7 master-sprint-26.2.6-end
```

This creates a new branch from the sprint-end tag.

---

### 4. Push All Branches

```powershell
git push --all
```

This pushes all local branches to the remote repository.

---

### 5. Push Tag

```powershell
git push origin $tagName
```

This pushes the newly created tag to the remote repository.

---

## Commands Shown in Preview Mode

In preview mode, the script only displays commands like below:

```text
[PREVIEW] Would run: git pull --all
[PREVIEW] Would run: git tag master-sprint-26.2.6-end origin/master
[PREVIEW] Would run: git branch sprint-testing/sprint-26.2.7 master-sprint-26.2.6-end
[PREVIEW] Would run: git push --all
[PREVIEW] Would run: git push origin master-sprint-26.2.6-end
```

No actual Git command is executed for creating tags, creating branches, or pushing.

---

## Example Workflow

### Step 1: Update Configuration

Before every sprint, update these values:

```powershell
$tagName = "master-sprint-26.2.6-end"
$branchName = "sprint-testing/sprint-26.2.7"
```

Example for next sprint:

```powershell
$tagName = "master-sprint-26.2.7-end"
$branchName = "sprint-testing/sprint-26.2.8"
```

---

### Step 2: Run Preview

```powershell
.\git-pull-tag-push.ps1
```

Check the output carefully.

Verify:

* Correct tag name
* Correct branch name
* Correct repositories
* Correct default branch
* No missing directories

---

### Step 3: Run Execute Mode

After verifying preview output, run:

```powershell
.\git-pull-tag-push.ps1 -Execute
```

This applies the changes.

---

## Example Output in Preview Mode

```text
*** PREVIEW MODE - No changes will be made ***
*** Run with -Execute flag to apply changes ***

Tag: master-sprint-26.2.6-end
Branch: sprint-testing/sprint-26.2.7
Repos: repo1, repo2, repo3

========================================
Processing: repo1
========================================
Default branch: master
[PREVIEW] Would run: git pull --all
[PREVIEW] Would run: git tag master-sprint-26.2.6-end origin/master
[PREVIEW] Would run: git branch sprint-testing/sprint-26.2.7 master-sprint-26.2.6-end
[PREVIEW] Would run: git push --all
[PREVIEW] Would run: git push origin master-sprint-26.2.6-end
```

---

## Example Output in Execute Mode

```text
*** EXECUTE MODE - Changes will be made ***

Tag: master-sprint-26.2.6-end
Branch: sprint-testing/sprint-26.2.7
Repos: repo1, repo2,, repo3

========================================
Processing: repo1
========================================
Default branch: master
Pulling...
Creating tag: master-sprint-26.2.6-end from origin/master
Creating branch: sprint-testing/sprint-26.2.7 from tag: master-sprint-26.2.6-end
Pushing all...
```

---

# Difference Between Both Scripts

| Feature                          | git-pull.ps1 | git-pull-tag-push.ps1 |
| -------------------------------- | ---------------- | --------------------- |
| Pull latest code                 | Yes              | Yes                   |
| Multiple repo support            | Yes              | Yes                   |
| Creates tag                      | No               | Yes                   |
| Creates branch                   | No               | Yes                   |
| Pushes branch                    | No               | Yes                   |
| Pushes tag                       | No               | Yes                   |
| Preview mode                     | No               | Yes                   |
| Execute flag needed              | No               | Yes                   |
| Used for daily update            | Yes              | No                    |
| Used for sprint/release activity | No               | Yes                   |

---

# When to Use Which Script

## Use `git-pull.ps1` When

* You only want to update local repositories.
* You do not want to create any branch or tag.
* You want a quick way to pull latest changes from multiple repos.

Example:

```powershell
.\git-pull.ps1
```

---

## Use `git-pull-tag-push.ps1` When

* Sprint is ending.
* You need to create a sprint-end tag.
* You need to create a new sprint branch.
* You need to push branch and tag to remote.
* You want to perform the same release action across multiple repos.

Example:

```powershell
.\git-pull-tag-push.ps1
.\git-pull-tag-push.ps1 -Execute
```

---

# Prerequisites

Before running these scripts, make sure:

1. Git is installed.
2. PowerShell is available.
3. You have access to all repositories.
4. The repositories are already cloned locally.
5. The repository folder names match the names in the `$repos` list.
6. You have permission to pull from and push to the remote repository.
7. Your Git authentication is already configured.
8. You have verified the correct sprint tag and branch names.

---

# Common Issues and Fixes

## Issue 1: Directory Not Found

Example:

```text
Directory not found: C:\Users\repo1
```

### Cause

The repository folder does not exist in the configured base directory.

### Fix

Check:

* Is the repo cloned locally?
* Is the folder name correct?
* Is `$baseDir` correct?
* Is the repo name correct in `$repos`?

---

## Issue 2: Git Command Not Recognized

Example:

```text
git : The term 'git' is not recognized
```

### Cause

Git is not installed or not added to the system PATH.

### Fix

Install Git and reopen PowerShell.

Check Git version:

```powershell
git --version
```

---

## Issue 3: Permission Denied During Push

Example:

```text
Permission denied
```

### Cause

You do not have permission to push to the remote repository, or Git authentication is not configured.

### Fix

Check your Git credentials and repository permissions.

---

## Issue 4: Tag Already Exists

Example:

```text
fatal: tag 'master-sprint-26.2.6-end' already exists
```

### Cause

The tag already exists locally.

### Fix

Check existing tags:

```powershell
git tag
```

Use a new tag name or delete the incorrect local tag only if required:

```powershell
git tag -d master-sprint-26.2.6-end
```

If the tag also exists remotely, coordinate with the team before deleting it.

---

## Issue 5: Branch Already Exists

Example:

```text
fatal: a branch named 'sprint-testing/sprint-26.2.7' already exists
```

### Cause

The branch already exists locally.

### Fix

Check branches:

```powershell
git branch
```

Check remote branches:

```powershell
git branch -a
```

Use a different branch name or confirm whether the existing branch should be used.

---

# Best Practices

1. Always run preview mode first for `git-pull-tag-push.ps1`.
2. Verify tag name before execution.
3. Verify branch name before execution.
4. Confirm repository list before execution.
5. Confirm default branch is correct.
6. Make sure working tree is clean before creating release tags.
7. Do not run execute mode without team approval.
8. Avoid deleting remote tags unless approved.
9. Keep the README updated when script behavior changes.
10. Use clear sprint naming conventions for tags and branches.

---

# Recommended Execution Order

For normal code update:

```powershell
.\git-pull.ps1
```

For sprint/release activity:

```powershell
.\git-pull-tag-push.ps1
```

Review preview output.

Then run:

```powershell
.\git-pull-tag-push.ps1 -Execute
```

---

# Final Summary

## git-pull.ps1

This script is a simple multi-repo pull script.

It only updates local repositories with the latest remote changes.

## git-pull-tag-push.ps1

This script is a sprint/release automation script.

It pulls the latest code, creates a sprint-end tag, creates a new sprint branch from that tag, and pushes the branch and tag to remote.

By default, it runs in preview mode to prevent accidental changes.
