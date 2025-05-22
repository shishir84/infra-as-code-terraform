variable "instances" {
  description = "List of EC2 instances to create"
  type = list(object({
    name    = string
    ami     = string 
    tags    = map(string)
    storage = number
  }))
}

resource "aws_instance" "this" {
  count         = length(var.instances)
  ami           = var.instances[count.index].ami 
  instance_type = "t3.micro"

  root_block_device {
    volume_size = var.instances[count.index].storage
  }

  tags = merge({
    "Name" = var.instances[count.index].name
  }, var.instances[count.index].tags)
}
