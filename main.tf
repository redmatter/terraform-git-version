data "external" "version" {
  count   = var.version_override == null ? 1 : 0
  program = ["bash", "${path.module}/git_describe.sh", var.version_environment_variable]
}
