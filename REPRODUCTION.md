# Reproduction

This project only supports Google Cloud Platform for deployment.

## Deployment

Follow steps explained in `readme.md` located in `iac/gcp` folder.

## Quantitative Evaluation

In this project we evaluate the meantime between the time that the error occured and the ticket published to a ticketing system. You can find more information in `README.md` located in `mttd` folder.

## Updated/Added Services

- Recommendation service located at `src/recommendationservice` is updated so that when the productCatalogFailure flag is enabled, it will not request that product anymore to prevent repeated ticket generation.

- Product Catalog service located at `src/productcatalogservice` is updated so that it will not log that the flag is on. This would make the case very easy for the AI assistant and very far from a real use-case scenario.

- The `ConfigMap``opentelemetry-demo-otelcol` is configured to send traces to the cloud function. It is also configured to group spans by trace id and filter out spans without any error.

- In the deployment named `opentelemetry-demo-loadgenerator`, the environmental variable `LOCUST_AUTOSTART` is set to false to prevent other errors from happening to avoid additional costs in ticketing.

### Cloud Function

The cloud function, namely "ai-ticketing" can be found under `src/ticketingservice` folder.