module "this" {
  source = "../../"

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

provider "aws" {
  region = "eu-central-1"
}
