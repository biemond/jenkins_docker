## maven

### JDK

```bash
curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jdk-8u91-linux-x64.rpm > /tmp/jdk-8u91-linux-x64.rpm
rpm -i /tmp/jdk-8u91-linux-x64.rpm
```

### Maven

```bash
export MAVEN_VERSION=3.3.9
yum -y install tar
sed -i '/.*EOF/d' /etc/security/limits.conf
echo "* soft nofile 16384" >> /etc/security/limits.conf
echo "* hard nofile 16384" >> /etc/security/limits.conf
echo "# EOF"  >> /etc/security/limits.conf
curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share
mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven
ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
```
