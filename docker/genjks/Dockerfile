ARG JVM_IMAGE=darkedges/jvm
ARG JVM_TAG=11-jre-alpine

FROM ${JVM_IMAGE}:${JVM_TAG}

COPY rootscripts/genjks.sh /usr/bin/genjks.sh

RUN apk add --no-cache openssl coreutils bash && \
    wget --no-check-certificate -O /usr/bin/kubectl https://dl.k8s.io/release/v1.25.2/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl && \
    chmod +x /usr/bin/genjks.sh && \
    kubectl version --client && \
    rm -rf /var/cache/apk/*

ENTRYPOINT /usr/bin/genjks.sh