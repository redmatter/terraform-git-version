# git-version

Module for retrieving versions from the git repo from which the parent module is running.

## Overrides

The version returned can be overridden via the environment and via a passed in override variable.

### Environment

By default, if the `TF_MODULE_VERSION` environment variable is set, this module will return the value of that variable
instead of using Git to determine a version.

The environment variable to check can be changed by setting the `version_environment_variable` variable.

### Override variable

The `version_override` variable defaults to `null`, but if set will be returned.
In this case neither the Git repo nor the environment will be checked.

This can be useful as a way to allow parent modules to override the version via a variable without needing to implement
logic of their own to optionally use the module depending on the status of their override variable.
Instead, they can just pass the override variable in and if it's `null` then it will be ignored.
