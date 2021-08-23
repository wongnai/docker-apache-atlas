FROM openjdk:8-jdk-buster

ARG VERSION=2.2.0

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apt-utils \
    && apt-get -y install \
        maven \
        wget \
        python \
		unzip \
    && cd /tmp \
    && wget http://mirror.linux-ia64.org/apache/atlas/${VERSION}/apache-atlas-${VERSION}-sources.tar.gz \
    && mkdir -p /tmp/atlas-src \
    && tar --strip 1 -xzvf apache-atlas-${VERSION}-sources.tar.gz -C /tmp/atlas-src \
    && rm apache-atlas-${VERSION}-sources.tar.gz \
    && cd /tmp/atlas-src \
    && sed -i 's/http:\/\/repo1.maven.org\/maven2/https:\/\/repo1.maven.org\/maven2/g' pom.xml \
    && export MAVEN_OPTS="-Xms2g -Xmx2g" \
    && mvn clean -Dmaven.repo.local=/tmp/.mvn-repo -Dhttps.protocols=TLSv1.2 -DskipTests package \
	&& mkdir -p /opt/atlas \
    && tar -xzvf /tmp/atlas-src/distro/target/apache-atlas-${VERSION}-server.tar.gz -C /opt/atlas \
	&& groupadd hadoop \
	&& useradd -m -d /opt/atlas -g hadoop atlas \
	&& chown -R atlas:hadoop /opt/atlas \
    && rm -Rf /tmp/atlas-src \
    && rm -Rf /tmp/.mvn-repo \
    && apt-get -y --purge remove maven \
    && apt-get -y autoremove \
    && apt-get -y clean

VOLUME ["/opt/atlas/conf", "/opt/atlas/logs", "/opt/atlas/data"]

USER atlas

COPY atlas/ /opt/atlas/

CMD [ "/opt/atlas/bin/start.sh" ]
