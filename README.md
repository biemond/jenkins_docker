# Building docker images with Maven & Jenkins 2

This will use maven to build a jenkins master and slave docker image

After this you can use these docker images to start your own jenkins environment. The jenkins nodes can also build docker images or itself

## docker maven plugin
https://github.com/fabric8io/docker-maven-plugin

introduction to this plugin

https://fabric8io.github.io/docker-maven-plugin/index.html

## for a new VM follow these guides
- docker_oel7.md
- maven.md

## all major utilities inside the image
```bash
mvn -v
java -version
docker -v
```

## set memory
- export MAVEN_OPTS='-Xms2048m -Xmx2048m'

## build with maven
- mvn package

## test and verify
- mvn verify

## run docker image
- mvm install

## push image to registry
- mvn docker:push

## Build your own environment

## start the jenkins master

### default which uses loopback adapter with devicemapper as storage-driver
- docker run -i -t --privileged -p 8080:8080 -p 50000:50000 --name jenkins_server jenkins/build-jenkins:latest

or with persistence
- docker run -i -t --privileged -p 8080:8080 -p 50000:50000 --name jenkins_server -v /vagrant/jenkins_persistence:/var/jenkins_home jenkins/build-jenkins:latest

### with btrfs as storage-driver
requires /var/lib/docker btrfs filesystem
- docker run -i -t --privileged -p 8080:8080 -p 50000:50000 -e DOCKER_STORAGE_DRIVER='-s btrfs' --name jenkins_server jenkins/build-jenkins:latest

or with persistence
- docker run -i -t --privileged -p 8080:8080 -p 50000:50000 -e DOCKER_STORAGE_DRIVER='-s btrfs'  --name jenkins_server -v /vagrant/jenkins_persistence:/var/jenkins_home jenkins/build-jenkins:latest

## activate jenkins 2
- get password from the output or do this
- docker exec -i -t jenkins_server bash
- cat /var/jenkins_home/secrets/initialAdminPassword and get password for enable jenkins
- Use admin with that password for the slaves

## start jenkins slaves with username/password
Replace XXXX with the acquired password
- docker run -i -t --privileged --hostname jenkinsslave1 --name jenkinsslave1 jenkins/build-jenkins-slave:latest -username admin -password XXXXX
- docker run -i -t --privileged --hostname jenkinsslave1 -e JENKINS_SERVER='x.x.x.x' --name jenkinsslave1 jenkins/build-jenkins-slave:latest -username admin -password XXXXX

### with btrfs as storage-driver
requires /var/lib/docker btrfs filesystem
- docker run -i -t --privileged --hostname jenkinsslave1 -e DOCKER_STORAGE_DRIVER='-s btrfs' --name jenkinsslave1 jenkins/build-jenkins-slave:latest -username admin -password XXXXX
- docker run -i -t --privileged --hostname jenkinsslave1 -e JENKINS_SERVER='x.x.x.x'  -e DOCKER_STORAGE_DRIVER='-s btrfs' --name jenkinsslave1 jenkins/build-jenkins-slave:latest -username admin -password XXXXX

### Setup maven & java
- maven /usr/share/maven
- java /usr/java/jdk1.8.0_91


## Usefull Docker commands

Show images
- docker images

Show instances
- docker ps -a

Remove instances
- docker rm XXXXX

Remove all instances
- docker rm $(docker ps -a -q)

Remove image
- docker rmi XXXX

Remove all images
- docker rmi $(docker images -q)


## Possbile Errors and solution

[ERROR] DOCKER> Driver devicemapper failed to remove root filesystem 32a7bdd7c4eae02ce72107848922811b9824554e52b2fe1034a12e6f391c4868: Device is Busy (Internal Server Error: 500)

Probably because of the devicemapper as storage-driver

```bash
find /var/lib/docker -name 32a7bdd7c4eae02ce72107848922811b9824554e52b2fe1034a12e6f391c4868
rm -rf those files
systemctl restart docker
docker rm $(docker ps -a -q)
```
