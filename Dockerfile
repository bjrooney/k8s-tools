FROM debian:12.1-slim

WORKDIR /root
env  PATH="/root/.krew/bin:$PATH"
RUN apt update && apt upgrade -y && apt install curl git jq yq vim zsh -y
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/bin
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x get_helm.sh && ./get_helm.sh && rm get_helm.sh
RUN curl -LO https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz
RUN tar zxvf krew-linux_amd64.tar.gz &&  ./krew-linux_amd64 install krew
RUN kubectl krew update
RUN kubectl krew install kc
RUN kubectl krew install ns
RUN kubectl krew install ctx
