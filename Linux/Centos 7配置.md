

# Centos  7 环境初始化

## 一、关闭selinux

```shell
setenforce 0
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
```

执行命令后重启，查看运行状态

```shell
getenforce
```

## 二、禁用防火墙

关闭防火墙

```shell
systemctl stop firewalld
```

禁止防火墙自启动

```shell
systemctl disable firewalld
```

## 三、NetworkManager

**NetworkManager服务与network服务冲突**

关闭NetworkManager

```shell
systemctl stop NetworkManager
```

禁止NetworkManage自启动

```shell
systemctl disable NetworkManager
```

## 四、关闭swap分区

临时关闭

```shell
swapoff -a && sysctl -w vm.swappiness=0
```

永久关闭（需重启）

```shell
sed -i "s/^\/dev\/mapper\/centos-swap/# \/dev\/mapper\/centos-swap/g" /etc/fstab
```

## 五、配置ulimt

```shell
echo 'DefaultLimitNOFILE=65536
DefaultLimitNPROC=65536' >> /etc/systemd/system.conf
echo 'DefaultLimitNOFILE=65536
DefaultLimitNPROC=65536' >> /etc/systemd/user.conf

echo '* soft nofile 655356
* hard nofile 65536 ' >> /etc/security/limits.conf

echo 'ulimit -n 65536' >> /etc/profile
```

## 六、配置内核参数

```shell
echo 'vm.swappiness=0' >> /etc/sysctl.conf

sysctl -p
```

## 六、时间同步


设置时区


```shell
timedatectl set-timezone Asia/Shanghai
```

开启自动同步时间

```
timedatectl set-ntp yes
```


任务计划同步时间

```shell
systemctl start crond
systemctl enable crond
yum install ntpdate
crontab -e
*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com
```
手动同步
```shell
ntpdate ntp1.aliyun.com
```


## 七、epel源

```shell
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
```

## 八、升级内核

更新yum源仓库

```shell
yum -y update
```

启用ELRepo 仓库

```shell
# 导入ELRepo仓库的公共密钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# 安装ELRepo仓库的yum源
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
```

查看可用的系统内核包

```shell
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
```

安装最新版本内核

```shell
yum --enablerepo=elrepo-kernel install kernel-ml
```

查看系统所有可用内核

```shell
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```

设置新的内核为grub2的默认方式

```shell
grub2-set-default 0 
# 其中0是上面查询出来的可用内核
```

生成 grub 配置文件并重启

```shell
grub2-mkconfig -o /boot/grub2/grub.cfg
```

验证

```shell
uname -r
```

查看系统中全部的内核

```shell
rpm -qa | grep kernel
```

卸载旧内核

```shell
yum remove kernel-3* kernel-tools-*
```

## 九、Docker

卸载旧版docker，安装docker依赖

```shell
yum remove docker docker-common docker-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2
```

设置docker的yum源

```shell
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

查看docker-ce全部版本

```shell
yum list docker-ce --showduplicates | sort -r
```

安装docker

```shell
yum install docker-ce
```

启动docker并添加自启动

```shell
systemctl start docker
systemctl enable docker
```

安装docker-compose

```shell
# github代理
curl -L "https://g.ioiox.com/https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# 最新版本
https://github.com/docker/compose/releases
```

#### 1、配置docker源

配置daemon.json（需重启）

```shell
echo '{
"registry-mirrors": ["https://jaq1wl6r.mirror.aliyuncs.com","https://docker.mirrors.ustc.edu.cn"]
}' > /etc/docker/daemon.json
```

#### 2、docker web界面-portainer

```shell
docker run -di -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock --restart=always --name prtainer portainer/portainer
```

#### 3、docker注册中心-registry

```shell
docker run -di --name=registry --restart=always -p 5000:5000 -v /data/docker/registry:/var/lib/registry registry
```

配置daemon.json（需重启）

```shell
vi /etc/docker/daemon.json
```

添加

```shell
echo '{
"registry-mirrors": ["https://jaq1wl6r.mirror.aliyuncs.com","https://docker.mirrors.ustc.edu.cn"],
"insecure-registries":["192.168.36.10:5000"]
}' > /etc/docker/daemon.json
```

## 十0、yum

显示所有已启动的资源库

```shell
yum repolist enabled
```

添加repository

```shell
yum-config-manager --add-repo repository_url
```

启动、关闭库资源

```shell
yum-config-manager --disable name
yum-config-manager --enable name
```

删除仓库，删除 /etc/yum.repos.d/ 目录下对应的repo文件即可

```shell
# 关闭以上仓库
yum-config-manager --disable docker-ce-stable elrepo
```



## 十、Java环境

查看系统自带jdk，并卸载

```shell
rpm -e --nodeps `rpm -qa | grep java`
```

上传文件解压

```shell
cd /usr/local
tar -xvf jdk-8u201-linux-x64.tar.gz
```

配置环境变量

```shell
echo '# java env
export JAVA_HOME=/usr/local/jdk1.8.0_201
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin ' >> /etc/profile
```

重新加载/etc/profile文件，并且验证

```shell
source /etc/profile
java -version
```

## 十一、MySQL

查看系统自带Maria DB，MySQL，并卸载

```shell
rpm -e --nodeps `rpm -qa | grep mariadb`
rpm -e --nodeps `rpm -qa | grep -i mysql`
```
**rpm yum任选一种**

rpm方式
```shell
# 上传文件 解压
tar -xvf mysql-5.7.31-1.el7.x86_64.rpm-bundle.tar
yum -y install perl net-tools
# common -> libs -> client -> server
rpm -ivh mysql-community-common-5.7.31-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.31-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.31-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.31-1.el7.x86_64.rpm
```
yum方式
```shell
wget -i -c https://repo.mysql.com//mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql-community-server
yum -y remove mysql57-community-release-el7-10.noarch
````

启动mysql并且查看自动生成的密码

```shell
systemctl start mysqld
cat /var/log/mysqld.log | grep password
```

登录mysql，并修改root密码

```shell
mysql -uroot -p
ALTER USER USER() IDENTIFIED BY '123Abc...';
# 设置密码安全策略
set global validate_password_policy=0;
set global validate_password_length=4;
ALTER USER USER() IDENTIFIED BY '123456';
# 远程访问
grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;
flush privileges ;
quit;
```

配置字符集utf8mb4

```shell
echo '[client]
default-character-set = utf8mb4
[mysql]
default-character-set = utf8mb4
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

max_allowed_packet=1073741824
sql_mode='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'

validate_password_policy=0
validate_password_length=4' >> /etc/my.cnf
```

重启mysql服务，关闭自启动


```shell
systemctl restart mysqld
systemctl disable mysqld
```

## 十二、 Maven

上传文件解压

```shell
cd /usr/local
tar -xvf apache-maven-3.6.3-bin.tar.gz
```

配置环境变量，修改setting.xml文件

```shell
echo '# maven env
export MAVEN_HOME=/usr/local/apache-maven-3.6.3
export PATH=$PATH:$MAVEN_HOME/bin' >> /etc/profile
```

重新加载/etc/profile文件，并且验证

```shell
source /etc/profile
mvn -version
```

## 十三、Jenkins

```shell
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins

# 自动安装完成之后： 
/usr/lib/jenkins/jenkins.war    WAR包 
/etc/sysconfig/jenkins       	配置文件
/var/lib/jenkins/        		默认的JENKINS_HOME目录
/var/log/jenkins/jenkins.log    Jenkins日志文件

yum remove jenkins
rm -rf /var/lib/jenkins/ /var/log/jenkins/jenkins.log

# 需要手动配置jdk
vi /etc/init.d/jenkins

>>>>>>
candidates="
......
/usr/local/java/jdk1.8.0_201/bin/java
"
<<<<<<

systemctl daemon-reload
systemctl start jenkins
tail -f /var/log/jenkins/jenkins.log
# 8ef68e522c2c4fd392e7de8013c33868

https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
```

# init.sh

```shell
#! /bin/bash
## Author: zkunm
## This script is used to initialize centos7

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m请使用root权限运行！\033[0m" 1>&2
  exit 1
fi

nowTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "现在的时间是：$nowTime"

echo "安装依赖...."
yum -y update
yum install -y ntpdate wget net-tools yum-utils

echo -e "\033[31m正在关闭Selinux...（需要重启）\033[0m"
setenforce 0
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/sysconfig/selinux
sed -i "s/^SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config

echo -e "\033[31m正在关闭firewalld...\033[0m"
systemctl stop firewalld
systemctl disable firewalld

echo -e "\033[31m正在关闭NetworkManager...\033[0m"
systemctl stop NetworkManager
systemctl disable NetworkManager

echo -e "\033[31m正在关闭swap...\033[0m"
sed -i "s/^\/dev\/mapper\/centos-swap/# \/dev\/mapper\/centos-swap/g" /etc/fstab
echo 'vm.swappiness=0' >>/etc/sysctl.conf
sysctl -p

echo -e "\033[31m正在修改文件限制...\033[0m"
echo 'DefaultLimitNOFILE=65536
DefaultLimitNPROC=65536' >>/etc/systemd/system.conf
echo 'DefaultLimitNOFILE=65536
DefaultLimitNPROC=65536' >>/etc/systemd/user.conf
echo '* soft nofile 655356
* hard nofile 65536 ' >>/etc/security/limits.conf
echo 'ulimit -n 65536' >>/etc/profile

echo -e "\033[31m正在修改host文件...\033[0m"
myIp=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:")
for line in $myIp; do
  echo "$line devos" >>/etc/hosts
done

echo -e "\033[31m正在设置自动同步时间...\033[0m"
timedatectl set-ntp yes
systemctl start crond
systemctl enable crond
if ! crontab -l | grep ntpdate &>/dev/null; then
  (
    echo "*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1"
    hwclock -w
    crontab -l
  ) | crontab
fi

echo -e "\033[31m正在升级内核...\033[0m"
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel -y install kernel-ml
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg

echo -e "\033[31m即将重启...\033[0m"
sleep 3
reboot
```

# installDocker.sh

```shell
#! /bin/bash
## Author: zkunm
## This script is used to initialize centos7

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m请使用root权限运行！\033[0m" 1>&2
  exit 1
fi

nowTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "现在的时间是：$nowTime"
echo -e "\033[31m安装依赖....\033[0m"
yum remove docker docker-common docker-selinux docker-engine
yum -y update
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl start docker
systemctl enable docker

echo -e "\033[31m安装docker-compose....\033[0m"
curl -L "https://g.ioiox.com/https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo -e "\033[31m修改docker镜像....\033[0m"
echo '{
"registry-mirrors": ["https://jaq1wl6r.mirror.aliyuncs.com","https://docker.mirrors.ustc.edu.cn"]
}' >/etc/docker/daemon.json
systemctl restart docker

echo -e "\033[31m安装portainer....\033[0m"
docker run -di -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock --restart=always --name prtainer portainer/portainer
echo -e "\033[31m安装registry....\033[0m"
docker run -di --name=registry --restart=always -p 5000:5000 -v /data/docker/registry:/var/lib/registry registry
echo '{
"registry-mirrors": ["https://jaq1wl6r.mirror.aliyuncs.com","https://docker.mirrors.ustc.edu.cn"],
"insecure-registries":["192.168.36.10:5000"]
}' >/etc/docker/daemon.json
systemctl restart docker
echo -e "\033[31mdocker安装完成....\033[0m"
sleep 3

```

# installJavaDev.sh

```shell
#! /bin/bash
## Author: zkunm
## This script is used to initialize centos7

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m请使用root权限运行！\033[0m" 1>&2
  exit 1
fi

if [ ! -f "ls | grep jdk" ]; then
  echo -e "\033[31m请拷贝jdk文件\033[0m" 1>&2
  exit 1
fi

if [ ! -f "ls | grep maven" ]; then
  echo -e "\033[31m请拷贝maven文件\033[0m" 1>&2
  exit 1
fi

nowTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "现在的时间是：$nowTime"

echo -e "\033[31m安装JDK8....\033[0m"
mv jdk* /usr/local
rpm -e --nodeps $(rpm -qa | grep java)
cd /usr/local || exit
tar -xvf jdk-8u201-linux-x64.tar.gz
rm -rf jdk-8u201-linux-x64.tar.gz
echo '# java env
export JAVA_HOME=/usr/local/jdk1.8.0_201
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin ' >>/etc/profile
source /etc/profile
java -version

echo -e "\033[31m安装Maven....\033[0m"
mv *maven* /usr/local
cd /usr/local || exit
tar -xvf apache-maven-3.6.3-bin.tar.gz
rm -rf apache-maven-3.6.3-bin.tar.gz
echo '# maven env
export MAVEN_HOME=/usr/local/apache-maven-3.6.3
export PATH=$PATH:$MAVEN_HOME/bin' >>/etc/profile
source /etc/profile
mvn -version

echo -e "\033[31mJavaDev部署完成....\033[0m"
cd ~ || exit
sleep 3

```

# installMySQL57.sh

```shell
#! /bin/bash
## Author: zkunm
## This script is used to initialize centos7

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m请使用root权限运行！\033[0m" 1>&2
  exit 1
fi

if [ ! -f "ls | grep mysql" ]; then
  echo -e "\033[31m请拷贝mysql文件\033[0m" 1>&2
  exit 1
fi

nowTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "现在的时间是：$nowTime"

rpm -e --nodeps $(rpm -qa | grep mariadb)
rpm -e --nodeps $(rpm -qa | grep -i mysql)
tar -xvf mysql-*
yum -y install perl net-tools
rpm -ivh mysql-community-common-5.7.31-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.31-1.el7.x86_64.rpm
rpm -ivh mysql-community-client-5.7.31-1.el7.x86_64.rpm
rpm -ivh mysql-community-server-5.7.31-1.el7.x86_64.rpm
rm -rf mysql-*
systemctl start mysqld
sleep 1
echo -e "\033[31m修改密码....\033[0m"
myPassword=$(cat /var/log/mysqld.log | grep "password is generated" | awk '{print $11}')
mysql -uroot -p${myPassword}  --connect-expired-password -e "
ALTER USER USER() IDENTIFIED BY '123Abc...';
# 设置密码安全策略
set global validate_password_policy=0;
set global validate_password_length=4;
ALTER USER USER() IDENTIFIED BY '123456';
# 远程访问
grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;
"
echo -e "\033[31m修改默认字符集为utf8mb4....\033[0m"
echo '[client]
default-character-set = utf8mb4
[mysql]
default-character-set = utf8mb4
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
validate_password_policy=0
validate_password_length=4' >>/etc/my.cnf
systemctl restart mysqld
echo -e "\033[31mMySQL5.7安装完成....
******密码:123456
\033[0m"
sleep 3

```

