FROM debian:12.1-slim

WORKDIR /root
ENV  PATH="/root/.krew/bin:$PATH"
RUN apt update && apt upgrade -y && apt install curl git jq yq vim zsh -y
RUN cd "$(mktemp -d)" && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/bin
RUN cd "$(mktemp -d)" && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod +x get_helm.sh && ./get_helm.sh 
RUN cd "$(mktemp -d)" && curl -LO https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz && tar zxvf krew-linux_amd64.tar.gz &&  ./krew-linux_amd64 install krew && kubectl krew update && kubectl krew install kc ns ctx
RUN cd "$(mktemp -d)" && curl -LO https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz && tar zxvf k9s_Linux_amd64.tar.gz && mv k9s /usr/bin