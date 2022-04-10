FROM darkedges/jre:11.0.14_9-jre-alpine

COPY rootscripts/genjks.sh /usr/bin/genjks.sh

RUN apk add --no-cache openssl coreutils bash && \
    wget --no-check-certificate -O /usr/bin/kubectl https://dl.k8s.io/release/v1.22.5/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl && \
    chmod +x /usr/bin/genjks.sh && \
    kubectl version --client && \
    rm -rf /var/cache/apk/*

ENTRYPOINT /usr/bin/genjks.sh