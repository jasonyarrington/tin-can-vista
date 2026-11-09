# Infrastructure

Terraform for the Google Cloud side of Tin Can Vista: a project, Firebase Hosting, and a keyless way for GitHub Actions to deploy.

It creates:

- A Google Cloud project and the APIs it needs.
- Firebase on that project, which provides Hosting at `PROJECT_ID.web.app`.
- A `github-deployer` service account that can only publish Hosting content.
- A Workload Identity pool so that only your GitHub repository can act as that service account. No keys are created.

The project has **no billing account**. Firebase Hosting works on the free Spark plan, so this costs nothing. The trade-off is that Cloud Storage is unavailable, so Terraform state is kept on your machine (see below).

## One-time setup

You need `gcloud`, `terraform`, and an account that can create projects in your organization (`roles/resourcemanager.projectCreator`).

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

   Set `github_repo` (as `owner/name`) and `org_id` if you use an organization. Change `project_id` if `tin-can-vista-blog` is taken. `terraform.tfvars` is git-ignored.

3. Create everything:

   ```bash
   terraform init
   ```

   ```bash
   terraform apply
   ```

4. In the GitHub repository, add three repository variables from the Terraform outputs (Settings > Secrets and variables > Actions > Variables, or `gh variable set`):

   | Variable | Terraform output |
   | --- | --- |
   | `GCP_PROJECT_ID` | `project_id` |
   | `GCP_WORKLOAD_IDENTITY_PROVIDER` | `workload_identity_provider` |
   | `GCP_SERVICE_ACCOUNT` | `deployer_service_account` |

   They are identifiers, not secrets, so plain variables are fine.

After that, pushing to `main` deploys the site, and pull requests from this repository get a preview link.

## State

Terraform state is the local, git-ignored file `infra/terraform.tfstate`. Back it up if you care about it. If it is lost, the resources still exist in Google Cloud, and you can rebuild state by running `terraform import` for each resource, which is small here (about 15).

If you later attach a billing account (set `billing_account`), you can add a Cloud Storage bucket and a `backend "gcs"` block, then run `terraform init -migrate-state`.

## Changing things later

Edit the `.tf` files, open a pull request (the `Infrastructure checks` workflow runs `fmt` and `validate`), merge it, then run `terraform apply` from your machine.

## Notes

- To use a custom domain such as `tincanvista.com`, add it under Hosting in the Firebase console and set the DNS records it gives you.
- The project has deletion protection by default. Removing it later means turning that off first.
- The billing account `Fast Forward Google Cloud Billing Account` is at its limit of linked projects, which is why this project is unbilled.
