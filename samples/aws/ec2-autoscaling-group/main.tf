locals {
  deployment_options = {
    stack       = var.deployment.stack
    service     = var.deployment.service
    environment = coalesce(var.deployment.environment, terraform.workspace)
  }
}

locals {
  deployment = {
    name        = "${local.deployment_options.stack}.${local.deployment_options.service}.${local.deployment_options.environment}"
    stack       = local.deployment_options.stack
    service     = local.deployment_options.service
    environment = local.deployment_options.environment
  }
}

locals {
  aws_options = {
    region = var.aws.region

    tags = {
      Deployment  = local.deployment.name
      Stack       = local.deployment.stack
      Service     = local.deployment.service
      Environment = local.deployment.environment
    }
  }
}

locals {
  resource_group_options = {
    name  = local.deployment.name
    query = <<JSON
{
  "ResourceTypeFilters": [ "AWS::AllSupported" ],
  "TagFilters": [ { "Key": "Deployment", "Values": [ "${local.aws_options.tags.Deployment}" ] } ]
}
JSON
  }
}

resource "aws_resourcegroups_group" "default" {
  name = local.resource_group_options.name

  resource_query {
    query = local.resource_group_options.query
  }

  tags = {
    Name = local.resource_group_options.name
  }
}

locals {
  aws = {
    region = local.aws_options.region

    tags = local.aws_options.tags

    resource_group_id   = aws_resourcegroups_group.default.id
    resource_group_name = aws_resourcegroups_group.default.name
  }
}
