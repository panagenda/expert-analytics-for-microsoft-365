# creates a resource group
resource "azurerm_resource_group" "oe" {
  name     = var.resource_group_name
  location = var.location
}

# Random string for resources
resource "random_string" "id" {
  length = 8
  special = false
  lower = false
  upper = false
  number = true
}

# storage account which stores the vm template
resource "azurerm_storage_account" "oe" {
  name = "${var.prefix}sa${random_string.id.result}"
  resource_group_name = azurerm_resource_group.oe.name
  location            = azurerm_resource_group.oe.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# storage container
resource "azurerm_storage_container" "oe" {
  name = "${var.prefix}sc${random_string.id.result}"
  storage_account_name = azurerm_storage_account.oe.name
  container_access_type = "private"
}

# template
resource "azurerm_storage_blob" "oe" {
  name = "oe.vhd"
  storage_account_name = azurerm_storage_account.oe.name
  storage_container_name = azurerm_storage_container.oe.name
  source_uri = var.source_vhd_path
  type = "Page"

  lifecycle {
    # enable to prevent recreation
    prevent_destroy = "false"
  }
}

# imports managed disk
resource "azurerm_managed_disk" "oe" {

  name                 = "${var.prefix}-osdisk"
  location             = azurerm_resource_group.oe.location
  resource_group_name  = azurerm_resource_group.oe.name
  storage_account_type = "Standard_LRS"
  create_option        = "Import"
  os_type              = "Linux"
  source_uri           = azurerm_storage_blob.oe.url
  storage_account_id   = azurerm_storage_account.oe.id
  disk_size_gb         = "20"

  depends_on = [ azurerm_storage_blob.oe ]
}
