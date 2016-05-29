# Pull base image
# ---------------
FROM jenkins/build-mvn:latest

# Maintainer
# ----------
MAINTAINER Edwin Biemond <biemond@gmail.com>

# https://github.com/jpetazzo/dind for docker inside docker
# https://github.com/jenkinsci/docker for jenkins
# https://github.com/docker-in-practice/jenkins for jenkins swarm

COPY docker.repo /etc/yum.repos.d/docker.repo

ENV DOCKER_DAEMON_ARGS "-D --insecure-registry=demo.example.com:5555"
ENV DOCKER_STORAGE_DRIVER "-s devicemapper"

# install git, setup sudo and install docker 1.11
RUN yum install -y git unzip btrfs-progs e2fsprogs xfsprogs docker-engine iproute net-tools && \
	yum -y clean all && \
	groupadd -g 1000 jenkins_slave && \
	useradd -d /home/jenkins_slave -s /bin/bash -m jenkins_slave -u 1000 -g jenkins_slave && \
	echo jenkins_slave:jpass | chpasswd && \
	echo '%jenkins_slave ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
	sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# setup docker daemon
COPY wrapdocker /usr/local/bin/wrapdocker
COPY loop.sh    /usr/local/bin/loop.sh
COPY startup.sh /usr/bin/startup.sh

RUN chmod +x /usr/local/bin/wrapdocker && \
	chmod +x /usr/local/bin/loop.sh && \
	wget -O /home/jenkins_slave/swarm-client-2.1-jar-with-dependencies.jar http://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/2.1/swarm-client-2.1-jar-with-dependencies.jar && \
	usermod -a -G docker jenkins_slave && \
	chmod +x /usr/bin/startup.sh && \
	chown jenkins_slave:jenkins_slave /usr/bin/startup.sh

USER jenkins_slave

ENTRYPOINT ["/usr/bin/startup.sh"]