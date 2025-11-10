# git-version

Terraform module for retrieving version information from the Git repository in which the parent module is running. This module uses `git describe` to generate semantic version strings based on Git tags, commit history, and working tree state.

> **Windows Users:** See the [Windows Compatibility Guide](WINDOWS.md) for detailed setup instructions and troubleshooting.

## Features

- **Zero external dependencies** - Only requires Bash (3.2+) and Git
- **Cross-platform compatible** - Works on Linux, macOS, and other Unix-like systems
- **Flexible version override system** - Support for environment variables and explicit overrides
- **CI/CD friendly** - Handles scenarios where Git may not be available during apply-time

## Dependencies

This module requires the following to be available in the execution environment:

| Dependency | Minimum Version | Purpose | Notes |
|------------|-----------------|---------|-------|
| **Terraform** | >= 0.12.0 | Infrastructure as Code runtime | Required |
| **Bash** | >= 3.2 | Shell script execution | Compatible with macOS default bash |
| **Git** | Any | Version control system | Must be available in PATH unless using overrides |

### Platform Compatibility

- ✅ **Linux** - All distributions with bash and git
- ✅ **macOS** - Compatible with default bash 3.2 (no Homebrew updates required)
- ✅ **Windows** - Git Bash, WSL, or Cygwin environments ([detailed Windows guide](WINDOWS.md))
- ✅ **CI/CD** - Works with environment variable overrides when Git is unavailable

**Windows Users:** Git Bash is automatically included with Git for Windows. No additional installation required. See the [Windows Compatibility Guide](WINDOWS.md) for details.

## Usage

### Basic Usage

```hcl
module "version" {
  source = "path/to/git-version"
}

output "current_version" {
  value = module.version.version
}
```

### With Custom Environment Variable

```hcl
module "version" {
  source = "path/to/git-version"

  version_environment_variable = "MY_CUSTOM_VERSION_VAR"
}
```

### With Explicit Override

```hcl
module "version" {
  source = "path/to/git-version"

  version_override = "1.2.3-custom"
}
```

## Version Resolution

The module resolves versions using the following priority order (highest to lowest):

### 1. Explicit Override (Highest Priority)

The `version_override` variable directly sets the version, bypassing both environment variables and Git.

```hcl
version_override = "2.0.0-rc1"
```

**Use case:** Parent modules that need to conditionally override versions without implementing their own logic.

### 2. Environment Variable Override

By default, the `TF_MODULE_VERSION` environment variable is checked. If set, its value is returned instead of querying Git.

```bash
export TF_MODULE_VERSION=1.5.0
terraform plan
```

The environment variable name can be customized:

```hcl
version_environment_variable = "DEPLOYMENT_VERSION"
```

**Use case:** CI/CD pipelines where Git may not be available during `terraform apply`, or when you want to pin a specific version for a deployment.

### 3. Git Describe (Default Fallback)

If no overrides are set, the module executes:

```bash
git describe --tags --long --dirty --always
```

This produces version strings like:

- `1.2.3-0-ga1b2c3d` - On a tagged commit
- `1.2.3-5-ga1b2c3d` - 5 commits after tag 1.2.3
- `1.2.3-5-ga1b2c3d-dirty` - Same as above with uncommitted changes
- `a1b2c3d` - No tags found (falls back to commit hash)

**Use case:** Standard development workflow where Git history accurately reflects versioning.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `version_environment_variable` | Name of the environment variable to check for version override | `string` | `"TF_MODULE_VERSION"` | No |
| `version_override` | Explicit version string to return (bypasses Git and environment) | `string` | `null` | No |

## Outputs

| Name | Description |
|------|-------------|
| `version` | The resolved version string from Git, environment, or override |

## How It Works

The module uses Terraform's `external` data source to execute a bash script ([git_describe.sh](git_describe.sh)) that:

1. Checks if the specified environment variable contains a version
2. If not, executes `git describe --tags --long --dirty --always`
3. Returns the version as JSON: `{"version": "..."}`
4. Falls back to `"UNKNOWN"` if Git command fails

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Terraform Plan
  env:
    TF_MODULE_VERSION: ${{ github.ref_name }}
  run: terraform plan
```

### GitLab CI Example

```yaml
terraform:
  variables:
    TF_MODULE_VERSION: $CI_COMMIT_TAG
  script:
    - terraform apply
```

### Jenkins Example

```groovy
environment {
    TF_MODULE_VERSION = "${env.GIT_TAG}"
}
```

## Migration Notes

**Version 1.2.0+**: Removed Python dependency in favor of Bash. The Python script (`git_describe.py`) is no longer used or required. If you have older versions of this module pinned, no changes are needed - the bash implementation produces identical output.

**For Windows users:** Git Bash (included with Git for Windows) provides all required functionality. No additional setup needed beyond Git, which is already required for version control. See [WINDOWS.md](WINDOWS.md) for comprehensive Windows compatibility information, troubleshooting, and FAQs.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

When modifying the bash script, ensure compatibility with bash 3.2+ for macOS support. Test on both modern Linux (bash 5.x) and macOS (bash 3.2) before submitting changes.
