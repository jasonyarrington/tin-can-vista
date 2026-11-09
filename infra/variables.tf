variable "project_id" {
  description = "ID of the Google Cloud project to create. Must be globally unique. It also becomes the Firebase Hosting address (PROJECT_ID.web.app)."
  type        = string
  default     = "tin-can-vista-blog"
}

variable "project_name" {
  description = "Display name of the project."
  type        = string
  default     = "Tin Can Vista"
}

variable "billing_account" {
  description = "Billing account ID to attach, like 000000-AAAAAA-BBBBBB. Leave null to stay on Firebase's free Spark plan (Hosting works without billing)."
  type        = string
  default     = null
}

variable "org_id" {
  description = "Organization ID to create the project under. Leave null for a project with no organization."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "Folder ID to create the project under. Use either this or org_id, not both."
  type        = string
  default     = null
}

variable "region" {
  description = "Default region for provider calls."
  type        = string
  default     = "us-central1"
}

variable "custom_domain" {
  description = "Domain served by Hosting. www.<domain> redirects to it."
  type        = string
  default     = "tincanvista.com"
}

variable "github_repo" {
  description = "GitHub repository allowed to deploy, as OWNER/NAME."
  type        = string
}
