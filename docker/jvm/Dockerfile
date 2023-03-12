ARG JVM_IMAGE=eclipse-temurin
ARG JVM_TAG=11-jre-alpine
FROM ${JVM_IMAGE}:${JVM_TAG}
ARG NAMESPACE=ping

RUN wget --no-check-certificate -O /tmp/intermediate.crt https://vault.internal.darkedges.com/v1/${NAMESPACE}_idam_intermediate/ca && \
    wget --no-check-certificate -O /tmp/root.crt https://vault.internal.darkedges.com/v1/${NAMESPACE}_idam_root/ca 

FROM ${JVM_IMAGE}:${JVM_TAG}
ARG NAMESPACE
RUN apk add --no-cache ca-certificates

COPY --from=0 /tmp/intermediate.crt /usr/local/share/ca-certificates/CAIntermediate.crt
COPY --from=0 /tmp/root.crt /usr/local/share/ca-certificates/CARoot.crt 

RUN update-ca-certificates && \
    keytool -import -trustcacerts -noprompt -cacerts -file /usr/local/share/ca-certificates/CARoot.crt -storepass changeit -alias CARoot && \
    keytool -import -trustcacerts -noprompt -cacerts  -file /usr/local/share/ca-certificates/CAIntermediate.crt -storepass changeit -alias CAIntermediate && \
    rm -rf /var/cache/apk/*