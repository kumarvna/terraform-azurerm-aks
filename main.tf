#---------------------------------
# Local declarations
#---------------------------------
locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}

#---------------------------------------------------------
# Resource Group Creation or selection - Default is "true"
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = local.location
}



resource "azurerm_private_dns_zone" "main" {
  count               = var.private_dns_zone_name != null ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "AKS-Private-DNS-Zone") }, var.tags, )
}

#--------------------------------------------------------------------------
# Managed Kubernetes Cluster (also known as AKS / Azure Kubernetes Service
#--------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                                = format("aks-%s", var.kubernetes_cluster_name)
  resource_group_name                 = local.resource_group_name
  location                            = local.location
  dns_prefix                          = var.cluster_dns_prefix == null ? var.kubernetes_cluster_name : var.cluster_dns_prefix
  dns_prefix_private_cluster          = var.dns_prefix_private_cluster
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  api_server_authorized_ip_ranges     = var.api_server_authorized_ip_ranges
  disk_encryption_set_id              = var.disk_encryption_set_id
  kubernetes_version                  = var.kubernetes_version
  node_resource_group                 = var.node_resource_group
  private_cluster_enabled             = var.private_cluster_public_fqdn_enabled == true ? true : false
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = var.private_dns_zone_name != null ? azurerm_private_dns_zone.main.0.id : "System"
  sku_tier                            = var.aks_sku_tier
  tags                                = merge({ "ResourceName" = format("aks-%s", var.kubernetes_cluster_name) }, var.tags, )

  default_node_pool {
    name                   = format("%s", var.default_node_pool.name)
    vm_size                = var.default_node_pool.vm_size
    availability_zones     = var.default_node_pool.type == "VirtualMachineScaleSets" && var.network_profile.load_balancer_sku == "Standard" ? var.default_node_pool.availability_zones : null
    enable_auto_scaling    = var.default_node_pool.type == "VirtualMachineScaleSets" ? lookup(var.default_node_pool, "enable_auto_scaling", false) : false
    enable_host_encryption = lookup(var.default_node_pool, "enable_host_encryption", false)
    enable_node_public_ip  = lookup(var.default_node_pool, "enable_node_public_ip", false)
    fips_enabled           = var.default_node_pool.fips_enabled
    kubelet_disk_type      = "OS"
    #    local_account_disabled   = var.default_node_pool.local_account_disabled
    max_pods                 = var.default_node_pool.max_pods
    node_public_ip_prefix_id = var.default_node_pool.enable_node_public_ip == true ? var.default_node_pool.node_public_ip_prefix_id : null
    node_labels              = var.default_node_pool.node_labels

    # Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint.
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled

    # This version must be supported by the Kubernetes Cluster - as such the version of Kubernetes used on the Cluster/Control Plane may need to be upgraded first.
    orchestrator_version = var.default_node_pool.orchestrator_version

    # The size of the OS Disk which should be used for each agent in the Node Pool.
    os_disk_size_gb = var.default_node_pool.os_disk_size_gb

    # The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed
    os_disk_type = var.default_node_pool.os_disk_type

    # The ID of the Subnet where the pods in the default Node Pool should exist.
    pod_subnet_id     = var.default_node_pool.pod_subnet_id
    type              = var.default_node_pool.type
    tags              = merge({ "ResourceName" = format("%s", var.default_node_pool.name) }, var.tags, )
    ultra_ssd_enabled = var.default_node_pool.ultra_ssd_enabled

    # The ID of a Subnet where the Kubernetes Node Pool should exist. A Route Table must be configured on this Subnet.
    vnet_subnet_id = var.default_node_pool.vnet_subnet_id
    max_count      = var.default_node_pool.enable_auto_scaling == true ? var.default_node_pool.max_count : null
    min_count      = var.default_node_pool.enable_auto_scaling == true ? var.default_node_pool.min_count : null
    node_count     = var.default_node_pool.enable_auto_scaling == false ? var.default_node_pool.node_count : null

    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings
      content {
        max_surge = upgrade_settings.value.max_surge
      }
    }

    dynamic "kubelet_config" {
      for_each = var.kubelet_config
      content {
        allowed_unsafe_sysctls    = kubelet_config.value.allowed_unsafe_sysctls
        container_log_max_line    = kubelet_config.value.container_log_max_line
        container_log_max_size_mb = kubelet_config.value.container_log_max_size_mb
        cpu_cfs_quota_enabled     = kubelet_config.value.cpu_cfs_quota_enabled
        cpu_cfs_quota_period      = kubelet_config.value.cpu_cfs_quota_period
        cpu_manager_policy        = kubelet_config.value.cpu_manager_policy
        image_gc_high_threshold   = kubelet_config.value.image_gc_high_threshold
        image_gc_low_threshold    = kubelet_config.value.image_gc_low_threshold
        pod_max_pid               = kubelet_config.value.pod_max_pid
        topology_manager_policy   = kubelet_config.value.topology_manager_policy
      }
    }

    dynamic "linux_os_config" {
      for_each = var.linux_os_config
      content {
        swap_file_size_mb             = linux_os_config.value.swap_file_size_mb
        transparent_huge_page_defrag  = linux_os_config.value.transparent_huge_page_defrag
        transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page_enabled

        dynamic "sysctl_config" {
          for_each = linux_os_config.value.sysctl_config
          content {
            fs_aio_max_nr                      = linux_os_config.value.fs_aio_max_nr
            fs_file_max                        = linux_os_config.value.fs_file_max
            fs_inotify_max_user_watches        = linux_os_config.value.fs_inotify_max_user_watches
            fs_nr_open                         = linux_os_config.value.fs_nr_open
            kernel_threads_max                 = linux_os_config.value.kernel_threads_max
            net_core_netdev_max_backlog        = linux_os_config.value.net_core_netdev_max_backlog
            net_core_optmem_max                = linux_os_config.value.net_core_optmem_max
            net_core_rmem_default              = linux_os_config.value.net_core_rmem_default
            net_core_rmem_max                  = linux_os_config.value.net_core_rmem_max
            net_core_somaxconn                 = linux_os_config.value.net_core_somaxconn
            net_core_wmem_default              = linux_os_config.value.net_core_wmem_default
            net_core_wmem_max                  = linux_os_config.value.net_core_wmem_max
            net_ipv4_ip_local_port_range_max   = linux_os_config.value.net_ipv4_ip_local_port_range_max
            net_ipv4_ip_local_port_range_min   = linux_os_config.value.net_ipv4_ip_local_port_range_min
            net_ipv4_neigh_default_gc_thresh1  = linux_os_config.value.net_ipv4_neigh_default_gc_thresh1
            net_ipv4_neigh_default_gc_thresh2  = linux_os_config.value.net_ipv4_neigh_default_gc_thresh2
            net_ipv4_neigh_default_gc_thresh3  = linux_os_config.value.net_ipv4_neigh_default_gc_thresh3
            net_ipv4_tcp_fin_timeout           = linux_os_config.value.net_ipv4_tcp_fin_timeout
            net_ipv4_tcp_keepalive_intvl       = linux_os_config.value.net_ipv4_tcp_keepalive_intvl
            net_ipv4_tcp_keepalive_probes      = linux_os_config.value.net_ipv4_tcp_keepalive_probes
            net_ipv4_tcp_keepalive_time        = linux_os_config.value.net_ipv4_tcp_keepalive_time
            net_ipv4_tcp_max_syn_backlog       = linux_os_config.value.net_ipv4_tcp_max_syn_backlog
            net_ipv4_tcp_max_tw_buckets        = linux_os_config.value.net_ipv4_tcp_max_tw_buckets
            net_ipv4_tcp_tw_reuse              = linux_os_config.value.net_ipv4_tcp_tw_reuse
            net_netfilter_nf_conntrack_buckets = linux_os_config.value.net_netfilter_nf_conntrack_buckets
            net_netfilter_nf_conntrack_max     = linux_os_config.value.net_netfilter_nf_conntrack_max
            vm_max_map_count                   = linux_os_config.value.vm_max_map_count
            vm_swappiness                      = linux_os_config.value.vm_swappiness
            vm_vfs_cache_pressure              = linux_os_config.value.vm_vfs_cache_pressure
          }
        }
      }
    }

  }

  dynamic "addon_profile" {
    for_each = var.addon_profile
    content {

      dynamic "aci_connector_linux" {
        for_each = addon_profile.value.aci_connector_linux
        content {
          enabled     = aci_connector_linux.value.enabled
          subnet_name = aci_connector_linux.value.subnet_name
        }
      }

      dynamic "azure_policy" {
        for_each = addon_profile.value.azure_policy
        content {
          enabled = azure_policy.value.enabled
        }
      }

      dynamic "http_application_routing" {
        for_each = addon_profile.value.http_application_routing
        content {
          enabled = http_application_routing.value.enabled
        }
      }

      dynamic "kube_dashboard" {
        for_each = addon_profile.value.kube_dashboard
        content {
          enabled = kube_dashboard.value.enabled
        }
      }

      dynamic "oms_agent" {
        for_each = var.log_analytics_workspace_name != null ? [1] : [0]
        content {
          enabled                    = var.log_analytics_workspace_name != null ? true : false
          log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logws.0.id
        }
      }

      dynamic "ingress_application_gateway" {
        for_each = addon_profile.value.ingress_application_gateway
        content {
          # If using enabled in conjunction with only_critical_addons_enabled, the AGIC pod will fail to start. A separate azurerm_kubernetes_cluster_node_pool is required to run the AGIC pod successfully. This is because AGIC is classed as a "non-critical addon".
          enabled      = lookup(ingress_application_gateway.value, "enabled", false)
          gateway_id   = ingress_application_gateway.value.gateway_id
          gateway_name = ingress_application_gateway.value.gateway_name
          subnet_cidr  = ingress_application_gateway.value.subnet_cidr
          subnet_id    = ingress_application_gateway.value.subnet_id
        }
      }
    }
  }

  dynamic "auto_scaler_profile" {

  }

  dynamic "identity" {

  }

  dynamic "kubelet_identity" {

  }

  dynamic "linux_profile" {

  }

  dynamic "maintenance_window" {

  }

  dynamic "network_profile" {
    for_each = var.network_profile != null ? [var.network_profile] : []
    content {
      # When network_plugin is set to `azure` - the `vnet_subnet_id` field in the `default_node_pool` block must be set and `pod_cidr` must not be set.
      network_plugin     = lookup(network_profile.value, "network_plugin", "kubenet")
      network_mode       = network_profile.value.network_plugin == "azure" ? network_profile.value.network_mode : null
      network_policy     = network_profile.value.network_plugin == "azure" ? "azure" : "calico"
      dns_service_ip     = network_profile.value.dns_service_ip
      docker_bridge_cidr = network_profile.value.docker_bridge_cidr
      outbound_type      = lookup(network_profile.value, "outbound_type", "loadBalancer")

      # This range should not be used by any network element on or connected to this VNet. Service address CIDR must be smaller than /12. docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set.  
      pod_cidr          = network_profile.value.network_plugin == "kubenet" ? network_profile.value.pod_cidr : null
      service_cidr      = network_profile.value.service_cidr
      load_balancer_sku = lookup(network_profile.value, "load_balancer_sku", "Standard")

      dynamic "load_balancer_profile" {
        for_each = network_profile.value.load_balancer_profile[*]
        content {
          outbound_ports_allocated = load_balancer_profile.value.outbound_ports_allocated
          idle_timeout_in_minutes  = load_balancer_profile.value.idle_timeout_in_minutes
          # User has to explicitly set `managed_outbound_ip_count` to empty slice ([]) to remove it.
          managed_outbound_ip_count = lookup(load_balancer_profile.value, "managed_outbound_ip_count", [])

          # User has to explicitly set `outbound_ip_prefix_ids` to empty slice ([]) to remove it.
          outbound_ip_prefix_ids = lookup(load_balancer_profile.value, "outbound_ip_prefix_ids", [])

          # User has to explicitly set outbound_ip_address_ids to empty slice ([]) to remove it.
          outbound_ip_address_ids = lookup(load_balancer_profile.value, "outbound_ip_address_ids", [])
        }
      }
    }
  }

  dynamic "role_based_access_control" {

  }

  dynamic "service_principal" {

  }

  dynamic "windows_profile" {

  }

}
