output "vm_count" {
  value = length(google_compute_instance.vm)
}

output "vm_names" {
  value = sort([for k, _ in google_compute_instance.vm : k])
}

output "public_ips" {
  value = { for k, vm in google_compute_instance.vm : k => vm.network_interface[0].access_config[0].nat_ip }
}
