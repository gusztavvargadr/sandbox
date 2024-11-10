output "deployment" {
  value = local.deployment
}

output "aws" {
  value = local.aws
}

output "s3" {
  value = local.s3
}

output "bootstrap_launch_template" {
  value = local.bootstrap_launch_template
}

output "bootstrap_autoscaling_group" {
  value = local.bootstrap_autoscaling_group
}

output "bootstrap_instances" {
  value = local.bootstrap_instances
}

output "server_launch_template" {
  value = local.server_launch_template
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
