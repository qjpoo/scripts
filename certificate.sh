#!/bin/bash
#
#********************************************************************
#Author:        wangxiaochun
#QQ:            29308620
#Date:          2020-02-07
#FileName：      certificate.sh
#URL:           http://www.liwenliang.org
#Description：       本脚本纪念武汉疫情吹哨人李文亮医生
#Copyright (C):     2020 All rights reserved
# 一键证书申请和颁发脚本
#********************************************************************
CA_SUBJECT="/O=heaven/CN=ca.god.com"
SUBJECT="/C=CN/ST=hubei/L=wuhan/O=Central.Hospital/CN=master.liwenliang.org"
SUBJECT2="/C=CN/ST=hubei/L=wuhan/O=Central.Hospital/CN=slave.liwenliang.org"
KEY_SIZE=2048 #此值不能使用1024
SERIAL=34
SERIAL2=35

CA_EXPIRE=202002
EXPIRE=365
FILE=master
FILE2=slave

#生成自签名的CA证书
openssl req  -x509 -newkey rsa:${KEY_SIZE} -subj $CA_SUBJECT -keyout cakey.pem -nodes -days $CA_EXPIRE -out cacert.pem

#第一个证书
#生成私钥和证书申请
openssl req -newkey rsa:${KEY_SIZE} -nodes -keyout ${FILE}.key  -subj $SUBJECT -out ${FILE}.csr
#颁发证书
openssl x509 -req -in ${FILE}.csr  -CA cacert.pem  -CAkey cakey.pem  -set_serial $SERIAL  -days $EXPIRE -out ${FILE}.crt

#第二个证书
openssl req -newkey rsa:${KEY_SIZE}  -nodes -keyout ${FILE2}.key  -subj $SUBJECT2 -out ${FILE2}.csr
openssl x509 -req -in ${FILE2}.csr  -CA cacert.pem  -CAkey cakey.pem  -set_serial $SERIAL2  -days $EXPIRE -out ${FILE2}.crt

chmod 600 *.key
