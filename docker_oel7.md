## One time, docker workstation setup

### Docker install

#### become root

    sudo su - or sudo -i

#### Docker Repo Docker

```bash
cat >/etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/oraclelinux/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

#### Docker 1.11

Watch out with docker 1.10 the kernel will be updated to UEK4 and it needs a reboot. Use 1.9.1 version for earlier kernels

- yum search docker-engine
- yum info docker-engine
- yum install docker-engine
- docker -v

```bash
systemctl start docker.service
systemctl enable docker.service
```

#### possible startup problems
- when error initializing graphdriver -> rm -rf /var/lib/docker/devicemapper

#### docker group and give permission to ebiemond

```bash
/usr/sbin/usermod -aG docker vagrant
chown root.docker /var/run/docker.sock
systemctl restart docker
```


#### Test setup

- docker run hello-world

#### using btrfs storage

when you are using this vagrant box then you can skip all this, because /dev/sda is already btrfs but you need to enable the storage engine with -s btrfs

overview
https://developerblog.redhat.com/2014/09/30/overview-storage-scalability-docker/

extra info installing BRTFS
https://docs.oracle.com/cd/E52668_01/E54669/html/section_kfy_f2z_fp.html

Add a new filesystem or change your current filesystem. In this case /dev/sdb

```bash
systemctl stop docker
rm -rf /var/lib/docker
yum install -y btrfs-progs btrfs-progs-devel
mkfs.btrfs -f /dev/sdb
mkdir /var/lib/docker
echo "/dev/sdb /var/lib/docker btrfs defaults 0 0" >> /etc/fstab
mount -a
```

check filesystem
- btrfs filesystem show /var/lib/docker
- btrfs filesystem df /var/lib/docker
- btrfs device stats /dev/sdb


update storage with -s btrfs
- vi /usr/lib/systemd/system/docker.service

```bash
ExecStart=/usr/bin/docker daemon -H fd:// -s btrfs $OPTIONS
```

Start docker
```bash
systemctl daemon-reload
systemctl start docker
```

check docker if btrfs is enabled
- docker info

### Docker registry

#### one time

- sudo vi /usr/lib/systemd/system/docker.service

update the following line with $OPTIONS
think about btrfs filesysytem or not

```bash
ExecStart=/usr/bin/docker daemon -H fd:// $OPTIONS
```

- sudo vi /etc/systemd/system/docker.service.d/50-insecure-registry.conf

```bash
[Service]
Environment="OPTIONS=--insecure-registry=cdt.docker.oraclecorp.com"
```

```bash
systemctl daemon-reload
systemctl restart docker
systemctl show docker --property Environment
```