data "external" "version" {
  count   = var.version_override == null ? 1 : 0
  program = ["python", "${path.module}/git_describe.py", var.version_environment_variable]
}
