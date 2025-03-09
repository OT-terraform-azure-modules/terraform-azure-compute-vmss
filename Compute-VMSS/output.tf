output "vmss_names" {
  value = [for vmss in azurerm_linux_virtual_machine_scale_set.modular_vmss : vmss.name]
}
