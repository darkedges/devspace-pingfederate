ARG JVM_IMAGE=darkedges/jvm
ARG JDK_TAG=11-jdk-alpine
ARG PINGFEDERATE_IMAGE=darkedges/pingfederate_base
ARG PINGFEDERATE_TAG=11.2.3

# Initial Configuration
FROM busybox:1.34 as ant
# Download the ANT Version we need
ADD https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.10-bin.tar.gz /tmp
# Extract it
RUN mkdir /tmp/ant && \
    tar -xvzf /tmp/apache-ant-1.10.10-bin.tar.gz --directory /tmp/ant --strip-components=1
# Get Maven
FROM maven:3.8.6-eclipse-temurin-11-alpine as maven
# Get Ping Federate
FROM ${PINGFEDERATE_IMAGE}:${PINGFEDERATE_TAG} as pingfed

# Runtime deployment
FROM ${JVM_IMAGE}:${JDK_TAG}
# Copy ant to this image
COPY --from=ant /tmp/ant /opt/apache/ant/
# Copy Maven to this image
COPY --from=maven /usr/share/maven/ /opt/apache/maven/
# Copy Ping Federate to this image
COPY --from=pingfed /opt/ping/federate/ /opt/ping/federate/
# Set up the Environment Variables for this iamge
ENV ANT_HOME=/opt/apache/ant \
    MAVEN_HOME=/opt/apache/maven/
ENV PATH=$MAVEN_HOME/bin:$ANT_HOME/bin:$PATH
# Set the base directory to the correct location
WORKDIR /opt/ping/federate/pingfederatesdk/
# We want to run ant
ENTRYPOINT  ["ant"]
# with this command
CMD [""]