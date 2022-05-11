
# VPC for RDS Database
resource "aws_vpc" "rds" {
  cidr_block = var.rds-vpc-cidr
  enable_dns_hostnames = true

  tags = {
    Name = "rds-vpc"
  }
}

# RDS VPC ARN
data "aws_arn" "rds" {
  arn = aws_vpc.rds.arn
}

resource "hcp_aws_network_peering" "rds" {
  hvn_id              = hcp_hvn.learn_hcp_vault_hvn.hvn_id
  peering_id          = var.peering_id
  peer_vpc_id         = aws_vpc.rds.id
  peer_account_id     = aws_vpc.rds.owner_id
  peer_vpc_region     = data.aws_arn.rds.region
}

resource "hcp_hvn_route" "rds" {
  hvn_link         = hcp_hvn.learn_hcp_vault_hvn.self_link
  hvn_route_id     = var.route_id
  destination_cidr = aws_vpc.rds.cidr_block
  target_link      = hcp_aws_network_peering.rds.self_link
}

resource "aws_vpc_peering_connection_accepter" "rds" {
  vpc_peering_connection_id = hcp_aws_network_peering.rds.provider_peering_id
  auto_accept               = true
}
