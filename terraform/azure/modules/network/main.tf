locals {
  virtual_network_name = "VNet-${var.resource_group_name}"
  virtual_network_cidr = ["10.0.0.0/16"]

  security_group_public_name  = "NSG-Public-${var.resource_group_name}"
  security_group_private_name = "NSG-Private-${var.resource_group_name}"

  subnet_public_name  = "Subnet-Public-${var.resource_group_name}"
  subnet_public_cidr  = "10.0.0.0/24"
  subnet_private_name = "Subnet-Private-${var.resource_group_name}"
  subnet_private_cidr = "10.0.1.0/24"

  nic_public_name  = "NIC-Public-${var.resource_group_name}"
  nic_private_name = "NIC-Private-${var.resource_group_name}"

  ip_name = "IP-${var.resource_group_name}"
}

resource "azurerm_network_security_group" "public_security_group" {
  name                = local.security_group_public_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  security_rule {
    name                       = "Allow-SSH"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "Allow-Http"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 200
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "Allow-Https"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 300
    direction                  = "Inbound"
  }
}

resource "azurerm_network_security_group" "private_security_group" {
  name                = local.security_group_private_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  security_rule {
    name                       = "Allow-SSH"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = local.subnet_public_cidr
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "Allow-Postgres"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 5432
    source_address_prefix      = local.subnet_public_cidr
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 200
    direction                  = "Inbound"
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = local.virtual_network_name
  resource_group_name = var.resource_group_name
  address_space       = local.virtual_network_cidr
  location            = var.resource_group_location
}

resource "azurerm_subnet" "public_subnet" {
  name                 = local.subnet_public_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefix       = local.subnet_public_cidr
}

resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_security_group.id
}

resource "azurerm_subnet" "private_subnet" {
  name                 = local.subnet_private_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefix       = local.subnet_private_cidr
}

resource "azurerm_subnet_network_security_group_association" "private_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_security_group.id
}

resource "azurerm_public_ip" "ip" {
  name                = local.ip_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
  domain_name_label   = lower(var.resource_group_name)
}

resource "azurerm_network_interface" "public_nic" {
  name                      = local.nic_public_name
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location

  ip_configuration {
    name                          = local.ip_name
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "public_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.public_nic.id
  network_security_group_id = azurerm_network_security_group.public_security_group.id
}

resource "azurerm_network_interface" "private_nic" {
  name                      = local.nic_private_name
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location

  ip_configuration {
    name                          = local.ip_name
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "private_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.private_nic.id
  network_security_group_id = azurerm_network_security_group.private_security_group.id
}

output "nic_public_id" {
  value = azurerm_network_interface.public_nic.id
}

output "nic_private_id" {
  value = azurerm_network_interface.private_nic.id
}
