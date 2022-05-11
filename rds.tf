# RDS Subnet in 1st Availability Zone
resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.rds.id
  availability_zone = var.rds-subnet-az-a
  cidr_block        = var.rds-subnet-cidr-a
}

# RDS Subnet in 2nd Availability Zone
resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.rds.id
  availability_zone = var.rds-subnet-az-b
  cidr_block        = var.rds-subnet-cidr-b
}

# Route Table Association for RDS Subnet 1
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_vpc.rds.main_route_table_id
}

# Route Table Association for RDS Subnet 2
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.b.id
  route_table_id = aws_vpc.rds.main_route_table_id
}

# RDS DB Subnet Group
resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.a.id, aws_subnet.b.id]
}

# RDS VPC Security Group
resource "aws_security_group" "postgres" {
  name        = "PostgreSQL"
  description = "Allow PostgreSQL Traffic"
  vpc_id      = aws_vpc.rds.id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.rds.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Provision PostgreSQL RDS Database
resource "aws_db_instance" "rds" {
  availability_zone      = "us-west-2b"
  vpc_security_group_ids = [aws_security_group.postgres.id]
  port                   = "5432"
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  db_name                = "postgresdb"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14.1"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  password               = "password"
  parameter_group_name   = "default.postgres14"
  skip_final_snapshot    = true
}

