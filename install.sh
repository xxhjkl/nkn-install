#! /bin/bash
#
# Auto install NKN
#
# System Required：Debian9
#
# Copyright (C)  2019 cellur

#更新源
apt-get update
apt-get install unzip git -y


# 开启bbr
modprobe tcp_bbr
echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

# 拉取程序
wget https://github.com/nknorg/nkn/releases/download/v1.0.1b-beta/linux-amd64.zip
wget https://raw.githubusercontent.com/sxzcy/nkn-install/master/config.json
unzip linux-amd64.zip
rm -r linux-amd64.zip
mv /root/linux-amd64/* /root
rm -r linux-amd64
chmod +x *

# 创建钱包
./nknc wallet -c -p 1234567

# 创建开机脚本
cat >> /etc/rc.local << "EOF"
#!/bin/sh -e
cd /root
nohup ./nknd -p 1234567 --no-nat > /dev/null 2>&1 &
exit 0
EOF

#启动nkn
nohup ./nknd -p 1234567 --no-nat > /dev/null 2>&1 &

#输出bbr
lsmod | grep bbr
./nknc info -s

