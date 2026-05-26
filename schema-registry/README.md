# schema-registry

Terraform wrapper around the Bitnami **schema-registry** Helm chart for deploying
[Confluent Schema Registry](https://docs.confluent.io/platform/current/schema-registry/index.html)
on an existing Kubernetes cluster.

This module stays intentionally narrow (similar to `modules/akhq` and
`modules/keycloak`):

- Deploys Schema Registry only; you bring **Kafka** (`kafka.brokers` and optional SASL settings).
- Disables bundled Kafka (`kafka.enabled = false`) and wires **externalKafka**.
- Encodes the Bitnami chart workaround for external-Kafka installs (empty `kafka.auth` / `kafka.service` stubs).
- Defaults the container image repository to **bitnamilegacy** per repository convention.
- Optional **Ingress** for consumer-managed controllers; no ingress controller or certificate automation.

## Requirements

- `helm` and `kubernetes` providers configured in the root module.
- Network reachability from the cluster to your Kafka brokers.

## Baseline usage

```terraform
module "schema_registry" {
  source = "dasmeta/shared/any//modules/schema-registry"

  kafka = {
    brokers = [
      "PLAINTEXT://kafka.example.internal:9092",
    ]
  }
}
```

## SASL credentials

| Mode | Inputs |
|------|--------|
| **Existing Secret** (preferred) | `kafka.sasl_existing_secret` + `kafka.sasl_user` — user must match the MSK SCRAM principal (e.g. `schema-registry` from `AmazonMSK_schema-registry`); password under key `client-passwords` |
| **Raw password** | `kafka.sasl_user` + `kafka.sasl_password` |

Do not set both `kafka.sasl_password` and `kafka.sasl_existing_secret`.

## Ingress

```terraform
module "schema_registry" {
  source = "dasmeta/shared/any//modules/schema-registry"

  hostname = "schema-registry.example.com"

  kafka = {
    brokers = ["PLAINTEXT://kafka.example.internal:9092"]
  }

  ingress = {
    enabled            = true
    ingress_class_name = "alb"
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internal"
    }
  }
}
```

## Bundled Kafka must stay off

The module always sets `kafka.enabled: false` (in `values.yaml`, generated values, and a
Helm `set`) and wires your brokers via `externalKafka`. A pod named
`schema-registry-kafka-controller-0` means bundled Kafka was installed — usually from a
prior release or apply before external-Kafka values were applied.

After upgrading with this module, confirm:

```shell
helm get values schema-registry -n <namespace> | grep -A2 '^kafka:'
```

You should see `enabled: false`. If Kafka StatefulSets remain, remove them (Helm should
prune on upgrade; manual cleanup is safe when MSK is the only broker):

```shell
kubectl delete statefulset -n <namespace> -l app.kubernetes.io/name=kafka
```

## Out of scope (first version)

- Bundled Kafka or Zookeeper
- Generic Helm `values` pass-through
- Ingress controller, DNS, or certificate lifecycle ownership

## Examples

See `examples/basic`.

## Tests

See `tests/basic` for Terraform validate-only coverage.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.3 |
| helm | ~> 2.0 |
| kubernetes | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| helm | ~> 2.0 |
| kubernetes | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| helm_release.this | resource |
| kubernetes_namespace_v1.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Helm release name | `string` | `"schema-registry"` | no |
| namespace | Kubernetes namespace | `string` | `"schema-registry"` | no |
| create_namespace | Create namespace before install | `bool` | `true` | no |
| chart_version | Bitnami chart version | `string` | `"26.0.5"` | no |
| kafka | External Kafka connection | `object` | n/a | yes |
| ingress | Optional ingress settings | `object` | `{}` | no |
| resources | Pod resources | `object` | `{}` | no |
| replicas | Replica count | `number` | `1` | no |
| hostname | Ingress hostname | `string` | `null` | no |
| helm_timeout | Helm timeout seconds | `number` | `600` | no |
| atomic | Helm atomic installs | `bool` | `true` | no |
| cleanup_on_fail | Helm cleanup on fail | `bool` | `true` | no |
| wait | Helm wait | `bool` | `true` | no |
| pod_labels | Extra pod labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| release_name | Helm release name |
| release_namespace | Release namespace |
| release_status | Helm release status |
| release_chart_version | Chart version applied |
| helm_metadata | Helm metadata |
| service_name | Kubernetes Service name |
| ingress_hostnames | Ingress hosts when enabled |
<!-- END_TF_DOCS -->
