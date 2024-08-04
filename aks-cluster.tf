# Configure the AzureRM Provider
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Create a Key Vault
resource "azurerm_key_vault" "example" {
  name     = "ronnie-vault"
  location = "centralus"
  resource_group_name = azurerm_resource_group.guru.name

  # Add these arguments
  tenant_id = "65d2d088-58a3-453e-bbd1-8f812655681c" 
  sku_name = "standard"  # Choose the appropriate SKU

}

# Create a Secret in the Key Vault
resource "azurerm_key_vault_secret" "app_id" {
  name         = "app-id"
  key_vault_id = azurerm_key_vault.example.id
  value        = var.appId  # Use var.appId instead of var.app_id
}

resource "azurerm_key_vault_secret" "client_secret" {
  name         = "client-secret"
  key_vault_id = azurerm_key_vault.example.id
  value        = var.password  # Use var.password instead of var.client_secret
}

# Import Resource Group Before Apply
resource "azurerm_resource_group" "guru" {
  name     = "guru"
  location = "centralus"  

  tags = {
    environment = "Demo"
  }
}

# Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "guru" {
  name                = "phib"
  location            = azurerm_resource_group.guru.location
  resource_group_name = azurerm_resource_group.guru.name
  dns_prefix          = "phib-k8s"

  default_node_pool {
    name            = "phib"
    node_count      = 2
    vm_size         = "standard_B2ms"
    os_disk_size_gb = 30
  }

  # Use the secrets from Key Vault
  service_principal {
    client_id     = azurerm_key_vault_secret.app_id.value
    client_secret = azurerm_key_vault_secret.client_secret.value
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
}
