variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create "
  type        = string
}

variable "resource_group_location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
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

variable "acr_id"{
    type = string
    description = "id for acr"
}

