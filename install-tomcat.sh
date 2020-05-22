#!/bin/bash
#
#********************************************************************
#Author:        wangxiaochun
#QQ:            29308620
#Date:          2020-02-09
#FileName：      install_tomcat_for_centos.sh
#URL:           http://www.wangxiaochun.com
#Description：       The test script
#Copyright (C):     2020 All rights reserved
# 基于CentOS 一键安装tomcat脚本
#********************************************************************
. /etc/init.d/functions
DIR=`pwd`
JDK_FILE="jdk-8u241-linux-x64.tar.gz"
TOMCAT_FILE="apache-tomcat-8.5.50.tar.gz"
JDK_DIR="/usr/local"
TOMCAT_DIR="/usr/local"

install_jdk(){
if !  [  -f "$DIR/$JDK_FILE" ];then
    action "$JDK_FILE 文件不存在" false 
    exit; 
elif [ -d $JDK_DIR/jdk ];then
        action "JDK 已经安装" false
    exit
else 
        [ -d "$JDK_DIR" ] || mkdir -pv $JDK_DIR
fi
tar xvf $DIR/$JDK_FILE  -C $JDK_DIR
cd  $JDK_DIR && ln -s jdk1.8.* jdk 

cat >  /etc/profile.d/jdk.sh <<EOF
export JAVA_HOME=$JDK_DIR/jdk
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=\$JAVA_HOME/lib/:\$JRE_HOME/lib/
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
.  /etc/profile.d/jdk.sh
java -version && action "JDK 安装完成" || { action "JDK 安装失败" false ; exit; }

}

install_tomcat(){
if ! [ -f "$DIR/$TOMCAT_FILE" ];then
        action "$TOMCAT_FILE 文件不存在" false 
    exit; 
elif [ -d $TOMCAT_DIR/tomcat ];then
        action "TOMCAT 已经安装" false
    exit
else 
    [ -d "$TOMCAT_DIR" ] || mkdir -pv $TOMCAT_DIR
fi
tar xf $DIR/$TOMCAT_FILE -C $TOMCAT_DIR
cd  $TOMCAT_DIR && ln -s apache-tomcat-*/  tomcat
echo "PATH=$TOMCAT_DIR/tomcat/bin:"'$PATH' > /etc/profile.d/tomcat.sh
id tomcat &> /dev/null || useradd -r -s /sbin/nologin tomcat

cat > $TOMCAT_DIR/tomcat/conf/tomcat.conf <<EOF
JAVA_HOME=$JDK_DIR/jdk
JRE_HOME=\$JAVA_HOME/jre
EOF

chown -R tomcat.tomcat $TOMCAT_DIR/tomcat/

cat > /lib/systemd/system/tomcat.service  <<EOF
[Unit]
Description=Tomcat
#After=syslog.target network.target remote-fs.target nss-lookup.target
After=syslog.target network.target 

[Service]
Type=forking
EnvironmentFile=$TOMCAT_DIR/tomcat/conf/tomcat.conf
ExecStart=$TOMCAT_DIR/tomcat/bin/startup.sh
ExecStop=$TOMCAT_DIR/tomcat/bin/shutdown.sh
PrivateTmp=true
User=tomcat

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tomcat.service
systemctl is-active tomcat.service &> /dev/null &&  action "TOMCAT 安装完成" || { action "TOMCAT 安装失败" false ; exit; }

}

install_jdk 

install_tomcat
