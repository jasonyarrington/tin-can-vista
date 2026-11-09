output "project_id" {
  description = "Set as the GitHub Actions variable GCP_PROJECT_ID."
  value       = google_project.blog.project_id
}

output "workload_identity_provider" {
  description = "Set as the GitHub Actions variable GCP_WORKLOAD_IDENTITY_PROVIDER."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "deployer_service_account" {
  description = "Set as the GitHub Actions variable GCP_SERVICE_ACCOUNT."
  value       = google_service_account.deployer.email
}

output "dns_apex" {
  description = "DNS records to add at the registrar for the bare domain."
  value       = google_firebase_hosting_custom_domain.apex.required_dns_updates
}

output "dns_www" {
  description = "DNS records to add at the registrar for www."
  value       = google_firebase_hosting_custom_domain.www.required_dns_updates
}

output "site_url" {
  description = "Where the blog is served."
  value       = "https://${google_project.blog.project_id}.web.app"
}
