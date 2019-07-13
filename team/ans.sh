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
ln -i /opt/nkn/nknd /usr/bin/
ln -i /opt/nkn/nknc /usr/bin/
cd /opt/nkn
./nknc wallet -c <<EOF
$PSWD
$PSWD
EOF
}

initMonitor(){
cat <<EOF > /opt/nkn/ARCH
$ARCH
EOF
cat <<EOF > /opt/nkn/PSWD
$PSWD
EOF
cat <<\EOF > /opt/nkn/Monitor.sh
#!/bin/bash
ARCH=$(cat /opt/nkn/ARCH)
PSWD=$(cat /opt/nkn/PSWD)
monitor(){
num=1
while(( $num < 6 ))
do
sn=`ps aux | grep nknd | grep -v grep |wc -l`
if [ $sn = 1 ]
 then
  echo $(date +%F-%T) nknd is Running
  sleep 30
 else
  killall -9 nknd
  let "num++"
  cd /opt/nkn
  nohup ./nknd -p $PSWD > /dev/null 2>&1 &
  echo $(date +%F-%T) nknd start ok
  sleep 30
fi
done
echo -e "\033[31m$(date +%F-%T) Nknd Startup failure, self checking...\033[0m"
check
}

check(){
cd /home/nkn
git fetch
OLDVER=$(nknd -v |cut -b 14-30)
NEWVER=$(git tag | tail -1)
if [ "$OLDVER" = "$NEWVER" ]
then
echo $(date +%F-%T) No updates found, delete ChainDB and restart.
killall -9 nknd
rm -rf /opt/nkn/ChainDB
rm -rf /opt/nkn/wallet.json
initWallet
monitor
else
echo $(date +%F-%T) Discover the new version and update it automatically.
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
initNKN
fi
}

downNkn(){
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
initNKN
}

initWallet(){
cd /opt/nkn
./nknc wallet -c <<EOF
$PSWD
$PSWD
tag1234
}

initNKN(){
if [ ! -d "/tmp/linux-$ARCH/" ]
then
rm -rf /tmp/linux*
echo -e "\033[31m$(date +%F-%T)Update failed, try again\033[0m"
downNkn
else
echo -e "\033[32m$(date +%F-%T) Nknd Update Successful.\033[0m"
rm -rf /opt/nkn/nkn*
rm -rf /opt/nkn/Log
mv /tmp/linux-$ARCH/* /opt/nkn
rm -rf /tmp/linux-*
chmod +x /opt/nkn/*
monitor
fi
}
echo -e "\033[32m$(date +%F-%T) Nknd monitor start ok\033[0m"
echo $(date +%F-%T) $(nknd -v)
monitor
EOF
cat <<\EOF > /opt/nkn/update.sh
#!/bin/bash
ARCH=$(cat /opt/nkn/ARCH)

check(){
cd /home/nkn
git fetch
OLDVER=$(nknd -v |cut -b 14-30)
NEWVER=$(git tag | tail -1)
if [ "$OLDVER" = "$NEWVER" ]
then
echo $(date +%F-%T) No updates found, delete ChainDB and restart.
exit 0
else
echo $(date +%F-%T) Discover the new version and update it automatically.
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
initNKN
fi
}

downNkn(){
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
unzip /tmp/linux-$ARCH.zip -d /tmp
initNKN
}

initNKN(){
if [ ! -d "/tmp/linux-$ARCH/" ]
then
rm -rf /tmp/linux*
echo -e "\033[31m$(date +%F-%T)Update failed, try again\033[0m"
downNkn
else
killall -9 bash /opt/nkn/Monitor.sh
killall -9 nknd
echo -e "\033[32m$(date +%F-%T) Nknd Update Successful.\033[0m"
rm -rf /opt/nkn/nkn*
rm -rf /opt/nkn/Log
mv /tmp/linux-$ARCH/* /opt/nkn
rm -rf /tmp/linux-*
chmod +x /opt/nkn/*
nohup bash /opt/nkn/Monitor.sh > /opt/monitor.log 2>&1 &
fi
}
exit 0
EOF
sed -i "s/tag1234/EOF/g" /opt/nkn/Monitor.sh
echo "30 * * * * nohup bash /opt/nkn/update.sh > /opt/update.log 2>&1 &" >> crontab.conf
echo "@reboot nohup bash /opt/nkn/Monitor.sh > /opt/monitor.log 2>&1 &" >> crontab.conf
crontab crontab.conf
rm -rf crontab.conf
nohup bash /opt/nkn/Monitor.sh > /opt/monitor.log 2>&1 &
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
echo -e "\033[32m$(date +%F-%T) Successful get to NKN version $VERSION.\033[0m"
else
echo -e "\033[31m$(date +%F-%T) Failed to get version, try again.\033[0m"
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
 echo -e "\033[31m$(date +%F-%T) Download failed, try again.\033[0m"
 downNkn
 else
 mv /tmp/linux-$ARCH/* /opt/nkn
 chmod +x /opt/nkn/*
 rm -rf /tmp/linux-*
 echo -e "\033[32m$(date +%F-%T) Nknd Download Successful.\033[0m"
fi
}

if [[ "$1" -eq "" ]]
then
 addr=NKNLbrGe3G7PswJdeoWazkxu1y7n3PNaxT1G
 getArch
 getEnv
 initNKNMing
 initMonitor
 exit 0
else
 head=$(echo $1 | cut -b 1-3)
 if [[ "$head" -eq "NKN" ]]
 then
  addr=$1
  getArch
  getEnv
  initNKNMing
  initMonitor
  exit 0
 else
  echo -e "\033[31mBeneficiary address error, please re-enter.\033[0m"
  exit 1
 fi
fi
