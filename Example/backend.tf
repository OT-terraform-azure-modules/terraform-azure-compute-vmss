terraform {
  backend "azurerm" {
    resource_group_name = "modular_infra_state_rg"
    storage_account_name = "modulartfstate"
    container_name = "modulartfstatecontainer"
    key = "modular.tfstate"  # Or any other key you prefer
  }
}