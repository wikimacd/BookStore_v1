resource "aws_ecr_repository" "backend" {
  name                 = "bookstore-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "frontend" {
  name                 = "bookstore-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
