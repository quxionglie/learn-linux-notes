# Rsync生产场景实战应用指南

20150823 修改 

# 1.	Rsync介绍
## 1.1.	什么是Rsync
Rsync是一款优秀的、快速的、多功能的本地或远程数据镜像同步备份工具。适用于unix/linux/windows等多种平台。

rsync - faster, flexible replacement for rcp

## 1.2.	Rsync 简介
Rsync（remote synchronize）具有可使本地主机不同分区或目录之间及本地和远程两台主机之间数据快速同步镜像，远程备份等功能。

在同步备份时，默认情况下，Rsync通过其独特的"quick check"算法，仅同步大小或最后修改时间发生变化的文件或目录（也可根据权限，属主等变化同步，需要指定参数），甚至只是同步文件里有变化的内容部分，所以，可以实现快速的同步数据的功能。

提示：传统的cp,scp工具拷贝每次均为完整拷贝，而rsync除了完整拷贝，还具备增量拷贝的功能，因此，从性能及效率上更胜一筹。
# 1.3.	Rsync的特性
      (1)	支持拷贝特殊文件如链接，设备等
      (2)	可以有排除指定文件或目录同步的功能，相当于打包命令tar
      (3)	可以做到保持原来文件或目录的权限、时间、软硬链接等所有属性均不改变。
      (4)	可实现增量同步，既只同步发生变化的部分，因此数据传输效率很高。
      (5)	可以使用rcp、rsh、ssh等方式来配合传输文件，也可以通过直接的socket连接
      (6)	支持匿名的或认证的进程模式传输，方便进行数据备份及镜像。
```
(man rsync查询)
Some of the additional features of rsync are:
o      support for copying links, devices, owners, groups, and permissions
o      exclude and exclude-from options similar to GNU tar
o      a CVS exclude mode for ignoring the same files that CVS would ignore
o      can use any transparent remote shell, including ssh or rsh
o      does not require super-user privileges
o      pipelining of file transfers to minimize latency costs
o      support for anonymous or authenticated rsync daemons (ideal for mirroring)
```

# 2.	Rsync工作方式
## 2.1.	本地数据传输(local-only mode)
rsync [OPTION]... SRC [SRC]... DEST

语法说明：src为待拷贝的分区、文件或目录等, DEST为目的分区、文件或目录等

实例测试（重要）：

上例演示了将本地/opt目录下的文件（不包含opt本身）同步到/tmp下，其中-avz就是保持目录或文件的相关属性的参数。
提示:注意以下两命令的差别：
```
(1)	rsync –avz /opt/ /tmp/
(2)	rsync –avz /opt /tmp/

(1)中/opt/意思是，仅把/opt/目录里面的内容同步过来，opt目录本身并不同步；
(2)中的/opt表示把opt本身及其内部内容全部同步到/tmp下，仅一个/,意义就大不相同，请大家注意使用的差别。
在下面请的通过远程shell进行数据传输的内容也会有类似的问题，请牢记。
在本地的不同目录之间需要数据传输，特别是经常需要增量传输时，这个案例命令可以替代cp等命令，为你提升拷贝的效率。
```
## 2.2.	通过远程shell进行数据传输(remote shell mode)
    通过远程shell传输分为两种情况：
    拉取pull：	rsync [OPTION]... [USER@]HOST:SRC [DEST]
    推送push：	rsync [OPTION]... SRC [SRC]... [USER@]HOST:DEST
    拉取（get）表示从远端主机把数据同步到执行命令的本地主机相应目录。
    推送(put)表示从本地主机执行命令把本地的数据同步到远端主机指定目录下。

    拉取实例：
    rsync –vzrtopg –progress –e 'ssh –p 22' oldboy@10.0.0.141:/opt	/tmp
    语法说明：
    (1)	–vzrtopg 	相当于上文的-avz,表示同步时文件和目录属性不变。参数细节见后文。
    (2)	–progress 	显示同步的过程，可以用-p替换。
    (3)	–e 'ssh –p 22' 	表示通过ssh通道数据，-p 22可省略。
    (4)	oldboy@10.0.0.141:/opt	远程的主机用户、地址、路径。
    (5)	/tmp	本地的路径。


    推送实例：
    rsync –vzrtopg –progress –e 'ssh –p 22' /etc  oldboy@10.0.0.141:/tmp

## 2.3.	使用守护进程的方式进行数据传输(daemon mode)
    同样分为两种情况，每种情况又有两种写法：
    拉取：
    (1)	rsync [OPTION]... [USER@]HOST::SRC [DEST]
    (2)	rsync [OPTION]... rsync://[USER@]HOST[:PORT]/SRC [DEST]
    
    推送：
    (1)	rsync [OPTION]... SRC [SRC]... [USER@]HOST::DEST
    (2)	rsync [OPTION]... SRC [SRC]... rsync://[USER@]HOST[:PORT]/DEST
    
    特别注意的是，与远程shell方式不同的是，第(1)种语法格式，[USER@]HOST::SRC [DEST]和
    SRC [SRC]... [USER@]HOST::DEST结尾处，均为双冒号连接SRC或DEST，另外，这个SRC或DEST也不再是路径了，而是守护进程中配置的模块名称。


# 3.	通过Rsync在本地传输数据实践
## 3.1.	Rsync命令同步参数选项
      rsync [OPTION]... SRC [SRC]... DEST
      常用参数选项说明：
      -v,--verbose		详细模式输出传输时的进度等信息
      -z,--compress		传输时进行压缩以提高传输效率，--compress-level=NUM可按级别压缩。
      -r,--recursive	对子目录以递归模式，即目录下的所有目录都同样传输。
      -t,--times		保持文件时间信息
      -o,--owner		保持文件属主信息
      -p,--perms		保持文件权限信息
      -g,--group		保持文件属组信息
      -P,--progress		显示同步的过程及传输时的进度等信息
      -a,--archive			归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rtopgDl
      -e,--rsh=COMMAND		使用的信道协议，指定替代rsh的shell程序。例如ssh
      --exclude=PATTERN	指定排除不需要传输的文件模式
      -D,--devices		保持设备文件信息
      -l,--links		保持软链接

    保持同步目录及文件属性：
    -avz –progress相当于-vzrtopgDl –progress(还多了Dl的功能)，生产环境常用的参数选项为-avz –progress或-vzrtopg –progress,如果是放入脚本中，也可把-v 和—progress去掉。

# 3.2.	使用Rsync在本地传备份传输数据
    [root@A-server ~]# rsync -avz -P /etc /tmp/
    ....省略...
    etc/yum/
    etc/yum/yum-updatesd.conf
    490 100%    0.61kB/s    0:00:00 (xfer#1033, to-check=2/1853)
    etc/yum/pluginconf.d/
    etc/yum/pluginconf.d/fastestmirror.conf
    143 100%    0.18kB/s    0:00:00 (xfer#1034, to-check=0/1853)
    第一次运行由于需要扫描并同步所有文件及目录，因此时间会长一些。如果再次备份就会进行快速对比，忽略通过的文件，速度更快。
    sent 5615436 bytes  received 27682 bytes  364072.13 bytes/sec
    total size is 53583647  speedup is 9.50
    [root@A-server ~]# rsync -avz -P /etc /tmp/
    building file list ...
    1853 files to consider
    
    sent 53064 bytes  received 20 bytes  106168.00 bytes/sec
    total size is 53583647  speedup is 1009.41
    
    本地备份不能能备份目录，也能同步文件设备。
    提示：在传输数据时，rsync命令也需要有对同步的目录拥有权限，才能实现正常传输数据。

# 4.	通过ssh通道在不同主机之间传输数据
    实例1:将192.168.65.128主机下的/oldboy/oldboy目录下全部内容备份到192.168.65.129主机的/tmp下面。
    
    主机网络参数设置：
    主机名	        网卡eth0
    A-Server	192.168.65.128
    B-client1	192.168.65.129
    C-client2	192.168.65.130

## 4.1.	将数据推送到远端主机例子
```
[oldboy@A-server ~]$ ls -l oldboy/
total 0
-rw-rw-r-- 1 oldboy oldboy 0 Jul 29 20:25 file-128

#第1次执行rsync
[oldboy@A-server ~]$ rsync -avz -P oldboy -e 'ssh -p 22' oldboy@192.168.65.129:/tmp
building file list ...
2 files to consider
oldboy/
oldboy/file-128
0 100%    0.00kB/s    0:00:00 (xfer#1, to-check=0/2)

sent 144 bytes  received 48 bytes  384.00 bytes/sec
total size is 0  speedup is 0.00

#第2次执行rsync
[oldboy@A-server ~]$ rsync -avz -P oldboy -e 'ssh -p 22' oldboy@192.168.65.129:/tmp
building file list ...
2 files to consider

sent 99 bytes  received 20 bytes  238.00 bytes/sec
total size is 0  speedup is 0.00


#查看一下129的机子上同步的文件
[root@B-client1 tmp]# ls -l /tmp/oldboy/
total 0
-rw-rw-r-- 1 oldboy oldboy 0 Jul 29 20:25 file-128
```
## 4.2.	从远端主机拉取数据例子
```
[oldboy@A-server ~]$ rsync -avz -P -e 'ssh -p 22' oldboy@192.168.65.129:/tmp/oldboy       /tmp
receiving file list ...
2 files to consider
oldboy/
oldboy/file-128
0 100%    0.00kB/s    0:00:00 (xfer#1, to-check=0/2)

sent 48 bytes  received 148 bytes  392.00 bytes/sec
total size is 0  speedup is 0.00
[oldboy@A-server ~]$ tree /tmp/oldboy/
/tmp/oldboy/
`-- file-128

0 directories, 1 file

```
如果事先设置了ssh key密钥免登录验证，即可用rsync通过ssh方式免登录同步传输数据，这是生产场景常用的方法之一。

# 5.	以守护进程的方式传输数据(重点)
## 5.1.	部署环境
      操作系统：
      [root@A-server ~]# cat /etc/redhat-release
      CentOS release 5.6 (Final)
      [root@A-server ~]# uname -mi
      i686 i386
      内核版本：
      [root@A-server ~]# uname -r
      2.6.18-238.el5
      主机网络参数设置：
      主机名	网卡eth0	默认网关	用途
      A-server	192.168.65.128		备份服务器
      B-client1	192.168.65.129		节点服务器
      C-client2	192.168.65.130		节点服务器
      提示：如无特殊说明，子网掩码均为：255.255.255.0
## 5.2.	具体需求
      要求在A-server上以rsync守护进程的方式部署rsync服务，使得客户端主机，可以把本地数据通过rsync的方式传输数据到备份服务器A-server上。本例的客户端以B-client1、C-client2为例。
## 5.3.	备份拓扑图
略

## 5.4.	开始部署rsync服务-Rsync服务端操作过程
### 5.4.1.	配置rsyncd.conf
```
[root@A-server ~]# cat /etc/rsyncd.conf
#rsync_config_______________start
#created by oldboy 15:01 2007-6-5
#QQ 31333741 blog:http://oldboy.blog.51cto.com
##rsyncd.conf start##
uid = root
gid = root
use chroot = no
max connections = 200
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
[oldboy]
path = /oldboy/
ignore errors
read only = false
list = false
hosts allow = 192.168.65.0/24
hosts deny = 0.0.0.0/32
auth users = rsync_backup
secrets file = /etc/rsync.password
#rsync_config_______________end
```

配置多模块的写法：

```
[root@A-SERVER ~]# cat /etc/rsyncd.conf
#rsync_config_______________start
#created by oldboy 15:01 2007-6-5
#QQ 31333741 blog:http://oldboy.blog.51cto.com
##rsyncd.conf start##
uid = root
gid = root
use chroot = no
max connections = 200
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
hosts allow = 192.168.65.0/24
hosts deny = 0.0.0.0/32
auth users = rsync_backup
secrets file = /etc/rsync.password
[etiantian]
path = /etiantian/
[oldboy]
path = /oldboy/
#rsync_config_______________end
```
```
配置文件常用参数说明：
/etc/rsyncd.conf参数	说明
uid=root	rsync使用的用户。缺省uid为-2,通常为nobody。
gid=root	rsync使用的组。缺省gid为-2,通常为nobody
use chroot=no	如果为true,daemon会在给客户端传输文件前"chroot to the path"。这是rsync安全的一个配置，因为我们大多数都是在内网使用rsync,所以不配也可以。
max connections = 200	设置最大连接数，默认为0表示无限制，负值为关闭这个模块。
timeout = 300	默认为0表示没有超时，建议为300-600(5-10分种)
pid file = /var/run/rsyncd.pid	rsync daemon启动后将其进程PID写入此文件。如果这个文件已经存在，rsync进程不会覆盖该文件，而是会终止。
lock file = /var/run/rsync.lock	指定lock文件用来支持"max connections"参数，使得总连接数不会超过限制。默认为/var/run/rsync.lock
log file = /var/log/rsyncd.log	不设置或者设置错误，rsync会使用syslog输出相关日志信息
ignore errors	忽略IO错误
read only = false	指定客户端是否可以上传文件,默认对所有模块都为true
list = false	是否允许客户端可以查看可用模块列表，默认为可以
hosts allow = 10.0.0.0/24	指定可以联系的客户端主机名或和IP地址或地址段，默认没有此参数，即都可以连接
hosts deny = 0.0.0.0/32	指定不可以联系的客户端主机名或和IP地址或地址段，默认没有此参数，即都可以连接
auth users = rsync_backup	指定以空格或逗号分隔的用户可以使用哪些模块，用户不需要在本地系统中存在，默认所有用户无密码的访问(anonymous rsync)
secrets file = /etc/rsync.password	指定用户名和密码存放的文件。格式：用户名：密码，密码不超过8位。
[oldboy]	模块名称，需用中括号括起来，起名称没有特殊要求，但最好是有意义的名称，便于以后维护
path = /oldboy/	在这个模块中，dae使用的文件系统或目录，目录的权限要注意和配置文件中的权限一致，否则会遇到读写的问题。
#exclude= a c b/2	排除的文件或目录，相对路径
特别说明：
(1)	模块中的参数可以拿到全局配置中使用
(2)	以上配置文件中的参数，为经常使用的参数，初学者掌握这些已经足够。
(3)	以上配置文件中没有提到的参数请参考附录一或man rsyncd.conf 查看
(4)	如果配置中的path = /oldboy/提到的路径不存在则需要创建，命令为：
mkdir –p /oldboy
chmod –R root.root /oldboy	#权限可以根据配置文件中的属主来
```
### 5.4.2.	配置用于rsync同步的账号、密码及账号文件权限
```
[root@A-server oldboy]# mkdir /oldboy -p
[root@A-server oldboy]# echo "rsync_backup:oldboy" >/etc/rsync.password
#注意，其中rsync_backup:oldboy中的rsync_backup为同步传输用到的虚拟账号，这个账号仅为rsync的账号，不需要是系统账号。后面的oldboy为密码，不超过8位。账号和密码中间用冒号分隔。

[root@A-server oldboy]# cat /etc/rsync.password 			#操作完检查
rsync_backup:oldboy
[root@A-server oldboy]# chmod 600 /etc/rsync.password 	#必须为600权限
[root@A-server oldboy]# ls -l /etc/rsync.password 			#操作完检查
-rw------- 1 root root 20 Jul 29 21:58 /etc/rsync.password
```
### 5.4.3.	启动rsync服务
```
以守护进程方式来启动rsync服务：
[root@A-server ~]# rsync --daemon
#rsync进程参数选项：
#--daemon		以守护进程方式来启动rsync服务
#--address	绑定指定IP地址提供服务
#--config=FILE	更改配置文件路径，而不是默认的/etc/rsync.conf
#--port=PORT		更改其它端口提供服务，而不是默认的873端口
#以上几个选项为了解内容，生产场景使用的不多

[root@A-server ~]# ps –ef | grep rsync | grep -v grep			#检查rsync服务
root      8260     1  0 22:05 ?        00:00:00 rsync --daemon
[root@A-server ~]# netstat -lnt|grep 873
tcp        0      0 0.0.0.0:873                 0.0.0.0:*                   LISTEN      
[root@A-server ~]# lsof -i tcp:873 			#根据端口反查是什么服务
COMMAND  PID USER   FD   TYPE DEVICE SIZE NODE NAME
rsync   8260 root    4u  IPv4  21628       TCP *:rsync (LISTEN)
```
### 5.4.4.	设置rsync服务开机自启动
```
[root@A-server ~]# echo "/usr/bin/rsync --daemon" >>/etc/rc.local
#注意：当然也可以使用chkconfig rsync on命令

[root@A-server ~]# tail -1 /etc/rc.local
/usr/bin/rsync –daemon

#重起rsync的组合命令
[root@A-server ~]# pkill rsync      #关闭rsync服务
[root@A-server ~]# rsync --daemon       #启动rsync服务



[root@A-server ~]# vi /etc/init.d/rsyncd
#!/bin/sh
#author oldboy QQ 31333741
#
# rsync       Start/Stop Rsync service
#
# chkconfig: 35 13 91
# description: This is Rsync service management shell script
# processname: rsyncd

# Source function library.
. /etc/rc.d/init.d/functions

start(){
        rsync --daemon
        if [ $? -eq 0 -a `ps -ef|grep -v grep|grep rsync|wc -l` -gt 0 ];then
          action "Starting Rsync:" /bin/true
          sleep 1
        else
          action "Starting Rsync:" /bin/false
          sleep 1
        fi
}
stop(){
        pkill rsync;sleep 1;pkill rsync
        #if [ $? -eq 0 -a `ps -ef|grep -v grep|grep rsync|wc -l` -lt 1 ];then
        if [ `ps -ef|grep -v grep|grep "rsync --daemon"|wc -l` -lt 1 ];then
  
          action "Stopping Rsync: `ps -ef|grep -v grep|grep rsync|wc -l` " /bin/true
          sleep 1
        else
          action "Stopping Rsync: `ps -ef|grep -v grep|grep "rsync --daemon"|wc -l` " /bin/false
          sleep 1
        fi
}

case "$1" in
   start)
      start;
     ;;
   stop)
     stop
     ;;
   restart|reload)
    $0 stop;
    $0 start;
     ;;
  *)
        echo $"Usage: $0 {start|stop|restart|reload}"
        ;;
esac


[root@A-server ~]# dos2unix /etc/init.d/rsyncd
dos2unix: converting file /etc/init.d/rsyncd to UNIX format ...
[root@A-server ~]# chmod 700 /etc/init.d/rsyncd
[root@A-server ~]# chkconfig rsyncd on
[root@A-server ~]# chkconfig --list rsyncd
rsyncd          0:off   1:off   2:on    3:on    4:on    5:on    6:off


[root@A-server ~]# /etc/init.d/rsyncd stop
Terminated
[root@A-server ~]# netstat -lnt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0      0 0.0.0.0:2049                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:647                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:620                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:718                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:52497               0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:25                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:443                 0.0.0.0:*                   LISTEN      
[root@A-server ~]# /etc/init.d/rsyncd start
Starting Rsync: [  OK  ]
[root@A-server ~]# netstat -lnt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0      0 0.0.0.0:2049                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:647                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:873                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:620                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:718                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:52497               0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:25                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:443                 0.0.0.0:*                   LISTEN      
[root@A-server ~]# netstat -lntup | grep 873
tcp        0      0 0.0.0.0:873                 0.0.0.0:*                   LISTEN      8439/rsync  

```

## 5.5.	开始部署rsync服务-Rsync客户端操作过程
### 5.5.1.	配置rsync账号及账号文件权限

请注意与服务端的配置的区别
```
[root@B-client1 ~]# echo "oldboy" >/etc/rsync.password	#只需要密码，不需要账号
[root@B-client1 ~]# chmod 600 /etc/rsync.password 			#必须为600权限
[root@B-client1 ~]# cat /etc/rsync.password
oldboy
[root@B-client1 ~]# ll /etc/rsync.password
-rw------- 1 root root 7 Jul 29 22:39 /etc/rsync.password
```
至此rsync服务配置大功告成。

### 5.5.2.	检查部署的rsync服务
以下操作均在B-client1下执行

#### 5.5.2.1.	数据推送操作
```

[root@B-client1 ~]# rsync -avz -P /tmp/oldboy rsync_backup@192.168.65.128::oldboy/ --password-file=/etc/rsync.password
building file list ...
2 files to consider
oldboy/
oldboy/file-128
0 100%    0.00kB/s    0:00:00 (xfer#1, to-check=0/2)

sent 140 bytes  received 44 bytes  368.00 bytes/sec
total size is 0  speedup is 0.00

[root@A-server oldboy]# pwd
/oldboy
[root@A-server oldboy]# tree
.
`-- oldboy
`-- file-128

1 directory, 1 file
[root@B-client1 oldboy]# touch /tmp/oldboy/file-129
[root@B-client1 ~]# rsync -avz -P /tmp/oldboy rsync://rsync_backup@192.168.65.128:/oldboy/ --password-file=/etc/rsync.password
building file list ...
3 files to consider
oldboy/
oldboy/file-129
0 100%    0.00kB/s    0:00:00 (xfer#1, to-check=0/3)

sent 168 bytes  received 44 bytes  424.00 bytes/sec
total size is 0  speedup is 0.00

```

#### 5.5.2.2.	数据抓取操作
```
[root@B-client1 ~]# rm -rf /tmp/oldboy/
[root@B-client1 oldboy]# rsync -avz -P rsync://rsync_backup@192.168.65.128:/oldboy/ /tmp/  --password-file=/etc/rsync.password
receiving file list ...
4 files to consider
./
oldboy/
oldboy/file-128
0 100%    0.00kB/s    0:00:00 (xfer#1, to-check=1/4)
oldboy/file-129
0 100%    0.00kB/s    0:00:00 (xfer#2, to-check=0/4)

sent 167 bytes  received 298 bytes  930.00 bytes/sec
total size is 0  speedup is 0.00
[root@B-client1 oldboy]# tree /tmp/oldboy/
/tmp/oldboy/
|-- file-128
`-- file-129

0 directories, 2 files

```
#### 5.5.2.3.	--delete参数的作用
```
[root@B-client1 ~]# mkdir bsd
[root@B-client1 ~]# ll /root/bsd/
total 0

[root@A-server oldboy]# ls
oldboy

[root@B-client1 ~]# rsync -avz -P --delete /root/bsd/ rsync_backup@192.168.65.128::oldboy/ --password-file=/etc/rsync.password
building file list ...
1 file to consider
deleting oldboy/file-129	#显示删除，将远端的文件都删除了
deleting oldboy/file-128
deleting oldboy/
./

sent 50 bytes  received 22 bytes  144.00 bytes/sec
total size is 0  speedup is 0.00


[root@A-server oldboy]# ls –l		#A-server上原有的文件已经被删除了
total 0
```
结论：它可以将本地的目录和rsync服务端指定的目录实现完全同步，即本地有啥远端就有啥，本地没有的，远端必须删除。确保数据一致！推送时使用—delete命令有使远端rsync服务端的目录丢失危险。如果拉取到本地的目录是系统目录，如/根目录就超级危险了。

