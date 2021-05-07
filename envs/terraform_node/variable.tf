variable "standard_tags" {
  default = {
    project = "terraform_node"      # Change here with your preferred name
    environment = "development"
  }
  description = "Tags to be applied to all resources"
  type = map(string)
}
