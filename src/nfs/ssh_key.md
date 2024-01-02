# SSH KEY免密码验证分发、管理、备份实战讲解

2012年写的笔记，部分内容可能已经过时，仅供参考。

# SSH介绍
SSH 为 Secure Shell 的缩写，由 IETF 的网络工作小组（Network Working Group）所制定；它通过对联机数据包加密的技术来进行数据传递，因此数据很安全。SSH 是目前较可靠，专为远程登录会话和其他网络服务提供安全性的协议。利用 SSH 协议可以有效防止远程管理过程中的信息泄露问题。

默认状态下，SSH本身提供两个服务功能：一个是类似telnet的远程联机使用shell的服务，即俗称的SSH;另一个是类似FTP服务的sftp-server，可以提供更安全的FTP服务。

从客户端来看，SSH提供两种级别的安全验证。

第一种级别（基于口令的安全验证）：只要用户知道自己账号和口令，就可以登录到远程主机。所有传输的数据都会被加密，但是不能保证用户正在连接的服务器就是用户想连接的服务器。可能会有别的服务器在冒充真正的服务器，也就是受到"中间人"这种方式的攻击。

第二种级别（基于密钥的安全验证）：需要依靠密钥，也就是用户必须为自己创建一对密钥，并把公用密钥放在需要访问的服务器上。如果你要连接到SSH服务器上，客户端SSH软件就会向服务器发出请求，请求用用户的密钥进行安全验证。服务器收到请求之后，先在用户在该服务器的家目录下寻找用户的公用密钥，然后把它和用户发送过来的公用密钥进行比较。如果两个密钥一致，服务器就用公用密钥加密"质询"（challenge）并把它发送给客户端软件。客户端软件收到"质询"之后就可以用用户的私人密钥解密再把它发送给服务器。
# 1.	分发数据(一把钥匙多把锁)
## 1.1.	操作系统环境
### 1.1.1.	部署环境
      操作系统：
      [root@nfs-server ~]# cat /etc/redhat-release
      CentOS release 5.6 (Final)
      [root@nfs-server ~]# uname -mi
      i686 i386
      内核版本：
      [root@nfs-server ~]# uname -r
      2.6.18-238.el5
      主机网络参数设置：
      主机名	网卡eth0	默认网关	用途
      A-Server	192.168.65.128		中心分发服务器
      B-client1	192.168.65.129		接收节点服务器
      C-client2	192.168.65.130		接收节点服务器
      提示：如无特殊说明，子网掩码均为：255.255.255.0
      1.2.	需求分析
      1.2.1.	具体需求
      要求将所有服务器在同一用户oldboy系统用户下，实现A机器从本地分发数据到B、C机器上，在分发过程中不需要B、C的提示系统密码验证，当然，还包括批量查看客户机的CPU，LOAD,MEM等使用信息。即实现从A服务器发布数据到B、C客户端服务器或查看信息的免密码登录验证解决方案。
      分发数据流方式如下：
      A---->B
      A---->C
      形象比喻：一把钥匙(A)开多把锁(B、C)
      1.2.2.	实现拓扑


# 1.3.	行动前准备
## 1.3.1.	添加系统账号
```
在部署密钥之前，首先要分别在A、B和C服务器上添加好oldboy用户并设置密码，然后通过oldboy用户来实现多个服务器之间免密码登录，以A服务器为例，具体步骤如下：
[root@stu412 ~]# useradd oldboy
[root@stu412 ~]# echo "123456" | passwd --stdin oldboy

#不需要和系统交互直接设置密码，如果是生产环境，密码至少要8位以上数字或组合。
#提示：此命令结合shell可以用来批量创建账号和密码。
Changing password for user oldboy.
passwd: all authentication tokens updated successfully.
#如果用户已经存在，可用userdel –r oldboy删除用户
```
# 1.4.	开始部署
因为A服务器为中心分发服务器，所以我们选择在A端建立Public key(锁)与Private key（钥匙）。

在本文中，为了方便读者更好的学习和理解，这里把服务器密钥对以生活中大家每天都要接触到的锁和钥匙来打比方。Public key公钥比作锁，Private key私钥比作钥匙。密钥的基本原理可以理解为生活中用钥匙开锁的过程。

提示：在整个方案实现中，钥匙(Private key)和锁(Public key)需要建立一次即可，可以在A、B、C任意机器上来执行，本文选择在Ａ服务器来生成密钥对。
## 1.4.1.	生成密钥对
```
在A机器上建立dsa key,生成Public key 锁与Private key钥匙，执行步骤如下。
[root@A-Server ~]# su - oldboy
[oldboy@A-Server ~]$ ssh-keygen -t dsa
#ssh-keygen是生成密钥的工具，-t参数指建立密钥的类型，这是建立dsa类型密钥。
#也可以ssh-keygen -t rsa来建立rsa类型的密钥。
Generating public/private dsa key pair.
Enter file in which to save the key (/home/oldboy/.ssh/id_dsa): #默认回车一路到底
Created directory '/home/oldboy/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/oldboy/.ssh/id_dsa.
#private key(钥匙)的路径
Your public key has been saved in /home/oldboy/.ssh/id_dsa.pub.
#public key(锁)的路径

The key fingerprint is:
f9:65:f4:c8:14:ca:9f:18:0b:35:a2:97:cb:8a:e4:bb oldboy@A-Server
[oldboy@A-Server ~]$ tree .ssh
.ssh
|-- id_dsa
`-- id_dsa.pub

0 directories, 2 files

#提示：
#1.一路回车即可。密钥的生成可以在任意的机器上，且生成一次即可。
#2.请仔细看建立密钥过程中的屏幕信息，可以看到密钥的存放路径为用户家目录下的.ssh目录。
#3.有关ssh-keygen说明请man ssh-keygen或参考http://lamp.linux.gov.cn/OpenSSH/ssh-keygen.html
(ssh-keygen 中文手册)



[oldboy@A-Server ~]$ ls -al
total 28
drwx------  3 oldboy oldboy 4096 Jul 24 07:39 .
drwxr-xr-x 22 root   root   4096 Jul 23 23:45 ..
-rw-r--r--  1 oldboy oldboy   33 Jul 23 23:45 .bash_logout
-rw-r--r--  1 oldboy oldboy  176 Jul 23 23:45 .bash_profile
-rw-r--r--  1 oldboy oldboy  124 Jul 23 23:45 .bashrc
drwx------  2 oldboy oldboy 4096 Jul 24 07:27 .ssh		#建立了.ssh目录
[oldboy@A-Server ~]$ ls -ld .ssh
drwx------ 2 oldboy oldboy 4096 Jul 24 07:27 .ssh
[oldboy@A-Server ~]$ ls -l .ssh
total 8
-rw------- 1 oldboy oldboy 672 Jul 24 07:27 id_dsa		#private key(钥匙)
-rw-r--r-- 1 oldboy oldboy 605 Jul 24 07:27 id_dsa.pub	#public key(锁)

创建密钥的同时在用户家目录下生成了.ssh隐藏目录。
提示：.ssh目录的权限为700,另外，private key(钥匙)id_dsa文件权限为600,public key （锁）id_dsa.pub当前文件权限为644。其中，private key(钥匙)id_dsa文件权限必须为600。
```
### 1.4.2.	分发公钥(锁)
把公钥(锁)从A拷贝到B、C端用户家目录各一份。
即在A端执行如下命令：
```
[oldboy@A-Server .ssh]$ pwd
/home/oldboy/.ssh

[oldboy@A-Server .ssh]$ ls -l --time-style=long-iso
total 8
-rw------- 1 oldboy oldboy 672 2012-07-24 07:27 id_dsa
-rw-r--r-- 1 oldboy oldboy 605 2012-07-24 07:27 id_dsa.pub

[oldboy@A-Server .ssh]$ ssh-copy-id -i id_dsa.pub oldboy@192.168.65.130
#需要将id_dsa.pub放到192.168.65.130上oldboy家目录的.ssh目录即可（需要改名）
# ssh-copy-id为系统自带的shell脚本，可用来分发公钥。
10
The authenticity of host '192.168.65.130 (192.168.65.130)' can't be established.
RSA key fingerprint is 9b:22:03:7f:1d:ad:25:54:2c:78:8e:dc:4d:32:c8:d5.
Are you sure you want to continue connecting (yes/no)? yes
#输入yes在本地添加ssh公钥信息，该信息默认会被添加到本地~/.ssh/known_hosts文件中。
Warning: Permanently added '192.168.65.130' (RSA) to the list of known hosts.
oldboy@192.168.65.130's password:
Now try logging into the machine, with "ssh 'oldboy@192.168.65.130'", and check in:

.ssh/authorized_keys

to make sure we haven't added extra keys that you weren't expecting.


[oldboy@B-client1 ~]$ ls -ld .ssh/
drwx------ 2 oldboy oldboy 4096 Jul 25 07:28 .ssh/
[oldboy@B-client1 ~]$ ls -l --time-style=long-iso .ssh/
total 4
-rw------- 1 oldboy oldboy 605 2012-07-25 07:28 authorized_keys

[oldboy@C-client2 ~]$ ls -ld .ssh/
drwx------ 2 oldboy oldboy 4096 Jul 25 07:29 .ssh/
[oldboy@C-client2 ~]$ ls -l --time-style=long-iso .ssh/
total 4
-rw------- 1 oldboy oldboy 605 2012-07-25 07:29 authorized_keys


B,C服务器上的oldboy用户家目录多了一个.ssh目录。目录里添加了一个文件authorized_keys，那么这个文件就是名的id_dsa.pub文件。默认情况下ssh配置文件中默认调用的公钥路径为.ssh，文件名就是authorized_keys。
[root@C-client2 oldboy]# cat /etc/ssh/sshd_config | grep authorized_key
#AuthorizedKeysFile     .ssh/authorized_keys
特别提示：.ssh目录的权限(700)及authorized_keys公钥锁的文件权限(600)
```
### 1.4.3.	有关拷贝ssh密钥对的说明
ssh-copy-id为当前centos5.x系统自带的拷贝公钥的脚本命令，执行这个脚本附带相关参数，就可以把公钥id_dsa.pub拷贝到其它分发节点机器上对应用户家目录下的.ssh目录（不存在会直接创建该目录），然后自动将拷贝的公钥id_dsa.pub改名为authorized_keys。

特别注意：当要分发的节点机器有数百台时，使用ssh-copy-id就相对麻烦了，因为，第一次拷贝时总需要人工输入密码。解决这个问题的办法就是用expext交互式命令来实现，有关expect内容请见本文附录或shell编程章节部分。另外一个办法就是，手动处理公钥的办法（见附录二）。

具体方案是，把公钥改名后做成压缩包，然后放到一个所有分发点都可以访问的http server上，然后分发在所有分的机器上写脚本直接wget下载解压即可。不过手工修改会带来部署出问题的风险，其中最常见是.SSH目录权限的问题。
### 1.4.4.	ssh-copy-id的特殊应用
### 1.4.5.	远程登录执行命令测试
```
[root@A-Server ~]# ssh oldboy@192.168.65.130 /sbin/ifconfig eth0
#在root用户下使用ssh登录到C(192.168.65.130)上要输入密码的
The authenticity of host '192.168.65.130 (192.168.65.130)' can't be established.
RSA key fingerprint is 9b:22:03:7f:1d:ad:25:54:2c:78:8e:dc:4d:32:c8:d5.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.65.130' (RSA) to the list of known hosts.
oldboy@192.168.65.130's password:
eth0      Link encap:Ethernet  HWaddr 00:0C:29:89:34:3A  
inet addr:192.168.65.130  Bcast:192.168.65.255  Mask:255.255.255.0
UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
RX packets:1545 errors:0 dropped:0 overruns:0 frame:0
TX packets:1280 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:173954 (169.8 KiB)  TX bytes:152909 (149.3 KiB)
Interrupt:67 Base address:0x2000

[root@A-Server ~]# su - oldboy
[oldboy@A-Server ~]$ ssh oldboy@192.168.65.130 /sbin/ifconfig eth0
#在oldboy用户下使用ssh登录到C(192.168.65.130)上不需要输入密码
#但第一次连接某节点，需要输入密码，之后连接一般就不会出现确认提示了。此步骤把ssh公钥认证信息写入本地的~/.ssh/known_hosts,后文会讲解此文件。
eth0      Link encap:Ethernet  HWaddr 00:0C:29:89:34:3A  
inet addr:192.168.65.130  Bcast:192.168.65.255  Mask:255.255.255.0
UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
RX packets:1584 errors:0 dropped:0 overruns:0 frame:0
TX packets:1311 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:179312 (175.1 KiB)  TX bytes:158266 (154.5 KiB)
Interrupt:67 Base address:0x2000
[oldboy@A-Server ~]$ ssh oldboy@192.168.65.129 free –m #查看内存
total       used       free     shared    buffers     cached
Mem:          1010        275        735          0         34        186
-/+ buffers/cache:         54        956
Swap:          509          0        509


[oldboy@A-Server ~]$ ssh oldboy@192.168.65.130
#没有提示输入密码就直接进入，因为配了免密码验证，也没有SSH密钥验证了，因为上面部署时曾经测试连接过一次了，那么第二次就不会提示SSH密钥认证了，除非要请求的服务器，重新安装或者~/.ssh/known_hosts文件内容丢失。
[oldboy@client2 ~]$ /sbin/ifconfig eth0	#机器名已经修改为client2了
eth0      Link encap:Ethernet  HWaddr 00:0C:29:89:34:3A  
inet addr:192.168.65.130  Bcast:192.168.65.255  Mask:255.255.255.0
UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
RX packets:118 errors:0 dropped:0 overruns:0 frame:0
TX packets:138 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:15282 (14.9 KiB)  TX bytes:21082 (20.5 KiB)
Interrupt:67 Base address:0x2000

[oldboy@client2 ~]$ exit
logout

Connection to 192.168.65.130 closed.
[oldboy@A-Server ~]$
```
我们实现A--->B, A--->C单向访问不需要输入密码认证了，如何实现B--->A, C--->A也不用输入密码呢?，见后文
## 1.5.	ssh免密码验证分发数据架构应用
批量获取网卡信息
批量获取内存信息
批量获取负载信息
….
### 1.5.1.	获取所有节点服务器的机器内部信息
### 1.5.2.	分发数据到所有的节点
#### 1.5.2.1.	建立测试数据
```
[oldboy@A-Server ~]$ mkdir -p /tmp/oldboy
[oldboy@A-Server ~]$ cd /tmp/oldboy/
[oldboy@A-Server oldboy]$ touch file1 file2 file3 file4 file5
[oldboy@A-Server oldboy]$ ls -l
total 0
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file1
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file2
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file3
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file4
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file5
查看C机器上面是否有数据
[oldboy@client2 ~]$ ls -l
total 0
```
#### 1.5.2.2.	从A: 192.168.65.128分发数据到节点129,130
```
使用scp分发
[oldboy@A-Server oldboy]$ scp -P22 -r /tmp/oldboy/ oldboy@192.168.65.130:~
file2                                                       100%    0     0.0KB/s   00:00    
file5                                                       100%    0     0.0KB/s   00:00    
file4                                                       100%    0     0.0KB/s   00:00    
file3                                                       100%    0     0.0KB/s   00:00    
file1                                                       100%    0     0.0KB/s   00:00
[oldboy@client2 ~]$ ls -l
total 4
drwxrwxr-x 2 oldboy oldboy 4096 Jul 25 22:11 oldboy
[oldboy@client2 ~]$ ls -l oldboy/
total 0
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:11 file1
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:11 file2
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:11 file3
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:11 file4
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:11 file5
```

使用rsync分发
```
[oldboy@A-Server oldboy]$ /usr/bin/rsync -avz -P -e 'ssh -p 22' /tmp/oldboy oldboy@192.168.65.129:~
building file list ...
6 files to consider
oldboy/
oldboy/file1
0 100%    0.00kB/s    0:00:00 (xfer#1, to-check=4/6)
oldboy/file2
0 100%    0.00kB/s    0:00:00 (xfer#2, to-check=3/6)
oldboy/file3
0 100%    0.00kB/s    0:00:00 (xfer#3, to-check=2/6)
oldboy/file4
0 100%    0.00kB/s    0:00:00 (xfer#4, to-check=1/6)
oldboy/file5
0 100%    0.00kB/s    0:00:00 (xfer#5, to-check=0/6)

sent 329 bytes  received 136 bytes  186.00 bytes/sec
total size is 0  speedup is 0.00
[oldboy@B-client1 ~]$ ls -l
total 4
drwxrwxr-x 2 oldboy oldboy 4096 Jul 25 22:08 oldboy
[oldboy@B-client1 ~]$ ls -l oldboy/
total 0
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file1
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file2
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file3
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file4
-rw-rw-r-- 1 oldboy oldboy 0 Jul 25 22:08 file5
```
### 1.5.3.	ssh,scp,rsync命令用法

(1)	ssh –p22 oldboy@10.0.0.150     						(小p22)

默认是22端口，-p22可以不写

(2)	scp –P22 –r –p /tmp/oldboy oldboy@10.0.0.150		(大p22)

-r　拷贝目录

-p	保持文件或目录属性

(3)	rsync
```
/usr/bin/rsync -avz –-delete  -e 'ssh -p 22' /tmp/oldboy oldboy@192.168.65.129:~
/usr/bin/rsync -avz -P         -e 'ssh -p 22' /tmp/oldboy oldboy@192.168.65.129:~
```
#同上文的scp,rsync工具有推送和抓取两种情况，其中rsync的—delete参数很危险，容易搞丢数据，初学者请慎用。曾经有血的教训。
## 1.6.	分发数据免密码登录的几点须知
```
(1)	本例中免验证登录是单向的，即只能从A免验证登录到B,C。
(2)	记住带authorized_key公钥密钥端我们定义为server服务端或者锁端，另一端有id_dsa私钥钥端定义为“钥匙端”。
(3)	所有密钥的默认目录为~/.ssh,.ssh目录权限最好为700，以免密钥数据泄露。
(4)	如果要建立其它主机如D机(ip为192.168.65.133)可以被A机免密码验证登录，只需要从A端执行ssh-copy-id -i id_dsa.pub oldboy@192.168.65.133即可
(5)	此种方法适用于生产环境分发数据/发布程序代码等生产场景。甚至查看所有机器内存，CPU,负载，进程等所有需要有服务器信息，应用非常普遍。
(6)	对于千台以上大规模服务器的公司，也可以考虑使用cfengine/puppet等分发同步工具，来实现本节所讲的内容。但其配置较复杂，大家可以根据自己的需求选用适合自己的。
```
特别提示：本文免验证连接是基于普通用户oldboy的，如果要实现hosts文件传送需要root才能处理。
```　
解决方法有三种：
(1)oldboy用户配置成sudo权限用户。1.visudo开启Defaults requiretty参数。2.使用ssh的如下命令"ssh –t hostname sudo <cmd>"。（老男孩推荐）
(2)使用setuid权限位。生产环境请不要使用此方法！
(3)配置root用户免验证登录，但这会带来安全问题。
不管使用什么方法，我们一定要管理好中心服务器A,因为它的权限最大，很重要。如何实现呢?
如取消中心分发服务器的外网IP,开启防火墙禁止SSH对外用户登录，并仅给某一台后端无外网机器访问。然后这台后端的服务器依然没外网IP,并且仅能通过VPN连接，这样中心服务器就相对安全了。
```

# 2.	备份数据(多把钥匙一把锁)
说明：备份数据在生产环境中，一般我们习惯用rsync的服务模式，而不是本文的SSH免Key认证的模式。这里讲理此内容，是为了给大家开拓思维。
## 2.1.	备份方案部署环境
## 2.2.	备份需求分析
### 2.2.1.	备份具体需求
### 2.2.2.	备份实现拓扑

## 2.3.	备份行前准备
### 2.3.1.	添加系统账号

## 2.4.	开始部署
### 2.4.1.	生成密钥对
### 2.4.2.	分发私钥

## 2.5.	ssh免密码验证备份数据架构应用

## 附录一：ssh-copy-id脚本解读
## 附录二：分发公钥的传统方法
## 附录六：文件分发及批量管理新方案
```
(1)	ssh key + rsync (中小公司首选，大公司也OK)
(2)	oldboyengine
(3)	cfengine
(4)	puppet
(5)	expect
```
