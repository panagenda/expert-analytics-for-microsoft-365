# creates virtual machine - static puplic ip (custom network deployment)
resource "azurerm_virtual_machine" "oe-custom-public" {
  name                  = "${var.prefix}-vm"
  count                 = var.subnet == "" ? 1 : 0
  location              = azurerm_resource_group.oe.location
  resource_group_name   = azurerm_resource_group.oe.name
  network_interface_ids = [azurerm_network_interface.oe-custom-public[0].id]
  vm_size               = var.vm_size
  # deletes disks on destroy
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    os_type           = "Linux"
    managed_disk_id   = azurerm_managed_disk.oe.id
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "Attach"
  }

  lifecycle {
    # enable to prevent recreation
    prevent_destroy = "false"
  }

  depends_on = [ azurerm_managed_disk.oe ]
}

# creates data disk - static puplic ip (custom network deployment)
resource "azurerm_managed_disk" "oe-data-custom-public" {
  name                 = "${var.prefix}-data"
  count                = var.subnet == "" ? 1 : 0
  location             = azurerm_resource_group.oe.location
  resource_group_name  = azurerm_resource_group.oe.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk
}
resource "azurerm_virtual_machine_data_disk_attachment" "oe-custom-public" {
  managed_disk_id    = azurerm_managed_disk.oe-data-custom-public[0].id
  count                 = var.subnet == "" ? 1 : 0
  virtual_machine_id = azurerm_virtual_machine.oe-custom-public[0].id
  lun                = "1"
  caching            = "ReadWrite"
}
