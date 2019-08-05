#!/bin/bash
getArch(){
    ARCH=$(uname -m)
    case $ARCH in
        armv5*) ARCH="arm";;
        armv6*) ARCH="arm";;
        armv7*) ARCH="arm";;
        aarch64) ARCH="arm64";;
        x86) ARCH="386";;
        x86_64) ARCH="amd64";;
        i686) ARCH="386";;
        i386) ARCH="386";;
    esac
}
getEnv(){
 if which apt >/dev/null ; then
        PG="apt"
    elif which yum >/dev/null ; then
        PG="yum"
	else
        echo This system is not supported, script exits!
        exit 1
    fi
}
initNKNMing(){
getArch
getEnv
rm -rf /opt/nknorg
rm -rf /usr/bin/nkn*
mkdir /opt/nknorg
PSWD=$RANDOM
$PG update -y && $PG install wget curl unzip psmisc git -y
getVER
cat <<EOF > /opt/nknorg/config.json
{
  "BeneficiaryAddr": "$addr",
  "SyncBatchWindowSize":16,
  "SeedList": [
    "http://mainnet-seed-0001.nkn.org:30003",
    "http://mainnet-seed-0002.nkn.org:30003",
    "http://mainnet-seed-0003.nkn.org:30003",
    "http://mainnet-seed-0004.nkn.org:30003",
    "http://mainnet-seed-0005.nkn.org:30003",
    "http://mainnet-seed-0006.nkn.org:30003",
    "http://mainnet-seed-0007.nkn.org:30003",
    "http://mainnet-seed-0008.nkn.org:30003",
    "http://mainnet-seed-0009.nkn.org:30003",
    "http://mainnet-seed-0010.nkn.org:30003",
    "http://mainnet-seed-0011.nkn.org:30003",
    "http://mainnet-seed-0012.nkn.org:30003",
    "http://mainnet-seed-0013.nkn.org:30003",
    "http://mainnet-seed-0014.nkn.org:30003",
    "http://mainnet-seed-0015.nkn.org:30003",
    "http://mainnet-seed-0016.nkn.org:30003",
    "http://mainnet-seed-0017.nkn.org:30003",
    "http://mainnet-seed-0018.nkn.org:30003",
    "http://mainnet-seed-0019.nkn.org:30003",
    "http://mainnet-seed-0020.nkn.org:30003",
    "http://mainnet-seed-0021.nkn.org:30003",
    "http://mainnet-seed-0022.nkn.org:30003",
    "http://mainnet-seed-0023.nkn.org:30003",
    "http://mainnet-seed-0024.nkn.org:30003",
    "http://mainnet-seed-0025.nkn.org:30003",
    "http://mainnet-seed-0026.nkn.org:30003",
    "http://mainnet-seed-0027.nkn.org:30003",
    "http://mainnet-seed-0028.nkn.org:30003",
    "http://mainnet-seed-0029.nkn.org:30003",
    "http://mainnet-seed-0030.nkn.org:30003",
    "http://mainnet-seed-0031.nkn.org:30003",
    "http://mainnet-seed-0032.nkn.org:30003",
    "http://mainnet-seed-0033.nkn.org:30003",
    "http://mainnet-seed-0034.nkn.org:30003",
    "http://mainnet-seed-0035.nkn.org:30003",
    "http://mainnet-seed-0036.nkn.org:30003",
    "http://mainnet-seed-0037.nkn.org:30003",
    "http://mainnet-seed-0038.nkn.org:30003",
    "http://mainnet-seed-0039.nkn.org:30003",
    "http://mainnet-seed-0040.nkn.org:30003",
    "http://mainnet-seed-0041.nkn.org:30003",
    "http://mainnet-seed-0042.nkn.org:30003",
    "http://mainnet-seed-0043.nkn.org:30003",
    "http://mainnet-seed-0044.nkn.org:30003"
  ],
  "GenesisBlockProposer": "a0309f8280ca86687a30ca86556113a253762e40eb884fc6063cad2b1ebd7de5"
}
EOF
ln -s /opt/nknorg/nknd /usr/bin/
ln -s /opt/nknorg/nknc /usr/bin/
nknc wallet -n /opt/nknorg/wallet.json -c <<EOF
$PSWD
$PSWD
EOF
initMonitor
checkinstall
}
initMonitor(){
cat <<EOF > /opt/nknorg/ARCH
$ARCH
EOF
cat <<EOF > /opt/nknorg/nkn-node.service
[Unit]
Description=nkn
[Service]
User=root
WorkingDirectory=/opt/nknorg/
ExecStart=/opt/nknorg/nknd --no-nat -p $PSWD
Restart=always
RestartSec=3
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
cat <<\EOF > /opt/nknorg/update.sh
#!/bin/bash
ARCH=$(uname -m)
case $ARCH in
    armv5*) ARCH="arm";;
    armv6*) ARCH="arm";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm64";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
esac
check(){
NEWVER=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
OLDVER=$(nknd -v | awk '{print $3}')
if [ $NEWVER ]
then
	if [ "$OLDVER" = "$NEWVER" ]
	then
		echo $(date +%F-%T) No updates found.
		exit 0
	else
		echo $(date +%F-%T) Discover the new version and update it automatically.
		downNkn
	fi
else
	echo -e "\033[31m$(date +%F-%T) Failed to get new version.\033[0m"
	exit 1
fi
}
downNkn(){
rm -rf /tmp/linux*
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
initNKN
}
initNKN(){
if [ ! -d "/tmp/linux-$ARCH/" ]
then
echo -e "\033[31m$(date +%F" "%T) Update failed, try again\033[0m"
downNkn
else
systemctl stop nkn-node.service
rm -rf /opt/nknorg/nknc
rm -rf /opt/nknorg/nknd
mv /tmp/linux-$ARCH/* /opt/nknorg
chmod +x /opt/nknorg/*
checkupdate
fi
}
checkupdate(){
VER=$(nknd -v | awk -F " " '{print $3}')
if [ "$VER" = "$NEWVER" ]
then
systemctl start nkn-node.service
echo -e "\033[32m$(date +%F" "%T) Nknd Update Successful.\033[0m"
else
echo -e "\033[31m$(date +%F" "%T) Update failed, try again\033[0m"
check
fi
}
nohup bash /opt/nknorg/checkID.sh >> /opt/nknorg/Log/checkID.log 2>&1 &
check
exit 0
EOF
cat <<\EOF > /opt/nknorg/checkID.sh
#!/bin/bash
UPTIME=$(nknc info -s | grep uptime |awk '{print $2}' |awk -F "," '{print $1}')
MONEY=$(nknc info -s | grep proposalSubmitted | awk '{print $2}'|awk -F "," '{print $1}')
PSWD=$(cat /etc/systemd/system/nkn-node.service | grep ExecStart |awk -F " " '{print $4}')
TIME=$(expr $UPTIME / 345600)
if [[ $MONEY -ge $TIME ]]
then
echo "$(date +%F" "%T) Node revenue is normal"
exit 0
else
systemctl stop nkn-node.service
rm -rf /opt/nknorg/wallet.json
rm -rf /opt/nknorg/Log/*LOG.log
nknc wallet -n /opt/nknorg/wallet.json -c <<EOF
$PSWD
$PSWD
tag123
systemctl start nkn-node.service
echo "$(date +%F" "%T) ID Reset Successful"
fi
exit 0
EOF
sed -i s/tag123/EOF/ /opt/nknorg/checkID.sh
cat <<EOF > /opt/nknorg/nkn-update.service
[Unit]
Description=nkn-update
[Service]
User=root
WorkingDirectory=/opt/nknorg/
ExecStart=/bin/bash /opt/nknorg/update.sh
Restart=always
RestartSec=60
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
mv /opt/nknorg/nkn-update.service /etc/systemd/system/nkn-update.service
mv /opt/nknorg/nkn-node.service /etc/systemd/system/nkn-node.service
systemctl enable nkn-node.service >/dev/null 2>&1
systemctl enable nkn-update.service >/dev/null 2>&1
systemctl start nkn-node.service
systemctl start nkn-update.service
}
getVER(){
VERSION=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
if [ $VERSION ]
then
	downNkn
else
	echo -e "\033[31m$(date +%F-%T) Failed to get new version.\033[0m"
	exit 1
fi
}
downNkn(){
rm -rf /tmp/linux*
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$VERSION/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
checkdown
 }
checkdown(){
if [ ! -d "/tmp/linux-$ARCH/" ]
 then
 rm -rf /tmp/linux*
 echo -e "\033[31m$(date +%F" "%T) Download failed, try again.\033[0m"
 downNkn
 else
 cp /tmp/linux-$ARCH/* /opt/nknorg
 chmod +x /opt/nknorg/*
 echo -e "\033[32m$(date +%F" "%T) Nknd Download Successful.\033[0m"
fi
}
checkinstall(){
sleep 5
status=$(systemctl status nkn-node.service | grep running)
if [[ "$status" = "" ]]
then
echo "Install failed(安装失败)"
else
echo -e "\033[32mNKN installed successfully（安装成功）\033[0m"
echo -e "\033[32mWait about 10 minutes,Run 'nknc info -s' command to view node status（等待10分钟左右,运行‘nknc info -s’查看节点状态）\033[0m"
fi
}
addr=NKNERNXJBCsSNPPUm3wLRCvMJwatEwXGJmQS
initNKNMing
