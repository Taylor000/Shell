#更新系统
yum update -y
#安装常用基础软件
yum install vim lrzsz screen git ntp crontabs -y
#设置时区
echo yes | cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#同步时间
ntpdate cn.pool.ntp.org
#添加系统定时任务自动同步时间
sed -i '$a\* * * * 1 ntpdate cn.pool.ntp.org >> /dev/null 2>&1' /etc/crontab
