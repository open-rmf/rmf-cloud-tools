variable "standard_tags" {
  default = {
    project = "terraform_node"
    environment = "development"
  }
  description = "Tags to be applied to all resources"
  type = map(string)
}
