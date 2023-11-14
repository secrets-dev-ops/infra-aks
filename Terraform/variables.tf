variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create "
  type        = string
}
  

variable "region" {
    type = string
    description = "Deployment Region"
}

variable "prefix_name" {
    type = string
    description = "Prefix for resources names"
}

variable "acr_id"{
    type = string
    description = "id for acr"
}

