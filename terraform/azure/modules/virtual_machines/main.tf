locals {
  vm_web_name     = "VM-Web-${var.resource_group_name}"
  vm_web_username = "${var.vm_username}"
  vm_web_os_disk  = "OS-Web-${var.resource_group_name}"
  vm_web_ssh      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy3wPpl4Ll7me1drv7iSg1t3ryQbDHzdkjX3Hw/DlYBLdGzPp8RbaLNcPwOx1l8A2tfgYNwo9jKCDumGzhB0kG6mWu82SjXFymkssh3vO07+YUtOG1RkAHWPaghhQL03W9ah40DoRHnurvRtn5/onsrcrIGVXVDq678rGtNkklJqJUDqxkhYg4vb+/1pVhd0uftvnOBaVyGPDPHQSZdwgcfGpAybqLwp9HUbtHCNL3Rhcr8breN3PCJN9MYhGrZX/RzoGAw8gHERqfghlQIsQ+hjXfpI71W4pLKTA2SQe4gd11OjL2sKu8SAQW/VFunsKKAMKEF/Ivzpdq+C+zqwPr"

  vm_db_name     = "VM-Db-${var.resource_group_name}"
  vm_db_username = "${var.vm_username}"
  vm_db_os_disk  = "OS-Db-${var.resource_group_name}"
  vm_db_ssh      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7v/3a5qoIwmQhC4V7bFTdCx4at785jf+RqMJGx/oX47B3MJ1qajfGClMLPdfsL++lMoDZJ/tJnOmLigQVMliiEFzhwYd5LDtbA0Po7r+R3XnjUWjsRPifDO9Dw+ojgET0KwW/J50mBQzGwY56S/CKCNrgNkDwaMKI70e+ii6GMyqUyUE14Cpy3r5GSZvs/rAst547nqXm0ucuA5G4mx+5kafeOHxaYT/D3ezPKyxM9DqYKxgQmPlSQzZcPqacH8oTXZ/+wRiT67g6XtjVIEXiooDxYOv21XjVzY9P52RI0/DNKHRrARK2OJ4ulLxFLuiNgOGrAdVH3PmjyAW0ScLn"
}

resource "azurerm_virtual_machine" "web_virtual_machine" {
  name                  = "${local.vm_web_name}"
  resource_group_name   = "${var.resource_group_name}"
  location              = "${var.resource_group_location}"
  network_interface_ids = ["${var.nic_web_id}"]
  vm_size               = "Basic_A0"

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${local.vm_web_ssh}"

      path = "/home/${local.vm_web_username}/.ssh/authorized_keys"
    }
  }

  os_profile {
    computer_name  = "${local.vm_web_name}"
    admin_username = "${local.vm_web_username}"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.4"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.vm_web_os_disk}"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

resource "azurerm_virtual_machine" "db_virtual_machine" {
  name                  = "${local.vm_db_name}"
  resource_group_name   = "${var.resource_group_name}"
  location              = "${var.resource_group_location}"
  network_interface_ids = ["${var.nic_db_id}"]
  vm_size               = "Basic_A0"

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = "${local.vm_db_ssh}"
      path     = "/home/${local.vm_db_username}/.ssh/authorized_keys"
    }
  }

  os_profile {
    computer_name  = "${local.vm_db_name}"
    admin_username = "${local.vm_db_username}"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.4"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.vm_db_os_disk}"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}
