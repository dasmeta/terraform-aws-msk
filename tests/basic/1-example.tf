module "this" {
  source = "../../"

  kms_key_owner_username = "dasmeta.julia"
  client_authentication = {
    "iam" : false,
    "sasl" : {
      "scram" : true
    },
    "tls" : null,
    "unauthenticated" : true
  }

  vpc_id         = "vpc-000000000000000"
  ingress_access = ["10.0.0.0/16"]
}
