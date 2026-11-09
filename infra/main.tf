locals {
  services = [
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    "firebasehosting.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "sts.googleapis.com",
  ]
}

# --- Project -----------------------------------------------------------------

resource "google_project" "blog" {
  project_id      = var.project_id
  name            = var.project_name
  billing_account = var.billing_account
  org_id          = var.org_id
  folder_id       = var.folder_id
}

resource "google_project_service" "enabled" {
  for_each = toset(local.services)

  project            = google_project.blog.project_id
  service            = each.value
  disable_on_destroy = false
}

# --- Firebase Hosting --------------------------------------------------------
# Adding Firebase to the project provisions its default Hosting site at
# PROJECT_ID.web.app. The pipeline deploys the built output/ folder to it.

resource "google_firebase_project" "blog" {
  provider = google-beta
  project  = google_project.blog.project_id

  depends_on = [google_project_service.enabled]
}

# --- GitHub Actions deploy access (Workload Identity Federation) -------------
# No keys are created. GitHub proves who it is with a short-lived token, and
# only the configured repository can act as the deployer service account.

resource "google_service_account" "deployer" {
  project      = google_project.blog.project_id
  account_id   = "github-deployer"
  display_name = "GitHub Actions deployer"

  depends_on = [google_project_service.enabled]
}

resource "google_project_iam_member" "deployer_hosting" {
  project = google_project.blog.project_id
  role    = "roles/firebasehosting.admin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_service_usage" {
  project = google_project.blog.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = google_project.blog.project_id
  workload_identity_pool_id = "github"
  display_name              = "GitHub Actions"

  depends_on = [google_project_service.enabled]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = google_project.blog.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Only tokens issued for this repository are accepted.
  attribute_condition = "assertion.repository == \"${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "deployer_wif" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}
