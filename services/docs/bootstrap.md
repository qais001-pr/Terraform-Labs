# Infrastructure Bootstrap — Manual Pre-Setup Steps

These steps must be completed **once per environment account** before running any Terragrunt commands.
Terraform cannot manage the S3 bucket that stores its own state (chicken-and-egg), so these are intentionally manual.

---

## Prerequisites

- AWS CLI installed and configured with SSO
- Appropriate SSO profile for the target account (see profile names below)
- `jq` installed (optional, for verification steps)

### SSO Profile Reference

| Environment | AWS Account ID | SSO Profile         |
|-------------|-------------|---------------------|
| dev         | `851236938681` | `nexaquanta-dev`      |
| staging     | `252303747121` | `naap-staging`      |
| prod        | _(TBC)_ | `naap-prod` _(TBC)_ |

### Login

```bash
aws sso login --profile <profile>
```

---

## Step 1 — Create the Terraform State S3 Bucket

Run the following for **each environment**. Substitute `<profile>` and `<bucket-name>` from the table below.

| Environment | Profile | Bucket Name |
|-------------|---------|-------------|
| staging | `naap-staging` | `naap-staging-tfstate-files` |
| prod | `naap-prod` | `naap-prod-tfstate-files` |

### 1a. Create the bucket

```bash
aws s3api create-bucket \
  --bucket <bucket-name> \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2 \
  --profile <profile>
```

### 1b. Enable versioning

Allows recovery from accidental state corruption or deletion.

```bash
aws s3api put-bucket-versioning \
  --bucket <bucket-name> \
  --versioning-configuration Status=Enabled \
  --profile <profile>
```

### 1c. Enable server-side encryption

```bash
aws s3api put-bucket-encryption \
  --bucket <bucket-name> \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }]
  }' \
  --profile <profile>
```

### 1d. Block all public access

```bash
aws s3api put-public-access-block \
  --bucket <bucket-name> \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --profile <profile>
```

### 1e. Verify

```bash
# Versioning should show "Enabled"
aws s3api get-bucket-versioning --bucket <bucket-name> --profile <profile>

# Encryption should show AES256 rule
aws s3api get-bucket-encryption --bucket <bucket-name> --profile <profile>

# Public access block — all four fields should be true
aws s3api get-public-access-block --bucket <bucket-name> --profile <profile>
```

---

## Step 2 — Verify SSO Session Before Running Terragrunt

Always confirm you have an active session for the correct account before applying.

```bash
aws sts get-caller-identity --profile <profile>
```

Expected output should show the correct `Account` ID from the table above.

---

## Step 3 — Running Terragrunt

Once the bucket exists, standard Terragrunt commands apply. Run from the relevant environment directory.

```bash
# Example — staging VPC
cd terradeploy/staging/eu-west-2/vpc

terragrunt plan
terragrunt apply
```

To run all modules in an environment at once:

```bash
cd terradeploy/staging
terragrunt run-all plan
terragrunt run-all apply
```

> **Note:** `run-all` respects `dependency` blocks and applies in the correct order automatically.

---

## Future Environments

When a new environment (e.g. `prod`) is added:

1. Obtain the AWS account ID and add a SSO profile to `~/.aws/config`
2. Repeat Steps 1 and 2 above for the new account/bucket
3. Add `terradeploy/<env>/account.hcl` with the correct profile and environment name
4. Copy and update `terradeploy/<env>/root.hcl` with the new bucket name
5. Add the environment to the profile reference table in this document

---

## Notes

- State locking uses Terraform's native S3 locking (`use_lockfile = true`) — no DynamoDB table required (requires Terraform >= 1.9)
- All state files are encrypted at rest (AES256) and versioned
- State buckets should never be managed by Terraform itself
