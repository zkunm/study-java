#! /bin/bash
## Author: zkunm
## This script is used to initialize centos7

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m请使用root权限运行！\033[0m" 1>&2
  exit 1
fi

if [ -f "ls | grep mysql" ]; then
  echo -e "\033[31m请拷贝mysql文件\033[0m" 1>&2
  exit 1
fi

nowTime=$(date "+%Y-%m-%d %H:%M:%S")
echo "现在的时间是：$nowTime"

rpm -e --nodeps $(rpm -qa | grep mariadb)
rpm -e --nodeps $(rpm -qa | grep -i mysql)
tar -xvf mysql-*
yum -y install perl net-tools numactl-libs
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
