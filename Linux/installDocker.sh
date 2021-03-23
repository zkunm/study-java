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
