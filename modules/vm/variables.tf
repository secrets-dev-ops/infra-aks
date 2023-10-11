variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default = "myvm"
}

variable "vm_location" {
  description = "The Azure Region in which the virtual machine should be created"
  type        = string
  default = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the virtual machine should be created"
  type        = string
  default = "myrg"
}
  
variable "network_interface_ids" {
  description = "The IDs of the network interfaces to attach to the virtual machine"
  type        = list(string)
  default = ["nic1"]
}