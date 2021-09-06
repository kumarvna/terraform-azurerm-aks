variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = false
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "kubernetes_cluster_name" {
  description = "The name of the Azure Kubernetes cluster"
  default     = ""
}
variable "cluster_dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster"
  default     = null
}

variable "dns_prefix_private_cluster" {
  description = "Specifies the DNS prefix to use with private clusters"
  default     = null
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are `patch`, `rapid`, `node-image` and `stable`."
  default     = null
}

variable "api_server_authorized_ip_ranges" {
  description = "The IP ranges to allow for incoming traffic to the server nodes."
  type        = list(string)
  default     = []
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used for the Nodes and Volumes"
  default     = null
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)"
  default     = ""
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist"
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to `false`"
  default     = false
}

variable "aks_sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are `Free` and `Paid` (which includes the Uptime SLA). Defaults to `Free`"
  default     = "Free"
}

variable "private_dns_zone_name" {
  description = "The name of the the Private DNS Zone which should be delegated to AKS Cluster"
  default     = null
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                         = string
    vm_size                      = string
    availability_zones           = optional(list(string))
    enable_auto_scaling          = optional(bool)
    enable_host_encryption       = optional(bool)
    enable_node_public_ip        = optional(bool)
    fips_enabled                 = optional(bool)
    local_account_disabled       = optional(bool)
    max_pods                     = optional(number)
    node_public_ip_prefix_id     = optional(string)
    node_labels                  = optional(map(string))
    only_critical_addons_enabled = optional(bool)
    orchestrator_version         = optional(string)
    os_disk_size_gb              = optional(number)
    os_disk_type                 = optional(string)
    pod_subnet_id                = optional(string)
    type                         = optional(string)
    ultra_ssd_enabled            = optional(bool)
    vnet_subnet_id               = optional(string)
    max_count                    = optional(number)
    min_count                    = optional(number)
    node_count                   = optional(number)
    upgrade_settings = optional(object({
      max_surge = number
    }))
  })
}

variable "kubelet_config" {
  description = "A subset of the Kubelet's configuration parameters"
  type = object({
    allowed_unsafe_sysctls    = optional(list(string))
    container_log_max_line    = optional(number)
    container_log_max_size_mb = optional(number)
    cpu_cfs_quota_enabled     = optional(bool)
    cpu_cfs_quota_period      = optional(number)
    cpu_manager_policy        = optional(string)
    image_gc_high_threshold   = optional(number)
    image_gc_low_threshold    = optional(number)
    pod_max_pid               = optional(number)
    topology_manager_policy   = optional(string)
  })
  default = {}
}

variable "linux_os_config" {
  description = "Linux OS configuration for Kubernete cluster default node pool"
  type = object({
    swap_file_size_mb             = optional(number)
    transparent_huge_page_defrag  = optional(string)
    transparent_huge_page_enabled = optional(string)
    sysctl_config = optional(object({
      fs_aio_max_nr                      = optional(number)
      fs_file_max                        = optional(number)
      fs_inotify_max_user_watches        = optional(number)
      fs_nr_open                         = optional(number)
      kernel_threads_max                 = optional(number)
      net_core_netdev_max_backlog        = optional(number)
      net_core_optmem_max                = optional(number)
      net_core_rmem_default              = optional(number)
      net_core_rmem_max                  = optional(number)
      net_core_somaxconn                 = optional(number)
      net_core_wmem_default              = optional(number)
      net_core_wmem_max                  = optional(number)
      net_ipv4_ip_local_port_range_max   = optional(number)
      net_ipv4_ip_local_port_range_min   = optional(number)
      net_ipv4_neigh_default_gc_thresh1  = optional(number)
      net_ipv4_neigh_default_gc_thresh2  = optional(number)
      net_ipv4_neigh_default_gc_thresh3  = optional(number)
      net_ipv4_tcp_fin_timeout           = optional(number)
      net_ipv4_tcp_keepalive_intvl       = optional(number)
      net_ipv4_tcp_keepalive_probes      = optional(number)
      net_ipv4_tcp_keepalive_time        = optional(number)
      net_ipv4_tcp_max_syn_backlog       = optional(number)
      net_ipv4_tcp_max_tw_buckets        = optional(number)
      net_ipv4_tcp_tw_reuse              = optional(number)
      net_netfilter_nf_conntrack_buckets = optional(number)
      net_netfilter_nf_conntrack_max     = optional(number)
      vm_max_map_count                   = optional(number)
      vm_swappiness                      = optional(number)
      vm_vfs_cache_pressure              = optional(number)
    }))
  })
  default = {}
}

variable "addon_profile" {
  description = "addon profile for Azure kubenetes cluser"
  type = object({
    aci_connector_linux = optional(object({
      enabled     = bool
      subnet_name = string
    }))
    azure_policy = optional(object({
      enabled = bool
    }))
    http_application_routing = optional(object({
      enabled = bool
    }))
    kube_dashboard = optional(object({
      enabled = bool
    }))
    ingress_application_gateway = optional(object({
      enabled      = bool
      gateway_id   = string
      gateway_name = string
      subnet_cidr  = string
      subnet_id    = string
    }))
  })
  default = {}
}

variable "auto_scaler_profile" {
  description = "value"
  type = object({
    balance_similar_node_groups      = bool
    expander                         = string
    max_graceful_termination_sec     = number
    max_node_provisioning_time       = string
    max_unready_nodes                = number
    max_unready_percentage           = number
    new_pod_scale_up_delay           = string
    scale_down_delay_after_add       = string
    scale_down_delay_after_delete    = string
    scale_down_delay_after_failure   = string
    scan_interval                    = string
    scale_down_unneeded              = string
    scale_down_unready               = string
    scale_down_utilization_threshold = string
    empty_bulk_delete_max            = number
    skip_nodes_with_local_storage    = bool
    skip_nodes_with_system_pods      = bool
  })
  default = null
}

variable "network_profile" {
  description = "value"
  type = object({
    network_plugin     = string
    network_mode       = optional(string)
    dns_service_ip     = optional(string)
    docker_bridge_cidr = optional(string)
    outbound_type      = optional(string)
    pod_cidr           = optional(list(string))
    service_cidr       = optional(list(string))
    load_balancer_sku  = optional(string)
    load_balancer_profile = optional(object({
      outbound_ports_allocated  = optional(number)
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
      outbound_ip_prefix_ids    = optional(list(string))
      outbound_ip_address_ids   = optional(list(string))
    }))
  })
  default = null
}

variable "log_analytics_workspace_name" {
  description = "The name of log analytics workspace name"
  default     = null
}

variable "storage_account_name" {
  description = "The name of the hub storage account to store logs"
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
