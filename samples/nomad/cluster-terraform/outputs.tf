output "deployment" {
  value = local.deployment
}

output "aws" {
  value = local.aws
}

output "launch_template" {
  value = local.launch_template
}

output "s3" {
  value = local.s3
}

output "bootstrap_autoscaling_group" {
  value = local.bootstrap_autoscaling_group
}

output "bootstrap_instances" {
  value = local.bootstrap_instances
}

output "bootstrap_token" {
  value = local.bootstrap_token
  sensitive = true
}

output "server_autoscaling_group" {
  value = local.server_autoscaling_group
}

output "server_instances" {
  value = local.server_instances
}

output "client_autoscaling_group" {
  value = local.client_autoscaling_group
}

output "client_instances" {
  value = local.client_instances
}
