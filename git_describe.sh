#!/usr/bin/env bash
# Compatible with bash 3.2+ (including macOS default bash)

version=""

# Check if an environment variable name was passed as argument
if [ $# -ge 1 ]; then
    # Indirect variable expansion - get the value of the variable named in $1
    # This syntax works in bash 3.2+
    eval "version=\${$1}"
fi

# If version is still empty, try to get it from git
if [ -z "$version" ]; then
    # Redirect stderr to /dev/null to suppress error messages
    if version=$(git describe --tags --long --dirty --always 2>/dev/null); then
        # Success - version is already set
        :
    else
        # Git command failed
        version="UNKNOWN"
    fi
fi

# Output JSON - using printf for better portability and to avoid echo quirks
printf '{"version": "%s"}\n' "$version"
