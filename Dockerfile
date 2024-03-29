#FROM ubuntu:bionic-20191029
FROM ubuntu:18.04
MAINTAINER github.com/insight-infrastructure

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update \
 && apt-get upgrade -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    sudo \
    ca-certificates \
    unzip \
    apt-transport-https \
    libssl-dev \
    build-essential \
    automake \
    pkg-config \
    libtool \
    libffi-dev \
    libgmp-dev \
    libyaml-cpp-dev \
    libsecp256k1-dev \
    build-essential \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    python-pip \
    python3.7-dev \
    python3-pip \
    curl \
    git \
    jq \
    netcat \
    openssh-server \
    openssh-client

RUN apt-get install -y software-properties-common && add-apt-repository ppa:rmescandon/yq -y && apt-get install -y yq

RUN pip install setuptools wheel
RUN pip install \
    cookiecutter \
    ansible \
    requests \
    && rm -rf /var/lib/apt/lists/*

ARG TG_VERSION="v0.21.5"
ARG TF_VERSION="0.12.14"
ARG PAKCER_VERSION=1.4.4

#
#   Terraform
#
RUN wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -O /tmp/terraform.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin/ && chmod +x /usr/local/bin/terraform
#
#   Packer
#
RUN wget https://releases.hashicorp.com/packer/1.4.4/packer_1.4.4_linux_amd64.zip -O /tmp/packer.zip
RUN unzip /tmp/packer.zip -d /usr/local/bin/ && chmod +x /usr/local/bin/packer
#
#   Terragrunt
#
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt
RUN chmod +x /usr/local/bin/terragrunt

RUN  apt-get clean &&  rm -r /var/lib/apt/lists/* && apt-get update && apt-get install gpg-agent -y

RUN curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
RUN apt-get install nodejs
RUN npm i -g meta

WORKDIR /apps

ARG ICON_HOME=/usr/local/icon

RUN useradd -ms /bin/bash -d ${ICON_HOME} icon
RUN chown -R icon: ${ICON_HOME}

USER icon
WORKDIR ${ICON_HOME}

VOLUME ${ICON_HOME}
ENTRYPOINT ["./tgrun.sh"]