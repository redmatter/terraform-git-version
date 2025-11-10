# Windows Compatibility Guide

This document provides comprehensive guidance for using the `terraform-git-version` module on Windows systems.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Installation Options](#installation-options)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [Frequently Asked Questions](#frequently-asked-questions)
- [Alternative: Using Python](#alternative-using-python)

## Quick Start

**TL;DR:** If you have Git installed on Windows (which you need for Terraform development anyway), this module will work without any additional setup.

```bash
# In Git Bash (comes with Git for Windows)
cd your-terraform-project
terraform init
terraform plan
```

## Prerequisites

### Required

| Software | Why It's Required | Typically Installed |
|----------|-------------------|---------------------|
| **Git for Windows** | Provides both the `git` command AND Git Bash shell | ✅ Yes - required for version control |
| **Terraform CLI** | Infrastructure as Code runtime | ✅ Yes - required for Terraform development |

### Not Required

| Software | Status |
|----------|--------|
| **Python** | ❌ Not needed (removed in v1.2.0+) |
| **WSL/WSL2** | ❌ Not needed (but works if you have it) |
| **Cygwin** | ❌ Not needed (but works if you have it) |
| **MinGW** | ❌ Not needed (but works if you have it) |

## Installation Options

### Option 1: Git Bash (Recommended)

Git Bash is automatically installed with Git for Windows and is the standard environment for Terraform development on Windows.

#### Step 1: Install Git for Windows (if not already installed)

1. Download Git for Windows from [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer with default settings
3. Git Bash will be installed automatically

#### Step 2: Verify Installation

Open **Git Bash** (not CMD or PowerShell) and run:

```bash
# Check Git is available
git --version
# Expected output: git version 2.x.x.windows.x

# Check Bash is available
bash --version
# Expected output: GNU bash, version 4.x.x or higher

# Check Terraform is available
terraform version
# Expected output: Terraform v1.x.x or higher
```

#### Step 3: Use the Module

```hcl
# main.tf
module "version" {
  source = "github.com/your-org/terraform-git-version"
}

output "version" {
  value = module.version.version
}
```

Run in Git Bash:

```bash
terraform init
terraform plan
```

**Result:** The module will execute `bash git_describe.sh` which works natively in Git Bash.

### Option 2: WSL (Windows Subsystem for Linux)

If you're using WSL for Terraform development, this module works without any changes.

```bash
# In WSL terminal
cd /mnt/c/your-terraform-project
terraform plan
```

**Note:** Make sure your Terraform project is accessible from WSL. Typically, Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc.

### Option 3: PowerShell with Git Bash

You can use PowerShell as your main terminal and still run Terraform with this module:

```powershell
# PowerShell will invoke Git Bash for the script execution
terraform plan
```

**How it works:** When Terraform executes `program = ["bash", "..."]`, Windows will find `bash.exe` from Git for Windows (added to PATH during installation).

## How It Works

### Execution Flow on Windows

1. **Terraform invokes the external data source:**
   ```hcl
   data "external" "version" {
     program = ["bash", "${path.module}/git_describe.sh", var.version_environment_variable]
   }
   ```

2. **Windows finds bash.exe:**
   - Git for Windows adds `C:\Program Files\Git\bin\` to your PATH
   - This includes `bash.exe`, `git.exe`, and other Unix tools

3. **Bash script executes:**
   - Reads environment variable (if specified)
   - Runs `git describe --tags --long --dirty --always`
   - Returns JSON: `{"version": "..."}`

4. **Terraform parses the JSON output**

### Why This Works Seamlessly

- ✅ **Git Bash is included** with Git for Windows (no extra install)
- ✅ **PATH is configured** automatically during Git installation
- ✅ **No credential issues** - uses the same Git credentials as your normal workflow
- ✅ **No WSL overhead** - runs natively on Windows via Git Bash

## Troubleshooting

### Error: "bash: command not found" or "program cannot be found"

**Cause:** Git for Windows is not installed or `bash.exe` is not in your PATH.

**Solution:**

1. Install Git for Windows: [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Verify PATH includes Git:
   ```powershell
   # In PowerShell
   $env:PATH -split ';' | Select-String 'Git'
   # Should show: C:\Program Files\Git\bin or similar
   ```
3. If not in PATH, add it:
   - Open "Environment Variables" in Windows
   - Add `C:\Program Files\Git\bin` to System PATH
   - Restart your terminal

### Error: "git: command not found"

**Cause:** Git is not installed or not in PATH.

**Solution:** Same as above - Git for Windows provides both `bash.exe` and `git.exe`.

### Error: Permission denied

**Cause:** The `git_describe.sh` script doesn't have execute permissions.

**Solution:**

```bash
# In Git Bash
chmod +x git_describe.sh
git add git_describe.sh
git commit -m "Fix permissions"
```

Or manually on Windows:
```powershell
# In PowerShell (if needed)
icacls git_describe.sh /grant Everyone:RX
```

### Module returns "UNKNOWN"

**Cause:** Git cannot find repository information or there are no tags.

**Solutions:**

1. **Check if you're in a Git repository:**
   ```bash
   git status
   # Should NOT show: "fatal: not a git repository"
   ```

2. **Check for Git tags:**
   ```bash
   git tag
   # If empty, create a tag:
   git tag -a v1.0.0 -m "Initial version"
   ```

3. **Use environment variable override:**
   ```hcl
   # In your terraform
   module "version" {
     source = "..."
     version_override = "1.0.0"  # Bypass Git entirely
   }
   ```

### Terminal: CMD vs PowerShell vs Git Bash

**Recommendation:** Use **Git Bash** for Terraform commands on Windows.

| Terminal | Works? | Notes |
|----------|--------|-------|
| **Git Bash** | ✅ Yes | Recommended - native bash environment |
| **PowerShell** | ✅ Yes | Works if Git Bash is in PATH |
| **CMD** | ✅ Yes | Works if Git Bash is in PATH |
| **WSL** | ✅ Yes | Full Linux environment |

## Frequently Asked Questions

### Q: Do I need to install WSL?

**A:** No. Git Bash (included with Git for Windows) is sufficient. WSL works but is not required.

### Q: Do I need Python?

**A:** No. As of version 1.2.0+, the Python dependency has been removed. The module now uses Bash exclusively.

### Q: What about AWS credentials or cloud provider setup?

**A:** This module doesn't interact with cloud providers at all. It only:
- Reads an optional environment variable
- Executes `git describe` to get version information
- Returns the result as JSON

Your AWS/Azure/GCP credentials are handled by Terraform itself, not by this module.

### Q: Will this work in CI/CD on Windows?

**A:** Yes! Most Windows CI/CD environments (GitHub Actions, GitLab CI, Azure DevOps, Jenkins) include Git and Git Bash by default.

**Example - GitHub Actions:**
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2

- name: Terraform Plan
  run: terraform plan
  # Works automatically - GitHub Actions Windows runners include Git Bash
```

### Q: What if I'm behind a corporate proxy?

**A:** Git proxy configuration works the same way:

```bash
# Configure Git proxy (affects both Git and Git Bash)
git config --global http.proxy http://proxy.example.com:8080
git config --global https.proxy http://proxy.example.com:8080
```

This module only uses local Git commands - no network access required (unless fetching remote tags).

### Q: Can I use this with Terraform Cloud/Enterprise on Windows?

**A:** Yes. During the `terraform plan` phase (typically run locally), the module will execute on your local Windows machine using Git Bash. The results are then sent to Terraform Cloud as part of the plan.

If you're running Terraform Cloud agents on Windows, ensure Git is installed on the agent machine.

## Alternative: Using Python

If you prefer to use Python instead of Bash (for example, if you already have Python standardized in your environment), the legacy Python script is still available:

### Option: Keep Python Script

1. **Revert main.tf to use Python:**
   ```hcl
   data "external" "version" {
     count   = var.version_override == null ? 1 : 0
     program = ["python", "${path.module}/git_describe.py", var.version_environment_variable]
   }
   ```

2. **Ensure Python is installed and in PATH:**
   ```powershell
   # Check Python availability
   python --version
   # or
   python3 --version
   ```

3. **Install Python if needed:**
   - Download from [https://www.python.org/downloads/](https://www.python.org/downloads/)
   - During installation, check "Add Python to PATH"

### Comparison: Bash vs Python

| Aspect | Bash (Default) | Python (Alternative) |
|--------|----------------|---------------------|
| **Installation** | Included with Git | Separate installation required |
| **Configuration** | Automatic (via Git setup) | Must add to PATH manually |
| **Dependencies** | Git only | Git + Python |
| **Windows Support** | Via Git Bash (included) | Via Python installer |
| **Compatibility** | bash 3.2+ (2007+) | Python 2.7+ or 3.x |
| **Maintenance** | Active | Legacy (deprecated) |

**Recommendation:** Unless you have a specific requirement for Python, use the default Bash implementation. It has fewer dependencies and is easier to set up on Windows.

## Getting Help

If you encounter issues not covered in this guide:

1. **Check Git installation:**
   ```bash
   git --version
   bash --version
   ```

2. **Verify module files exist:**
   ```bash
   ls -la git_describe.sh
   # Should show: -rwxr-xr-x ... git_describe.sh
   ```

3. **Test the script directly:**
   ```bash
   bash git_describe.sh
   # Should output: {"version": "..."}
   ```

4. **Check Terraform debug output:**
   ```bash
   TF_LOG=DEBUG terraform plan 2>&1 | grep -i external
   ```

5. **Report issues:**
   - For module issues: [GitHub Issues](https://github.com/your-org/terraform-git-version/issues)
   - For Git Bash issues: [Git for Windows Issues](https://github.com/git-for-windows/git/issues)

## Summary

**The key takeaway:** If you're doing Terraform development on Windows, you already have everything you need:

✅ Git for Windows (required for version control) → includes Git Bash
✅ Terraform CLI (required for infrastructure as code)
❌ No additional dependencies needed

This module leverages tools you already have installed, making it one of the most Windows-friendly Terraform modules available.
