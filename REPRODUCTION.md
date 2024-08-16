# Reproduction

This project only supports Google Cloud Platform and minikube for deployment.

# REPRODUCTION - Approach 1 - AI-Driven Ticket Generation

To reproduce the AI-Driven Ticket Generation, follow the steps below.

1. Set up envrionment to access required external services (OpenAI API, Notion API)
2. Create infrastructure (locally with minikube, GCP - google cloud)
3. Configure kubernetes services (opentelemetry demo)
4. Execute tests
5. Destroy infrastructure
6. Quantitative Evaluation

## Step 1. Set up envrionment to access required external services

Set required variables in a `.tfvars` file under `iac/gcp`.

List of required variables:
- openai_key:
    1. Login to your OpenAI developer account
    2. Go to [api key page](https://platform.openai.com/api-keys) to create one if you do not have one already
- project_id:
    1. Use the project id from 'Cloud Version: Google Cloud - GCP' section
- notion_apikey:
    1. Go to your notion account and create a workspace
    2. Add an internal integration as described [here](https://www.notion.so/help/create-integrations-with-the-notion-api)
    3. Use the secret api key shown after creation
- notion_db_id:
    1. Create an empty database as shown [here](https://www.notion.so/help/guides/creating-a-database)
    2. Make sure your database page is connected to the internal integration. [Here is how?](https://www.notion.so/help/add-and-manage-connections-with-the-api#add-connections-to-pages)
    3. Use the {database_id} part of your database link which is formatted as follows:
        `https://www.notion.so/{database_id}?v={variable}` 
    4. Make sure you have the following properties on your database:
        - Name (type: Title)
        - Duration (sec) (type: Number with commas)
- model_type (optional):
    1. The default is set to "gpt-4o-mini". If you want to use another model from OpenAI Chat Completion API you can set it here. You can access the list of models [here](https://platform.openai.com/docs/models/gpt-4o-mini).

## Step 2. Create Infrastructure

Provision the nodes and kubernetes cluster using one of the following options:

### Local Version

**Running the Cloud Function locally**

1. Define the following environmental variables in `.env.yaml` in `src/ticketingservice` with values described above.
```
---
    OPENAI_API_KEY: ${open-ai-key}
    MODEL_TYPE: "gpt-4o-mini"
    NOTION_API_KEY: ${notion-api-key}
    NOTION_DB_ID: ${notion-db-id}
```

2. Install packages by running the following in `src/ticketingservice`

```shell
npm install && npm install --only=dev
npm test
```
3. Dublicate the file `src/otelcollector/otelcol-config.tpl` and rename the extension as `.yml` and apply following steps
    1. Replace ${ai_ticketing_endpoint} with service endpoint
    2. Replace all `$${` with `${`

**Minikube**

Requirements

- [Install minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Install kubectl](https://kubernetes.io/docs/tasks/tools/)

In case of using MacOS, you can use the following commands to install both tools using [HomeBrew - Package Manager](https://brew.sh/).

- For minikube:
  ```shell
   brew install minikube
  ```
- For kubectl:
  ```shell
   brew install kubernetes-cli
  ```

**Enable Kubernetes in Docker Desktop**
1. Open Docker Desktop.
2. Go to the Settings (or Preferences on macOS).
3. Navigate to the Kubernetes tab.
4. Check the box that says Enable Kubernetes.
5. Click Apply & Restart to start Kubernetes.

1. Start minikube cluster

```shell
minikube start --cpus 2 --memory 6000
```

2. Check access to the cluster using kubectl

```shell
kubectl get events --sort-by .lastTimestamp
```

It should display something similar as the following:

```
LAST SEEN   TYPE     REASON                    OBJECT          MESSAGE
42s         Normal   Starting                  node/minikube
56s         Normal   Starting                  node/minikube   Starting kubelet.
56s         Normal   NodeAllocatableEnforced   node/minikube   Updated Node Allocatable limit across pods
56s         Normal   NodeHasSufficientMemory   node/minikube   Node minikube status is now: NodeHasSufficientMemory
56s         Normal   NodeHasNoDiskPressure     node/minikube   Node minikube status is now: NodeHasNoDiskPressure
56s         Normal   NodeHasSufficientPID      node/minikube   Node minikube status is now: NodeHasSufficientPID
44s         Normal   RegisteredNode            node/minikube   Node minikube event: Registered Node minikube in Controller
```

### Cloud Version

**Google Cloud - GCP**

Requirements

- [Google Cloud Platform (GCP) Account](https://cloud.google.com/)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started). Tip: In mac use `brew install terraform`
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install). Tip: Use brew `brew install --cask google-cloud-sdk`

Follow the documentation to use GCP provider in terraform: [https://registry.terraform.io/providers/hashicorp/google/latest/docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

1. Create a GCP Project **cnae-open-telemetrics**. Hint: Take the project id.
   ![GCP Projects](../.docs/images/gcp_projects.png)
2. In the file, .tfvars, replace the project_id with the project id created in the previous step.
3. Configure Google cloud cli with the project
```shell
gcloud init
```
4. Authenticate with Google cloud cli
```shell
gcloud auth application-default login
```
5. Enable Required APIs
    - Enable Compute Engine API [here](https://console.cloud.google.com/apis/library/compute.googleapis.com?project=cnae-open-telemetrics)
    - Enable Kubernetes API [here](https://console.cloud.google.com/apis/library/container.googleapis.com?project=cnae-open-telemetrics)
    - Enable IAM API [here](https://console.cloud.google.com/marketplace/product/google/iam.googleapis.com?project=cnae-open-telemetrics)
    - Enable Secret Management API [here](https://console.cloud.google.com/marketplace/product/google/secretmanager.googleapis.com?project=cnae-open-telemetrics)
    - Enable CloudFunctions API [here](https://console.cloud.google.com/marketplace/product/google/cloudfunctions.googleapis.com?project=cnae-open-telemetrics)

6. Install gcloud-auth-plugin
```shell
gcloud components install gke-gcloud-auth-plugin
```
7. Go to `iac/gcp` folder and execute terraform
```shell
cd iac/gcp
terraform init
terraform apply --var-file .tfvars
```
8. (In iac/gcp folder). Connect to the kubernetes cluster already created
```shell
cd iac/gcp
gcloud container clusters get-credentials gke-cnae-cluster --region $(terraform output -raw region) --project $(terraform output -raw project_id)
```

## Step 3 - Configure kubernetes services

Terraform will generate the following files and inject the publicly accesible function uri to configuration files.

Generated configuration files:
- `docker-compose.yml` from `docker-compose.tpl`
- `src/otelcollector/otelcol-config.yml` from `src/otelcollector/otelcol-config.tpl`
- `kubernetes/opentelemetry-demo.yaml` from `kubernetes/opentelemetry-demo.tpl`

Install Opentelemetry - Demo with generated configurations to handle the AI ticket generation.
Note. Assuming that your current location is `iac/gcp`.

```shell
kubectl apply --namespace otel-demo -f ../../kubernetes/opentelemetry-demo.yaml
```
Wait until all the pods are running in the namespaces "otel-demo".

## Step 4. Execute tests

Start generating tickets and publishing them to Notion.

### Modify feature flags

**Experimented feature flag: productCatalogFailure**
This flag causes "Error: ProductCatalogService Fail Not Found" log to be added in the span when the product with ID "OLJCESPC7Z" is requested. This will trigger the ticket generation.

1. Find `demo.flagd.json` field of the `ConfigMap` named `opentelemetry-demo-flagd-config`
2. Adjust the flag you wish to enable by setting its `defaultVariant` field to `on`
3. Apply new configuration
    
    Note. Assuming that you current location is `iac/gcp`
    ```shell
    kubectl apply --namespace otel-demo -f ../../kubernetes/opentelemetry-demo.yaml
    ```
Note. It may take some time for the configuration to be updated.

### Access to the microservices

**Alternative 1**

Connect to a tunel using kubernetes to access the opentelemetry-demo-frontendproxy

```shell
kubectl port-forward -n otel-demo svc/opentelemetry-demo-frontendproxy 8080:8080
```

**Alternative 2:**

To forward with the Google cloud load balancer run:

```shell
kubectl apply -f ingress.yaml
```

### Trigger error

Send a request to the following endpoints:
 - If using port-forwarding: http://localhost:8080/product/OLJCESPC7Z
 - If using ingress: ${ingress-endpoint}/product/OLJCESPC7Z

You can view the generated tickets in the Notion database.

## Step 5. Destroy infrastructure

In order to destroy:
Note. Assuming that you current location is `iac/gcp`

In case of using ingress, destroy ingress
```shell
kubectl delete -f ingress.yaml
```

Destroy kubernetes services
```shell
kubectl delete --namespace otel-demo -f ../../kubernetes/opentelemetry-demo.yaml
```
In case of using GCP, destroy the infrastructure with terraform

```shell
cd iac/gcp
terraform destroy --var-file .tfvars
```

In case of using minikube, stop the cluster

```shell
minikube delete --all
```

## Step 6. Quantitative Evaluation

In this project we evaluate the meantime between the time that the error occured and the ticket published to a ticketing system. You can find more information in `README.md` located in `mttd` folder.

### Running the evaluation

Do not forget to adjust the variables with your Notion API Key and Notion database ID.

```shell
cd mttd
npm install @notionhq/client

NOTION_API_KEY=${NOTION_API_KEY} NOTION_DB_ID=${NOTION_DB_ID} node mttd.js
```

### Possible Problems

If you face the problem that Google Cloud can not access to the docker images stored in DockerHub, try [authentication helper for Docker](https://cloud.google.com/artifact-registry/docs/docker/authentication).

```shell
gcloud auth configure-docker
```