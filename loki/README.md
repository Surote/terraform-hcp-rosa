# LokiStack IAM Policies (optional)

Optional add-on for OpenShift logging with LokiStack. Skip this folder unless you are deploying Loki.

These policies are **not managed by Terraform** — apply them by hand after the cluster exists, since they depend on the cluster's OIDC provider ID, which only exists post-creation.

## Files

| File | Purpose |
|------|---------|
| `policy.json` | Permission policy — S3 access for the Loki object store |
| `trust-policy.json` | Trust policy — lets the `openshift-logging:loki` service account assume the role via OIDC |

## Placeholders

Both files ship with placeholders so no real identifier lands in this public repo. Fill them at apply time:

| Placeholder | Where to get it |
|-------------|-----------------|
| `<AWS_ACCOUNT_ID>` | `aws sts get-caller-identity --query Account --output text` |
| `<OIDC_PROVIDER>` | `rosa describe cluster -c <cluster_name> -o json \| jq -r .aws.sts.oidc_endpoint_url \| sed 's\|https://\|\|'` |
| `<LOKI_BUCKET>` | Name of the S3 bucket you created for Loki |

## Apply

Fill placeholders into copies, keeping the tracked originals untouched:

```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
OIDC=$(rosa describe cluster -c "$CLUSTER" -o json | jq -r .aws.sts.oidc_endpoint_url | sed 's|https://||')
BUCKET=your-loki-bucket

sed -e "s|<AWS_ACCOUNT_ID>|$ACCOUNT|g" -e "s|<OIDC_PROVIDER>|$OIDC|g" trust-policy.json > /tmp/loki-trust.json
sed -e "s|<LOKI_BUCKET>|$BUCKET|g" policy.json > /tmp/loki-perm.json

aws iam create-role --role-name "${CLUSTER}-loki" \
  --assume-role-policy-document file:///tmp/loki-trust.json
aws iam put-role-policy --role-name "${CLUSTER}-loki" \
  --policy-name loki-s3 --policy-document file:///tmp/loki-perm.json
```

The resolved copies contain real account IDs — write them to `/tmp`, never into this repo.
