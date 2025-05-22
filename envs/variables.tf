variable "ec2_resources" {
  type = list(object({
    name    = string
    tags    = map(string)
    storage = number
  }))
}
