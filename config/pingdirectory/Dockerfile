ARG PINGDIRECTORY_IMAGE=darkedges/pingdirectory_base
ARG PINGDIRECTORY_TAG=9.2.0.0

# Initial Configuration
FROM alpine:3.17.2

COPY config/ /var/tmp/config

# Final Configuration
FROM ${PINGDIRECTORY_IMAGE}:${PINGDIRECTORY_TAG}

COPY --chown=ping:ping license/ /opt/ping/directory/