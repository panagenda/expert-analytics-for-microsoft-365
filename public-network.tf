# creates virtual network
resource "azurerm_virtual_network" "oe" {
  name                = "${var.prefix}-network"
  count               = var.subnet == "" ? 1 : 0
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.oe.location
  resource_group_name = azurerm_resource_group.oe.name
}

# creates internal subnet
resource "azurerm_subnet" "oe" {
  name                 = "${var.prefix}-subnet"
  count                = var.subnet == "" ? 1 : 0
  resource_group_name  = azurerm_resource_group.oe.name
  virtual_network_name = azurerm_virtual_network.oe[0].name
  address_prefix       = "10.0.2.0/24"
}
# requests public ip
resource "azurerm_public_ip" "oe" {
  name                    = "${var.prefix}-pip"
  count                   = var.subnet == "" ? 1 : 0
  location                = azurerm_resource_group.oe.location
  resource_group_name     = azurerm_resource_group.oe.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = {
    environment = var.tags
  }
}

# creates network security group
resource "azurerm_network_security_group" "oe" {
  name                        = "${var.prefix}-secgroup"
  count                       = var.subnet == "" ? 1 : 0
  location                    = azurerm_resource_group.oe.location
  resource_group_name         = azurerm_resource_group.oe.name
}

# creates network security group roles
resource "azurerm_network_security_rule" "oe_ssh" {
  name                        = "${var.prefix}-sec-role-ssh"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

resource "azurerm_network_security_rule" "oe_http" {
  name                        = "${var.prefix}-sec-role-http"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

resource "azurerm_network_security_rule" "oe_https" {
  name                        = "${var.prefix}-sec-role-https"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

resource "azurerm_network_security_rule" "oe_vnc" {
  name                        = "${var.prefix}-sec-role-vnc"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "5901"
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

resource "azurerm_network_security_rule" "oe_incoming" {
  name                        = "${var.prefix}-sec-role-oe-incoming"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["127.0.0.1", azurerm_public_ip.oe[0].ip_address]
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name

  depends_on = [azurerm_public_ip.oe]
}

resource "azurerm_network_security_rule" "oe_bots_zookeeper" {
  name                        = "${var.prefix}-sec-role-oe-bots-zookeeper"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "22181"
  source_address_prefixes     = var.source_address_prefixes_bots
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

resource "azurerm_network_security_rule" "oe_bots_kafka" {
  name                        = "${var.prefix}-sec-role-oe-bots-kafka"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 107
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "29092"
  source_address_prefixes     = var.source_address_prefixes_bots
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

  resource "azurerm_network_security_rule" "oe_public_https" {
  name                        = "${var.prefix}-sec-role-oe-public-https"
  count                       = var.subnet == "" ? 1 : 0
  priority                    = 108
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "4443"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = azurerm_resource_group.oe.name
  network_security_group_name = azurerm_network_security_group.oe[0].name
}

# creates nic
resource "azurerm_network_interface" "oe-custom-public" {
  name                      = "${var.prefix}-nic"
  count                     = var.subnet == "" ? 1 : 0
  location                  = azurerm_resource_group.oe.location
  resource_group_name       = azurerm_resource_group.oe.name

  ip_configuration {
    name                          = "${var.prefix}-nic"
    subnet_id                     = azurerm_subnet.oe[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.oe[0].id
  }
}

resource "azurerm_subnet_network_security_group_association" "oe-custom-public-security-group" {
  network_security_group_id = azurerm_network_security_group.oe[0].id
  subnet_id = azurerm_subnet.oe[0].id
}
