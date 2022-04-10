FROM eclipse-temurin:11.0.14_9-jre-alpine
ARG NAMESPACE=darkedges

RUN wget --no-check-certificate -O /tmp/intermediate.crt https://vault.internal.darkedges.com/v1/${NAMESPACE}_idam_intermediate/ca && \
    wget --no-check-certificate -O /tmp/root.crt https://vault.internal.darkedges.com/v1/${NAMESPACE}_idam_root/ca 

FROM eclipse-temurin:11.0.14_9-jre-alpine
ARG NAMESPACE
RUN apk add --no-cache ca-certificates

COPY --from=0 /tmp/intermediate.crt /usr/local/share/ca-certificates/$NAMESPACE-intermediate.crt
COPY --from=0 /tmp/root.crt /usr/local/share/ca-certificates/$NAMESPACE-root.crt 

RUN update-ca-certificates && \
    keytool -import -trustcacerts -noprompt -cacerts -file /usr/local/share/ca-certificates/$NAMESPACE-root.crt -storepass changeit -alias ${NAMESPACE}Root && \
    keytool -import -trustcacerts -noprompt -cacerts  -file /usr/local/share/ca-certificates/$NAMESPACE-intermediate.crt -storepass changeit -alias ${NAMESPACE}Intermediate && \
    rm -rf /var/cache/apk/*