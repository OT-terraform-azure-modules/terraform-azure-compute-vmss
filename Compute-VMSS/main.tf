data "azurerm_resource_group" "modular_rg" {
  name = var.resource_group_name
}

resource "azurerm_network_interface" "modular_nic" {
  for_each = var.network_interfaces

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "modular_vmss" {
  for_each = var.virtual_machine_scale_sets

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = each.value.sku
  instances           = each.value.instances
  admin_username      = each.value.admin_username

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file(each.value.ssh_public_key)
  }

  network_interface {
    name                      = "${each.value.name}-nic"
    primary                   = true
#    network_security_group_id  = each.value.nsg_id
    ip_configuration {
      name                          = "internal"
      subnet_id                     = each.value.subnet_id
      primary                       = true
    }
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags                = var.tag_map
}

resource "azurerm_monitor_autoscale_setting" "modular_autoscale" {
  for_each = var.autoscale_settings

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.modular_vmss[each.value.vmss_key].id

  profile {
    name = "default"

    capacity {
      default = each.value.default_capacity
      minimum = each.value.min_capacity
      maximum = each.value.max_capacity
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.modular_vmss[each.value.vmss_key].id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = each.value.cpu_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
