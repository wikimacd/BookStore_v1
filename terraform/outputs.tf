output "public_ip" {
  value = aws_instance.app_server.public_ip
}

output "backend_repo_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_repo_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "private_key_pem" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true
}
