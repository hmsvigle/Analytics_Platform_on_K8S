# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04
ARG USR=zeppelin
ARG T=""

# `Z_VERSION` will be updated by `dev/change_zeppelin_version.sh`
ENV Z_VERSION="0.8.0" \
    LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    Z_HOME="/zeppelin" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN echo "$LOG_TAG update and install basic packages" && \
    apt-get -y update && \
    apt-get install -y locales && \
    locale-gen $LANG && \
    apt-get install -y software-properties-common && \
    apt -y autoclean && \
    apt -y dist-upgrade && \
    apt-get install -y build-essential

RUN echo "$LOG_TAG install tini related packages" && \
    apt-get install -y wget curl grep sed dpkg vim && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN echo "$LOG_TAG Install java8" && \
    apt-get -y update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# should install conda first before numpy, matploylib since pip and python will be installed by conda
RUN echo "$LOG_TAG Install miniconda2 related packages" && \
    apt-get -y update && \
    apt-get install -y bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion && \
    echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.3.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

RUN echo "$LOG_TAG Install python related packages" && \
    apt-get -y update && \
    apt-get install -y python-dev python-pip && \
    apt-get install -y gfortran && \
    # numerical/algebra packages
    apt-get install -y libblas-dev libatlas-dev liblapack-dev && \
    # font, image for matplotlib
    apt-get install -y libpng-dev libfreetype6-dev libxft-dev && \
    # for tkinter
    apt-get install -y python-tk libxml2-dev libxslt-dev zlib1g-dev && \
    pip install numpy && \
    pip install matplotlib

RUN echo "$LOG_TAG Install R related packages" && \
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | tee -a /etc/apt/sources.list && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add - && \
    apt-get -y update && \
    apt-get -y install r-base r-base-dev && \
    R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" && \
    # for devtools, Rcpp
    apt-get -y install libcurl4-gnutls-dev libssl-dev && \
    R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" && \
    Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')"

RUN echo "$LOG_TAG Download Zeppelin binary with selected interpreters" && \
wget -O /tmp/zeppelin-${Z_VERSION}-bin-netinst.tgz http://archive.apache.org/dist/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-netinst.tgz && \
tar -zxvf /tmp/zeppelin-${Z_VERSION}-bin-netinst.tgz && \
rm -rf /tmp/zeppelin-${Z_VERSION}-bin-netinst.tgz && \
mv /zeppelin-${Z_VERSION}-bin-netinst ${Z_HOME} && \
${Z_HOME}/bin/install-interpreter.sh --name python,jdbc,file,livy,cassandra

RUN set -x && \
    mkdir -p ${Z_HOME}/interpreter/mongodb && \
    wget https://github.com/bbonnin/zeppelin-mongodb-interpreter/releases/download/0.7.0/zeppelin-mongodb-0.7.0.zip -P ${Z_HOME}/interpreter/mongodb/ && \
    mv ${Z_HOME}/interpreter/mongodb/zeppelin-mongodb-0.7.0.zip ${Z_HOME}/interpreter/mongodb/zeppelin-mongodb-0.7.0.jar && \
    mv ${Z_HOME}/conf/zeppelin-site.xml.template ${Z_HOME}/conf/zeppelin-site.xml && \
    mv ${Z_HOME}/conf/zeppelin-env.sh.template  ${Z_HOME}/conf/zeppelin-env.sh && \
    sed -n 321p ${Z_HOME}/conf/zeppelin-site.xml >> temp.txt && \
    sed -i 's/<\/value>/,org.apache.zeppelin.mongodb.MongoDbInterpreter\<\/value\>/g' temp.txt && \
    T=`cat temp.txt` && \
    sed -i '321d' $Z_HOME/conf/zeppelin-site.xml && \
    sed -i "320a${T}" $Z_HOME/conf/zeppelin-site.xml

RUN wget --no-check-certificate --no-cookies https://archive.apache.org/dist/spark/spark-2.1.3/spark-2.1.3-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.1.3-bin-hadoop2.7.tgz -C /etc && \
    ln -s /etc/spark-2.1.3-bin-hadoop2.7 /etc/spark  && \
    wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.7/hadoop-2.7.7.tar.gz && \
    tar -xzvf hadoop-2.7.7.tar.gz -C /etc && \
    ln -s /etc/hadoop-2.7.7 /opt/hadoop

ENV HADOOP_HOME=/opt/hadoop  \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    HADOOP_MAPRED_HOME=/opt/hadoop \
    HADOOP_COMMON_HOME=/opt/hadoop \
    YARN_CONF_DIR=/opt/hadoop/etc/hadoop

RUN echo "$LOG_TAG Cleanup" && \
apt-get autoclean && \
apt-get clean

RUN set -x && \
    groupadd ${USR} && \
    useradd ${USR} -g ${USR}  && \
    [ `id -u ${USR}` -eq 1000 ] && \
    [ `id -g ${USR}` -eq 1000 ] && \
    mkdir -p /home/${USR} && \
    chown -R "${USR}:${USR}" ${JAVA_HOME} ${Z_HOME} /opt/conda/ /etc/hadoop-2.7.7 ${HADOOP_HOME} /etc/spark-2.1.3-bin-hadoop2.7 /home/${USR} 

EXPOSE 8080
USER ${USR}

ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]
