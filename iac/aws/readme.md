# AWS - Terraform

## Requirements

- [AWS Account](https://aws.amazon.com/)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Steps

### Terraform

Follow the documentation to use AWS provider in terraform: [https://registry.terraform.io/providers/hashicorp/aws/latest/docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

```shell
terraform init
terraform apply
aws eks --region $(terraform output -raw region) update-kubeconfig \
    --name $(terraform output -raw cluster_name)
```

### Kubernetes

Open telemetrics steps

1. Invoke script
```shell
kubectl apply --namespace otel-demo -f ../../kubernetes/opentelemetry-demo.yaml
```

## Destroy

In order to destroy:

```shell
kubectl delete --namespace otel-demo -f ../../kubernetes/opentelemetry-demo.yaml
terraform destroy
```