#!/bin/bash
#
#********************************************************************
#Author:        wangxiaochun
#QQ:            29308620
#Date:          2020-02-12
#FileName：      install_mysql5.7_for_centos.sh
#URL:           http://www.magedu.com
#Description：       The test script
#Copyright (C):     2020 All rights reserved
# 一键安装MySQL5.7脚本
#********************************************************************
#MySQL Download URL: https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.29-linux-glibc2.12-x86_64.tar.gz

. /etc/init.d/functions 
SRC_DIR=`pwd`
MYSQL='mysql-5.7.29-linux-glibc2.12-x86_64.tar.gz'
COLOR="echo -e \\033[01;31m"
END='\033[0m'
MYSQL_ROOT_PASSWORD=magedu

check (){
cd  $SRC_DIR
if [ !  -e $MYSQL ];then
        $COLOR"缺少${MYSQL}文件"$END
        $COLOR"请将相关软件放在${SRC_DIR}目录下"$END
        exit
elif [ -e /usr/local/mysql ];then
        action "数据库已存在，安装失败" false
        exit
else
    return
fi
} 

install_mysql(){
    $COLOR"开始安装MySQL数据库..."$END
     yum  -y -q install libaio numactl-libs   libaio &> /dev/null
    cd $SRC_DIR
    tar xf $MYSQL -C /usr/local/
    MYSQL_DIR=`echo $MYSQL| sed -nr 's/^(.*[0-9]).*/\1/p'`
    ln -s  /usr/local/$MYSQL_DIR /usr/local/mysql
    chown -R  root.root /usr/local/mysql/
    id mysql &> /dev/null || { useradd -s /sbin/nologin -r  mysql ; action "创建mysql用户"; }

    echo 'PATH=/usr/local/mysql/bin/:$PATH' > /etc/profile.d/mysql.sh
    .  /etc/profile.d/mysql.sh
    cat > /etc/my.cnf <<-EOF
[mysqld]
server-id=1
log-bin
datadir=/data/mysql
socket=/data/mysql/mysql.sock                                                                                                   
log-error=/data/mysql/mysql.log
pid-file=/data/mysql/mysql.pid
[client]
socket=/data/mysql/mysql.sock
EOF
    mysqld --initialize --user=mysql --datadir=/data/mysql 
    cp /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysqld
    chkconfig --add mysqld
    chkconfig mysqld on
    service mysqld start
    [ $? -ne 0 ] && { $COLOR"数据库启动失败，退出!"$END;exit; }
    MYSQL_OLDPASSWORD=`awk '/A temporary password/{print $NF}' /data/mysql/mysql.log`
    mysqladmin  -uroot -p$MYSQL_OLDPASSWORD password $MYSQL_ROOT_PASSWORD &>/dev/null
    action "数据库安装完成" 
}

check

install_mysql
