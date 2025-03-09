data "azurerm_resource_group" "modular_rg" {
  name = var.resource_group_name
}

module "compute_vmss" {
  source = "../Compute-VMSS"

  resource_group_name = data.azurerm_resource_group.modular_rg.name
  location           = data.azurerm_resource_group.modular_rg.location
  network_interfaces = var.network_interfaces
  virtual_machine_scale_sets = var.virtual_machine_scale_sets
  autoscale_settings = var.autoscale_settings
  tag_map                = var.tag_map
}
