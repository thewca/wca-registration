# Infrastructure

The infrastructure for running the WCA Registration Service.

## Setup

First, install terraform and initialize with:

```
terraform init
terraform workspace select prod || terraform workspace new prod
```

To apply changes run:

```
terraform apply
```

## Details

The WCA Registration System runs on a single Docker container

### App

We use ECS to run the app container(s). Currently the service runs on one t3.small instance which can house up to two containers

### Deployment

To automate deployment we use a CodePipeline that is triggered by pushing a new app image to ECR. The pipeline:

  1. Sources the new ECR image arn.
  2. Prepares files necessary for CodeDeploy (`appspec.yaml`, `taskdef.json`)
  3. Triggers CodeDeploy to do Blue/Green deployment.
