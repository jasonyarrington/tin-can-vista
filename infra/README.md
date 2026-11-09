# Infrastructure

Terraform for the Google Cloud side of Tin Can Vista: a project, Firebase Hosting, a state bucket, and a keyless way for GitHub Actions to deploy.

It creates:

- A Google Cloud project with billing attached, and the APIs it needs.
- A Cloud Storage bucket (`PROJECT_ID-tfstate`) that holds Terraform's own state.
- Firebase on that project, which provides Hosting at `PROJECT_ID.web.app`.
- A `github-deployer` service account that can only publish Hosting content.
- A Workload Identity pool so that only your GitHub repository can act as that service account. No keys are created.

## One-time setup

You need `gcloud`, `terraform`, and an account that can create projects and use a billing account (`roles/resourcemanager.projectCreator` and `roles/billing.user`).

1. Sign in:

   ```bash
   gcloud auth login
   ```

   ```bash
   gcloud auth application-default login
   ```

2. Fill in your values:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Set `billing_account`, `org_id` (if you use an organization) and `github_repo` (as `owner/name`). Change `project_id` if `tin-can-vista-blog` is taken. `terraform.tfvars` is git-ignored.

3. First apply. State is kept on your machine this time, because the state bucket does not exist yet:

   ```bash
   terraform init
   ```

   ```bash
   terraform apply
   ```

4. Move state into the new bucket. Create `infra/backend.tf` with the bucket name from the `state_bucket` output:

   ```hcl
   terraform {
     backend "gcs" {
       bucket = "tin-can-vista-blog-tfstate"
       prefix = "terraform/state"
     }
   }
   ```

   ```bash
   terraform init -migrate-state
   ```

   Answer yes. Commit `backend.tf`. You can then delete the local `terraform.tfstate` files.

5. In the GitHub repository, open Settings > Secrets and variables > Actions > Variables, and add three repository variables from the Terraform outputs (or run `gh variable set`):

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
- To use a custom domain such as `tincanvista.com`, add it under Hosting in the Firebase console and set the DNS records it gives you.
- The project has deletion protection by default. Removing it later means turning that off first.
