# Linux用户切换(su sudo)


# 1.	linux用户身份切换命令
root权限太大，如果管理不好，就会给系统带来严重隐患。在工作场景中，我们只在必要时才使用root的权限。当普通用户切换到超级用户，有两个命令su和sudo可完成用户切换的工作。
## 1.1.	su
su是切换用户身份的命令。
超级用户root向普通用户或虚拟用户切换时不需要密码验证，其他普通用户之间或普通用户切换到root,都需要切换用户的密码验证。
### 1.1.1.	su命令用法
```
su [选项参数] [用户]

su参数选项	说明
- , -l , --login	make the shell a login shell
  #使一个shell成为登录的shell,如执行su – oldboy时，表示该用户想改变身份为oldboy,并且使用oldboy用户的环境变量配置，如：
  /home/oldboy/.bash_profile等
  -c , --command=COMMAN	pass a single COMMAND
  #切换到一个shell下，执行一个命令，然后退出所切换的用户环境。
  -m,--preserve-environment	do not reset environment variables, same as –P
  #切换用户时，不重置用户环境变量，-p的功能同-m,这个参数为su的默认值，一般较少使用。
  -s,--shell=SHELL	run SHELL if /etc/shells allows it
  #如果/etc/shell允许，则运行指定的shell
  在生产环境中，su命令比较常用的参数为 – 和 –c ,其它的参数很少用到。
  1.1.2.	su命令实例
  当不加任何参数执行su命令时，表示要切换到root用户，但这样执行，会遇到一些问题，因为虽然是切换到root了，但并没有改变为root用户登录环境，用户默认的登录环境，可以在/etc/passwd中查得到，包括家目录，shell类型等。比较规范的操作方法是"su –"。
```


实例1：由普通用户oldboy切换到root用户
```
[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ su
Password: #root用户密码
[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ su
Password:
[root@stu412 oldboy]# env	#还是oldboy的环境变量
HOSTNAME=stu412
TERM=vt100
SHELL=/bin/bash
HISTSIZE=1000
USER=oldboy
JRE_HOME=/data/jdk1.6.0_26/jre
… 省略 …
MAIL=/var/spool/mail/oldboy
PWD=/home/oldboy
INPUTRC=/etc/inputrc
LANG=en_US.UTF-8
HOME=/root
SHLVL=2
LOGNAME=oldboy
CLASSPATH=.:/data/jdk1.6.0_26/lib:/data/jdk1.6.0_26/jre/lib:
LESSOPEN=|/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env…

[oldboy@stu412 ~]$ su –
[root@stu412 ~]# env | egrep "USER|MAIL|PWD|LOGNAME" #环境变量已经修改了
USER=root
MAIL=/var/spool/mail/root
PWD=/root
LOGNAME=root
如果使用su而不加上"-"这个参数，那么，切换前的用户的相关信息还会存在，这会引起很多麻烦，甚至是意想不到的结果。因此，切换用户时，最好是"su – 用户名"。这是生产环境中标准的切换用户的方法。

su命令总结：
(1)	普通用户切换到root用户，可使用su – 或su – root。必须输入root的密码才能完成切换。
(2)	root用户切换到普通用户，可使用”su – 普通用户名”的写法。不需要输入任何密码就能完成切换。可能会因为PATH环境变量的问题，找不到部分命令，如ifconfig。
(3)	如果仅希望在某用户下执行命令，而不直接切换到该用户下操作，可以使用su – 用户名 –c “命令”的方式。
```
实例2:root用户切换到普通用户oldboy
```
[root@stu412 ~]# su – oldboy	#不需要密码验证
[oldboy@stu412 ~]$ env | egrep "USER|MAIL|PWD|LOGNAME"
USER=oldboy
MAIL=/var/spool/mail/oldboy
PWD=/home/oldboy
```
实例3:oldboy用户使用root身份执行一个命令
```
[oldboy@stu412 ~]$ ls -l /root
ls: /root: Permission denied
[oldboy@stu412 ~]$ su - -c "ls -l /root"	#su的参数组合，表示切换到root用户，并且改变到root环境，然后列出root家目录的文件，然后退出root用户。
Password: 	#输入root的密码
total 107940
-rw------- 1 root root      964 Jun  4 03:35 anaconda-ks.cfg
drwxr-xr-x 2 root root     4096 Jun 22 08:33 destination
… 省略 …

```
实例4:su命令生产环境应用的案例
```
在生产环境中，为了安全起见，我们一般会使用普通用户来启动服务进程(如apache,nginx,resin,tomcat等)。
这时候我们临一个问题，如何让系统在每一次开机时，也要自动以普通用户启动指定的服务脚本呢？

#tail -5 /etc/rc.local  #把要执行的脚本放入开机自启动配置文件/etc/rc.local中。
su – tddoc –c '/bin/sh /home/tddoc/bin/deploy.sh'
#大家注意了，这是在系统开机时，通过su – 用户 –c "命令"，执行的启动服务的命令。通过普通用户跑服务是个很好的提升系统安全的方法，在生产环境中，大多数服务（如apache，ngin——resin，tomoca，rsync等）都可以通过普通用户来启动，而不是root,这样做使用系统安全又提高了一个等级。目前，taobao、支付宝等大公司均有采用。
```
## 1.1.3.	su命令优缺点
多人可使用su切换到root,只要有一人对系统操作失误，都可能导致整个系统崩溃或数据损失。

使用su命令切换身份在多个系统管理员共同管理的场合，并不是最好的选择。如果是一般的中小公司中不超过3个管理员时，为了管理方便，使用su来共同管理是可以接受的。

我们希望超级用户root密码掌握到少数或唯一的管理员手中，又希望多个管理员能够完成更多更复杂的系统管理操作。使用sudo命令来替代或结合su命令来完成这样苛刻且必要的管理需求。

# 1.2.	sudo
### 1.2.1.	sudo命令介绍与工作原理
```
su命令的致命缺点：
1)	普通用户必须知道root密码才能切换到root,这样root密码就泄露了。
2)	使用su切换身份，无法对切换后的身份做精细的控制，拿到超级权限的人可以为所欲为。
```
通过sudo命令，可以将某些超级用户权限分类有针对性授权给rag指定的普通用户，uah并且普通用户可以不需要知道root密码就可以得到授权。
```
sudo命令执行的大概流程
(1)	当用sudo执行命令，系统首先会查找/var/run/sudo/%HOME(如果是新用户会先生成此目录)，目录中是否有用户时间戳文件，如果时间戳文件过期，则提示用户是否输入自身的密码，（注意：这里输入的是当前执行命令用户的密码，不是root或其它要切换的用户的密码）
(2)	当密码验证成功后，系统会查找/etc/sudoers配置文件，判断用户是否有执行相应sudo命令权限。
(3)	如果具备执行相应sudo命令权限，就会自动由当前用户切换到root(或其它指定切换到的用户),然后以root（或其它指定的切换到的用户）身份角色执行该命令。
(4)	执行完成后，又会自动的直接退回到当前用户shell下。
```
执行sudo的过程，无须知道root的密码。此外，用户能够执行的命令是可以被sudo配置文件控制的。比如我们可以对某一个用户仅授权reboot的工作。

权限控制完全依赖/etc/sudoer这个配置文件，要默认的情况下，普通用户无法使用sudo，只有编辑/etc/sudoer文件加入用户授权规则后才可以，这就需要visudo命令。

### 1.2.2.	sudo命令语法
```
sudo, sudoedit - execute a command as another user

sudo [参数选项] 命令

参数选项	说明 (绿色部分必须要掌握)  
-l	列出用户在主机上可用的和被禁止的命令;当配置好sudo授权规则后，可用这个参数来查看授权情况。
-v	验证用户的时间戳；当用户运行sudo，输入用户密码后，在短时间内可以不用输入口令直接进行sudo操作，用-v可以跟踪最新的时间戳。
-u	指定以某个用户身份执行特定的命令操作
-k	同-K,删除时间戳,下一个sudo命令要求提供密码。前提是该用户授权中不能的NOPASSWD参数。
sudo的参数很多，但在生产场景中经常使用的比较少，这里我们还是讲解常用的参数的用法。
```
### 1.2.3.	sudo命令实例

实例1：使用oldboy用户在root目录下建立文件
```
[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ sudo touch /root/ett	#生产环境的标准用法
[sudo] password for oldboy:
oldboy is not in the sudoers file.  This incident will be reported.
#oldboy用户没有在sudoer文件里配置
```
实例2：配置sudoers文件，对oldboy授权，然后在实现上例操作。
```
[root@stu412 ~]# echo "oldboy ALL=(ALL) ALL">>/etc/sudoers
#特别提示：对于新手请不要用这个命令，如果配置出错，会导致所有普通用户无法使用sudo的问题发生。这样使用，是因为这样更改不需要和系统交互，可以批量操作管理。对于新手，请使用visudo
[root@stu412 ~]# tail -1 /etc/sudoers
oldboy ALL=(ALL) ALL
[root@stu412 ~]# visudo –c		#验证是否正确！
/etc/sudoers: parsed OK

[oldboy@stu412 ~]$ sudo touch /root/ett
[sudo] password for oldboy: 			#输入oldboy密码
[oldboy@stu412 ~]$ sudo ls /root/		#不需要输入密码了
anaconda-ks.cfg  echo.sh  file2    install.log         jdk-6u26-linux-i586.bin  mysql-5.1.62.tar.gz  nohup.out  us.sh
destination      ett      file.py  install.log.syslog  multi_blanks.txt         nginx-1.0.15.tar.gz  test
[oldboy@stu412 ~]$ sudo -k				#-k或-K参数，删除时间戳，下一个sudo命令要求密码验证
[oldboy@stu412 ~]$ sudo touch /root/ett1
[sudo] password for oldboy:			#又要输入密码了
```
实例3：sudo与su两个命令结合使用的案例
```
特别说明：这个案例操作，在生产环境会经常用到。
[oldboy@stu412 ~]$ sudo su -  	#通过sudo切换到root用户
[sudo] password for oldboy:
#提示：有时可能输入密码后会等待很长的时间，这可能是你的/etc/host中的主机名配置和当前系统主机名不一致导致的。
[root@stu412 ~]# head -3 /etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1	stu412 localhost.localdomain localhost

[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ sudo su – alex		#切换到alex用户
[alex@stu412 ~]$
```
实例4：oldboy用户通过sudo切换到ett用户下创建目录
```
[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ sudo -u ett mkdir /home/ett/tmpdir
#oldboy用户通过sudo命令切换到ett用户下创建目录
[oldboy@stu412 ~]$ ls -l /home/ett
ls: /home/ett: Permission denied
[oldboy@stu412 ~]$ sudo -u ett ls -l /home/ett
total 8
-rw-r--r-- 1 ett ett    9 Jul 10 22:18 testfile
drwxr-xr-x 2 ett ett 4096 Jul 10 22:18 tmpdir
[oldboy@stu412 ~]$ whoami
oldboy
```
### 1.2.4.	更改授权/etc/sudoers的方法
```
(1)	执行visudo命令自动编辑/etc/sudoers(推荐)
特别说明：在没有特别需求的情况下，请大家一定要使用这个方法。这个方法是最安全的授权方法。缺点就是必须和系统交互才能完成授权。

(2)	直接修改/etc/sudoers文件方法（不推荐）
使用方法请参见实例2
# echo "oldboy ALL=(ALL) ALL">>/etc/sudoers
# tail -1 /etc/sudoers
# visudo –c
直接修改sudoers文件要注意以下几点：
(1)	echo命令是追加，不是重定向>，除了echo外，还可以使用cat,sed等命令实现类似的功能
(2)	修改操作完成后，一定要执行visudo –c进行语法检查，这样能弥补直接修改的不足。
(3)	确保/etc/sudoers权限是正确的（-r—r----）,权限不对会导致sudo功能导常。
(4)	及时对授权的操作进行测试，验证是否正确（最好不要退出当前授权窗口，以便发现问题及时恢复）。
(5)	确保知道正确root用户密码，以便在出现问题时，可以通过普通用户等候执行su – 命令切换到root进行恢复。
没有特殊紧急批量添加sudoer文件内容的情况下，建议通过vissudo来修改，毕竟系统安全的相当重要的。
(3)	通过用户组方式实现sudo授权
授权sa组具备以上所有主机的管理权限，这样以后有用户需要相同的授权时，直接将用户加入到sa组就可以享受到sa的sudo授权了。如：
%sa		ALL=(ALL)		ALL
#注意用户组授权和普通用户的区别，开头以"%"百分号。sa组同用户一样必须是已经存在的。

[root@stu412 ~]# echo "%sa ALL=(ALL) ALL" >> /etc/sudoers #配置sudoers
[root@stu412 ~]# tail -1 /etc/sudoers 	#验证配置是否正确
%sa ALL=(ALL) ALL
[root@stu412 ~]# visudo -c
/etc/sudoers: parsed OK
[root@stu412 ~]# ls -l /etc/sudoers
-r--r----- 1 root root 3439 Jul 10 22:37 /etc/sudoers

[root@stu412 ~]# su - ett
[ett@stu412 ~]$ sudo ls /root		#ett用户执行sudo

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for ett:
ett is not in the sudoers file.  This incident will be reported.

[root@stu412 ~]# usermod -g sa ett	#修改ett的用户组
[root@stu412 ~]# id ett
uid=1810(ett) gid=801(sa) groups=801(sa)

[ett@stu412 ~]$ sudo ls /root			# ett执行sudo操作成功了
[sudo] password for ett:
echo.sh  file.py  jdk-6u26-linux-i586.bin  mysql-5.1.62.tar.gz  nginx-1.0.15.tar.gz  test  us.sh
```
### 1.2.5.	sudo配置文件/etc/sudoers
```
我们可以用专用工具visudo来完成sudo的授权配置。使用visodu的好处是添加规则后，保存退出时会检查授权配置的语法。
当授权配置完成后，可以切换到授权的用户下，通过 sudo –l 来查看哪些超级权限命令是可以执行或禁止的。
/etc/sudoers配置的每一行就是一个规则，前面带有#号的为注释说明和内容，当规则超过一行的长度时，可以使用"\"号来续行。
/etc/sudoer的规则大致可分为两类：一类是别名定义，另一类是授权规则；别名定义并不是必须的，但是授权规则是必须的。
```
### 1.2.6.	/etc/sudoers配置文件中的别名定义
```
别名类型（Alias_Type）：别名类型包括如下四种：
(1)	Host_Alias定义主机别名
## Host Aliases
## Groups of machines. You may prefer to use hostnames (perhap using
## wildcards for entire domains) or IP addresses instead.
# Host_Alias     FILESERVERS = fs1, fs2		#注意定义规范，"=" 号两边有空格
# Host_Alias     MAILSERVERS = smtp, smtp2	#注意定义规范，每个成员用逗号分隔，逗号后面有空格
说明：
1.	在生产场景,一般情况不需要设置主机别名，在定义授权规时可以通过ALL来匹配所有的主机。
2.	请注意上面的规范。

(2)	User_Alias定义用户别名
别名成员可以是用户或用户组(前面有%)
## User Aliases
## These aren't often necessary, as you can use regular groups
## (ie, from files, LDAP, NIS, etc) in this file - just use %groupname
## rather than USERALIAS
# User_Alias ADMINS = jsmith, mikem, %groupname
提示：设置用户别名也不是必须的，更多的情况，我们可能通过%groupname的方式作为成员。

(3)	Runnas_Alias定义runas别名
这个别名指定的是"用户身份"，即sudo允许切换至的用户
Runnas_Alias定义的某个系统用户可以执行sudo切换身份到Runnas_Alias下包含的成员身份。
实际语法为：Runnas_Alias op = root

(4)	Cmnd_Alias定义命令别名
## Command Aliases
## These are groups of related commands...

## Networking
#Cmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/dhclient, /usr/bin/net, /sbin/iptables, /usr/bin/rfcomm, /usr/bin/wvdial, /sbin/iwconfig, /sbin/mii-tool

## Installation and management of software
#Cmnd_Alias SOFTWARE = /bin/rpm, /usr/bin/up2date, /usr/bin/yum

## Services
#Cmnd_Alias SERVICES = /sbin/service, /sbin/chkconfig
#命令别名就是设置可以执行哪些命令

定义别名举例--
由于主机别名在工作中使用的很少，这里就不多介绍了。
```
实例1：定义用户别名User_Alias
```
User_Alias ADMINS = oldboy, ett, %oldboy

#为了管理方便，所有别名尽可能使用有意义的别名。另外，所有包含成员都必须是系统中存在的用户
```
实例2：定义命令别名Cmnd_Alias
```
Cmnd_Alias USERCMD = /usr/sbin/useradd, /usr/sbin/userdel, \
/usr/bin/passwd [A-za-z]*, /bin/chown, /bin/chmod
Cmnd_Alias DISKCMD = /sbin/fdisk, /sbin/parted
Cmnd_Alias NETMAG = /sbin/ifconfig, /etc/init.d/network
Cmnd_Alias CTRLCMD = /usr/sbin/reboot, /usr/sbin/halt
特别说明：
所有的命令别名下的成员必须是文件或目录的绝对路径。
命令别名超过一行时，可以通过'\'号换行；
在定义时，可以使用正则表达式。

```
实例3：定义runas别名Runas_Alias
```
Runas_Alias OP = root, oldboy
runas别名的定义也不多见
```
### 1.2.7.	/etc/sudoers配置文件中的授权规则
```
/etc/sudoer的授权规则就是分配权限的执行规则，前面我们讲到的定义别名主要是为了更方便授权引用别名。如果系统中用户不多，也可以不用定义别名，而是针对系统用户直接授权。
如果想了解授权规则写法，可执行man sudoers或man /etc/sudoers查询。
#Allow oldboy to run any command anywhere
oldboy 		ALL=(ALL)		ALL
授权用户 主机=(指定的可切换的用户)	可以执行的命令动作
oldboy用户可以在所有的主机上，切换到所有的用户，执行所有的命令。
#授权中的所有ALL字符串必须要大写。其中，第一、第二个ALL字符串不大写的话,visudo语法检查可以过，但是授权规则达不到配置需求，最后一个ALL必须大写，否则visudo语法检查不过。

如果想要oldboy用户切换到ett用户下执行命令，可写成
oldboy		ALL=(ett) 		ALL

如果忽略上面括号内的内容(ett),如写成
oldboy 		ALL=				ALL
#那么实际的情况就是，仅能进行root用户的切换操作。

上面讲的是用户授权，但在实际的工作中，有很多用户时，使用用户组授权会更方便更有效率。给用户组授权完成后，以后其它用户需要同样的授权时，把这个用户加入到已经授权过的用户组即可，就不需要再配置/etc/sudoers了。
授权用户组的语法格式是：
##Allows people in group wheel to run all commands
%wheel 		ALL=(ALL)		ALL
##Same thing without a password
%wheel 		ALL=(ALL)		NOPASSWD:ALL
#如果希望在执行命令时不提示密码，就用这个NOPASSWD:ALL语法来授权
## Allows members of the users group to mount and unmount the
## cdrom as root
# %users  ALL=/sbin/mount /mnt/cdrom, /sbin/umount /mnt/cdrom

## Allows members of the users group to shutdown this system
# %users  localhost=/sbin/shutdown -h now
```
### 1.2.8.	sudo(/etc/sudoers)授权规则实例
```
实例1：oldboy ALL=/usr/sbin/useradd,/usr/sbin/userdel
对oldboy的授权规则如下：
oldboy ALL=/usr/sbin/useradd,/usr/sbin/userdel
#表示oldboy可以在所有系统中，切换到root用户以root身份执行/usr/sbin/useradd和/usr/sbin/userdel命令。
[oldboy@stu412 ~]$ sudo –l #查看授权结果
Matching Defaults entries for oldboy on this host:
requiretty, !visiblepw, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS MAIL PS1 PS2 QTDIR USERNAME LANG
LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME
LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"

User oldboy may run the following commands on this host:
(root) /usr/sbin/useradd, (root) /usr/sbin/userdel

[oldboy@stu412 ~]$ sudo useradd tmpuser11
sudo: useradd: command not found
[oldboy@stu412 ~]$ sudo /usr/sbin/useradd tmpuser11	#通过全路径命令来添加用户
[oldboy@stu412 ~]$ sudo tail -1 /etc/passwd		#oldboy无此sudo权限
Sorry, user oldboy is not allowed to execute '/usr/bin/tail -1 /etc/passwd' as root on stu412.
[oldboy@stu412 ~]$ tail -1 /etc/passwd			#tail不需要sudo权限
tmpuser11:x:1811:1811::/home/tmpuser11:/bin/bash

做点非份之想看：
[oldboy@stu412 ~]$ sudo su - #切换到root试试
Sorry, user oldboy is not allowed to execute '/bin/su -' as root on stu412.
[oldboy@stu412 ~]$ sudo passwd root
Sorry, user oldboy is not allowed to execute '/usr/bin/passwd root' as root on stu412.
提示：非分之想均宣告失败



#解决命令找不到的问题
[oldboy@stu412 ~]$ cat .bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin:/usr/local/sbin:/usr/local/bin:/sbin:/usr/sbin:/root/bin
#后面是自己加的,考虑安全性，默认只要加/sbin:/usr/sbin就可以了
export PATH
[oldboy@stu412 ~]$ source .bash_profile
[oldboy@stu412 ~]$ echo $PATH
/data/jdk1.6.0_26/bin:/data/jdk1.6.0_26/jre/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/oldboy/bin:/home/oldboy/bin:/usr/local/sbin:/home/oldboy/bin:/usr/local/sbin:/home/oldboy/bin:/usr/local/sbin:/usr/local/bin:/sbin:/usr/sbin:/root/bin

[oldboy@stu412 ~]$ sudo userdel -r tmpuser11
[sudo] password for oldboy:
[oldboy@stu412 ~]$ tail -1 /etc/passwd	#删除用户成功
ett:x:1810:801::/home/ett:/bin/bash
[oldboy@stu412 ~]$ grep tmpuser11 /etc/passwd
[oldboy@stu412 ~]$



实例2：oldboy ALL=(root) /usr/sbin/useradd,/usr/sbin/userdel
对oldboy的授权规则更改为如下：
oldboy ALL=(root)       /usr/sbin/useradd,/usr/sbin/userdel
#上一行表示oldboy用户可以在所有的主机中，切换到root下执行useradd和userdel命令，和实例1的功能是等价的。

[oldboy@stu412 ~]$ sudo -l
[sudo] password for oldboy:
Matching Defaults entries for oldboy on this host:
requiretty, !visiblepw, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS MAIL PS1 PS2 QTDIR USERNAME LANG
LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME
LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"

User oldboy may run the following commands on this host:
(root) /usr/sbin/useradd, (root) /usr/sbin/userdel

#添加NOPASSWD:参数
oldboy ALL=(root)       NOPASSWD:/usr/sbin/useradd,/usr/sbin/userdel
[oldboy@stu412 ~]$ sudo -l
Matching Defaults entries for oldboy on this host:
requiretty, !visiblepw, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS MAIL PS1 PS2 QTDIR USERNAME LANG
LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME
LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"

User oldboy may run the following commands on this host:
(root) NOPASSWD: /usr/sbin/useradd, (root) /usr/sbin/userdel

#进一步修改
oldboy ALL=(ALL)        NOPASSWD:/usr/sbin/useradd,/usr/sbin/userdel
[oldboy@stu412 ~]$ sudo -l
Matching Defaults entries for oldboy on this host:
requiretty, !visiblepw, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS MAIL PS1 PS2 QTDIR USERNAME LANG
LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME
LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"

User oldboy may run the following commands on this host:
(ALL) NOPASSWD: /usr/sbin/useradd, (ALL) /usr/sbin/userdel

实例3：用户组的配置例子
%oldboy 	ALL=/usr/sbin/*,/sbin/*
#表示oldboy用户组下的所有成员，在所有的用户主机下，可以切换到root用户下运行/usr/sbin和/sbin目录下的所有命令。


实例4：练习禁止某个命令的执行
禁止某个命令的执行，要在命令前加上!号。
oldboy 	ALL=/usr/sbin/*,/sbin/*,!/sbin/fdisk
#oldboy用户在所有主机上可以执行/usr/sbin和/sbin下所有命令，但fdisk除外
[oldboy@stu412 ~]$ sudo -l
User oldboy may run the following commands on this host:
(root) /usr/sbin/*, (root) /sbin/*, (root) !/sbin/fdisk

[oldboy@stu412 ~]$ sudo fdisk –l	#fdisk操作是失败的
Sorry, user oldboy is not allowed to execute '/sbin/fdisk -l' as root on stu412.
[oldboy@stu412 ~]$ sudo /sbin/fdisk -l
Sorry, user oldboy is not allowed to execute '/sbin/fdisk -l' as root on stu412.

实例5：别名及授权规则综合实践例子（可应用到生产场景中）
假如我们就一台主机oldboy,能通过hostname来查看，并且有oldboy,ett,oldboy1,ett1等用户及oldboy用户组。
##User_Alias by oldboy##
User_Alias ADMINS = oldboy, ett, %oldboy
User_Alias NETADMINS = oldboy1, ett1
User_Alias USERADMINS = ett
User_Alias DISKADMINS = ett1

##Cmnd_Alias by oldboy##
Cmnd_Alias USERCMD = /usr/sbin/useradd, /usr/sbin/userdel, \
!/usr/bin/passwd, /usr/bin/passwd [A-za-z]*, /bin/chown, /bin/chmod, !/usr/bin/passwd root
#定义命令别名，允许执行useradd,userdel,chown,chmod,passwd 普通用户，但不允许passwd及passwd root命令
Cmnd_Alias DISKCMD = /sbin/fdisk, /sbin/parted
Cmnd_Alias NETCMD = /sbin/ifconfig, /etc/init.d/network
Cmnd_Alias CTRLCMD = /usr/sbin/reboot, /usr/sbin/halt

##Runas_Alias by oldboy##
Runas_Alias SUUER = root

ADMINS		ALL=(ALL)	USERCMD, NETCMD, CTRLCMD
NETADMINS	ALL=(SUUER)	NOPASSWD: NETCMD
DISKADMINS	ALL=(SUUER)	NOPASSWD: DISKCMD



删除掉注释后：
##User_Alias by oldboy##
User_Alias ADMINS = oldboy, ett, %oldboy
User_Alias NETADMINS = oldboy1, ett1
User_Alias USERADMINS = ett
User_Alias DISKADMINS = ett1

##Cmnd_Alias by oldboy##
Cmnd_Alias USERCMD = /usr/sbin/useradd, /usr/sbin/userdel, \
!/usr/bin/passwd, /usr/bin/passwd [A-za-z]*, /bin/chown, /bin/chmod, !/usr/bin/passwd root
Cmnd_Alias DISKCMD = /sbin/fdisk, /sbin/parted
Cmnd_Alias NETCMD = /sbin/ifconfig, /etc/init.d/network
Cmnd_Alias CTRLCMD = /usr/sbin/reboot, /usr/sbin/halt

##Runas_Alias by oldboy##
Runas_Alias SUUER = root

ADMINS		ALL=(ALL)	USERCMD, NETCMD, CTRLCMD
NETADMINS	ALL=(SUUER)	NOPASSWD: NETCMD
DISKADMINS	ALL=(SUUER)	NOPASSWD: DISKCMD

注意事项：
(1)	授权规则中的所有ALL字符串必须是大写字母。
(2)	Cmnnd_alias USERCMD=/user/sbin/useradd,/usr/sbin/userdel,\
!/usr/bin/passwd,/usr/bin/passwd[A-Za-z]*,/bin/chown,/bin/chmod,!/user/bin/passwd root
允许执行的命令是有顺序的。从测试的结果来看，命令的顺序是从后向前的，即把允许执行的命令放在禁止命令的后面。如!/user/bin/passwd,/user/bin/passwd [A-Za-z]*前面的为禁止，后面的为允许。
(3)	一行内容长度超长可以用"\"斜线换行。
(4)	"!"叹号表示非，就是命令取反的意思即禁止执行的命令。

#测试上面配置是否正确！
[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ sudo -l
User oldboy may run the following commands on this host:
(ALL) /usr/sbin/useradd, /usr/sbin/userdel, !/usr/bin/passwd, /usr/bin/passwd [A-za-z]*, /bin/chown, /bin/chmod, !/usr/bin/passwd root,
(ALL) /sbin/ifconfig, /etc/init.d/network, (ALL) /usr/sbin/reboot, /usr/sbin/halt
[oldboy@stu412 ~]$ sudo useradd oldboy55	#添加用户成功
[oldboy@stu412 ~]$ tail -1 /etc/passwd
oldboy55:x:1813:1813::/home/oldboy55:/bin/bash
[oldboy@stu412 ~]$ sudo userdel -r oldboy55
[oldboy@stu412 ~]$ tail -1 /etc/passwd
oldboy1:x:1812:1812::/home/oldboy1:/bin/bash
[oldboy@stu412 ~]$
[oldboy@stu412 ~]$ sudo passwd				#不能修改自己的密码
Sorry, user oldboy is not allowed to execute '/usr/bin/passwd' as root on stu412.

[oldboy@stu412 ~]$ sudo passwd ett1			#可以修改ett1的密码
Changing password for user ett1.
New UNIX password:
BAD PASSWORD: it does not contain enough DIFFERENT characters
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
[oldboy@stu412 ~]$ sudo passwd root		#不能修改root的密码
Sorry, user oldboy is not allowed to execute '/usr/bin/passwd root' as root on stu412.
[oldboy@stu412 ~]$ sudo ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:00:19:DF  
inet addr:192.168.65.128  Bcast:192.168.65.255  Mask:255.255.255.0
UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
RX packets:6581 errors:0 dropped:0 overruns:0 frame:0
TX packets:5352 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:647670 (632.4 KiB)  TX bytes:683724 (667.6 KiB)
Interrupt:67 Base address:0x2000


[root@stu412 ~]# su - ett1
[ett1@stu412 ~]$ sudo -l
User ett1 may run the following commands on this host:
(root) NOPASSWD: /sbin/ifconfig, /etc/init.d/network
(root) NOPASSWD: /sbin/fdisk, /sbin/parted


在不透漏root密码的情况下（同时禁止用户修改root密码，禁止修改/etc/sudoers,禁止su等），很好的实现对系统用户精细的权限控制，在实际的生产环境中，我们需要根据实际需求，综合运用。
```
# 2.	远程执行sudo命令
在默认情况下，我们是无法通过ssh远程执行sudo命令的。
```
#
# Disable "ssh hostname sudo <cmd>", because it will show the password in clear.
#         You have to run "ssh -t hostname sudo <cmd>".
#
Defaults    requiretty

根据注释我们知道，这个“Defaults requiretty”就是禁止我们通过ssh执行duso命令的明确配置。但是禁止执行的远程ssh sudo命令格式为”ssh hostname sudo <cmd>”，原因是因为会显示明文密码。但是我们可以通过”ssh –t hostname sudo <cmd>”的方式来执行。
#man ssh
-t      Force pseudo-tty allocation.  This can be used to execute arbitrary screen-based programs on a remote machine,which can be very useful, e.g., when implementing menu services.  Multiple -t options force tty allocation, even if ssh has no local tty.

[root@stu412 ~]# ssh oldboy@192.168.65.128 sudo -l
oldboy@192.168.65.128's password:
sudo: sorry, you must have a tty to run sudo
[root@stu412 ~]# ssh -t oldboy@192.168.65.128 sudo -l
oldboy@192.168.65.128's password: 	#要输入两次oldboy密码
[sudo] password for oldboy:
Matching Defaults entries for oldboy on this host:
requiretty, !visiblepw, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS MAIL PS1 PS2 QTDIR USERNAME LANG
LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME
LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"

User oldboy may run the following commands on this host:
(ALL) /usr/sbin/useradd, /usr/sbin/userdel, !/usr/bin/passwd, /usr/bin/passwd [A-za-z]*, /bin/chown, /bin/chmod, !/usr/bin/passwd root,
(ALL) /sbin/ifconfig, /etc/init.d/network, (ALL) /usr/sbin/reboot, /usr/sbin/halt
Connection to 192.168.65.128 closed.
[root@stu412 ~]# ssh -t oldboy@192.168.65.128 sudo useradd old123
oldboy@192.168.65.128's password:
sudo: useradd: command not found	#命令找不到，要加全部路径！
Connection to 192.168.65.128 closed.
[root@stu412 ~]# ssh -t oldboy@192.168.65.128 sudo /usr/sbin/useradd old123
oldboy@192.168.65.128's password:
Connection to 192.168.65.128 closed.

使用ssh的方式远程执行sudo权限的功能在后面的ssh key + rsync远程批量管理的课程讲理中有很大的妙用。
```

# 3.	配置sudo命令日志审计
## 3.1.	安装sudo,syslog命令服务(默认已安装)
yum install –y sudo syslog
## 3.2.	配置系统日志/etc/ssylog.conf
```
[root@stu412 ~]# echo "local2.debug /var/log/sudo.log">>/etc/syslog.conf
[root@stu412 ~]# tail -1 /etc/syslog.conf
local2.debug /var/log/sudo.log
```
## 3.3.	配置/etc/sudoers
```
[root@stu412 ~]# echo "Defaults logfile=/var/log/sudo.log">>/etc/sudoers
[root@stu412 ~]# tail -1 /etc/sudoers
Defaults logfile=/var/log/sudo.log
[root@stu412 ~]# visudo -c
visudo: Warning: unused User_Alias USERADMINS
/etc/sudoers: parsed OK  
## 3.4.	重启syslog内核日志
[root@stu412 ~]# /etc/init.d/syslog restart
Shutting down kernel logger: [  OK  ]
Shutting down system logger: [  OK  ]
Starting system logger: [  OK  ]
Starting kernel logger: [  OK  ]
#此时会自动建立一个/var/log/sudo.log文件，且文件权限为600，所有者和组均为root
[root@stu412 ~]# ls -l /var/log/sudo.log
-rw------- 1 root root 0 Jul 11 22:11 /var/log/sudo.log
```
## 3.5.	测试sudo日志审计配置结果
```
进行相关sudo操作后，查看相应的sudo的日志文件/var/log/sudo.log
[root@stu412 ~]# su - oldboy
[oldboy@stu412 ~]$ whoami
oldboy
[oldboy@stu412 ~]$ sudo useradd abc
[sudo] password for oldboy:
[oldboy@stu412 ~]$ sudo userdel -r abc
[oldboy@stu412 ~]$ exit
logout
[root@stu412 ~]# cat /var/log/sudo.log
Jul 11 22:20:40 : oldboy : TTY=pts/0 ; PWD=/home/oldboy ; USER=root ;
COMMAND=/usr/sbin/useradd abc
Jul 11 22:20:54 : oldboy : TTY=pts/0 ; PWD=/home/oldboy ; USER=root ;
COMMAND=/usr/sbin/userdel -r abc
```