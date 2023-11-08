variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create "
  type        = string
}
  
variable "resource_group_location" {
  description = "value of the location"
  type        = string
}

variable "tags" {
  description = "tags for the resource"
  type        = map(any)
  default     = {}
}

variable "region" {
    type = string
    description = "Deployment Region"
}

variable "prefix_name" {
    type = string
    description = "Prefix for resources names"
}

variable "admin_username" {
    type = string
    description = "usuario ssh"
}

variable "admin_password" {
    type = string
    description = "password ssh"
}
