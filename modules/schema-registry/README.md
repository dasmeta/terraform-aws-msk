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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_atomic"></a> [atomic](#input\_atomic) | Wait for release to succeed and roll back on failure. | `bool` | `true` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the Bitnami schema-registry Helm chart. | `string` | `"26.0.5"` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created when an upgrade fails. | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace with the Kubernetes provider before the Helm release. | `bool` | `true` | no |
| <a name="input_helm_timeout"></a> [helm\_timeout](#input\_helm\_timeout) | Helm wait timeout in seconds. | `number` | `600` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname for Ingress when ingress.enabled is true. | `string` | `null` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress configuration for consumer-managed controllers (ALB, nginx, etc.). | <pre>object({<br/>    enabled            = optional(bool, false)<br/>    ingress_class_name = optional(string)<br/>    annotations        = optional(map(string), {})<br/>    path               = optional(string, "/")<br/>    path_type          = optional(string, "ImplementationSpecific")<br/>    tls                = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_kafka"></a> [kafka](#input\_kafka) | Consumer-managed Kafka connection (externalKafka). Brokers use protocol://host:port entries. Set sasl\_mechanism (e.g. SCRAM-SHA-512 for MSK) when using SASL. | <pre>object({<br/>    brokers              = list(string)<br/>    listener_protocol    = optional(string, "PLAINTEXT")<br/>    sasl_mechanism       = optional(string)<br/>    sasl_user            = optional(string)<br/>    sasl_password        = optional(string)<br/>    sasl_existing_secret = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | Schema Registry HTTP listeners (chart value listeners). | `string` | `"http://0.0.0.0:8081"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Helm release. | `string` | `"schema-registry"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace for Schema Registry. | `string` | `"schema-registry"` | no |
| <a name="input_pod_labels"></a> [pod\_labels](#input\_pod\_labels) | Extra labels for Schema Registry pods. | `map(string)` | `{}` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of Schema Registry replicas (chart value replicaCount). | `number` | `1` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Container resources for Schema Registry pods. | <pre>object({<br/>    limits   = optional(map(string), {})<br/>    requests = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | Kubernetes Service type for Schema Registry (chart value service.type). | `string` | `"ClusterIP"` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Wait until all resources are ready. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_metadata"></a> [helm\_metadata](#output\_helm\_metadata) | Helm release metadata for the deployed Schema Registry release. |
| <a name="output_ingress_hostnames"></a> [ingress\_hostnames](#output\_ingress\_hostnames) | Ingress hostnames configured when ingress is enabled. |
| <a name="output_release_chart_version"></a> [release\_chart\_version](#output\_release\_chart\_version) | Chart version used for the Schema Registry Helm release. |
| <a name="output_release_name"></a> [release\_name](#output\_release\_name) | Name of the Schema Registry Helm release. |
| <a name="output_release_namespace"></a> [release\_namespace](#output\_release\_namespace) | Namespace of the Schema Registry Helm release. |
| <a name="output_release_status"></a> [release\_status](#output\_release\_status) | Status of the Schema Registry Helm release. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Kubernetes Service name for the Schema Registry release (matches release name). |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
