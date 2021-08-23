FROM maven:3.8.2-jdk-8 AS builder

ARG ATLAS_VERSION=2.2.0

ENV MAVEN_OPTS "-Xms2g -Xmx2g"
 
RUN cd /tmp \
    && wget http://mirror.linux-ia64.org/apache/atlas/${ATLAS_VERSION}/apache-atlas-${ATLAS_VERSION}-sources.tar.gz \
    && mkdir -p /tmp/atlas-src \
    && tar --strip-components 1 -xzvf apache-atlas-${ATLAS_VERSION}-sources.tar.gz -C /tmp/atlas-src

RUN cd /tmp/atlas-src \
    && mvn -DskipTests clean package > /tmp/mvn.log \
    && pwd \
    && tail -100 /tmp/mvn.log

RUN mkdir -p /opt/atlas \
    && tar --strip-components 1 -xzvf /tmp/atlas-src/distro/target/apache-atlas-${ATLAS_VERSION}-server.tar.gz -C /opt/atlas


FROM openjdk:8-jdk-buster

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-utils python \
    && apt-get -y autoremove \
    && apt-get -y clean

VOLUME ["/opt/atlas/conf", "/opt/atlas/logs", "/opt/atlas/data"]


RUN mkdir /opt/atlas \
    && groupadd hadoop \
    && useradd -m -d /opt/atlas -g hadoop atlas \
    && chown -R atlas:hadoop /opt/atlas


COPY --from=builder --chown=atlas /opt/atlas_out /opt/atlas

USER atlas

COPY atlas/ /opt/atlas/

CMD [ "/opt/atlas/bin/start.sh" ]
