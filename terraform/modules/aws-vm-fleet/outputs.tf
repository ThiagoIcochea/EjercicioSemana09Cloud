output "vm_count" {
  value = length(aws_instance.vm)
}

output "vm_names" {
  value = sort([for k, _ in aws_instance.vm : k])
}

output "public_ips" {
  value = { for k, vm in aws_instance.vm : k => vm.public_ip }
}
