# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "aks" {
  //source  = "kumarvna/aks/azurerm"
  //version = "1.0.0"
  source = "../../"

  # By default, this module will not create a resource group. Location will be same as existing RG.
  # proivde a name to use an existing resource group, specify the existing resource group name, 
  # set the argument to `create_resource_group = true` to create new resrouce group.
  resource_group_name     = "rg-shared-westeurope-01"
  location                = "westeurope"
  kubernetes_cluster_name = "example-aks-demo1"
  kubernetes_version      = "1.20.9"

  node_pools = {
    np1 = {
      name       = "default"
      node_count = 2
      vm_size    = "Standard_D2_v2"
    },
  }

  linux_profile = {
    admin_username = "hademoadmin"
  }

  windows_profile = {
    admin_password = "haddemoadmin"
    admin_username = "P@$$W0rd@123"
  }

  /*   service_principal = {
    client_id = "${module.service-principal.client_id}"
    client_secret = "${module.service-principal.client_secret}"
  } */

  # (Optional) To enable Azure Monitoring for Azure Frontdoor
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage. 
  log_analytics_workspace_name = "loganalytics-we-sharedtest2"

  # Adding TAG's to your Azure resources 
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}

/* 
module "service-principal" {
  source                     = "kumarvna/service-principal/azuread"
  version                    = "2.1.0"
  service_principal_name     = "simple-appaccess"
  password_rotation_in_years = 1
}
 */

/* 
node_pools = {
  "key" = {
    availability_zones = [ "value" ]
    enable_auto_scaling = false
    enable_host_encryption = false
    enable_node_public_ip = false
    fips_enabled = false
    local_account_disabled = false
    max_count = 1
    max_pods = 1
    min_count = 1
    name = "value"
    node_count = 1
    node_labels = {
      "key" = "value"
    }
    node_public_ip_prefix_id = "value"
    only_critical_addons_enabled = false
    orchestrator_version = "value"
    os_disk_size_gb = 1
    os_disk_type = "value"
    pod_subnet_id = "value"
    type = "value"
    ultra_ssd_enabled = false
    upgrade_settings = {
      max_surge = 1
    }
    vm_size = "value"
    vnet_subnet_id = "value"
  }
} 
*/
