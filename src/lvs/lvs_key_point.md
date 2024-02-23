# Lvs+keepalived集群生产实战维护要点


# 1.	LVS+keepalived负载均衡部署问题排错思路
## 1.1.	iptables防火墙问题
[Director和Real Server]

iptables防火墙造成Client用户、Director和RS真实服务器3者之者任意两者连接问题，在实际部署过程中，我们最好配置防火墙允许LAN内所有IP互相访问，如果是学习测试环境，建议把iptables防火墙关掉测试。Directors之间failover切换会被防火墙影响，建议LVS Director两边都启动VIP发生裂脑。
## 1.2.	LINUX负载均衡器转发问题[Director]

对于NAT模式，LINUX内核转发及iptables转发功能需要开放。对于DR模式的负载均衡，转发开关可以不打开。
## 1.3.	RS端抑制ARP问题[RS]

这个经常忘记执行，要注意，每个RS端都搞，习惯通过一个脚本来执行(ipvs_client)。
## 1.4.	RS端lo上绑定业务VIP,多业务VIP，每个RS都要绑定[RS]

这个经常忘记执行，要注意，每个RS端都搞，习惯通过一个脚本来执行(ipvs_client)。
```
#!/bin/bash
# description: Config realserver lo and apply noarp 
VIP=(
        192.168.65.123
     )

. /etc/rc.d/init.d/functions

case "$1" in
start)
        for ((i=0; i<`echo ${#VIP[*]}`; i++))
        do
           interface="lo:`echo ${VIP[$i]}|awk -F . '{print $4}'`"
           /sbin/ifconfig $interface ${VIP[$i]} broadcast ${VIP[$i]} netmask 255.255.255.255 up
        done
        echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
        echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
        echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
        echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
	    action "Start LVS of RearServer.by old1boy"
        ;;
stop)
        for ((i=0; i<`echo ${#VIP[*]}`; i++))
        do
            interface="lo:`echo ${VIP[$i]}|awk -F . '{print $4}'`"
            /sbin/ifconfig $interface ${VIP[$i]} broadcast ${VIP[$i]} netmask 255.255.255.255 down
        done
        echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
        echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
        echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
        echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
	    action "Close LVS of RearServer.by old2boy"
        ;;
*)
        echo "Usage: $0 {start|stop}"
        exit 1
esac

```

## 1.5.	RS端lo上绑定业务VIP,有时lo接口VIP会丢失，例如执行/etc/init.d/network restart后
解决方法：

(1)	将ipvs_client完整脚本启动命令放入/etc/rc.local

(2)	通过nagios监控对RS端lo上绑定的业务VIP做监控报警

(3)	将RS端lo上绑定的业务VIP做成网卡配置文件提供服务如/etc/sysconfig/network-scripts/ ifcfg-lo:127
```
#cat /etc/sysconfig/network-scripts/ifcfg-lo:127
DEVICE=lo:127
IPADDR=192.168.65.127
NETMASK=255.255.255.255
ONBOOT=yes
NAME=loopback
```
## 1.6.	确保client,Director和RS 任意两者之间可访问
检查可用wget或telnet命令
## 1.7.	ipvsadm -L -n检查LVS真实服务器情况及VIP连接及配置
## 1.8.	检查keepalived配置文件(主从的不同)
主要配置文件的不同是：route_id,state,priority

## 1.9.	查看系统日志/var/log/messages
## 1.10.	通过tcpdump跳跃数据包流向
## 1.11.	注意lvs配置语法，尤其是大括号问题，可写个脚本判断大括号是不是成对
# 2.	LVS+keepalived生产环境负载均衡维护思路

(1)	业务高峰期尽量不修改负载均衡配置，以免发生故障影响用户体验。

(2)	修改keepalived.conf时，执行临时备份：/bin/cp keepalived.conf keepalived.conf.oldboy.2012090101

(3)	修改keepalived.conf时，将两个负载均衡器的keepalived.conf改名标识好，然后下载下来，保留原始备份，然后复制出两份，通过比较工具修改另一份。线上可用diff.

(4)	替换正式配置文件后，主负载均衡器可以通过执行/etc/init.d/keepalived stop，把业务切到备份负载均衡器上，也可以直接/etc/init.d/keepalived restart重启直接让主生效。如果有异常，立即stop,用事先准备好的命令恢复(脚本瞬间恢复)。

主负载均衡器调整好之后，备份负载均衡器直接/etc/init.d/keepalived restart重启直接生效。如果有必要切换分别测试下，以免配置不对导致以后自动切换时异常。

# 3.	LVS均衡器下多台RS代码上线方案思路
集群节点多，上线时，希望最大限度不影响用户体验

(1)	通过ipvsadm命令下线机器

ipvsadm -d -t 192.168.1.181:80 -r 192.168.1.179:80

(2)	通过url做健康检查，然后移除检查文件。这要Director会把此RS从转发池中移除。

然后对下线机进行测试。
# 4.	LVS其它相关经验
```
(1)	LVS调度的最小单位是"连接"
(2)	当apache的KeepAlive被设置为Off时，"连接"才能被均衡的调度。
(3)	当不指定-p参数时,lvs才真正以"连接"为单位按"权值"调度流量。
(4)	在指定-p参数时，则一个client在一定时间内，将会被调度到同一台RS
(5)	可以通过"ipvsadm --set tcp tcpfin udp"来调整TCP和UDP的超时，让连接淘汰得快一些。
ipvsadm --set 30 5 60
ipvsadm -Ln --timeout
(6)	在NAT模式时,rs的port参数才有意义，DR模式负载均衡无法做端口的转换。
(7)	DR和TUN模式时，InActConn是没有意义的。
(8)	在使用脚本部署LVS时，需要执行/sbin/arping -f -q -c 5 -I eth0 -s $WEB_VIP -U $GW,在发生failover切换时通知服务器清空arp缓存。
/sbin/arping -I eth0 -c 3 -s 192.168.1.181 192.168.1.1
```
# 5.	LVS性能调优
```
(1)	关闭iptables,使用硬件防火墙
(2)	performance Tuning base LVS调整连接超时时间
(3)	内核优化(安装操作系统时)
(4)	网卡优化
使用更快的网卡,如千兆，万兆网卡
可以进一步将两块或多块网卡绑定,bonding时mode=0 (balance-rr)或者mod=4(802.3ad,需要交换机支持聚合端口)，miimon=80或miimon=100(ms)
(5)	TCP/IP优化
net.core.netdev_max_backlog=65000
(6)	硬件优化(服务器稳定即可，高配置是种浪费)
(7)	增大哈希表,调ip_vs_conn_tab_bigs到20
```