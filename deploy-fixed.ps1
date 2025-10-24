# ============================================================================
# Elite MT5 EA Showcase - Cloudflare Pages Deployment Script
# ============================================================================
# This script automates the deployment of the presentation to Cloudflare Pages
# via GitHub repository integration.
#
# Prerequisites:
# - Git must be installed
# - GitHub account
# - Cloudflare account (free tier works)
#
# Usage: .\deploy.ps1
# ============================================================================

param(
    [string]$GitHubUsername = "",
    [string]$RepoName = "ea-showcase",
    [switch]$Help
)

# Color functions
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Info { Write-ColorOutput Cyan $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }

# Display header
function Show-Header {
    Clear-Host
    Write-ColorOutput Magenta @"

===============================================================
                                                               
        Elite MT5 EA Showcase - Deployment Script        
                                                               
           Automated GitHub & Cloudflare Pages Setup          
                                                               
===============================================================

"@
}

# Display help
function Show-Help {
    Write-Info @"
USAGE:
    .\deploy.ps1 [-GitHubUsername <username>] [-RepoName <name>] [-Help]

PARAMETERS:
    -GitHubUsername    Your GitHub username (optional, will prompt if not provided)
    -RepoName          Repository name (default: ea-showcase)
    -Help              Display this help message

EXAMPLES:
    .\deploy.ps1
    .\deploy.ps1 -GitHubUsername "johndoe"
    .\deploy.ps1 -GitHubUsername "johndoe" -RepoName "my-ea-showcase"

WHAT THIS SCRIPT DOES:
    1. Checks prerequisites (Git installation)
    2. Initializes Git repository
    3. Creates .gitignore file
    4. Commits all files
    5. Creates GitHub repository (if GitHub CLI available)
    6. Pushes code to GitHub
    7. Provides Cloudflare Pages setup instructions

REQUIREMENTS:
    - Git installed (https://git-scm.com/download/win)
    - GitHub account
    - Cloudflare account (free: https://dash.cloudflare.com/sign-up)

OPTIONAL:
    - GitHub CLI (gh) for automated repo creation
      Install: winget install --id GitHub.cli

"@
    exit 0
}

# Check if Git is installed
function Test-GitInstalled {
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-Success "[OK] Git is installed: $gitVersion"
            return $true
        }
    }
    catch {
        Write-Error "[ERROR] Git is not installed!"
        Write-Warning "`nPlease install Git from: https://git-scm.com/download/win"
        Write-Warning "After installation, restart PowerShell and run this script again."
        return $false
    }
}

# Check if GitHub CLI is installed
function Test-GitHubCLI {
    try {
        $ghVersion = gh --version 2>$null
        if ($ghVersion) {
            Write-Success "[OK] GitHub CLI is installed"
            return $true
        }
    }
    catch {
        Write-Warning "[INFO] GitHub CLI not found (optional)"
        Write-Info "   To install: winget install --id GitHub.cli"
        return $false
    }
}

# Initialize Git repository
function Initialize-GitRepo {
    Write-Info "`n[STEP] Initializing Git repository..."
    
    if (Test-Path ".git") {
        Write-Warning "Git repository already exists. Skipping initialization."
        return $true
    }
    
    try {
        git init | Out-Null
        git branch -M main | Out-Null
        Write-Success "[OK] Git repository initialized"
        return $true
    }
    catch {
        Write-Error "[ERROR] Failed to initialize Git repository: $_"
        return $false
    }
}

# Create .gitignore
function New-GitIgnore {
    Write-Info "`n[STEP] Creating .gitignore file..."
    
    $gitignoreContent = @"
# OS Files
.DS_Store
Thumbs.db
desktop.ini

# Editor Files
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
*.log

# Temporary Files
*.tmp
*.temp

# Environment Files
.env
.env.local

# Build Files (if any)
/dist/
/build/

# Node Modules (if any)
node_modules/

# Backup Files
*.bak
*.backup
"@
    
    try {
        $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
        Write-Success "[OK] .gitignore created"
        return $true
    }
    catch {
        Write-Error "[ERROR] Failed to create .gitignore: $_"
        return $false
    }
}

# Stage and commit files
function Invoke-GitCommit {
    Write-Info "`n[STEP] Staging and committing files..."
    
    try {
        git add . | Out-Null
        git commit -m "Initial commit: Elite MT5 EA Analysis Showcase" | Out-Null
        Write-Success "[OK] Files committed successfully"
        return $true
    }
    catch {
        Write-Error "[ERROR] Failed to commit files: $_"
        return $false
    }
}

# Create GitHub repository (if GitHub CLI available)
function New-GitHubRepo {
    param([string]$Username, [string]$RepoName)
    
    Write-Info "`n[STEP] Creating GitHub repository..."
    
    if (Test-GitHubCLI) {
        try {
            Write-Info "Creating repository: $RepoName"
            gh repo create $RepoName --public --source=. --remote=origin --push 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "[OK] Repository created and code pushed!"
                Write-Info "   Repository URL: https://github.com/$Username/$RepoName"
                return $true
            }
            else {
                Write-Warning "GitHub CLI command failed. Will use manual method."
                return $false
            }
        }
        catch {
            Write-Warning "Could not create repository automatically: $_"
            return $false
        }
    }
    
    return $false
}

# Manual GitHub setup instructions
function Show-ManualGitHubInstructions {
    param([string]$Username, [string]$RepoName)
    
    Write-Info "`n========================================="
    Write-Info "Manual GitHub Setup Instructions:"
    Write-Info "========================================="
    Write-Info "`n1. Go to: https://github.com/new"
    Write-Info "2. Repository name: $RepoName"
    Write-Info "3. Set to Public"
    Write-Info "4. Do NOT initialize with README"
    Write-Info "5. Click 'Create repository'"
    Write-Info "`n6. Then run these commands:"
    Write-ColorOutput Yellow @"

    git remote add origin https://github.com/$Username/$RepoName.git
    git push -u origin main

"@
}

# Cloudflare Pages setup instructions
function Show-CloudflareInstructions {
    param([string]$Username, [string]$RepoName)
    
    Write-Info "`n========================================="
    Write-Info "Cloudflare Pages Deployment Instructions:"
    Write-Info "========================================="
    
    Write-ColorOutput Cyan @"

1. LOGIN TO CLOUDFLARE:
   Go to: https://dash.cloudflare.com
   Navigate to 'Pages' section

2. CREATE NEW PROJECT:
   Click 'Create a project'
   Click 'Connect to Git'

3. CONNECT GITHUB:
   Authorize Cloudflare to access GitHub
   Select repository: $RepoName

4. CONFIGURE BUILD SETTINGS:
   Production branch:        main
   Build command:            (leave empty)
   Build output directory:   /
   Root directory:           /

5. DEPLOY:
   Click 'Save and Deploy'
   Wait 1-2 minutes
   Your site will be live at: https://$RepoName.pages.dev

6. OPTIONAL - CUSTOM DOMAIN:
   In project settings, go to 'Custom domains'
   Add your domain (e.g., ea-analysis.yourdomain.com)
   Follow DNS configuration instructions

"@
}

# Success message
function Show-SuccessMessage {
    param([string]$RepoName)
    
    Write-Success "`n========================================="
    Write-Success "DEPLOYMENT PREPARATION COMPLETE!"
    Write-Success "========================================="
    Write-Info "`nYour project is ready to deploy to Cloudflare Pages!"
    Write-Info "`nNext steps:"
    Write-Info "  1. Complete the GitHub repository setup (if not done automatically)"
    Write-Info "  2. Follow the Cloudflare Pages instructions above"
    Write-Info "  3. Your presentation will be live in minutes!"
    Write-Info "`nPresentation password: eliteEA2024"
    Write-Info "`nFor detailed documentation, see README.md"
    Write-Info "=========================================`n"
}

# Main execution
function Main {
    Show-Header
    
    if ($Help) {
        Show-Help
    }
    
    # Get GitHub username if not provided
    if (-not $GitHubUsername) {
        Write-Info "Please enter your GitHub username:"
        $GitHubUsername = Read-Host "GitHub Username"
        
        if (-not $GitHubUsername) {
            Write-Error "GitHub username is required. Exiting."
            exit 1
        }
    }
    
    Write-Info "`nConfiguration:"
    Write-Info "  GitHub Username: $GitHubUsername"
    Write-Info "  Repository Name: $RepoName"
    Write-Info "`nStarting deployment process..."
    
    # Check prerequisites
    if (-not (Test-GitInstalled)) {
        exit 1
    }
    
    # Initialize repository
    if (-not (Initialize-GitRepo)) {
        exit 1
    }
    
    # Create .gitignore
    New-GitIgnore | Out-Null
    
    # Commit files
    if (-not (Invoke-GitCommit)) {
        exit 1
    }
    
    # Try to create GitHub repo automatically
    $autoCreated = New-GitHubRepo -Username $GitHubUsername -RepoName $RepoName
    
    # If auto-creation failed, show manual instructions
    if (-not $autoCreated) {
        Show-ManualGitHubInstructions -Username $GitHubUsername -RepoName $RepoName
        
        Write-Info "`nPress any key after you have pushed to GitHub..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    
    # Show Cloudflare instructions
    Show-CloudflareInstructions -Username $GitHubUsername -RepoName $RepoName
    
    # Success message
    Show-SuccessMessage -RepoName $RepoName
}

# Run the script
Main
