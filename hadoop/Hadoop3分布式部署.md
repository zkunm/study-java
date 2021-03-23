### 1. 环境介绍

服务器环境：Centos7	3台服务器 (已安装好jdk1.8环境)	1cpu2g

| 节点 | IP             |                                      |
| ---- | -------------- | ------------------------------------ |
| m1   | 192.168.36.100 | NameNode,DataNode,NodeManager        |
| m2   | 192.168.36.101 | DataNode,NodeManager,ResourceManager |
| m3   | 192.168.36.102 | DataNode,NodeManager,SecondNamenode  |

![image-20210218195112597](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210218195112.png)

安装计划：

​	软件安装目录为 /opt/hadoop

​	数据存放目录为 /opt/data/hadoop

### 2.  hadoop安装前准备

#### 1）、修改linux主机名

```shell
三台主机分别设置主机名为m1,m2,m3

hostnamectl set-hostname m1
hostnamectl set-hostname m2
hostnamectl set-hostname m3
```

#### 2）、修改linux IP地址

```shell
vim /etc/sysconfig/network-scripts/ifcfg-ens32

把bootproto类型改为static,并在文件下面追加如下内容,保存后使用systemctl restart network重启网卡设备
```

![image-20210218200453298](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210218200453.png)

#### 3）、修改hosts文件

```shell
echo '192.168.36.100 m1
192.168.36.101 m2
192.168.36.102 m3'>> /etc/hosts
```

#### 4）、配置ssh远程登陆

```shell
ssh-keygen
ssh-copy-id m1
ssh-copy-id m2
ssh-copy-id m3
```

#### 5）、使用scp命令把hosts拷贝到其他机器

```shell
scp -r /etc/host m2:/etc/hosts
scp -r /etc/host m3:/etc/hosts
```

### 3. 安装Hadoop3.2.2集群

#### 1）、下载并解压文件

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.2.2/hadoop-3.2.2.tar.gz
mv hadoop-3.2.2.tar.gz /opt/
cd /opt/
tar -xvf hadoop-3.2.2.tar.gz
mv hadoop-3.2.2 hadoop
rm -rf hadoop-3.2.2.tar.gz
```

#### 2）、修改配置文件

##### core-site.xml

```shell
cd hadoop/etc/hadoop
vim core-site.xml

<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://m1:9000</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/opt/data/hadoop</value>
  </property>
</configuration>

```

![image-20210219142318258](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210219142318.png)

##### hdfs-site.xml

```shell
<configuration>
  <!-- nn web端访问地址-->
  <property>
    <name>dfs.namenode.http-address</name>
    <value>m1:50090</value>
  </property>
  <!-- 2nn web端访问地址-->
  <property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>m3:50091</value>
  </property>
</configuration>
```



![image-20210219142745318](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210219142745.png)

##### yarn-site.xml

```shell
<configuration>
  <!--指定mapreduce走shuffle -->
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <!-- 指定ResourceManager的地址-->
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>m2</value>
  </property>
  <!-- 环境变量的继承 -->
  <property>
    <name>yarn.nodemanager.env-whitelist</name>
    <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
  </property>
</configuration>
```



![image-20210219142909534](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210219142909.png)

##### mapred-site.xml

```shell
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
</configuration>
```

![image-20210219143052319](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210219143052.png)

##### hadoop-env.sh

```shell
export HDFS_DATANODE_USER=root
export HDFS_NAMENODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
export JAVA_HOME=/usr/local/jdk1.8.0_201
```

![image-20210219143451395](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210219143451.png)

##### workers

![image-20210219143530418](https://zkunm-markdown-images.oss-cn-shanghai.aliyuncs.com/img/20210219143530.png)

系统变量

```shell
echo '# hadoop env
export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin'>>/etc/profile
```

##### scp 发送文件

```shell
scp -r /opt/hadoop m2:/opt/hadoop
scp -r /opt/hadoop m3:/opt/hadoop
```

### 4.启动hadoop集群

```shell
hdfs namenode -format #第一次启动需要格式化节点

start-all.sh
# 启动失败可进入hadoop/logs目录查看日志

jps #查看各节点是否运行正确
```

### 5.验证wordcount

```shell
vim words.txt

hadoop fs -ls /			#查看根目录
hadoop fs -mkdir /input	#新建输入目录
hadoop fs -put words.txt /input/ #上传文件到hdfs
cd /opt/hadoop/share/hadoop/mapreduce #切换到自带mapreduce目录
hadoop jar hadoop-mapreduce-examples-3.2.2.jar wordcount /input /output/
hadoop fs -cat /output/part-r-00000 #查看结果
```

