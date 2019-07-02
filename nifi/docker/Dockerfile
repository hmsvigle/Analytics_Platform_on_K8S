FROM       ubuntu:16.04 

ARG        DIST_MIRROR=http://archive.apache.org/dist/nifi
ARG        VERSION=1.9.2
ARG        USR=nifi

ENV        NIFI_HOME=/opt/nifi/nifi-$VERSION \
           JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
           PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin \
           BANNER_TEXT="" \
           S2S_PORT=""

RUN        set -x && \
           apt-get update && \
           apt-get install -y  wget bash wget curl openjdk-8-jre-headless && \
           apt install -y netcat && \
           mkdir -p ${NIFI_HOME} && \
          # curl -fSL http://mirrors.estointernet.in/apache/nifi/$VERSION/nifi-$VERSION-bin.tar.gz -o /tmp/nifi-$VERSION-bin.tar.gz && \
           curl -fSL https://www-eu.apache.org/dist/nifi/$VERSION/nifi-$VERSION-bin.tar.gz -o /tmp/nifi-$VERSION-bin.tar.gz && \
           tar -zxf /tmp/nifi-$VERSION-bin.tar.gz -C ${NIFI_HOME} && \
           mv ${NIFI_HOME}/nifi-${VERSION}/* ${NIFI_HOME} && \
           rm -rf ${NIFI_HOME}/nifi-${VERSION} && \
           rm -rf *.tar.gz && \
           chmod +x ${NIFI_HOME}/bin/nifi.sh && \
           mkdir /jars && \
           curl -fSL https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -o /jars/postgresql-42.2.5.jar && \
           useradd ${USR} && \
           [ `id -u ${USR}` -eq 1000 ] && \
           [ `id -g ${USR}` -eq 1000 ] && \
           chown -R "${USR}:${USR}" ${NIFI_HOME} 

EXPOSE     8080 8081 8443

USER       ${USR}

WORKDIR    ${NIFI_HOME}
#CMD        ./bin/nifi.sh run
