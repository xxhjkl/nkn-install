#!/usr/bin/env bash 
env_check(){
    if which apt >/dev/null ; then
        PG="apt"
    elif which yum >/dev/null ; then
        PG="yum"
    elif which pacman>/dev/null ; then
        PG="pacman"
    else
        exit 1
	fi
}
jq_yum_ins(){
    # 安装EPEL仓库就为了装个jq,可恶
    wget -O $TMP/epel-release-latest-7.noarch.rpm http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -ivh $TMP/epel-release-latest-7.noarch.rpm
    yum install -y jq
}
ins_jq(){
    # 安装jq json文件分析工具
    if which jq>/dev/null; then
        return
    fi
    env_check
    case $PG in
        apt     ) $PG install -y jq ;;
        yum     ) jq_yum_ins ;;
        pacman  ) $PG -S jq ;;
    esac
}
installDocker(){
env_check
if which docker >/dev/null
then
	echo 'Docker installed, skip'
else
    OS=$(cat /etc/issue |head -1 |awk -F " " '{print $1}' )
	case $OS in
	Ubuntu*) OS="ubuntu";;
	Centos*) OS="centos";;
	Debian*) OS="debian";;
	*) echo -e "\033[31Run the script again after installing docker manually\033[0m"&&exit 1;;
esac
	if [[ "$PG" == "apt" ]]
	then
		apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
		curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo apt-key add -
		sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$OS $(lsb_release -cs) stable"
		apt update -y
		apt install docker-ce -y
	elif [[ "$PG" == "yum" ]]
	then
		yum install -y yum-utils
		yum-config-manager --add-repo http://mirrors.ustc.edu.cn/docker-ce/linux/$OS/docker-ce.repo
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
only_ins_network_docker_run(){
docker run -d --cap-add=NET_ADMIN --sysctl net.ipv6.conf.all.disable_ipv6=0 --device /dev/net/tun --restart=always --mac-address=$MAC_ADDR -e bcode=$bcode -e email=$EMAIL --name=bxc -v bxc_data:/opt/bcloud qinghon/bxc-net:amd64
sleep 3
# 检测绑定成功与否
con_id=$(docker ps --no-trunc | grep qinghon | awk '{print $1}')
fail_echo=$(docker echos "${con_id}" 2>&1 |grep 'bonud fail'|head -n 1)
if [[ -n "${fail_echo}" ]]; then
    echo "bound fail\n${fail_echo}\n"
    docker stop "${con_id}"
    docker rm "${con_id}"
    return 
fi
create_status=$(docker container inspect "${con_id}" --format "{{.State.Status}}")
if [[ "$create_status" == "created" ]]; then
    echowarn "Delete can not run container\n"
    docker container rm "${con_id}"
    return
fi
}
only_ins_network_docker_openwrt(){
installDocker
ins_jq
docker pull qinghon/bxc-net:amd64
json=$(curl -fsSL "https://console.bonuscloud.io/api/bcode/getBcodeForOther/?email=$EMAIL")
bcode_list=$(echo "${json}"|jq '.ret.non_mainland')
bcode=$(echo "${bcode_list}"|jq -r '.[]|.bcode'|head -1)
MAC_ADDR=$(echo "88:93:CB$(dd bs=1 count=3 if=/dev/random 2>/dev/null |hexdump -v -e '/1 ":%02X"')")
only_ins_network_docker_run
}
EMAIL=tao.ramiko@gmail.com
only_ins_network_docker_openwrt
sync
