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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
