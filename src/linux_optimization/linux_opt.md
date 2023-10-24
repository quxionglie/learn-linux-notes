# 配置优化Centos5.X Linux操作系统
 
一键优化脚本

```shell
#!/bin/bash
# centos_optimize
# Filename: centos_optimize.sh
# Author: quxl
# Date: 2010-10-21

ping -c 1 www.baidu.com >/dev/null
[ ! $? -eq 0 ] && echo "ping error,check network" && exit 1

# 设置升级源
cd /etc/yum.repos.d/
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.`date +"%Y-%m-%d_%H-%M-%S"`
wget http://mirrors.163.com/.help/CentOS5-Base-163.repo
mv -f CentOS5-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo
yum makecache


#安装软件
yum install -y sysstat lrzsz rsync 

#设置系统时间同步
yum -y install ntp
echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com>/dev/null 2>&1'>>/var/spool/cron/root

#优化内核参数
mv /etc/sysctl.conf /etc/sysctl.conf.`date +"%Y-%m-%d_%H-%M-%S"`
echo -e "kernel.core_uses_pid = 1\n"\
"kernel.msgmnb = 65536\n"\
"kernel.msgmax = 65536\n"\
"kernel.shmmax = 68719476736\n"\
"kernel.shmall = 4294967296\n"\
"kernel.sysrq = 0\n"\
"net.core.netdev_max_backlog = 262144\n"\
"net.core.rmem_default = 8388608\n"\
"net.core.rmem_max = 16777216\n"\
"net.core.somaxconn = 262144\n"\
"net.core.wmem_default = 8388608\n"\
"net.core.wmem_max = 16777216\n"\
"net.ipv4.conf.default.rp_filter = 1\n"\
"net.ipv4.conf.default.accept_source_route = 0\n"\
"net.ipv4.ip_forward = 0\n"\
"net.ipv4.ip_local_port_range = 5000 65000\n"\
"net.ipv4.tcp_fin_timeout = 1\n"\
"net.ipv4.tcp_keepalive_time = 30\n"\
"net.ipv4.tcp_max_orphans = 3276800\n"\
"net.ipv4.tcp_max_syn_backlog = 262144\n"\
"net.ipv4.tcp_max_tw_buckets = 6000\n"\
"net.ipv4.tcp_mem = 94500000 915000000 927000000\n"\
"# net.ipv4.tcp_no_metrics_save=1\n"\
"net.ipv4.tcp_rmem = 4096    87380   16777216\n"\
"net.ipv4.tcp_sack = 1\n"\
"net.ipv4.tcp_syn_retries = 1\n"\
"net.ipv4.tcp_synack_retries = 1\n"\
"net.ipv4.tcp_syncookies = 1\n"\
"net.ipv4.tcp_timestamps = 0\n"\
"net.ipv4.tcp_tw_recycle = 1\n"\
"net.ipv4.tcp_tw_reuse = 1\n"\
"net.ipv4.tcp_window_scaling = 1\n"\
"net.ipv4.tcp_wmem = 4096    16384   16777216\n" > /etc/sysctl.conf
sysctl -p

# 增加文件描述符限制
/bin/cp /etc/security/limits.conf /etc/security/limits.conf.`date +"%Y-%m-%d_%H-%M-%S"`
sed -i '/# End of file/i\*\t\t-\tnofile\t\t65535' /etc/security/limits.conf

# 使ctrl+alt+del关机键无效
/bin/cp /etc/inittab /etc/inittab.`date +"%Y-%m-%d_%H-%M-%S"`
sed -i "s/ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/#ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/" /etc/inittab
/sbin/init q

# 禁止开机自启动无用服务
for service in `chkconfig --list|grep 3:on|awk '{print $1}'`;do chkconfig --level 3 $service off;done
for service in crond network syslog sshd;do chkconfig --level 3 $service on;done

#禁止root通过SSH远程登录并更改SSH端口
useradd manuser
echo "123456" | passwd --stdin manuser
echo "manuser ALL=(ALL) NOPASSWD:ALL">>/etc/sudoers

/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.ori
sed -i 's/^#Port 22/Port 52003/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

#check
egrep '^Port|^PermitRootLogin|^PermitEmptyPasswords|^UseDNS' /etc/ssh/sshd_config
/etc/init.d/sshd restart


#配置sudo命令日志审计
yum install -y sudo syslog
echo "local2.debug /var/log/sudo.log">>/etc/syslog.conf
echo "Defaults logfile=/var/log/sudo.log">>/etc/sudoers
/etc/init.d/syslog restart
ls -l /var/log/sudo.log

```