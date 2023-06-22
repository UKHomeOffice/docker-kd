FROM alpine:3.18 AS BUILDER

ARG KUBECTL_VERSION
ARG KUBECTL_SHA512

ARG KD_VERSION
ARG KD_SHA512

RUN set -euxo pipefail ;\
  mkdir -p /tmp/installroot ;\
  #Dependencies to clone ACP CAs
  apk add --no-cache \
    curl \
    coreutils \
    git ;\
  #Create directories to hold files intended for final container e.g. package dependencies
  mkdir -p /tmp/installroot/usr/local/share/ca-certificates ;\
  mkdir -p /tmp/installroot/usr/local/bin ;\
  #Retreive ACP CAs
  git clone https://github.com/UKHomeOffice/acp-ca.git /tmp/acp-ca ;\
  mv /tmp/acp-ca/ca.pem /tmp/installroot/usr/local/share/ca-certificates/acp_root_ca.crt ;\
  mv /tmp/acp-ca/ca-intermediate.pem /tmp/installroot/usr/local/share/ca-certificates/acp_int_ca.crt ; \
  #Retrieve Kubectl
  curl -sLO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" ;\
  echo "$KUBECTL_SHA512 ./kubectl" | sha512sum --strict --check - ;\
  mv ./kubectl /tmp/installroot/usr/local/bin/ ;\
  chmod +x /tmp/installroot/usr/local/bin/kubectl ;\
  #Retrieve kd
  curl -sLo ./kd "https://github.com/UKHomeOffice/kd/releases/download/v${KD_VERSION}/kd_linux_amd64" ;\
  echo "$KD_SHA512 ./kd" | sha512sum --strict --check - ;\
  mv ./kd /tmp/installroot/usr/local/bin/ ;\
  chmod +x /tmp/installroot/usr/local/bin/kd ;

FROM alpine:3.18
# Non-Root Application User
ARG USER=kd
ARG UID=1000

COPY --from=BUILDER /tmp/installroot /

RUN set -euxo pipefail ;\
  # Create non-Root user
  adduser \
  -D \
  -g "" \
  -u "$UID" \
  "$USER"  ;\
  #Add dependencies
  apk add --no-cache \
    bash \
    ca-certificates \
    openssl ;\
  #change ownership of /usr/local/share/ca-certificates as alpine does not suppport directories.
  chown -R $USER:$USER /usr/local/share/ca-certificates ;\
  chown -R $USER:$USER /etc/ssl/certs/ ;\
  ls -lRt /usr/local/share/ca-certificates ;\
  update-ca-certificates ;\
  kubectl version --client ;\
  kd --version ;

USER $UID
ENTRYPOINT ["kd"]
CMD ["--help"]
