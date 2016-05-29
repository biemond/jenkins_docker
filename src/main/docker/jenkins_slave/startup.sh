#!/bin/bash

# only for not BTRFS  storage engines
echo "used storagedriver ${DOCKER_STORAGE_DRIVER}"
if [ "${DOCKER_STORAGE_DRIVER}" == "-s devicemapper" ]
then
  echo "add 2 loop adapters for this storagedriver"
  sudo /usr/local/bin/loop.sh
fi

set +e
value=$( egrep -c '(svm|vmx)' /proc/cpuinfo )
if [ $value -ge 1 ]
then
   echo "Found vmx or svm cpu extension"
   sudo lsmod | grep '\<kvm\>' > /dev/null || {
     echo >&2 "KVM module not loaded; software emulation will be used"
   }

   if [ ! -e /dev/kvm ]
   then
      sudo mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ') || {
         echo >&2 "Unable to make /dev/kvm node; software emulation will be used"
         echo >&2 "(This can happen if the container is run without -privileged)"
      }
   fi

   sudo dd if=/dev/kvm count=0 2>/dev/null || {
     echo >&2 "Unable to open /dev/kvm; qemu will use software emulation"
   }

else
   echo "No vmx or svm cpu extension found; software emulation will be used"
fi
set -e

sudo -E /usr/local/bin/wrapdocker &
sleep 5
sudo chown root.docker /var/run/docker.sock

echo `ip route`
HOST_IP=$(ip route | grep ^default | awk '{print $3}')
JENKINS_SERVER=${JENKINS_SERVER:-$HOST_IP}
JENKINS_PORT=${JENKINS_PORT:-8080}
JENKINS_LABELS=${JENKINS_LABELS:-swarm}
JENKINS_HOME=${JENKINS_HOME:-$HOME}
echo "Starting up swarm client with args:"
echo "$@"
echo "and env:"
echo "$(env)"
set -x
java -jar /home/jenkins_slave/swarm-client-2.1-jar-with-dependencies.jar -disableClientsUniqueId -fsroot "$JENKINS_HOME" -labels "$JENKINS_LABELS" -master http://$JENKINS_SERVER:$JENKINS_PORT $@
#sleep infinity
while true; sleep 1; done
