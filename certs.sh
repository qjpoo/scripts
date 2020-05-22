#!/bin/bash
#
#********************************************************************
#Author:        wangxiaochun
#QQ:            29308620
#Date:          2020-02-29
#FileName：      test.sh
#URL:           http://www.wangxiaochun.com
#Description：       The test script
#Copyright (C):     2020 All rights reserved
# 一键申请多个证书 shell 脚本
#********************************************************************
. /etc/init.d/functions

CERT_INFO=([00]="/O=heaven/CN=ca.god.com" \
           [01]="cakey.pem" \
           [02]="cacert.pem" \
           [03]=2048 \
           [04]=3650 \
           [05]=0    \
           [10]="/C=CN/ST=hubei/L=wuhan/O=Central.Hospital/CN=master.liwenliang.org" \
           [11]="master.key" \
           [12]="master.crt" \
           [13]=2048 \
           [14]=365
           [15]=1 \
           [16]="master.csr" \
           [20]="/C=CN/ST=hubei/L=wuhan/O=Central.Hospital/CN=slave.liwenliang.org" \
           [21]="slave.key" \
           [22]="slave.crt" \
           [23]=2048 \
           [24]=365 \
           [25]=2 \
           [26]="slave.csr"   )

COLOR="echo -e \\E[1;32m"
END="\\E[0m"
DIR=/data
cd $DIR 

for i in {0..2};do
    if [ $i -eq 0 ] ;then
        openssl req  -x509 -newkey rsa:${CERT_INFO[${i}3]} -subj ${CERT_INFO[${i}0]} \
            -set_serial ${CERT_INFO[${i}5]} -keyout ${CERT_INFO[${i}1]} -nodes -days ${CERT_INFO[${i}4]} \
            -out ${CERT_INFO[${i}2]} &>/dev/null

    else 
        openssl req -newkey rsa:${CERT_INFO[${i}3]} -nodes -subj ${CERT_INFO[${i}0]} \
            -keyout ${CERT_INFO[${i}1]}   -out ${CERT_INFO[${i}6]} &>/dev/null

        openssl x509 -req -in ${CERT_INFO[${i}6]}  -CA ${CERT_INFO[02]} -CAkey ${CERT_INFO[01]}  \
            -set_serial ${CERT_INFO[${i}5]}  -days ${CERT_INFO[${i}4]} -out ${CERT_INFO[${i}2]} &>/dev/null
    fi
    $COLOR"**************************************生成证书信息**************************************"$END
    openssl x509 -in ${CERT_INFO[${i}2]} -noout -subject -dates -serial
    echo 
done
chmod 600 *.key
action "证书生成完成"
