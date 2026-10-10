output "vm_count" {
  value = module.vm_fleet.vm_count
}

output "vm_names" {
  value = module.vm_fleet.vm_names
}

output "vm_public_ips" {
  value = module.vm_fleet.public_ips
}

output "eks_cluster_name" {
  value = var.enable_kubernetes ? module.kubernetes[0].cluster_name : null
}
