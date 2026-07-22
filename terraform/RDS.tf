
resource "aws_db_instance" "fligth_db" {
    allocated_storage = var.db_allocated_storage
    max_allocated_storage = var.db_max_allocated_storage
    engine = var.db_engine
    engine_version = var.db_engine_version
    instance_class = var.db_instance_class
    db_name = "flightdb"
    storage_type = "gp2"
    username = var.db_username
    password = var.db_password
    parameter_group_name = var.db_parameter_group_name
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    db_subnet_group_name = aws_db_subnet_group.flight_db_subnet_group.name
    skip_final_snapshot = true

    tags = {
        Name = "flight_db_instance"
    }
}

resource "aws_db_subnet_group" "flight_db_subnet_group" {
    name = "flight_db_subnet_group"
    subnet_ids = aws_subnet.private[*].id

    tags = {
        Name = "flight_db_subnet_group"
    }
}

