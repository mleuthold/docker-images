FROM alpine:latest

# curl for Taskfile
# git for Terraform and Terragrunt repos
# wget, unzip for Terraform Kafka proficer
# musl-dev for GO
# go for Terratest
# Python3 for awscli
# bash for install scripts relying on bash
RUN apk add --no-cache curl git wget unzip go musl-dev python3 bash

RUN pip3 install awscli

# TASKFILE
RUN curl -sL https://taskfile.dev/install.sh | sh

# TERRAFORM
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
    && ln -s ~/.tfenv/bin/* /usr/local/bin \
    && tfenv install 0.12.20

# TERRAGRUNT
RUN git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv \
    && ln -s ~/.tgenv/bin/* /usr/local/bin \
    && tgenv install 0.21.11

# TERRAFORM - KAFKA PROVIDER
RUN TERRAFORM_KAFKA_PROVIDER_VERSION=0.2.3 \
    && wget https://github.com/Mongey/terraform-provider-kafka/releases/download/v"$TERRAFORM_KAFKA_PROVIDER_VERSION"/terraform-provider-kafka_"$TERRAFORM_KAFKA_PROVIDER_VERSION"_linux_amd64.tar.gz \
    && tar -xf terraform-provider-kafka_"$TERRAFORM_KAFKA_PROVIDER_VERSION"_linux_amd64.tar.gz \
    && mkdir --parents ~/.terraform.d/plugins \
    && mv terraform-provider-kafka_v"$TERRAFORM_KAFKA_PROVIDER_VERSION" ~/.terraform.d/plugins/ \
    && rm -rf terraform-provider-kafka_"$TERRAFORM_KAFKA_PROVIDER_VERSION"_linux_amd64.tar.gz LICENSE README.md
