FROM maven:3.5.4-jdk-8 AS stage-atlas

ENV	MAVEN_OPTS "-Xms2g -Xmx2g"

RUN git clone http://github.com/apache/atlas.git \
	&& cd atlas \
	&& mvn clean -DskipTests package -Pdist \
	&& mv distro/target/apache-atlas-*-bin.tar.gz /apache-atlas.tar.gz

RUN mkdir /opt/atlas \
	&& cd /opt/atlas \
	&& tar xzf /apache-atlas.tar.gz --strip-components=1


FROM centos:7

RUN yum update -y \
	&& yum install -y python python36 java-1.8.0-openjdk java-1.8.0-openjdk-devel net-tools \
	&& yum clean all

RUN groupadd hadoop \
	&& useradd -m -d /opt/atlas -g hadoop atlas

USER atlas

COPY --from=stage-atlas --chown=atlas /opt/atlas /opt/atlas
ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]

EXPOSE 21000
