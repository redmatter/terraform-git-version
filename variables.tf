variable "version_environment_variable" {
  default     = "TF_MODULE_VERSION"
  description = "Name of the environment variable to use as the version to be returned, if set"
}

variable "version_override" {
  default     = null
  description = "Version to return instead of using Git or the environment"
}
