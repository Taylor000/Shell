#!/bin/bash
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
install_ssr(){
	clear
	stty erase '^H' && read -p " mysql服务器密码:" sspass
	stty erase '^H' && read -p " SSR节点ID（nodeid）:" ssnode
	
	clear
	cd /usr/
  	wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz
  	tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
  	./configure && make -j2 && make install
  	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	cd /usr/
  	rm -rf libsodium-1.0.16.tar.gz
	echo 'libsodium安装完成'
	
  	git clone -b master https://github.com/828768/shadowsocksr.git && cd shadowsocksr && sh setup_cymysql.sh && sh initcfg.sh
	echo 'ssr安装完成'

	sed -i -e "s/ssserver/db\.wubase\.cn/g" usermysql.json
	sed -i -e "s/ssport/3306/g" usermysql.json
	sed -i -e "s/ssuser/ssrpanel/g" usermysql.json
	sed -i -e "s/sspass/$sspass/g" usermysql.json
	sed -i -e "s/ssdb/ssrpanel/g" usermysql.json
	sed -i -e "s/ssnode/$ssnode/g" usermysql.json
	echo 'ssr配置完成'
	chmod +x run.sh && ./run.sh
	#开机自动运行
	sed -i '/shadowsocksr\/run.sh$/d'  /etc/rc.d/rc.local
	echo "/usr/shadowsocksr/run.sh" >> /etc/rc.d/rc.local
	cd /usr/
	echo 'ssr已开始运行'
	
	service iptables stop
	service firewalld stop
	systemctl disable firewalld.service
	chkconfig iptables off
	echo '已关闭iptables、firewalld，如有需要请自行配置。'
}

open_bbr(){
	clear
	cd
	wget --no-check-certificate -O bbr.sh https://github.com/teddysun/across/raw/master/bbr.sh
	chmod +x bbr.sh
	./bbr.sh
}

auto_reboot(){
	clear
	echo '设置每天几点几分重启节点'
	stty erase '^H' && read -p " 小时(0-23):" hour
	stty erase '^H' && read -p " 分钟(0-59):" minute
	chmod +x /etc/rc.d/rc.local
	sed -i '/service crond start$/d'  /etc/rc.d/rc.local
	echo /sbin/service crond start >> /etc/rc.d/rc.local
	sed -i '/shadowsocksr\/run.sh$/d'  /etc/rc.d/rc.local
	echo "/usr/shadowsocksr/run.sh" >> /etc/rc.d/rc.local
	echo '设置开机运行SSR'
	sed -i '/sbin\/reboot$/d'  /etc/crontab
	echo "$minute $hour * * * root /sbin/reboot" >> /etc/crontab
	service crond start
}

yum -y install git
yum -y groupinstall "Development Tools"
clear
echo ' 注意：此脚本基于centos7编写，其他系统可能会出问题'
echo ' 1. 安装 SSR'
echo ' 2. 安装 BBR'
echo ' 3. 设置定时重启'
stty erase '^H' && read -p " 请输入数字 [1-3]:" num
case "$num" in
	1)
	install_ssr
	;;
	2)
	open_bbr
	;;
	3)
	auto_reboot
	;;
	*)
	echo '请输入正确数字 [1-3]'
	;;
esac
