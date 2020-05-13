data "azurerm_subnet" "oe" {
  name                 = var.subnet
  count                = var.subnet == "" ? 0 : 1
  virtual_network_name = var.vnet
  resource_group_name  = var.rg
}

# creates nic
resource "azurerm_network_interface" "oe" {
  name                      = "${var.prefix}-nic"
  count                     = var.subnet == "" ? 0 : 1
  location                  = azurerm_resource_group.oe.location
  resource_group_name       = azurerm_resource_group.oe.name

  ip_configuration {
    name                          = "${var.prefix}-nic"
    subnet_id                     = data.azurerm_subnet.oe[0].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ip
  }
}