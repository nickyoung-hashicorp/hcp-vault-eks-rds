# Outputs file
output "vault_ip" {
  value = "http://${aws_eip.vault.public_ip}"
}

# Output RDS endpoint with port
output "rds-endpoint" { value = aws_db_instance.rds.endpoint }