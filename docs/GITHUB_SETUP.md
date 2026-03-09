# GitHub Repository Setup Guide

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Fill in repository details:
   - **Repository name**: `dark-ascension`
   - **Description**: "A 2D turn-based auto-battler dungeon crawler with necromancer shadow extraction mechanics"
   - **Visibility**: 
     - ✅ Public (if you want community/portfolio)
     - ⬜ Private (if keeping it private for now)
   - **Initialize repository**: 
     - ⬜ Do NOT add README (we already have one)
     - ⬜ Do NOT add .gitignore (we already have one)
     - ⬜ Do NOT add license yet
3. Click "Create repository"

## Step 2: Initialize Local Git Repository

Open PowerShell in your project directory and run:

```powershell
# Navigate to project directory
cd D:\Development\GameIdea

# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "chore: initial project setup with documentation"

# Rename default branch to main (if needed)
git branch -M main
```

## Step 3: Connect to GitHub

Replace `YOUR_USERNAME` with your GitHub username:

```powershell
# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/dark-ascension.git

# Push to GitHub
git push -u origin main
```

## Step 4: Set Up Branch Protection (Optional but Recommended)

On GitHub:
1. Go to repository Settings → Branches
2. Add branch protection rule for `main`:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass
   - ✅ Include administrators

## Step 5: Create Development Branch

```powershell
# Create and switch to develop branch
git checkout -b develop

# Push develop branch to GitHub
git push -u origin develop
```

## Step 6: Add Collaborators (If Team Project)

On GitHub:
1. Go to Settings → Collaborators
2. Click "Add people"
3. Enter GitHub usernames

## Recommended GitHub Settings

### Repository Settings

**General:**
- ✅ Allow merge commits
- ✅ Allow squash merging
- ⬜ Allow rebase merging

**Issues:**
- ✅ Enable issues
- Add labels: `bug`, `enhancement`, `documentation`, `asset`, `good first issue`

**Projects:**
- Create project board with columns:
  - 📋 Backlog
  - 🎯 To Do
  - 🚧 In Progress
  - ✅ Done

### Add Topics (for discoverability)

Add these topics to your repository:
- `godot`
- `godot-engine`
- `game-development`
- `2d-game`
- `auto-battler`
- `dungeon-crawler`
- `indie-game`

## Daily Workflow

### Starting Work

```powershell
# Switch to develop branch
git checkout develop

# Pull latest changes
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name
```

### During Work

```powershell
# Check status
git status

# Add changes
git add .

# Commit with descriptive message
git commit -m "feat(combat): add shadow positioning system"

# Push to GitHub
git push origin feature/your-feature-name
```

### Finishing Work

1. Push final changes
2. Go to GitHub and create Pull Request
3. Merge to `develop` after review
4. Delete feature branch

### Periodic Merges to Main

When `develop` is stable:

```powershell
git checkout main
git merge develop
git push origin main
git tag -a v0.1.0 -m "Alpha release"
git push origin v0.1.0
```

## Useful Git Commands

```powershell
# View commit history
git log --oneline --graph

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard local changes
git checkout -- .

# View differences
git diff

# Switch branches
git checkout branch-name

# Delete local branch
git branch -d branch-name

# Delete remote branch
git push origin --delete branch-name
```

## Troubleshooting

### Authentication Issues

If prompted for credentials, use Personal Access Token:
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scopes: `repo`, `workflow`
4. Use token as password when pushing

### Large Files

If you accidentally commit large files (>100MB):
```powershell
# Remove from git but keep locally
git rm --cached large-file.psd

# Add to .gitignore
echo "*.psd" >> .gitignore

# Commit the change
git commit -m "chore: remove large files from tracking"
```

## GitHub Features to Use

### Issues
- Track bugs and feature requests
- Use templates for consistency
- Link commits to issues with `#issue-number`

### Projects
- Kanban board for task management
- Automate card movement with GitHub Actions

### Releases
- Tag stable versions
- Attach compiled game builds
- Write release notes

### Wiki (Optional)
- Extended documentation
- Game lore and world-building
- Development diary

## Next Steps

After setup:
1. ✅ Create initial commit
2. ✅ Push to GitHub
3. ✅ Create develop branch
4. Create first issue: "Set up Godot project structure"
5. Start development!

## Security Notes

**Never commit:**
- API keys or secrets
- Personal information
- Large binary files (use Git LFS if needed)
- Compiled builds (use Releases instead)

**Already in .gitignore:**
- Godot import cache
- Build artifacts
- System files
- Temporary files
