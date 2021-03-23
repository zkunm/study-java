# docker

## 1. docker 配置

### 1.1 安装

```shell
yum remove docker docker-common docker-selinux docker-engine
yum install -y yum-utils device-mapper-persistent-data lvm2

yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum list docker-ce --showduplicates | sort -r
yum install docker-ce

systemctl start docker
systemctl enable docker
docker info


# github代理
curl -L "https://git.yumenaka.net/https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# 最新版本
https://github.com/docker/compose/releases

# docker目录
/var/lib/docker
```

### 1.2 设置镜像

```shell
# 编辑该文件
vi /etc/docker/daemon.json

echo '{
"registry-mirrors": ["https://jaq1wl6r.mirror.aliyuncs.com","https://docker.mirrors.ustc.edu.cn"]
}' > /etc/docker/daemon.json
```


## 2. 常用命令

### 2.1. 镜像

```shell
# 查看镜像
docker images
# 镜像存储在宿主机的/var/lib/docker目录下

# 搜索镜像
docker search 镜像名称

# 拉取镜像 
docker pull 镜像名称

# 按镜像删除
docker rmi 镜像ID
docker rmi 镜像名称：版本号
# 删除所有镜像
docker rmi `docker images -q`
```

### 2.2 容器

```shell
# 查看正在运行的容器
docker ps
# 查看所有容器
docker ps –a
# 查看最后一次运行的容器
docker ps –l
# 查看停止的容器
docker ps -f status=exited
```

```
创建容器常用的参数说明：
创建容器命令：docker run
-i：表示运行容器
-t：表示容器启动后会进入其命令行。
--name :为创建的容器命名。
-v：表示目录映射关系（前者是宿主机目录，后者是映射到宿主机上的目录），可以使用多个－v做多个目录
或文件映射。注意：最好做目录映射，在宿主机上做修改，然后共享到容器上。
-d：在run后面加上-d参数,则会创建一个守护式容器在后台运行（这样创建容器后不会自动登录容器，如果
只加-i -t两个参数，创建后就会自动进去容器）。
-p：表示端口映射，前者是宿主机端口，后者是容器内的映射端口。可以使用多个-p做多个端口映射
```

```shell
# 1 交互式方式创建容器
# 会进入容器内部shell
docker run -it --name=容器名称 镜像名称:标签 /bin/bash
# 退出当前容器
exit
# 2 守护式方式创建容器
docker run -di --name=容器名称 镜像名称:标签
# 3 登录守护式容器
docker exec -it 容器名称 (或者容器ID) /bin/bash
```

```shell
# 停止容器
docker stop 容器名称（或者容器ID）
# 启动容器
docker start 容器名称（或者容器ID）
```

```shell
# 将文件拷贝到容器内可以使用cp命令
docker cp 需要拷贝的文件或目录 容器名称:容器目录
# 将文件从容器内拷贝出来
docker cp 容器名称:容器目录 需要拷贝的文件或目录
```

```shell
docker run -di -v centos7:/usr --name=centos centos:7
# 如果共享的是多级的目录，可能会出现权限不足的提示.这是因为CentOS7中的安全模块selinux把权限禁掉了，需要添加参数--privileged=true来解决挂载的目录没有权限的问题
docker run -di -v centos7:/usr --name=centos --privileged=true centos:7 
```

```shell
# 通过以下命令查看容器运行的各种数据
docker inspect 容器名称（容器ID）
# 也可以直接执行下面的命令直接输出IP地址
docker inspect --format='{{.NetworkSettings.IPAddress}}' 容器名称（容器ID）
```

```shell
# 容器启动不成功时，可以查看容器日志解决问题
docker logs -f 容器名称(容器ID)
```

```shell
# 删除指定的容器：
docker rm 容器名称（容器ID）
```

## 3. 应用部署

### 3.1 mysql

```shell
# 创建容器
# -e 代表添加环境变量 MYSQL_ROOT_PASSWORD是root用户的登陆密码
docker run -p 3306:3306 --name mysql -v /opt/mysql/conf:/etc/mysql/conf.d -v /opt/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.22


[client]
default-character-set = utf8mb4
[mysql]
default-character-set = utf8mb4
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

max_allowed_packet=1073741824
sql_mode='STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'

```

### 3.2 redis

```shell
# 创建容器
docker run -di --name=redis -v redis:/data -p 6379:6379 redis
```

### 3.3 portainer

``` shell
# 创建容器
docker run -di -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock --restart=always --name prtainer portainer/portainer
# --restart=always 意味这此容器伴随docker的启动而启动
# prtainer要求第一次使用时需要注册一个本地账户，注册成功选择local模式即可
```

### 3.4 registry

```shell
docker run -di --name=registry --restart=always -p 5000:5000 -v /data/docker/registry:/var/lib/registry registry

{"insecure-registries":["192.168.36.10:5000"]} 
```

### 3.5 gitea

```shell
docker run -di --name=gitea -p 10022:22 -p 3000:3000 -v /data/docker/gitea:/data --restart=always gitea/gitea:latest
```

### 3.6 gitlab

```shell
docker pull twang2218/gitlab-ce-zh

docker run -di -p 10443:443 -p 10080:80 -p 10022:22 --name gitlab --restart always -v /data/docker/gitlab/config:/etc/gitlab -v /data/docker/gitlab/logs:/var/log/gitlab -v /data/docker/gitlab/data:/var/opt/gitlab --privileged=true twang2218/gitlab-ce-zh

root

cd /data/docker/gitlab/config
vim gitlab.rb

external_url 'http://192.168.36.11:10080'
nginx['listen_port'] = 80  ## 容器内的端口，配置后会将宿主机的10080跳转到容器的80
gitlab_rails['gitlab_ssh_host'] = '192.168.36.11'
gitlab_rails['gitlab_shell_ssh_port'] = 10022
```

### 3.7 jenkins

```shell
docker pull jenkinsci/blueocean

docker run -di -u root --name jenkins --privileged=true -d -p 8080:8080 -p 50000:50000 -v /data/docker/jenkins-data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkinsci/blueocean

# 管理员初始密码
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# 镜像源
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
```

