#!/bin/bash
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
    cd /opt/nkn
    wget https://raw.githubusercontent.com/sxzcy/nkn-install/master/team/Ramik0.json -O config.json
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
nohup bash /opt/nkn/Monitor.sh > /opt/monitor.log 2>&1 &
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
