FROM alpine:latest

RUN apk add --no-cache alpine-sdk util-linux findutils python3 wget unzip docker jq git bash

# TASKFILE
RUN curl -sL https://taskfile.dev/install.sh | sh

# TERRAFORM
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
    && sudo ln -s ~/.tfenv/bin/* /usr/local/bin \
    && tfenv install 0.12.20

# TERRAGRUNT
RUN git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv \
    && sudo ln -s ~/.tgenv/bin/* /usr/local/bin \
    && tgenv install 0.21.11

# TERRAFORM - KAFKA PROVIDER
RUN TERRAFORM_KAFKA_PROVIDER_VERSION=0.2.3 \
    && wget https://github.com/Mongey/terraform-provider-kafka/releases/download/v"$TERRAFORM_KAFKA_PROVIDER_VERSION"/terraform-provider-kafka_"$TERRAFORM_KAFKA_PROVIDER_VERSION"_linux_amd64.tar.gz \
    && tar -xf terraform-provider-kafka_"$TERRAFORM_KAFKA_PROVIDER_VERSION"_linux_amd64.tar.gz \
    && mkdir --parents ~/.terraform.d/plugins \
    && mv terraform-provider-kafka_v"$TERRAFORM_KAFKA_PROVIDER_VERSION" ~/.terraform.d/plugins/
