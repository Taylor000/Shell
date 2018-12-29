#!/usr/bin/env bash
# Require Root Permission
# panel node deploy script
# Author: 阿拉凹凸曼 (https://sobaigu.com)

[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
sys_bit=$(uname -m)
if [[ -f /usr/bin/apt-get ]] || [[ -f /usr/bin/yum && -f /bin/systemctl ]]; then
	if [[ -f /usr/bin/yum ]]; then
		cmd="yum"
	fi
	if [[ -f /bin/systemctl ]]; then
		systemd=true
	fi
else
	echo -e " 哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}" && exit 1
fi

install_ssr(){
	cd /root/
	yum -y install git
	
	clear
	cd /usr/
  	wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz
  	tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
  	./configure && make -j2 && make install
  	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
  	rm -rf libsodium-1.0.16.tar.gz
	echo 'libsodium安装完成'
	
	cd /usr/
	echo 'SSR下载中...'
	git clone -b master https://github.com/ssrpanel/shadowsocksr.git && cd shadowsocksr && sh setup_cymysql.sh && sh initcfg.sh
	echo 'SSR安装完成'
	echo '开始配置节点连接信息...'
	stty erase '^H' && read -p "数据库服务器地址:" mysqlserver
	stty erase '^H' && read -p "数据库服务器端口:" port
	stty erase '^H' && read -p "数据库名称:" database
	stty erase '^H' && read -p "数据库用户名:" username
	stty erase '^H' && read -p "数据库密码:" pwd
	stty erase '^H' && read -p "本节点ID:" nodeid
	stty erase '^H' && read -p "本节点流量计算比例:" ratio
	sed -i -e "s/server_host/$mysqlserver/g" usermysql.json
	sed -i -e "s/server_port/$port/g" usermysql.json
	sed -i -e "s/server_db/$database/g" usermysql.json
	sed -i -e "s/server_user/$username/g" usermysql.json
	sed -i -e "s/server_password/$pwd/g" usermysql.json
	sed -i -e "s/nodeid/$nodeid/g" usermysql.json
	sed -i -e "s/noderatio/$ratio/g" usermysql.json
	echo -e "配置完成!\n如果无法连上数据库，请检查本机防火墙或者数据库防火墙!\n请自行编辑user-config.json，配置节点加密方式、混淆、协议等"
	
	#启动并设置开机自动运行
	chmod +x run.sh && ./run.sh
	sed -i '/shadowsocksr\/run.sh$/d'  /etc/rc.d/rc.local
	echo "/usr/shadowsocksr/run.sh" >> /etc/rc.d/rc.local
}

install_v2ray(){
	curl -L -s https://raw.githubusercontent.com/ColetteContreras/v2ray-ssrpanel-plugin/master/install-release.sh | bash
}

install_caddy() {
	local caddy_tmp="/tmp/install_caddy/"
	local caddy_tmp_file="/tmp/install_caddy/caddy.tar.gz"
	if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
		local caddy_download_link="https://caddyserver.com/download/linux/386?license=personal"
	elif [[ $sys_bit == "x86_64" ]]; then
		local caddy_download_link="https://caddyserver.com/download/linux/amd64?license=personal"
	else
		echo -e "$red 自动安装 Caddy 失败！不支持你的系统。$none" && exit 1
	fi

	mkdir -p $caddy_tmp

	if ! wget --no-check-certificate -O "$caddy_tmp_file" $caddy_download_link; then
		echo -e "$red 下载 Caddy 失败！$none" && exit 1
	fi

	tar zxf $caddy_tmp_file -C $caddy_tmp
	cp -f ${caddy_tmp}caddy /usr/local/bin/

	if [[ ! -f /usr/local/bin/caddy ]]; then
		echo -e "$red 安装 Caddy 出错！" && exit 1
	fi

	setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/caddy

	if [[ $systemd ]]; then
		cp -f ${caddy_tmp}init/linux-systemd/caddy.service /lib/systemd/system/
		# sed -i "s/www-data/root/g" /lib/systemd/system/caddy.service
		sed -i "s/on-failure/always/" /lib/systemd/system/caddy.service
		systemctl enable caddy
	else
		cp -f ${caddy_tmp}init/linux-sysvinit/caddy /etc/init.d/caddy
		# sed -i "s/www-data/root/g" /etc/init.d/caddy
		chmod +x /etc/init.d/caddy
		update-rc.d -f caddy defaults
	fi

	mkdir -p /etc/ssl/caddy

	if [ -z "$(grep www-data /etc/passwd)" ]; then
		useradd -M -s /usr/sbin/nologin www-data
	fi
	chown -R www-data.www-data /etc/ssl/caddy

	mkdir -p /etc/caddy/
	rm -rf $caddy_tmp
	echo -e "$red 把 Caddyfile 放到 /etc/caddy 然后启动就可以了"
}

open_bbr(){
	cd
	wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
	chmod +x bbr.sh
	./bbr.sh
}

echo -e "1.Install SSR"
echo -e "2.Install V2Ray"
echo -e "3.Install Caddy"
echo -e "4.Open BBR"
stty erase '^H' && read -p "请输入数字进行安装[1-4]:" num
case "$num" in
	1)
	install_ssr
	;;
	2)
	install_v2ray
	;;
	3)
	install_caddy
	;;
	4)
	open_bbr
	;;
	*)
	echo "请输入正确数字[1-4]:"
	;;
esac