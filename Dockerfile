FROM phusion/baseimage:0.9.13
MAINTAINER Wayne Leroux <WayneLeroux@gmail.com>

# Set up base image
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y dist-upgrade
ENV HOME /root
RUN echo 'LANG="en_EN.UTF-8"' > /etc/default/locale
CMD ["/sbin/my_init"]

# Support SSH
VOLUME /root/.ssh

# Install Java 7
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer
RUN update-java-alternatives -s java-7-oracle
RUN echo 'export JAVA_HOME="/usr/lib/jvm/java-7-oracle"' >> ~/.bashrc
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
ENV PATH $PATH:$JAVA_HOME/bin
RUN export PATH=$PATH

# Install Administration Utilities
RUN apt-get -y install wget unzip git sudo zip bzip2 fontconfig curl vim

# Install Bamboo
ENV BAMBOO_VERSION 5.6.1
RUN wget -P /tmp http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz \
    && tar xzf /tmp/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz -C /opt
RUN mkdir /etc/service/atlassian-bamboo-${BAMBOO_VERSION} \
    && echo "#!/bin/bash\n/opt/atlassian-bamboo-${BAMBOO_VERSION}/bin/start-bamboo.sh -fg" > /etc/service/atlassian-bamboo-${BAMBOO_VERSION}/run \
    && chmod +x /etc/service/atlassian-bamboo-${BAMBOO_VERSION}/run
RUN echo 'export BAMBOO_HOME="/var/bamboo-home"' >> ~/.bashrc
ENV BAMBOO_HOME /var/bamboo-home
RUN mkdir -p /var/bamboo-home && chmod 777 /var/bamboo-home
VOLUME /var/bamboo-home
EXPOSE 8085

# Install MySQL Support for Bamboo
RUN wget -P /tmp http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.32.tar.gz
RUN tar xzf /tmp/mysql-connector-java-5.1.32.tar.gz -C /tmp
RUN cp /tmp/mysql-connector-java-5.1.32/mysql-connector-java-5.1.32-bin.jar /opt/atlassian-bamboo-${BAMBOO_VERSION}/atlassian-bamboo/WEB-INF/lib/mysql-connector-java-5.1.32-bin.jar

# Clean up when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

