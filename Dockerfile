FROM debian:latest
# To make it easier for build and release pipelines to run apt-get,
ENV DEBIAN_FRONTEND=noninteractive
ENV VENDIR_VERSION=0.42.0
ENV KLUCTL_VERSION=2.25.1
ENV TERRAFORM_VERSION=1.9.7

WORKDIR /root
ENV PATH="/root/.krew/bin:$PATH"
ENV TERM=xterm
RUN echo "export TERM=xterm" >> /etc/profile
RUN echo $ARCH
RUN apt update \
    && apt upgrade -y \
    && apt-get install curl wget gpg git jq yq vim zsh zoxide ca-certificates apt-transport-https lsb-release gnupg  unzip -y
RUN cd "$(mktemp -d)" \
    && curl -LO https://github.com/junegunn/fzf/releases/download/0.42.0/fzf-0.42.0-linux_amd64.tar.gz \
    && tar zxvf fzf-0.42.0-linux_amd64.tar.gz \
    && mv fzf /usr/bin
RUN mkdir -p /etc/apt/keyrings \
    && curl -sLS https://packages.microsoft.com/keys/microsoft.asc |   gpg --dearmor |  tee /etc/apt/keyrings/microsoft.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/microsoft.gpg \
    && AZ_DIST=$(lsb_release -cs) \
    && echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" |    tee /etc/apt/sources.list.d/azure-cli.list \
    && apt install azure-cli -y
RUN cd "$(mktemp -d)" \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/bin
RUN cd "$(mktemp -d)" \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod +x get_helm.sh \
    && ./get_helm.sh 
RUN cd "$(mktemp -d)" \
    && curl -LO https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz \
    && tar zxvf krew-linux_amd64.tar.gz \
    &&  ./krew-linux_amd64 install krew \
    && kubectl krew update \
    && kubectl krew install kc ns ctx
RUN cd "$(mktemp -d)" \
    && curl -LO https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz \
    && tar zxvf k9s_Linux_amd64.tar.gz \
    && mv k9s /usr/bin
RUN cd "$(mktemp -d)" \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN cd "$(mktemp -d)" \
    && curl "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/terraform

# RUN "az aks install-cli"
RUN cd "$(mktemp -d)" \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN cd "$(mktemp -d)" \
    && curl -s -L https://github.com/carvel-dev/vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64 > /usr/local/bin/vendir \
    && chmod +x /usr/local/bin/vendir \
    && vendir version

RUN cd "$(mktemp -d)" \
    && export kluctl_VERSION=${KLUCTL_VERSION} \
	&& curl -s https://kluctl.io/install.sh



ENTRYPOINT ["tail", "-f", "/dev/null"]
