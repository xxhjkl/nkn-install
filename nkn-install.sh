#!/bin/bash
read -p "输入收益钱包地址（官网申请）:" bfaddr
initArch(){
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
initEnv(){
 if which apt >/dev/null ; then
        PG="apt"
    elif which yum >/dev/null ; then
        PG="yum"
    fi
}
initNKNMing(){
    rm -rf /opt/nkn
	mkdir /opt/nkn
    PSWD=$RANDOM
    $PG update -y && $PG install unzip git -y
    cd /tmp
    git clone https://github.com/nknorg/nkn.git
    cd /tmp/nkn
    VERSION=$(git tag | tail -1)
    wget -P /tmp https://github.com/nknorg/nkn/releases/download/$VERSION/linux-$ARCH.zip
    unzip /tmp/linux-$ARCH.zip -d /tmp
	mv /tmp/linux-$ARCH/* /opt/nkn
	chmod +x /opt/nkn/*
cat <<EOF > /opt/nkn/config.json
{
  "BeneficiaryAddr": "$bfaddr",
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
    cd /opt/nkn
    chmod +x *
./nknc wallet -c <<EOF
$PSWD
$PSWD
EOF
	rm -rf /tmp/linux-$ARCH*
	rm -rf /tmp/nkn*
}
initMonitor(){
cat <<EOF > /opt/nkn/ARCH
$ARCH
EOF
cat <<EOF > /opt/nkn/start.sh
#! /bin/bash
cd /opt/nkn
nohup ./nknd -p $PSWD > /dev/null 2>&1 &
EOF
cat <<\EOF > /opt/nkn/Monitor.sh
#!/bin/bash
num=1
while(( $num < 5 ))
do
sn=`ps aux | grep nknd | grep -v grep |wc -l`
if [ $sn = 1 ]
then
sleep 30
else
killall -9 nknd
let "num++"
bash /opt/nkn/start.sh
fi
done
rm -rf /opt/nkn/nkn*
rm -rf /opt/nkn/Log
rm -rf /opt/nkn/ChainDB
ARCH=$(cat /opt/nkn/ARCH)
cd /tmp
git clone https://github.com/nknorg/nkn.git
cd /tmp/nkn
VERSION=$(git tag | tail -1)
wget -P /tmp https://github.com/nknorg/nkn/releases/download/$VERSION/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
mv /tmp/linux-$ARCH/* /opt/nkn
chmod +x /opt/nkn/*
reboot
EOF
echo "@reboot bash /opt/nkn/Monitor.sh" >> crontab.conf
crontab crontab.conf
rm -rf crontab.conf
}
start(){
nohup bash /opt/nkn/Monitor.sh > /dev/null 2>&1 &
}
initArch
initEnv
initNKNMing
initMonitor
start
