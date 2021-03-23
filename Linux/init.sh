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
yum install -y ntpdate wget net-tools yum-utils vim

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