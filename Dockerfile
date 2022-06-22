FROM ubuntu:latest

RUN apt-get update \
  && apt-get install -y curl unzip wget git zip \
  && mkdir -p /app \
  && cd /app \
  && curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o identity_linux_amd64.zip \
  && unzip -o identity_linux_amd64.zip \
  && rm -f identity_linux_amd64.zip \
  && chmod +x identity \
  && mv identity /usr/local/bin/identity \
  && git clone https://github.com/bharathappali/storj-identity-generator.git

ENTRYPOINT [ "/app/storj-identity-generator/generate_identity.sh" ]
