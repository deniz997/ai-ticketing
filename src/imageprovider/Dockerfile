# Copyright The OpenTelemetry Authors
# SPDX-License-Identifier: Apache-2.0

FROM nginx:1.25.3

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    lsb-release \
    ca-certificates \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Update NGINX GPG key
RUN wget https://nginx.org/keys/nginx_signing.key \
    && gpg --no-default-keyring --keyring /usr/share/keyrings/nginx-archive-keyring.gpg --import nginx_signing.key \
    && rm nginx_signing.key

# This file is needed for nginx-module-otel to be found.
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list

# Install nginx-module-otel
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    nginx-module-otel \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /static
COPY src/imageprovider/static /static

EXPOSE ${IMAGE_PROVIDER_PORT}

STOPSIGNAL SIGQUIT

COPY src/imageprovider/nginx.conf.template /nginx.conf.template

# Start nginx
CMD ["/bin/sh" , "-c" , "envsubst '$OTEL_COLLECTOR_HOST $IMAGE_PROVIDER_PORT $OTEL_COLLECTOR_PORT_GRPC $OTEL_SERVICE_NAME' < /nginx.conf.template > /etc/nginx/nginx.conf && cat  /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"]
