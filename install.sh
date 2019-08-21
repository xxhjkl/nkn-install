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
$PG update && $PG install curlftpfs tar -y
mkdir /mnt/ftp
curlftpfs -o codepage=gbk $FTP /mnt/ftp
rm -rf /opt/nknorg
rm -rf /usr/bin/nkn*
mkdir -p /opt/nknorg
$PG update -y && $PG install wget curl unzip psmisc git -y
getVER
cat <<EOF > /opt/nknorg/config.json
{
  "BeneficiaryAddr": "$addr",
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
ln -s /opt/nknorg/nknd /usr/bin/
ln -s /opt/nknorg/nknc /usr/bin/
mkdir -p /mnt/ftp/nkn/ex
wallet=$(ls -l /mnt/ftp/nkn | grep json | head -`echo $((RANDOM%9))` | tail -1 |awk '{print $9}')
if [ $wallet ]
  then
    mv /mnt/ftp/nkn/$wallet /mnt/ftp/nkn/ex/$wallet
    cp /mnt/ftp/nkn/ex/$wallet /tmp/$wallet
    PSWD=$(echo $wallet |awk -F "-" '{print $3}' |awk -F "." '{print $1}')
    mv /tmp/$wallet /opt/nknorg/wallet.json
else
PSWD=$RANDOM
nknc wallet -n /opt/nknorg/wallet.json -c <<EOF
$PSWD
$PSWD
EOF
echo `cat /opt/nknorg/wallet.json  |awk -F '"' '{print $18}'` >> /tmp/`cat /opt/nknorg/wallet.json  |awk -F '"' '{print $18}'`
mv /tmp/`cat /opt/nknorg/wallet.json  |awk -F '"' '{print $18}'` /mnt/ftp/nkn/wallet
fi
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
	echo -e "\033[31m$(date +%F-%T) Failed to get NKN version,Checking network please.\033[0m"
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
	echo -e "\033[31m$(date +%F-%T) Failed to get version,Checking network please.\033[0m"
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
BXCinstall(){
mkdir -p /opt/bcloud
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
        checkenv
        case $PG in
        apt     ) $PG install -y jq ;;
        yum     ) yuminstalljq ;;
        esac
}

installDocker(){
        checkenv
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
                getBcode
        fi
        create_status=$(docker container inspect bxc --format "{{.State.Status}}")
        if [[ "$create_status" == "created" ]]; then
                echo "Run failed, delete and try again"
                docker stop bxc
                docker rm bxc
                getBcode
        fi
        tar -czvf /mnt/ftp/bcode/in/$(cat /var/lib/docker/volumes/bxc_data/_data/node.db | awk -F '"' '{print $12}').tar.gz -C /var/lib/docker/volumes/ bxc_data
        umount /mnt/ftp
		exit 0
}

checkBcode(){
        if [ $bcode ]
        then
                echo "Get Bcode of backup successful"
				inDocker
        else
		    sleep $(($RANDOM%999))
			for EMAIL in $MAIL1 $MAIL2
			do
                getBcode
			done
			echo "Automatic attempt to obtain backup Bcode"
			getBack
        fi
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
        bcode=$(cat /var/lib/docker/volumes/bxc_data/_data/node.db |awk -F '"' '{print $4}')
		email=$(cat /var/lib/docker/volumes/bxc_data/_data/node.db |awk -F '"' '{print $8}')
        MAC_ADDR=$(cat /var/lib/docker/volumes/bxc_data/_data/node.db |awk -F '"' '{print $12}' )
        checkBcode
	  else
		checkBcode
	fi
}
FTP="ftp://biwang:biwang123@ramiko.me"
MAC_HEAD="93:02"
MAIL1="sxzcy1993@gmail.com"
MAIL2="13675752119@qq.com"
installDocker
installjq
$PG update && $PG install curlftpfs tar -y
umount /mnt/ftp
rm -rf /mnt/ftp
mkdir -p /mnt/ftp
curlftpfs -o codepage=gbk $FTP /mnt/ftp
mkdir -p /mnt/ftp/bcode/in
mkdir -p /mnt/ftp/bcode/ex
docker pull qinghon/bxc-net:amd64
getBack
sync
EOF
}
FTP="ftp://biwang:biwang123@ramiko.me"
umount /mnt/ftp
rm -rf /mnt/ftp
passwd root <<EOF
biwang123
biwang123
EOF
if [[ "$(nknc info -s | grep uptime)" ]]
then
echo "NKN is running, skip"
else
systemctl stop nkn-node.service 
addr="NKNERNXJBCsSNPPUm3wLRCvMJwatEwXGJmQS"
initNKNMing
fi
if [[ "$(docker ps -a | grep bxc)" ]]
then 
echo "Bcloud is running, skip"
else
kill `ps aux | grep bxc_install.sh | grep -v grep | awk '{print $2}'`
rm -rf /opt/bcloud/bxc_install.log 
BXCinstall
nohup bash /opt/bcloud/bxc_install.sh >> /opt/bcloud/bxc_install.log 2>&1 &
fi
sync
