
variable "region" {
    type = string
    description = "region for vpc"
    default = "us-east-1"
}

variable "vpc_cidr" {
    type = string
    description = "cidr block for vpc"
    default = "172.16.0.0/16"

}

variable "public_cidrs" {
    type = list(string)
    description = "cidr for public subnets"
    default = ["172.16.1.0/24","172.16.2.0/24" ]
  
}

variable "azs" {
    type = list(string)
    description = "azs for subnets"
    default = [ "us-east-1a","us-east-1b" ]
  
}

variable "private_cidrs" {
    type = list(string)
    description = "cidr for private subnets"
    default = ["172.16.10.0/24","172.16.11.0/24" ]
}


variable "desired_size" {
    default = 2
}

variable "max_size" {
    default = 5
}
variable "min_size" {
    default = 2
}

variable "instance_type" {
    default = ["c7i-flex.large"]
}
variable "eks_version" {
    default = "1.33"
}

variable "db_allocated_storage" {
    default = 20
}

variable "db_max_allocated_storage" {
    default = 100

}

variable "db_engine" {
    default = "mysql"
}

variable "db_engine_version" {
    default = "8.0"
}

variable "db_instance_class" {
    default = "db.t3.micro"

}

variable "db_username" {
    default = "admin"

}

variable "db_password" {
    default = "Redhat123"
}

variable"db_parameter_group_name" {
    default = "default.mysql8.0"
}

variable "key_name" {
    default = "new-key-pair"
}



# jenkins insatnce type

variable "instance_type_jenkins" {
  type    = string
  default = "c7i-flex.large"
}