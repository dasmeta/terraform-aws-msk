resource "aws_security_group" "allow_kafka_connection" {
  name        = var.name
  description = "Allow Kafka inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Access to 9092"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = var.ingress_access
  }

  ingress {
    description = "Access to 9094"
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = var.ingress_access
  }

  ingress {
    description = "Access to 9096"
    from_port   = 9096
    to_port     = 9096
    protocol    = "tcp"
    cidr_blocks = var.ingress_access
  }

  ingress {
    description = "Access to 9098"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = var.ingress_access
  }

  egress {
    description = "Full outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
