```shell
apt install -y vim curl openssh-server
```

## 1. 网络配置

### 关闭ipv6

```shell
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf | sysctl -p
```

### 修改ip

```shell
vim /etc/network/interfaces

auto ens32
iface ens32 inet static
address 192.168.36.10
netmask 255.255.255.0
gateway 192.168.36.2

systemctl restart networking
```

## 2. 内核参数

### ulimit

```shell
echo "* soft nofile 655365
* hard nofile 655365
root soft nofile 655365
root hard nofile 655365
" >> /etc/security/limits.conf
```

### 禁用虚拟内存（不懂不要设置这个）

```shell
echo "vm.swappiness=0" >> /etc/sysctl.conf | sysctl -p


vim /etc/fstab
把swap那行加注释
```

## 3. 软件配置

### docker

```shell
curl -fsSL https://get.docker.com -o docker.sh
sh docker.sh --mirror Aliyun 

echo '{
"registry-mirrors": ["https://jaq1wl6r.mirror.aliyuncs.com","https://docker.mirrors.ustc.edu.cn"]
}' > /etc/docker/daemon.json | systemctl restart docker

curl -L "https://download.fastgit.org/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### java

```shell
echo '# java env
export JAVA_HOME=/usr/local/jdk1.8.0_201
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin ' >> /etc/profile

source /etc/profile
java -version

echo '# maven env
export MAVEN_HOME=/usr/local/apache-maven-3.6.3
export PATH=$PATH:$MAVEN_HOME/bin' >> /etc/profile

source /etc/profile
mvn -version
```

### ssh

```shell
vim /etc/ssh/sshd_config
```

### 时间同步

```shell
apt install ntpdate -y
crontab -e
*/1 * * * * /usr/sbin/ntpdate ntp1.aliyun.com
```

