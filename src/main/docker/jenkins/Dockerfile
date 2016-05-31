# Pull base image
# ---------------
FROM jenkins/build-mvn:latest

# Maintainer
# ----------
MAINTAINER Edwin Biemond <edwin.biemond@gmail.com>

# https://github.com/jpetazzo/dind for docker inside docker
# https://github.com/jenkinsci/docker for jenkins
# https://github.com/docker-in-practice/jenkins for jenkins swarm

ENV JENKINS_HOME /var/jenkins_home
ENV JENKINS_SLAVE_AGENT_PORT 50000
ENV DOCKER_DAEMON_ARGS "-D --insecure-registry=demo.example.com:5555"
ENV DOCKER_STORAGE_DRIVER "-s devicemapper"

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
ENV JENKINS_UC https://updates.jenkins-ci.org

# add user jenkins with sudo rights which also works as daemon process
RUN	useradd -d /home/jenkins_master -u 1212 -s /bin/bash jenkins_master && \
	mkdir -p /var/jenkins_home && \
	mkdir -p /usr/share/jenkins && \
	mkdir -p /usr/share/jenkins/ref && \
	mkdir -p /home/jenkins_master/.m2 && \
	mkdir -p /home/jenkins_master/.ssh && \
	chown -R jenkins_master:jenkins_master "$JENKINS_HOME" /usr/share/jenkins /home/jenkins_master/.ssh /home/jenkins_master/.m2 && \
	echo '%jenkins_master ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
	sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

COPY uek4.repo /etc/yum.repos.d/uek4.repo
COPY docker.repo /etc/yum.repos.d/docker.repo
# setup docker daemon
COPY wrapdocker /usr/local/bin/wrapdocker
# make some new loopadaters
COPY loop.sh /usr/local/bin/loop.sh
# for slave agents
COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/tcp-slave-agent-port.groovy

# install jenkins 1.6, git and docker 1.11
RUN wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo && \
	rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key && \
	yum install -y jenkins git unzip btrfs-progs e2fsprogs xfsprogs docker-engine iproute net-tools && \
	yum -y clean all && \
	mv /usr/lib/jenkins/jenkins.war /usr/share/jenkins/ && \
	chmod +x /usr/local/bin/wrapdocker && \
	chmod +x /usr/local/bin/loop.sh && \
	usermod -a -G docker jenkins_master

# Copy over private key, and set permissions
COPY ssh/id_rsa     /home/jenkins_master/.ssh/id_rsa
COPY ssh/id_rsa.pub /home/jenkins_master/.ssh/id_rsa.pub
COPY settings.xml   /home/jenkins_master/.m2/settings.xml
COPY jenkins.sh     /usr/local/bin/jenkins.sh
COPY plugins.sh     /usr/local/bin/plugins.sh

RUN chown -R jenkins_master:jenkins_master /home/jenkins_master/.ssh /home/jenkins_master/.m2 /usr/local/bin/jenkins.sh /usr/local/bin/plugins.sh && \
	chmod -R 700 /home/jenkins_master/.ssh && \
	chmod +x /usr/local/bin/jenkins.sh && \
	chmod +x /usr/local/bin/plugins.sh

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME /var/jenkins_home

# optional re-use docker images
VOLUME /var/lib/docker

# expose jenkins ports
EXPOSE 8080 50000

USER jenkins_master

# install plugins
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/plugins.sh /tmp/plugins.txt

ENTRYPOINT ["/usr/local/bin/jenkins.sh"]

