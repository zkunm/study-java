#! /bin/bash
## Author: zkunm
## This script is used to initialize centos7

if [[ $EUID -ne 0 ]]; then
  echo -e "\033[31m请使用root权限运行！\033[0m" 1>&2
  exit 1
fi

if [ -f "ls | grep jdk*" ]; then
  echo -e "\033[31m请拷贝jdk文件\033[0m" 1>&2
  exit 1
fi

if [ -f "ls | grep *maven*" ]; then
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
mv apache-maven* /usr/local
cd /usr/local || exit
tar -xvf apache-maven-3.6.3-bin.tar.gz
rm -rf apache-maven-3.6.3-bin.tar.gz
echo '# maven env
export MAVEN_HOME=/usr/local/apache-maven-3.6.3
export PATH=$PATH:$MAVEN_HOME/bin' >>/etc/profile
source /etc/profile
mvn -version

rm -rf *.tar.gz

echo -e "\033[31mJavaDev部署完成....\033[0m"
cd ~ || exit
sleep 3
