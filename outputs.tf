output "version" {
  value       = var.version_override == null ? data.external.version[0].result.version : var.version_override
  description = "Version obtained from the git repo"
}
