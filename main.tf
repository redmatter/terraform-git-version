data "external" "version" {
  program = ["python", "${path.module}/git_describe.py", var.version_environment_variable]
}
