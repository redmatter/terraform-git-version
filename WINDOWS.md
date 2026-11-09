# Windows Compatibility Guide

**TL;DR:** Got Git? You're good to go! 🎉

If you have Git for Windows installed (which you need for Terraform anyway), this module works immediately. No extra setup, no Python, no WSL required.

```bash
# In Git Bash (comes with Git for Windows)
cd your-terraform-project
terraform plan
```

**That's it.** Read on if you need troubleshooting or want to understand why this works.

---

## What You Need

✅ **Git for Windows** - You already have this (required for Terraform development)
✅ **Terraform CLI** - You already have this
❌ **Python** - Not needed anymore!
❌ **WSL** - Not needed (though it works if you have it)
❌ **Cygwin/MinGW** - Not needed (though they work too)

<details>
<summary>📖 Why does this work? (click to expand)</summary>

When you install Git for Windows, you automatically get:

- `git.exe` - the Git command
- `bash.exe` - the Bash shell
- Git Bash terminal - a Unix-like environment

This module needs both `git` and `bash` commands. Since Git for Windows bundles them together, you're already set! No Python installation, no WSL setup, no extra steps.

</details>

---

## How to Use It

### Step 1: Open Git Bash

Find "Git Bash" in your Start Menu and open it. (It came with Git for Windows)

### Step 2: Run Terraform

```bash
cd your-terraform-project
terraform plan
```

**Done!** The module works automatically.

<details>
<summary>🔧 First time setup? (click if you don't have Git yet)</summary>

**Install Git for Windows:**

1. Download from [git-scm.com/download/win](https://git-scm.com/download/win)
2. Run installer with default settings
3. Git Bash is installed automatically

**Verify it works:**

```bash
# Open Git Bash and check:
git --version        # Should show: git version 2.x.x
bash --version       # Should show: GNU bash, version 4.x.x
terraform version    # Should show: Terraform v1.x.x
```

</details>

<details>
<summary>💻 Can I use PowerShell or CMD? (click to expand)</summary>

**Yes!** All Windows terminals work:

- **Git Bash** ✅ Recommended - native bash environment
- **PowerShell** ✅ Works - calls bash.exe automatically
- **CMD** ✅ Works - calls bash.exe automatically
- **WSL** ✅ Works - full Linux environment

When Terraform runs `program = ["bash", "..."]`, Windows finds `bash.exe` from your Git installation (it's in your PATH). You don't need to do anything special.

</details>

---

## Common Questions

### "Do I need to install WSL?"

**No.** Git Bash (included with Git) is enough. WSL works if you already have it, but it's not required.

### "Do I need Python?"

**No.** We removed the Python dependency in v1.2.0. This module now uses only Bash and Git - both included with Git for Windows.

### "What about AWS credentials or cloud provider setup?"

**Not relevant.** This module doesn't touch AWS, Azure, or any cloud provider. It only:

- Reads an optional environment variable
- Runs `git describe` to get your version
- Returns the result

Your cloud credentials are handled by Terraform itself, not this module.

### "Will this work in CI/CD?"

**Yes!** Most Windows CI/CD runners include Git by default:

- ✅ GitHub Actions (Git pre-installed)
- ✅ GitLab CI (Git pre-installed)
- ✅ Azure DevOps (Git pre-installed)
- ✅ Jenkins (install Git on agent)

<details>
<summary>📋 Example: GitHub Actions (click to expand)</summary>

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2

- name: Terraform Plan
  run: terraform plan
  # Works automatically - GitHub Windows runners include Git Bash
```

</details>

### "I'm behind a corporate proxy?"

**No problem.** Configure Git proxy and everything works:

```bash
git config --global http.proxy http://proxy.example.com:8080
git config --global https.proxy http://proxy.example.com:8080
```

This module only uses local Git commands anyway - no network calls (unless you're fetching remote tags).

---

## Troubleshooting

### 🚫 Error: "bash: command not found"

**Fix:** Install Git for Windows from [git-scm.com/download/win](https://git-scm.com/download/win)

<details>
<summary>🔍 Still not working? Check your PATH (click to expand)</summary>

```powershell
# In PowerShell, verify Git is in PATH:
$env:PATH -split ';' | Select-String 'Git'
# Should show: C:\Program Files\Git\bin
```

If missing, add `C:\Program Files\Git\bin` to System PATH:

1. Windows Search → "Environment Variables"
2. Edit "System PATH"
3. Add `C:\Program Files\Git\bin`
4. Restart terminal

</details>

### 🚫 Module returns "UNKNOWN"

**Cause:** No Git repository or no tags found.

**Quick fixes:**

```bash
# Check you're in a Git repo:
git status

# Create a tag if none exist:
git tag v1.0.0

# Or bypass Git entirely:
export TF_MODULE_VERSION=1.0.0
terraform plan
```

<details>
<summary>🔧 More troubleshooting options (click to expand)</summary>

**Check for tags:**

```bash
git tag  # Should list tags like v1.0.0
```

**Use Terraform override:**

```hcl
module "version" {
  source = "..."
  version_override = "1.0.0"  # Bypasses Git
}
```

**Enable debug logging:**

```bash
TF_LOG=DEBUG terraform plan 2>&1 | grep -i external
```

</details>

### 🚫 Error: Permission denied

Rare, but if it happens:

```bash
chmod +x git_describe.sh
```

---

## Still Want to Use Python?

If you have Python standardized in your environment and prefer it:

<details>
<summary>🐍 Switch back to Python (click to expand)</summary>

**Change main.tf to use Python:**

```hcl
data "external" "version" {
  count   = var.version_override == null ? 1 : 0
  program = ["python", "${path.module}/git_describe.py", var.version_environment_variable]
}
```

**Ensure Python is installed:**

```powershell
python --version  # or python3 --version
```

**Install if needed:** [python.org/downloads](https://www.python.org/downloads/) (check "Add Python to PATH")

**Why Bash is recommended:**

| Aspect | Bash (Default) | Python (Alternative) |
|--------|----------------|---------------------|
| Installation | Included with Git | Separate install |
| PATH config | Automatic | Manual |
| Dependencies | Git only | Git + Python |

</details>

---

## Bottom Line

**You already have everything you need.** Git for Windows = Git + Bash. This module uses both. No extra setup required.

Questions? Problems? Test the script directly:

```bash
bash git_describe.sh
# Should output: {"version": "..."}
```

That's all there is to it! 🎉
