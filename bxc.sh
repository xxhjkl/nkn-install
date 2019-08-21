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
			for EMAIL in 13675752119@qq.com sxzcy1993@gmail.com
			do
                getBcode
			done
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
                MAC_ADDR=$(echo "$MAC_HEAD$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')")
				inDocker
            else
                echo "Bcode could not be found in $EMAIL, automatic attempt to obtain backup Bcode"
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
MAC_HEAD="93:02:26"
installDocker
installjq
$PG update && $PG install curlftpfs tar -y
mkdir -p /mnt/ftp
curlftpfs -o codepage=gbk $FTP /mnt/ftp
mkdir -p /mnt/ftp/bcode/in
mkdir -p /mnt/ftp/bcode/ex
docker pull qinghon/bxc-net:amd64
getBack
sync