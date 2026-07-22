resource "aws_ecr_repository" "flight_backend_app" {
    name = "flight-backend-app"
    force_delete = true

    image_tag_mutability = "MUTABLE"
    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "flight_backend_app_ecr"
        env = "dev"
    }
}
