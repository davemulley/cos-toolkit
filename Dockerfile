# IBM Java SDK UBI is not available on public docker yet. Use regular
# base as builder until this is ready. For reference:
# https://github.com/ibmruntimes/ci.docker/tree/master/ibmjava/8/sdk/ubi-min

FROM ibmjava:8-sdk AS builder
LABEL maintainer="IBM Java Engineering at IBM Cloud"

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get install -y maven
RUN mvn -N io.takari:maven:wrapper -Dmaven=3.5.0
RUN ./mvnw install

# Multi-stage build. New build stage that uses the UBI as the base image.
FROM ibmcom/websphere-liberty:kernel-java8-ibmjava-ubi
LABEL maintainer="IBM Java Engineering at IBM Cloud"
ENV PATH /project/target/liberty/wlp/bin/:$PATH

COPY --from=builder /app/target/liberty/wlp/usr/servers/defaultServer /config/

USER root
RUN chmod g+w /config/apps
RUN configure.sh
USER 1001
