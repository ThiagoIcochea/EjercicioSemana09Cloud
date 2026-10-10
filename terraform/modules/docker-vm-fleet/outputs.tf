output "vm_count" {
  value = length(docker_container.vm)
}

output "vm_names" {
  value = sort([for k, _ in docker_container.vm : k])
}

output "endpoints" {
  value = { for k, p in local.ports : k => "http://localhost:${p}" }
}
