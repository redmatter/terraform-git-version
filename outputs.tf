output "version" {
  value       = data.external.version.result.version
  description = "Version obtained from the git repo"
}

