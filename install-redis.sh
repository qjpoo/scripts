#!/bin/bash
#
#********************************************************************
#Author:        wangxiaochun
#QQ:            29308620
#Date:          2020-02-22
#FileName：      install_redis_for_centos.sh
#URL:           http://www.magedu.com
#Description：       The test script
#Copyright (C):     2020 All rights reserved
# 基于CentOS 一键编译安装Redis脚本
#********************************************************************
. /etc/init.d/functions 
VERSION=redis-4.0.14
PASSWORD=123456
INSTALL_DIR=/apps/redis

install() {
yum  -y install gcc jemalloc-devel || { action "安装软件包失败，请检查网络配置" false ; exit; }

wget http://download.redis.io/releases/${VERSION}.tar.gz || { action "Redis 源码下载失败" false ; exit; }

tar xf ${VERSION}.tar.gz
cd ${VERSION}
make -j 4 PREFIX=${INSTALL_DIR} install && action "Redis 编译安装完成" || { action "Redis 编译安装失败" false ;exit ; }

ln -s ${INSTALL_DIR}/bin/redis-*  /usr/bin/
mkdir -p ${INSTALL_DIR}/{etc,logs,data,run}
cp redis.conf  ${INSTALL_DIR}/etc/
sed -i.bak -e 's/bind 127.0.0.1/bind 0.0.0.0/' -e "/# requirepass/a requirepass $PASSWORD"  ${INSTALL_DIR}/etc/redis.conf

if id redis &> /dev/null ;then 
    action "Redis 用户已存在" false  
else
    useradd -r -s /sbin/nologin redis
    action "Redis 用户创建成功"
fi

chown -R redis.redis ${INSTALL_DIR}

cat >> /etc/sysctl.conf <<EOF
net.core.somaxconn = 1024
vm.overcommit_memory = 1
EOF

cat > /usr/lib/systemd/system/redis.service <<EOF
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=${INSTALL_DIR}/bin/redis-server ${INSTALL_DIR}/etc/redis.conf --supervised systemd
ExecStop=/bin/kill -s QUIT \$MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target

EOF
systemctl daemon-reload 
systemctl start redis &> /dev/null && action "Redis 服务启动成功,Redis信息如下:" || { action "Redis 启动失败" false ;exit; } 

redis-cli -a $PASSWORD INFO Server 2> /dev/null

}

install 
