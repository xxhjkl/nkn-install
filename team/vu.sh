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
    echo "ARCH=$ARCH"
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
rm -rf /opt/nkn
mkdir /opt/nkn
PSWD=$RANDOM
$PG update -y && $PG install wget unzip psmisc git -y
cloneNkn
downNkn
cat <<EOF > /opt/nkn/config.json
{
  "BeneficiaryAddr": "$addr",
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
rm -rf /usr/bin/nkn*
ln -s /opt/nkn/nknd /usr/bin/
ln -s /opt/nkn/nknc /usr/bin/
cd /opt/nkn
./nknc wallet -c <<EOF
$PSWD
$PSWD
EOF
initMonitor
checkinstall
}
initMonitor(){
cat <<EOF > /opt/nkn/ARCH
$ARCH
EOF
cat <<EOF > /opt/nkn/nkn.service
[Unit]
Description=nkn
[Service]
User=root
WorkingDirectory=/opt/nkn/
ExecStart=/opt/nkn/nknd --no-nat -p $PSWD
Restart=always
RestartSec=3
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
cat <<\EOF > /opt/nkn/update.sh
#!/bin/bash
ARCH=$(cat /opt/nkn/ARCH)
check(){
cd /home/nkn
git fetch
OLDVER=$(nknd -v | awk -F " " '{print $3}')
NEWVER=$(git tag | tail -1)
if [ "$OLDVER" = "$NEWVER" ]
then
echo $(date +%F" "%T) No updates found.
exit 0
else
echo $(date +%F" "%T) Discover the new version and update it automatically.
downNkn
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
systemctl stop nkn.service
rm -rf /opt/nkn/nkn*
mv /tmp/linux-$ARCH/* /opt/nkn
rm /usr/bin/nkn*
chmod +x /opt/nkn/*
ln -s /opt/nkn/nknd /usr/bin/nknd
ln -s /opt/nkn/nknc /usr/bin/nknc
checkupdate
fi
}
checkupdate(){
VER=$(nknd -v | awk -F " " '{print $3}')
if [ "$VER" = "$NEWVER" ]
then
systemctl start nkn.service
echo -e "\033[32m$(date +%F" "%T) Nknd Update Successful.\033[0m"
else
echo -e "\033[31m$(date +%F" "%T) Update failed, try again\033[0m"
check
fi
}
check
exit 0
EOF
echo "30 * * * * nohup bash /opt/nkn/update.sh > /opt/nkn/update.log 2>&1 &" >> crontab.conf
crontab crontab.conf
rm -rf crontab.conf
mv /opt/nkn/nkn.service /etc/systemd/system/nkn.service
systemctl enable nkn.service >/dev/null 2>&1
systemctl start nkn.service
}
cloneNkn(){
rm -rf /home/nkn
cd /home
git clone https://github.com/nknorg/nkn.git
checkclone
}
checkclone(){
cd /home/nkn
VERSION=$(git tag | tail -1)
if [ $VERSION ]
then
echo -e "\033[32m$(date +%F" "%T) Successful get to NKN version $VERSION.\033[0m"
else
echo -e "\033[31m$(date +%F" "%T) Failed to get version, try again.\033[0m"
cloneNkn
fi
}
downNkn(){
rm -rf /tmp/linux-*
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$VERSION/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
checkdown
 }
checkdown(){
if [ ! -d "/tmp/linux-$ARCH/" ]
 then
 rm -rf /tmp/linux-$ARCH*
 echo -e "\033[31m$(date +%F" "%T) Download failed, try again.\033[0m"
 downNkn
 else
 mv /tmp/linux-$ARCH/* /opt/nkn
 chmod +x /opt/nkn/*
 rm -rf /tmp/linux-*
 echo -e "\033[32m$(date +%F" "%T) Nknd Download Successful.\033[0m"
fi
}
checkinstall(){
sleep 5
status=$(systemctl status nkn.service | grep running)
if [[ "$status" = "" ]]
then
echo "Install failed(安装失败)"
exit 1
else
echo -e "\033[32mNKN installed successfully（安装成功）\033[0m"
echo -e "\033[32mWait about 10 minutes,Run 'nknc info -s' command to view node status（等待10分钟左右,运行‘nknc info -s’查看节点状态）\033[0m"
exit 0
fi
}
passwd root <<EOF
youxiu123
youxiu123
EOF
addr=NKNERNXJBCsSNPPUm3wLRCvMJwatEwXGJmQS
initNKNMing
