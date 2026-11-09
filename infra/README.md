# Infrastructure

Terraform for the Google Cloud side of Tin Can Vista: a project, Firebase Hosting, and a keyless way for GitHub Actions to deploy.

It creates:

- A Google Cloud project with billing attached, and the APIs it needs.
- Firebase on that project, which provides Hosting at `PROJECT_ID.web.app`.
- A `github-deployer` service account that can only publish Hosting content.
- A Workload Identity pool so that only your GitHub repository can act as that service account. No keys are created.

## One-time setup

You need `gcloud`, `terraform`, and an account that can create projects and use a billing account (`roles/resourcemanager.projectCreator` and `roles/billing.user`).

1. Sign in:

   ```bash
   gcloud auth application-default login
   ```

2. Create a bucket to hold Terraform state. It must live in a project you already have, because the blog's project does not exist yet. Pick a globally unique name.

   ```bash
   gcloud storage buckets create gs://YOUR-STATE-BUCKET --project=EXISTING-PROJECT --location=us-central1 --uniform-bucket-level-access
   ```

   ```bash
   gcloud storage buckets update gs://YOUR-STATE-BUCKET --versioning
   ```

3. Fill in your values:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Set `billing_account` and `github_repo` (as `owner/name`). Change `project_id` if `tin-can-vista-blog` is taken.

4. Create everything:

   ```bash
   terraform init -backend-config="bucket=YOUR-STATE-BUCKET"
   ```

   ```bash
   terraform apply
   ```

5. In the GitHub repository, open Settings > Secrets and variables > Actions > Variables, and add three repository variables from the Terraform outputs:

   | Variable | Terraform output |
   | --- | --- |
   | `GCP_PROJECT_ID` | `project_id` |
   | `GCP_WORKLOAD_IDENTITY_PROVIDER` | `workload_identity_provider` |
   | `GCP_SERVICE_ACCOUNT` | `deployer_service_account` |

   They are identifiers, not secrets, so plain variables are fine.

After that, pushing to `main` deploys the site, and pull requests from this repository get a preview link.

## Changing things later

Edit the `.tf` files, open a pull request (the `Infrastructure checks` workflow runs `fmt` and `validate`), merge it, then run `terraform apply` from your machine.

## Notes

- Firebase creates the default Hosting site at `PROJECT_ID.web.app` when Firebase is added to the project. If the first deploy says the site does not exist, create it in the Firebase console and re-run the workflow.
- To use a custom domain, add it under Hosting in the Firebase console and set the DNS records it gives you.
