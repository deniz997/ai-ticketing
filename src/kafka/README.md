# Kafka

This is used as a message queue service to connect the checkout service with
the accounting and fraud detection services.

Kafka is run in KRaft mode. Environment variables are substituted at
deploy-time.
## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/kafka:original -f ./src/kafka/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/kafka:original
```
