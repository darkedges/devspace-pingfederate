FROM eclipse-temurin:11.0.14_9-jre-alpine

RUN wget --no-check-certificate -O /tmp/darkedges-intermediate.crt https://vault.internal.darkedges.com/v1/darkedges_idam_intermediate/ca && \
    wget --no-check-certificate -O /tmp/darkedges-root.crt https://vault.internal.darkedges.com/v1/darkedges_idam_root/ca 

FROM eclipse-temurin:11.0.14_9-jre-alpine

RUN apk add --no-cache ca-certificates

COPY --from=0 /tmp/darkedges-intermediate.crt /usr/local/share/ca-certificates/darkedges-intermediate.crt
COPY --from=0 /tmp/darkedges-root.crt /usr/local/share/ca-certificates/darkedges-root.crt 

RUN update-ca-certificates && \
    keytool -import -trustcacerts -noprompt -cacerts -file /usr/local/share/ca-certificates/darkedges-root.crt -storepass changeit -alias DarkEdgesRoot && \
    keytool -import -trustcacerts -noprompt -cacerts  -file /usr/local/share/ca-certificates/darkedges-intermediate.crt -storepass changeit -alias DarkEdgesIntermediate && \
    rm -rf /var/cache/apk/*