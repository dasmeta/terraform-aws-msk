# Quickstart: Provisioning Kafka Topics with the msk-topics Module

**Time to complete**: ~15 minutes
**Prerequisites**: Terraform ≥ 1.3.0 installed, AWS MSK cluster already running, network access to MSK brokers

---

## Repository Layout

After implementation, the repository will look like this:

```
msk-topics/
├── modules/
│   └── msk-topics/           ← the reusable module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
└── environments/
    ├── dev/
    │   ├── main.tf           ← calls the module
    │   ├── variables.tf
    │   ├── terraform.tfvars  ← topic definitions for dev
    │   └── backend.tf        ← remote state config
    ├── staging/
    │   └── ...
    └── production/
        └── ...
```

---

## Step 1: Find Your MSK Bootstrap Brokers

In the AWS Console, navigate to **Amazon MSK → your cluster → View client information**.

Copy the **TLS endpoint** (port 9094). It looks like:

```
b-1.mycluster.abc123.c2.kafka.us-east-1.amazonaws.com:9094,b-2.mycluster.abc123.c2.kafka.us-east-1.amazonaws.com:9094
```

If your cluster uses SASL/SCRAM, copy the **SASL/SCRAM endpoint** (port 9096) instead.

---

## Step 2: Define Your Topics

Edit `environments/dev/terraform.tfvars`:

```hcl
bootstrap_brokers = "b-1.mycluster.abc123.c2.kafka.us-east-1.amazonaws.com:9094,b-2.mycluster.abc123.c2.kafka.us-east-1.amazonaws.com:9094"

topics = {
  "orders" = {
    partitions         = 6
    replication_factor = 1        # Use 1 for dev (single-broker clusters)
    config = {
      "retention.ms"   = "86400000"  # 1 day
      "cleanup.policy" = "delete"
    }
  }

  "payments" = {
    partitions         = 6
    replication_factor = 1
  }

  "audit-log" = {
    partitions         = 3
    replication_factor = 1
    config = {
      "cleanup.policy" = "compact"
    }
  }
}
```

> **Production tip**: Set `replication_factor = 3` for all topics in staging and production to survive broker failures.

---

## Step 3: Initialise Terraform

```bash
cd environments/dev
terraform init
```

Terraform will download the `Mongey/kafka` provider automatically.

---

## Step 4: Preview Changes

```bash
terraform plan
```

Expected output (first run on a fresh cluster):

```
Plan: 3 to add, 0 to change, 0 to destroy.
```

---

## Step 5: Apply

```bash
terraform apply
```

Type `yes` when prompted. After apply completes, all topics exist on the cluster.

---

## Step 6: Verify

Use the Kafka CLI to confirm (run from a host with broker access):

```bash
kafka-topics.sh \
  --bootstrap-server <your-broker-endpoint> \
  --list
```

You should see `audit-log`, `orders`, and `payments`.

---

## Adding a New Topic

1. Add an entry to `terraform.tfvars`:
   ```hcl
   "notifications" = {
     partitions         = 3
     replication_factor = 1
   }
   ```
2. Run `terraform plan` — confirm exactly `1 to add, 0 to change, 0 to destroy`.
3. Run `terraform apply`.

---

## Promoting to Staging / Production

1. Copy the `environments/dev/terraform.tfvars` file to `environments/staging/terraform.tfvars`.
2. Update `bootstrap_brokers` to point to the staging MSK cluster.
3. Update `replication_factor` values to match the staging broker count (typically 3).
4. Run `terraform init && terraform plan && terraform apply` from `environments/staging/`.

Production follows the same pattern.

---

## SASL/SCRAM Authentication

If your MSK cluster uses SASL/SCRAM, set these additional variables in `terraform.tfvars`:

```hcl
sasl_mechanism = "scram-sha-512"
sasl_username  = "my-kafka-user"
```

Supply the password via environment variable (never in tfvars):

```bash
export TF_VAR_sasl_password="$(aws secretsmanager get-secret-value \
  --secret-id msk/my-cluster/kafka-password \
  --query SecretString --output text)"

terraform apply
```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `context deadline exceeded` during plan | Broker unreachable | Check VPC/security group rules; confirm the Terraform runner can reach port 9094 |
| `replication factor: X is larger than available brokers` | `replication_factor` > broker count | Lower `replication_factor` or scale the MSK cluster |
| `Topic 'X' already exists` (import error) | Topic was created outside Terraform | Run `terraform import module.msk_topics.kafka_topic.topics["X"] X` |
| Zero changes but topic config differs | Config drift not reflected in state | Run `terraform refresh` then `terraform plan` |
