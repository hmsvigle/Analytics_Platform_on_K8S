FROM ubuntu:16.04
ENV KAFKA_MNGR_USER=kafka-mon \
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
KAFKA_MNGR_HOME=/opt/kafka-manager-1.3.3.22 \
PATH=$PATH:/opt/kafka-manager-1.3.3.22/bin

COPY kafka-manager-1.3.3.22.zip /tmp/
RUN set -x \
    && apt-get update \
    && apt-get install -y openjdk-8-jre-headless wget netcat unzip \
    && unzip /tmp/kafka-manager-1.3.3.22.zip -d /opt

RUN set -x \
    && useradd $KAFKA_MNGR_USER \
    && [ `id -u $KAFKA_MNGR_USER` -eq 1000 ] \
    && [ `id -g $KAFKA_MNGR_USER` -eq 1000 ] \
    && chown -R "$KAFKA_MNGR_USER:$KAFKA_MNGR_USER" $KAFKA_MNGR_HOME

USER $KAFKA_MNGR_USER
WORKDIR $KAFKA_MNGR_HOME
