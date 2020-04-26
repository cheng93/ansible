locals {
    blog_storage_name = "storageblog${var.resource_group_name}"
}

resource "azurerm_storage_account" "storage_blog" {
    name                     = local.blog_storage_name
    resource_group_name      = var.resource_group_name
    location                 = var.resource_group_location
    account_tier              = "Standard"
    account_replication_type = "LRS"
    
    static_website {
        index_document = "index.html"
    }
}

output "storage_blog_host_name" {
  value = azurerm_storage_account.storage_blog.primary_web_host
}
