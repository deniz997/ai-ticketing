# Currency Service

The Currency Service does the conversion from one currency to another.
It is a C++ based service.

## Building docker image

To build the currency service, run the following from root directory
of opentelemetry-demo

```sh
docker-compose build currencyservice
```

## Run the service

Execute the below command to run the service.

```sh
docker-compose up currencyservice
```

## Run the client

currencyclient is a sample client which sends some request to currency
service. To run the client, execute the below command.

```sh
docker exec -it <container_name> currencyclient 7000
```

'7000' is port where currencyservice listens to.
## Docker Build

From the root directory, run:

**GitLab container registry:**
```sh
docker login git.tu-berlin.de:5000
docker build -t git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/currencyservice:original -f ./src/currencyservice/Dockerfile .
docker push git.tu-berlin.de:5000/cnae_ss_2024/opentelemetry-demo/currencyservice:original
```
