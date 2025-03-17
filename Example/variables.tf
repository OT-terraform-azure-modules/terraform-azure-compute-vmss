variable "resource_group_name" {
  description = "The name of the existing resource group."
  type        = string
}

variable "network_interfaces" {
  description = "Map of network interfaces."
  type = map(object({
    name      = string
    subnet_id = string
  }))
}

variable "tag_map" {
  description = "The tags to associate with the VMSS."
  type        = map(string)
  default     = {}
}

variable "virtual_machine_scale_sets" {
  description = "Map of VMSS instances."
  type = map(object({
    name             = string
    subnet_id        = string
#    nsg_id           = string
    sku              = string
    instances        = number
    admin_username   = string
    ssh_public_key   = string
    image            = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    image_id = string
  }))
}

variable "autoscale_settings" {
  description = "Map of autoscaling settings."
  type = map(object({
    name            = string
    vmss_key        = string
    default_capacity = number
    min_capacity     = number
    max_capacity     = number
    cpu_threshold    = number
  }))
}
