# Linux系统定时任务详解

最后更新：20150614 by qxl

# 1.	cron/crond/crontab说明

https://en.wikipedia.org/wiki/Cron

The software utility Cron is a time-based job scheduler in Unix-like computer operating systems.

Cron is driven by a crontab (cron table) file, a configuration file that specifies shell commands to run periodically on a given schedule. The crontab files are stored where the lists of jobs and other instructions to the cron daemon are kept. Users can have their own individual crontab files and often there is a system wide crontab file (usually in /etc or a subdirectory of /etc) that only system administrators can edit.

crontab命令用于设置周期性被执行的指令。该命令从标准输入设备读取指令，并将其存放于"crontab"文件中，以供之后读取和执行。

crontab储存的指令会被守护进程crond激活。 crond常常在后台运行，每一分钟检查是否有预定的作业(cron jobs)需要执行。crond会每分钟检查cron jobs配置，如果有变更，crond会自动reload配置。所以不需要重启crond。

crond是linux系统中定期执行命令或指定程序任务的服务,通过/etc/init.d/crond进行启动。


# 2.	安装服务
## 2.1.	环境说明
针对环境
```
# centos5.8 x86_64
[root@c5 ~]# cat /etc/redhat-release
CentOS release 5.8 (Final)
[root@c5 ~]# uname -ri
2.6.18-308.el5 x86_64

# centos6.6 x86_64
[root@c6 ~]# cat /etc/redhat-release
CentOS release 6.6 (Final)
[root@c6 ~]# uname -ri
2.6.32-504.el6.x86_64 x86_64
```
主机名c5代表centos5.8系统主机。

主机名c6代表centos6.6系统主机。

## 2.2.	安装过程
```
yum -y install vixie-cron
chkconfig --list crond
chkconfig --add crond
chkconfig crond on
chkconfig --list crond
```
# yum卸载命令(慎用)
```
yum -y remove vixie-cron
```
需要确认服务是启动状态(running)，并随开机启动的(3:on)。
```
[root@c5 ~]# chkconfig --list | grep crond
crond           0:off   1:off   2:on    3:on    4:on    5:on    6:off
#服务上需要保证启动级别3是on状态

[root@c5 ~]# /etc/init.d/crond status		#服务状态
crond (pid  3006) is running...
[root@c5 ~]# /etc/init.d/crond restart		#服务重起
Stopping crond: [  OK  ]
Starting crond: [  OK  ]
```
# 3.	基础介绍
## 3.1.	crontab指令语法
      crontab [ -u user] file
      crontab [ -u user] { -l | –r | -e }

## 3.2.	crontab指令说明
通过crontab我们可以在固定的间隔时间执行指定的系统指令或shell脚本。时间间隔单位可以是分钟、小时、日、月、周及以上任意组合。这个命令非常适合周期性日志分析或数据备份等工作。

## 3.3.	使用者权限文件
```
/etc/cron.deny 	文件中所列用户不允许使用crontab命令
/etc/cron.allow	文件中所列用户可以使用crontab命令（此文件默认是不存在）
/var/spool/cron/ 所有用户crontab文件存放的目录，以用户名命名。
```
按优先级来说，/etc/cron.allow比/etc/cron.deny优先。默认情况下，任何用户只要不被列入/etc/cron.deny中，就可以直接执行"crontab -e"编辑自己的定时任务命令。

将用户列入/etc/cron.deny后，此用户下已经定义的定时任务还会继续执行。

如果/etc/cron.deny和/etc/cron.allow都不存在,那只有超级管理员才能使用crontab命令。
```
#将u1列入禁止名单
[root@c5 ~]# cat /etc/cron.deny
u1

#切换到u1后执行
[u1@c5 ~]$ crontab -e
You (u1) are not allowed to use this program (crontab)
See crontab(1) for more information
[u1@c5 ~]$ crontab -l
You (u1) are not allowed to use this program (crontab)
See crontab(1) for more information


/var/spool/cron/里crontab文件的存在，让我们不通过crontab –e的交互命令就可以通过shell脚本配置自动调度。

示例：服务器安装后优化部分shell脚本：
#设置系统时间同步
yum -y install ntp
echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com>/dev/null 2>&1'>>/var/spool/cron/root

/etc/init.d/crond start


[root@c5 ~]# ll /var/spool/cron/
total 4
-rw------- 1 root root 62 Jun 14 09:40 root
[root@c5 ~]# cat /var/spool/cron/root
*/5 * * * * /usr/sbin/ntpdate time.windows.com>/dev/null 2>&1
```
## 3.4.	指令选项说明含义表
```
参数名	含义	示例
-l (是字母)	显示用户crontab文件内容 , --list	crontab -l
-e	进入vi编辑用户crontab文件 	crontab -e
-i	删除用户crontab文件前确认	crontab -ri
-r	删除用户crontab文件	crontab -r
-u user	指定使用者	crontab –u u1 -l

[root@c5 ~]# crontab -u u1 -l
no crontab for u1
```
## 3.5.	crontab时间段的含义
```
*/5 * * * * /usr/sbin/ntpdate time.windows.com

# 文件格式说明
#  ——分钟 (0 - 59)
# |  ——小时 (0 - 23)
# | |  ——日   (1 - 31)
# | | |  ——月   (1 - 12)
# | | | |  ——星期 (0 - 7)（星期日=0或7）
# | | | | |
# * * * * * 被执行的命令

段	含义	取值范围
1	代表分钟	00-59
2	代表小时	00-23
3	代表日期	01-31
4	代表月份	01-12
5	代表星期,0和7代表星期日	0-7
```
## 3.6.	特殊符号含义
```
特殊字符	含义
*	表示任意时间。00 23 * * * command 表示无论何月何日何周的23:00都执行任务。
-	减号，表示分割符，表示一个时间段，如17-19点，每小时的00分执行任务。
     00 17-19 * * * command
     ,	逗号，表示分割时段的意思。30 17,18,19 * * * command
     每天的17,18,19点的30分执行命令command。
     /n	n代表数字，即"每隔n单位时间"。如每10分钟执行一次任务：*/10 * * * command,
     其中,*/10也可以写成0-59/10。
```
## 3.7.	crontab配置文件
### 3.7.1.	/var/spool/cron/{user}
```
默认情况下，用户建立的crontab文件存在于/var/spool/cron中,其中crontab对应的文件与用户名一致。
[root@c5 ~]# ll /var/spool/cron
total 12
-rw------- 1 root root 298 Jun 17 21:56 root
-rw------- 1 root root  56 Jun 18 23:12 u1
-rw------- 1 root root  56 Jun 18 23:12 u2
# root,u1,u2都有定义定时任务

# 用户u1的cron job的定义
[root@c5 ~]# cat /var/spool/cron/u1
* * * * * /bin/sh /home/u2/echo_date.sh >/dev/null 2>&1
```
### 3.7.2.	/etc/crontab
```
#centos5.x
[root@c5 ~]# cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/

# run-parts
01 * * * * root run-parts /etc/cron.hourly
02 4 * * * root run-parts /etc/cron.daily
22 4 * * 0 root run-parts /etc/cron.weekly
42 4 1 * * root run-parts /etc/cron.monthly

# run-parts 这是/etc/crontab默认定义的四项工作任务，分别以每小时、每周、每天、每月进行一次的工作。系统默认的例行性工作是以root身份来执行的。
[root@c5 ~]# ls /etc/cron.daily
0anacron  0logwatch  logrotate	makewhatis.cron  mlocate.cron  prelink	rpm  tmpwatch
#上面scripts会在每天凌晨4:02开始运行

#centos6.x
[root@c6 cron]# cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

直接写入：适用于centos5.x和centos6.x
[root@c6 ~]# echo "* * * * * u1 /bin/sh /home/u1/echo_date.sh >/dev/null 2>&1">>/etc/crontab
[root@c6 ~]# tail -1 /etc/crontab
* * * * * u1 /bin/sh /home/u1/echo_date.sh >/dev/null 2>&1

格式共分为七段，前五段为时间指定段（分时日月周），第六段为哪个用户执行crontab命令（默认是当前用户），第七段为所要执行的命令段。
格式如下：
01 * * * * root command
00 4 * * * root command		#每天凌晨4点执行command命令
```
### 3.7.3.	/etc/cron.{daily,weekly,monthly}相关目录
```
cron.daily  	#每天执行
cron.hourly 	#每小时执行
cron.monthly	#每月执行
cron.weekly	#每周执行

注意：
centos5.x的/etc/crontab中有上述文件的执行定义。
Centos6.x的都定义在 /etc/anacrontab 中,使用anacron执行。

anacron并不能指定何时执行某任务，而是以天为单位或者是开机后立刻执行进行anacron的操作，她会检测停机期间应该进行但没有进行的crontab任务，并将该任务执行一遍，然后anacron就会自动停止了。

# man  crontabs
Historically the crontab file contained configuration which called run-parts on files in cron.{daily,weekly,monthly} directories. These jobs are  now  run
indirectly  through anacron to prevent conflicts between cron and anacron.  That means the anacron package has to be installed if the jobs in these direc-
tories should be running. Refer to the anacron(8) how to limit the time of day of the job execution.


#man  anacrontab
/etc/anacrontab - configuration file for anacron

[root@c6 ~]# cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
1	5	cron.daily		nice run-parts /etc/cron.daily
7	25	cron.weekly		nice run-parts /etc/cron.weekly
@monthly 45	cron.monthly		nice run-parts /etc/cron.monthly

# 在/etc/cron.d/0hourly中有hourly调度的定义
[root@c6 ~]# cat /etc/cron.d/0hourly
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/
01 * * * * root run-parts /etc/cron.hourly
```


## 3.8.	总结：定义cron jobs的5种方式

### 1)	crontab –e 编辑(常用)
```
      以交互形式编写自动调度。
      推荐这种方式，原因：
      (1)	并不每个人都有root权限，普通用户使用crontab –e也能编辑自动的调度命令。
      (2)	crontab –e编辑保存时，如果格式错误会有提示。
      [root@c5 ~]# crontab -e
      crontab: installing new crontab
      "/tmp/crontab.XXXXzGCW7G":10: bad command
      errors in crontab file, can't install.
      Do you want to retry the same edit?
```
### 2)	/var/spool/cron/{user} (主要用于shell脚本生成定时调度)

如以前我在执行pxe+dhcp+nfs+kickstart无人值守批量安装centos后，会执行一些系统优化脚本。脚本里会设置一些定时调度任务(如时间同步)。
```
#设置系统时间同步
yum -y install ntp
echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com>/dev/null 2>&1'>>/var/spool/cron/root
```

### 3)	/etc/crontab (较少用)
```
      直接在里面编写定时调度。需要管理员权限。
      如：
      [root@c5 ~]# cat /etc/crontab
      SHELL=/bin/bash
      PATH=/sbin:/bin:/usr/sbin:/usr/bin
      MAILTO=root
      HOME=/

# run-parts
01 * * * * root run-parts /etc/cron.hourly
02 4 * * * root run-parts /etc/cron.daily
22 4 * * 0 root run-parts /etc/cron.weekly
42 4 1 * * root run-parts /etc/cron.monthly

* * * * * u1 /bin/sh /home/u1/echo_date.sh >/dev/null 2>&1    #自定义的jobs
*/20 * * * * root run-parts /etc/cron.myjobs
注意：需要指定执行命令的用户。
```

### 4)	/etc/cron.{houry,daily,weekly,monthly} 目录
```
注意：里面存储的脚本必须有可执行权限。
[root@c5 ~]# ll /etc/cron.hourly/
total 12
-rwxr--r-- 1 root root 147 Jun 14 17:13 echo_date_hourly.sh
# x 标志位就表示属主root有可执行权限。
-rwxr-xr-x 1 root root 390 May 19  2011 mcelog.cron
[root@c5 ~]# cat /etc/cron.hourly/echo_date_hourly.sh
#!/bin/bash
# crontab test
# echo date
# Date:   2015-06-14
# Author: xionglie.qu

echo `date "+%Y-%m-%d %H:%M:%S"` >>/root/echo_date_hourly.log

#测试：
[root@c5 ~]# chmod 644 /etc/cron.hourly/echo_date_hourly.sh
[root@c5 ~]# ll  /etc/cron.hourly/echo_date_hourly.sh
-rw-r--r-- 1 root root 147 Jun 14 17:13 /etc/cron.hourly/echo_date_hourly.sh
[root@c5 ~]# date -s '2015-06-18 23:00:00'		#设置时间
Thu Jun 18 23:00:00 CST 2015
[root@c5 ~]# cat /root/echo_date_hourly.log		#没有输出结果
cat: /root/echo_date_hourly.log: No such file or directory

[root@c5 ~]# date
Thu Jun 18 23:01:32 CST 2015
[root@c5 ~]# cat /root/echo_date_hourly.log		#到了23:01:32，没有输出结果
cat: /root/echo_date_hourly.log: No such file or directory


#设置可执行权限，重新测试
[root@c5 ~]# ll  /etc/cron.hourly/echo_date_hourly.sh
-rw-r--r-- 1 root root 147 Jun 14 17:13 /etc/cron.hourly/echo_date_hourly.sh
[root@c5 ~]# chmod u+x /etc/cron.hourly/echo_date_hourly.sh #设置可执行权限
[root@c5 ~]# ll  /etc/cron.hourly/echo_date_hourly.sh
-rwxr--r-- 1 root root 147 Jun 14 17:13 /etc/cron.hourly/echo_date_hourly.sh
[root@c5 ~]# date -s '2015-06-18 23:00:00'	 #设置时间
Thu Jun 18 23:00:00 CST 2015
[root@c5 ~]# cat /root/echo_date_hourly.log #等待1分钟后，看到了输出结果
2015-06-18 23:01:01
```
### 5)	/etc/cron.d目录
```
centos5:
[root@c5 ~]# ls -l /etc/cron.d
total 0

centos6:
[root@c6 ~]# ls -l /etc/cron.d
total 12
-rw-r--r--. 1 root root 113 Nov 23  2013 0hourly
-rw-------. 1 root root 108 Sep  5  2014 raid-check
-rw-------. 1 root root 235 Oct 16  2014 sysstat
[root@c6 ~]# cat /etc/cron.d/0hourly
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/
01 * * * * root run-parts /etc/cron.hourly
```
# 4.	实例说明
```
* * * * * /bin/sh /server/scripts/echo_date.sh
每隔1分钟执行命令/server/scripts/echo_date.sh

其它例子
(1)	30 3,12 * * *  /bin/sh /server/scripts/echo_date.sh
每天凌晨3点半和中午12点半执行任务。

(2)	30 */6 * * * /bin/sh /server/scripts/echo_date.sh
每隔6小时的半点执行任务。

(3)	30 8-18/2 * * * /bin/sh /server/scripts/echo_date.sh
早晨的8点到下午18点之间每两个小时的半点执行任务。

(4)	30 21 * * * /app/apache/bin/apachectl graceful
每晚21:30重启apache。

(5)	45 4 1,10,22 * * * /app/apache/bin/apachectl graceful
每月1、10、22日的凌晨4:45分重启apache。

(6)	10 1 * * 6,0 /app/apache/bin/apachectl graceful
每周六、周日的凌晨1:10分重启apache。

(7)	0,30 18-23 * * * /app/apache/bin/apachectl graceful
每天18点至23点之间每隔30分钟重启apache。
最后一次执行任务是23:30分。

(8)	00 */1 * * * /app/apache/bin/apachectl graceful
每隔1小时的整点重启apache.

(9)	* 23-7/1 * * * /app/apache/bin/apachectl graceful
每天晚上23点到早上7点之间，每隔1小时重启apache
提示：上面结果不对？
定时任务的每一列为*,表示每分钟(23点-7点)都执行任务。很可怕！

(10)	0 11 * 4 1-3 /app/apache/bin/apachectl graceful
4月的每周一到周三的11点重启apache。
```
# 5.	进阶
## 5.1.	crontab命令生产环境专业写法
```
例2：每周六日上午9:00和下午14:00执行脚本 (/server/script/test.sh)
答案：
#cron job for test by xionglie.qu 2015-06-14
00 09,14 * * 6,0 /bin/sh /server/script/test.sh >/dev/null 2>&1
```
```
说明: (非常重要)
(1)	写定时任务要写清楚注释,这是个好习惯。如什么人，什么时间，因为谁，做了什么事。都标记清楚了，这样其他维护人员可以很容易理解。如果是开发的任务一定要写上需求人。
(2)	尽量将任务写到单独的脚本中。在执行脚本时，尽量带上/bin/sh,否则有可能因为脚本没有执行权限而无法执行。
(3)	需要root权限的任务可以登陆到root用户下设置，如果不需要root权限，可能登陆到普通用户下，然后设置。这里要特别注意不同用户的环境变量问题，如果是调用了环境变量（如生产环境的java脚本），此时最好在脚本中将环境变量重新export下。
(4)	定时任务命令的结尾最好加上>/dev/null 2>&1等内容，如果要打印日志，可以追加到指定的日志里，不推荐留空这种不专业的写法。如果定时任务不加>/dev/null 2>&1等命令设置，时间长了，可能会导致邮件临时目录/var/spool/clientmqueue 文件数猛增，占用大量磁盘inode节点。
(5)	在开发定时任务或脚本时，在调试好脚本程序后，尽量把DEBUG及屏幕输出的内容的命令去掉，如果还需要，可定向到日志中。
```

磁盘塞满的原因：

那是因为当cron执行时，会将相关结果以mail传送给执行身份的帐号。但当sendmail没有启动时，所有信件就会暂存在/var/spool/clientmqueue这个目录。时间一长,硬盘就爆掉了。
出现问题时检查：
```
/var/spool/clientmqueue
/var/spool/mail/{用户名}
```

centos5测试：
```
[root@c5 clientmqueue]# crontab -l
#*/5 * * * * /usr/sbin/ntpdate time.windows.com>/dev/null 2>&1
*/2 * * * * /usr/sbin/ntpdate time.windows.com
[root@c5 ~]# /etc/init.d/sendmail stop
Shutting down sm-client:                                   [  OK  ]
Shutting down sendmail:                                    [  OK  ]
[root@c5 ~]# /etc/init.d/sendmail status
sendmail is stopped
[root@c5 ~]# ll /var/spool/clientmqueue
total 8
-rw-rw---- 1 smmsp smmsp  85 Jun 14 19:06 dft5EB645t025399
-rw-rw---- 1 smmsp smmsp 881 Jun 14 19:06 qft5EB645t025399
[root@c5 ~]# cat /var/spool/clientmqueue/qft5EB645t025399
V8
T1434279964
K1434279964
N1
P30387
MDeferred: Connection refused by [127.0.0.1]
Fbs
$_root@localhost
${daemon_flags}c u
Sroot
Aroot@localhost.localdomain
MDeferred: Connection refused by [127.0.0.1]
C:root
rRFC822; root@localhost.localdomain
RPFD:root
H?P?Return-Path: <�g>
H??Received: (from root@localhost)
by localhost.localdomain (8.13.8/8.13.8/Submit) id t5EB645t025399;
Sun, 14 Jun 2015 19:06:04 +0800
H?D?Date: Sun, 14 Jun 2015 19:06:04 +0800
H?x?Full-Name: CronDaemon
H?M?Message-Id: <201506141106.t5EB645t025399@localhost.localdomain>
H??From: root (Cron Daemon)
H??To: root
H??Subject: Cron <root@c5> /usr/sbin/ntpdate time.windows.com
H??Content-Type: text/plain; charset=UTF-8
H??Auto-Submitted: auto-generated
H??X-Cron-Env: <SHELL=/bin/sh>
H??X-Cron-Env: <HOME=/root>
H??X-Cron-Env: <PATH=/usr/bin:/bin>
H??X-Cron-Env: <LOGNAME=root>
H??X-Cron-Env: <USER=root>
.
[root@c5 ~]# cat /var/spool/clientmqueue/dft5EB645t025399
14 Jun 19:06:04 ntpdate[25395]: adjust time server 23.101.187.68 offset 0.060237 sec
[root@c5 ~]# head /var/spool/mail/root
From MAILER-DAEMON@localhost.localdomain  Sun Jun 14 10:21:07 2015
Return-Path: <MAILER-DAEMON@localhost.localdomain>
Received: from localhost.localdomain (n1 [127.0.0.1])
by localhost.localdomain (8.13.8/8.13.8) with ESMTP id t5E2L7Yp004587
for <root@localhost.localdomain>; Sun, 14 Jun 2015 10:21:07 +0800
Received: from localhost (localhost)
by localhost.localdomain (8.13.8/8.13.8/Submit) id t5E2L6gF004585;
Sun, 14 Jun 2015 10:21:07 +0800
Date: Sun, 14 Jun 2015 10:21:07 +0800
From: Mail Delivery Subsystem <MAILER-DAEMON@localhost.localdomain>
```
centos6有点区别，因为sendmail并不是服务，/var/spool/clientmqueue不存在，但/var/spool/mail/root也会慢慢增大。

## 5.2.	crontab生产解决案例
### 案例1：No space left on device 故障1
```
df –i检查还有空间，df –i 显示var已占用100%,如果inode耗尽，则系统上不能创建文件。
原因：系统中cron执行的程序有输出内容，输出内容会以邮件形式发给cron的用户，而sendmail没有启动所以就产生了这些文件。
解决方法：开启邮件服务，并将crontab里面的命令后面加上>/dev/null 2>&1,在做定时脚本时，把屏幕输出定向到日志中。

[root@c6 ~]# df -i
Filesystem     Inodes IUsed  IFree IUse% Mounted on
/dev/sda2      610800 51416 559384    9% /
tmpfs          125544     1 125543    1% /dev/shm
/dev/sda1       51200    38  51162    1% /boot

Inodes		inode总数
IUsed  	已使用的inode数
IFree		剩余的inode数
```
## 5.3.	定时调度要注意的问题
```
使用crontab需要注意的问题汇总
1.export变量问题
crontab执行shell时只能识别为数不多的系统环境变量，普通变量是无法识别的，如果在编写的脚本中需要使用变量，最好使用export重新声明下该变量，脚本才能正常执行。

2.任务路径问题
crontab执行shell时，如果shell路径是相对路径或shell里含有相对路径，此时就会找不到任务路径，因此，在shell脚本中调用脚本或定时任务调用的脚本都要使用绝对路径。

3.脚本权限问题
要确保crontab的执行者有访问shell脚本所在目录并且执行此shell脚本的权限（可用chmod和chown修改脚本权限和所有者）。当然，最佳方法是执行脚本前加/bin/sh执行测试下。在配置任务执行脚本时，可以省略当前用户配置，但最好带上/bin/sh，否则有可能因为忘了为脚本设定执行权限，而无法完成任务。本条是一个经验型的好习惯。

4.时间变量问题
"%"号在crontab任务中被认为是newline，需要要用\来转义。crontab任务命令中，如果有"date +%Y%m%d"，必须替换为："date +\%Y\%m\%d"，但写在脚本中就不需要了。

5.>/dev/null 2>&1问题
当任务在你所指定的时间执行后，系统会寄一封信给你，显示该程式执行的内容，若系统未开启邮件服务就会导致邮件临时目录碎文件逐渐增多，以至于大量消耗inode数量，其实，可在每一行任务结尾空一格之后加上> /dev/null 2>&1 或1>/dev/null 2>/dev/null将输出定向为空来规避这个问题。
如果需要打印日志输出，也可以追加到指定的日志文件里，尽量不要留空。如果任务本身是命令的话，添加>/dev/null 2>&1时要慎重，需多测试并且有检查手段。如：*/1 * * * * echo "==" >> /tmp/echo.log >/dev/null 2>&1，该任务规则就是无法执行的。
说明：/dev/null 为特殊的设备，表示黑洞设备或空设备。2>&1表示让标准错误和标准输出一样都定向到空设备，本命令内容就是把脚本的输出重定向到/dev/null，即不记录任何输出，也不给系统管理员发邮件。
如果定时任务程序或命令结尾不加">/dev/null 2>&1"等命令配置，如果任务出错或有大量输出信息，时间长了，可能由于系统未开始邮件服务而导致邮件临时目录/var/spool/clientmqueue内文件数越来越多，结果会占用大量磁盘inode节点，如果磁盘inode被写满，就无法在写入正常数据了。很多人都已经发生过血的教训了。
特别提示：/var/spool/clientmqueue目录的清理工作可以作为Linux系统优化的一个点。比如定时清理30天前的该目录下的文件。
如清理清理命令find /var/spool/clientmqueue/ -type f -mtime +30|xargs rm -f（定时任务格式写法就留给大家了）。
提示：上面的>/dev/null 2>&1写法也可以写成1>/dev/null 2>/dev/null ，例： $JAVA -jar $RESIN_HOME/lib/resin.jar $ARGS stop 1>/dev/null 2>/dev/null，此写法来自resin服务默认启动脚本。

6.定时任务加注释
写定时任务规则时要加上注释,这是个好习惯。如：什么人，什么时间，因为谁，做了什么事都标记清楚了，这样其他的维护人员就可以很容易理解。

7.使用脚本程序替代命令
使用脚本执行任务可以让我们少犯错误，提升效率、规范，是个好习惯。定时任务中执行命令有一些限制，如时间变量问题，多个重定向命令混用问题等。

8.避免不必要的程序输出
在开发定时任务程序或脚本时，在调试好脚本程序后，应尽量把DEBUG及命令输出的内容信息屏蔽掉，如果还需要，可定向到指定日志文件里，以免产生多余的系统垃圾。
```
# 6.	实战

# 6.1.	例子
```
1.每隔1分钟，打印一个+号到app.log ,请给出crontab完整命令。
解答：

2.每隔5分钟将/etc/services文件打包备份到/tmp下（最好每次备份成不同的备份包）。
解答：

3.每天晚上12点，打包站点目录/var/www/html 备份到/data目录下（最好每次备份按时间生成不同的备份包）
解答：
```
# 6.2.	参考答案
```
1.每隔1分钟，打印一个+号到app.log ,请给出crontab完整命令。
解答：
命令：
echo '#print a "+" every min by quxl ,2015-06-15'>>/var/spool/cron/root
echo '*/1 * * * * echo + >>/tmp/app.log'>>/var/spool/cron/root
crontab -l | tail -2
tail -f /tmp/app.log

echo '#!bin/sh' >>/tmp/echo.sh
echo 'echo + >>/tmp/app.log' >>/tmp/echo.sh
cat /tmp/echo.sh
echo '#print a "+" every min by quxl 2015-06-15'>>/var/spool/cron/root
echo '*/1 * * * * /bin/sh /tmp/echo.sh >/dev/null 2>&1' >>/var/spool/cron/root
tail -2 /var/spool/cron/root
tail -f /tmp/app.log

过程：
方法1：直接写到指定的配置文件，适合命令行或脚本中使用，无需和系统交互。
[root@c5 ~]# echo '#print a "+" every min by quxl ,2015-06-15'>>/var/spool/cron/root
[root@c5 ~]# echo '*/1 * * * * echo + >>/tmp/app.log'>>/var/spool/cron/root
[root@c5 ~]# crontab -l | tail -2
#print a "+" every min by quxl ,2015-06-15
*/1 * * * * echo + >>/tmp/app.log
[root@c5 ~]# tail -f /tmp/app.log
+
+
说明：1代表标准输出，2代表错误信息输出。
>/dev/null将标准输出定向到空设备；
2>&1 , 将错误定向到和1一样的输出设备。
>/dev/null 2>&1 表示禁止打印输出到屏幕。

方法2：把执行命令放在文件中以脚本的方式执行（工作环境常用）
[root@c5 ~]# echo '#!/bin/sh' >>/tmp/echo.sh
[root@c5 ~]# echo 'echo + >>/tmp/app.log' >>/tmp/echo.sh
[root@c5 ~]# cat /tmp/echo.sh
#!/bin/sh
echo + >>/tmp/app.log
[root@c5 ~]# echo '#print a "+" every min by quxl 2015-06-15'>>/var/spool/cron/root
[root@c5 ~]# echo '*/1 * * * * /bin/sh /tmp/echo.sh >/dev/null 2>&1' >>/var/spool/cron/root
[root@c5 ~]# tail -2 /var/spool/cron/root
#print a "+" every min by quxl 2015-06-15
*/1 * * * * /bin/sh /tmp/echo.sh >/dev/null 2>&1
[root@c5 ~]#
[root@c5 ~]# tail -f /tmp/app.log
+
+
+
注意：
脚本执行要加上/bin/sh,以防止脚本无执行权限。
脚本执行最后要加上>/dev/null 2>&1
脚本中输出的日志要全路径。
错误的写法：
*/1 * * * * echo + >>/tmp/app.log >/dev/null 2>&1
echo后面的内容会当命令。

2.每隔5分钟将/etc/services文件打包备份到/tmp下（最好每次备份成不同的备份包）。
解答：
[root@c5 ~]# cat /tmp/tar.sh
#!/bin/sh
tar -zcpf /tmp/services_$(date +%Y%m%d%H%M).tar.gz /etc/services

[root@c5 ~]# tail -2 /var/spool/cron/root
#tar /etc/services by shell script by xionglie.qu at 2015-06-17
*/5 * * * * /bin/sh /tmp/tar.sh >/dev/null 2>&1
说明：
1)	定时任务后台打包，就没有必要使用v参数，加v是为了执行时给人看的！
2)	在不确定的情况下，不要加大P；
3)	带时间变量$(date +%Y%m%d%H%M)直接写在任务里，会导致定时任务无法执行。


# 测试：直接在crontab写tar命令
[root@c5 tmp]# tail -1 /var/spool/cron/root
*/1 * * * * tar -zcf /tmp/s_$(date +%Y%m%d%H%M).tar.gz /etc/services
#直接执行能打包,但定时任务是没有结果的
出错信息：
[root@c5 ~]# tail -30 /var/spool/mail/root
X-Cron-Env: <LOGNAME=root>
X-Cron-Env: <USER=root>

/bin/sh: -c: line 0: unexpected EOF while looking for matching `)'
/bin/sh: -c: line 1: syntax error: unexpected end of file

From root@localhost.localdomain  Wed Jun 17 21:26:01 2015
Return-Path: <root@localhost.localdomain>
Received: from localhost.localdomain (c5 [127.0.0.1])
by localhost.localdomain (8.13.8/8.13.8) with ESMTP id t5HDQ1tb003434
for <root@localhost.localdomain>; Wed, 17 Jun 2015 21:26:01 +0800
Received: (from root@localhost)
by localhost.localdomain (8.13.8/8.13.8/Submit) id t5HDQ17D003432;
Wed, 17 Jun 2015 21:26:01 +0800
Date: Wed, 17 Jun 2015 21:26:01 +0800
Message-Id: <201506171326.t5HDQ17D003432@localhost.localdomain>
From: root@localhost.localdomain (Cron Daemon)
To: root@localhost.localdomain
Subject: Cron <root@c5> tar -zcf /tmp/s_$(date +
Content-Type: text/plain; charset=UTF-8
Auto-Submitted: auto-generated
X-Cron-Env: <SHELL=/bin/sh>
X-Cron-Env: <HOME=/root>
X-Cron-Env: <PATH=/usr/bin:/bin>
X-Cron-Env: <LOGNAME=root>
X-Cron-Env: <USER=root>

/bin/sh: -c: line 0: unexpected EOF while looking for matching `)'
/bin/sh: -c: line 1: syntax error: unexpected end of file
说明：
1)	$(date +%Y%m%d%H%M)为date命令的用法，表示按分钟打不同的包。写法有$()或``反引号，直接放在文件名即可。
2)	如果是按分钟打包，时间变量必须要精确到分，否则过一段时间包就会被覆盖。
3)	记得查看服务日志；

执行crontab –l查看设置结果。
watch ls –l /tmp 持续查看备份变化情况。

[root@c5 ~]# watch ls -l /tmp
Every 2.0s: ls -l /tmp                                                                                                                                       Wed Jun 17 21:11:43 2015

total 528
-rw-r--r-- 1 root root     0 Jun 15 07:00 app.log
-rw-r--r-- 1 root root    31 Jun 15 06:57 echo.sh
-rw-r--r-- 1 root root 99009 Jun 17 21:00 s_201506172100.tar.gz
-rw-r--r-- 1 root root 99009 Jun 17 20:56 services_201506172056.tar.gz
-rw-r--r-- 1 root root 99009 Jun 17 21:00 services_201506172100.tar.gz
-rw-r--r-- 1 root root 99009 Jun 17 21:05 services_201506172105.tar.gz
-rw-r--r-- 1 root root 99009 Jun 17 21:10 services_201506172110.tar.gz
-rw-r--r-- 1 root root    77 Jun 17 20:55 tar.sh

3.每天晚上12点，打包站点目录/var/www/html 备份到/data目录下
解答：
命令脚本：
[root@c5 tmp]# cat tar_site.sh
#!/bin/bash
cd /var/www && tar -czf /data/html_`date +%F`.tar.gz ./html
定时设置：
# tar /var/www/html by xionglie.qu at 2015-06-17
0  0 * * * /bin/sh /tmp/tar_site.sh >/dev/null 2>&1
```
## 6.3.	生产环境如何调试crontab定时任务
```
(1)	在调试时，将任务执行频率调快一点，如：每分钟、每五分钟执行一次，看是否能执行，是不是按你想的去执行。如果正常没问题了，再改成你需要的时间。
(2)	用正确的执行任务的时间，设置完成后，可以修改系统当前时间，改成任务执行前几分钟来测试。
(3)	在脚本中加入日志输出，然后将输出打到指定的日志中，然后观察日志内容结果，看是否执行正确。
(4)	注意：*/1 * * * * echo "==" >>/tmp/echo.log >/dev/null 2>&1 这种隐蔽的无法正确执行的任务配置。
(5)	调试java程序任务的时候,注意环境变量，把环境变量的定义加到脚本里。
(6)	查看定时任务日志: tail –f /var/log/cron
```

# 7.	附录
## 7.1.	设置服务器时间
```
[root@c5 ~]# date -s '2015-06-14 17:00:00'
Sun Jun 14 17:00:00 CST 2015
[root@c5 ~]# date
Sun Jun 14 17:00:03 CST 2015
```
## 7.2.	anacron
```
#/etc/anacrontab配置文件
[root@c6 ~]# cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
1	5	cron.daily		nice run-parts /etc/cron.daily
7	25	cron.weekly		nice run-parts /etc/cron.weekly
@monthly 45	cron.monthly		nice run-parts /etc/cron.monthly

#最后执行时间
[root@c6 ~]# more /var/spool/anacron/*
::::::::::::::
/var/spool/anacron/cron.daily
::::::::::::::
20150614
::::::::::::::
/var/spool/anacron/cron.monthly
::::::::::::::
::::::::::::::
/var/spool/anacron/cron.weekly
::::::::::::::
20150614

#如/var/spool/anacron/cron.daily记录最后执行anacron的时间为20150614
```
## 7.3.	man帮助

### (1)	man crontab
```
[root@c5 ~]# man crontab
NAME
crontab - maintain crontab files for individual users (ISC Cron V4.1)
# 为个人用户维护crontab文件
SYNOPSIS
crontab [-u user] file
crontab [-u user] [-l | -r | -e] [-i] [-s]

DESCRIPTION
Crontab  is  the program used to install, deinstall or list the tables used to drive the cron(8) daemon in ISC Cron.  Each user can have their own crontab, and though these are files in /var/spool/ , they are not intended to be edited directly. For SELinux in mls mode can be  even  more  crontabs  -  for  each  range. For more see selinux(8).

       If  the  cron.allow file exists, then you must be listed therein in order to be allowed to use this command.  If the cron.allow file does not exist but the  cron.deny file does exist, then you must not be listed in the cron.deny file in order to use this command.  If neither of  these  files  exists,  only  the  super user will be allowed to use this command.
# 如果cron.allow存在，则列在里面的用户可以使用此命令。
# 如果cron.allow不存在，但cron.deny存在，则不列在cron.deny里面的用户可以使用此命令。
# 如果cron.allow和cron.deny都不存在，只有超级管理员能使用此命令。

OPTIONS
-u     It  specifies  the name of the user whose crontab is to be tweaked.  If this option is not given, crontab examines "your" crontab, i.e., the crontab of the person executing the command.  Note that su(8) can confuse crontab and that if you are running inside of su(8) you should always use  the  -u  option  for  safety’s  sake.   The first form of this command is used to install a new crontab from some named file or standard input if the pseudo- filename "-" is given.

       -l     The current crontab will be displayed on standard output.

       -r     The current crontab will be removed.

       -e     This option is used to edit the current crontab using the editor specified by the VISUAL or EDITOR environment variables.  After you exit  from  the editor, the modified crontab will be installed automatically.

       -i     This option modifies the -r option to prompt the user for a ’y/Y’ response before actually removing the crontab.

       -s     It will append the current SELinux security context string as an MLS_LEVEL setting to the crontab file before editing / replacement occurs - see the documentation of MLS_LEVEL in crontab(5).

...省略…
```
### (2)	man cron
```
[root@c5 ~]# man cron
CRON(8)                                                                CRON(8)

NAME
cron - daemon to execute scheduled commands (ISC Cron V4.1)
cron – 以守护进程执行预定的命令。
SYNOPSIS
cron [-n | -p | -m<mailcommand>]
cron -x [ext,sch,proc,pars,load,misc,test,bit]

DESCRIPTION
Cron should be started from /etc/rc.d/init.d or /etc/init.d

       Cron  searches  /var/spool/cron for crontab files which are named after accounts in /etc/passwd; crontabs found are loaded into memory.  Cron also searches for /etc/crontab and the files in the /etc/cron.d directory, which are in a different format (see crontab(5) ).  Cron then wakes up every minute, examining all stored crontabs, checking each command to see if it should be run in the current minute.  When executing commands, any output is mailed to the owner of  the crontab (or to the user named in the MAILTO environment variable in the crontab, if such exists).
Cron会搜索/var/spool/cron下以用户名(在/etc/passwd的用户名)命令的文件。
Cron会搜索/etc/crontab文件 和/etc/cron.d目录下的文件。Cron每分钟会唤醒一次，并检查所有存储的crontabs,检查每个command是否能在这一分钟被执行。 当每一次执行的时候，会将command执行的输出以邮件发送出command的所执行的用户。

       Additionally, cron checks each minute to see if its spool directory’s modtime (or the modtime on /etc/crontab) has changed, and if it has, cron  will  then  examine  the  modtime on all crontabs and reload those which have changed.  Thus cron need not be restarted whenever a crontab file is modified.  Note that  the crontab(1) command updates the modtime of the spool directory whenever it changes a crontab.
cron会每分钟检查crontabs配置，如果自动调度有变更，cron会自动载入变更。

...省略…
```
### (3)	man anacron
```
[root@c5 ~]# man anacron
ANACRON(8)                   Anacron Users’ Manual                  ANACRON(8)

NAME
anacron - runs commands periodically

SYNOPSIS
anacron [-s] [-f] [-n] [-d] [-q] [-t anacrontab] [job] ...
anacron -u [-t anacrontab] [job] ...
anacron [-V|-h]

DESCRIPTION
Anacron  can  be used to execute commands periodically, with a frequency specified in days.  Unlike cron(8), it does not assume that the machine is running continuously.  Hence, it can be used on machines that aren’t running 24 hours a day, to control daily, weekly, and monthly jobs that are usually controlled by cron.

       When  executed,  Anacron reads a list of jobs from a configuration file, normally /etc/anacrontab (see anacrontab(5)).  This file contains the list of jobs that Anacron controls.  Each job entry specifies a period in days, a delay in minutes, a unique job identifier, and a shell command.

       For each job, Anacron checks whether this job has been executed in the last n days, where n is the period specified for that job.  If not, Anacron runs the job’s shell command, after waiting for the number of minutes specified as the delay parameter.

       After the command exits, Anacron records the date in a special timestamp file for that job, so it can know when to execute it again.  Only the date is used  for the time calculations.  The hour is not used.

       When there are no more jobs to be run, Anacron exits.

       Anacron only considers jobs whose identifier, as specified in the anacrontab matches any of the job command-line arguments.  The job arguments can be shell wildcard patterns (be sure to protect them from your shell with adequate quoting).  Specifying no job arguments, is equivalent to specifying "*"  (That is, all jobs will be considered).

       Unless the -d option is given (see below), Anacron forks to the background when it starts, and the parent process exits immediately.

       Unless the -s or -n options are given, Anacron starts jobs immediately when their delay is over.  The execution of different jobs  is  completely  independent.

       If a job generates any output on its standard output or standard error, the output is mailed to the user running Anacron (usually root).

       Informative messages about what Anacron is doing are sent to syslogd(8) under facility cron, priority notice.  Error messages are sent at priority error.

       "Active"  jobs (i.e. jobs that Anacron already decided to run and now wait for their delay to pass, and jobs that are currently being executed by Anacron), are "locked", so that other copies of Anacron won’t run them at the same time.
OPTIONS
-f     Force execution of the jobs, ignoring the timestamps.

       -u     Only update the timestamps of the jobs, to the current date, but don’t run anything.

       -s     Serialize execution of jobs.  Anacron will not start a new job before the previous one finished.

       -n     Run jobs now.  Ignore the delay specifications in the /etc/anacrontab file.  This options implies -s.

       -d     Don’t fork to the background.  In this mode, Anacron will output informational messages to standard error, as well as to syslog.  The output of jobs
              is mailed as usual.

       -q     Suppress messages to standard error.  Only applicable with -d.

       -t anacrontab
              Use specified anacrontab, rather than the default

       -V     Print version information, and exit.

       -h     Print short usage message, and exit.

SIGNALS
After receiving a SIGUSR1 signal, Anacron waits for running jobs, if any, to finish and then exits.  This can be used to stop Anacron cleanly.

NOTES
Make sure that the time-zone is set correctly before Anacron is started.  (The time-zone affects the date).  This is usually accomplished by setting the TZ
environment variable, or by installing a /usr/lib/zoneinfo/localtime file.  See tzset(3) for more information.

FILES
/etc/anacrontab
Contains specifications of jobs.  See anacrontab(5) for a complete description.

       /var/spool/anacron
              This directory is used by Anacron for storing timestamp files.

SEE ALSO
anacrontab(5), cron(8), tzset(3)

...省略…
```


### (4)	wiki zh cron
https://zh.wikipedia.org/wiki/Cron

常见错误
```
一个常见的错误是，命令行双引号中使用%时，未加反斜线\，例如：
# 错误的例子:
1 2 3 4 5 touch ~/error_`date "+%Y%m%d"`.txt
在守护进程发出的电子邮件中会见到错误信息：
/bin/sh: unexpected EOF while looking for `'''''''
# 正确的例子:
1 2 3 4 5 touch ~/right_$(date +\%Y\%m\%d).txt

# 使用单引号也可以解决问题：
1 2 3 4 5 touch ~/error_$(date '+%Y%m%d').txt

# 使用单引号就不用加反斜线了。这个例子会产生这样一个文件 ~/error_\2006\04\03.txt
1 2 3 4 5 touch ~/error_$(date '+\%Y\%m\%d').txt
下例是另一个常见错误：
# Prepare for the daylight savings time shift
59 1 1-7 4 0 /root/shift_my_times.sh
初看似要在四月的第一个星期日早晨1时59分运行shift_my_times.sh，但是这样设置不对。
与其他域不同，第三和第五个域之间执行的是“或”操作。所以这个程序会在4月1日至7日以及4月余下的每一个星期日执行。
这个例子可以重写如下：
# Prepare for the daylight savings time shift
59 1 1-7 4 * test `date +\%w` = 0 && /root/shift_my_times.sh
另一个常见错误是对分钟设置的误用。下例欲一个程两个小时运行一次：
# adds date to a log file
* 0,2,4,6,8,10,12,14,16,18,20,22 * * * date >> /var/log/date.log
  而上述设置会使该程序在偶数小时内的每一分钟执行一次。正确的设置是：
# runs the date command every even hour at the top of the hour
0 0,2,4,6,8,10,12,14,16,18,20,22 * * * date >> /var/log/date.log
# an even better way
0 */2 * * * date >> /var/log/date.log
不发送电子邮件
如果输出结果来自crontab里的命令，那么cron守护进程会用电子邮件将它发给用户。
•	若想关闭某个命令的输出结果，可以将输出结果重定向至/dev/null。
>/dev/null 2>&1
•	在常用的Vixie cron中，也可以在文件的开始部分加入命令来关闭所有命令的邮件输出：
MAILTO=""

```
### (5)	wiki en cron
https://en.wikipedia.org/wiki/Cron

The software utility Cron is a time-based job scheduler in Unix-like computer operating systems. People who set up and maintain software environments use cron to schedule jobs (commands or shell scripts) to run periodically at fixed times, dates, or intervals. It typically automates system maintenance or administration—though its general-purpose nature makes it useful for things like connecting to the Internet and downloading email at regular intervals.[1] The origin of the name cronis obscure;[2] it has been suggested that it comes from the Greek word for time, χρόνος chronos,[3] or that it is an acronym for "Command Run On Notice"[4] or for "Commands Run Over Night".[2][discuss]

Overview

Cron is driven by a crontab (cron table) file, a configuration file that specifies shell commands to run periodically on a given schedule. The crontab files are stored where the lists of jobs and other instructions to the cron daemon are kept. Users can have their own individual crontab files and often there is a system wide crontab file (usually in /etc or a subdirectory of /etc) that only system administrators can edit.
Each line of a crontab file represents a job, and is composed of a CRON expression, followed by a shell command to execute. Some cron implementations, such as in the popular 4th BSD edition written by Paul Vixie and included in many Linux distributions, add a sixth field: an account username that runs the specified job (subject to user existence and permissions). This is allowed only in the system crontabs—not in others, which are each assigned to a single user to configure. The sixth field is alternatively sometimes used for year instead of an account username—the nncron daemon for Windows does this.
While normally the job is executed when the time/date specification fields all match the current time and date, there is one exception: if both "day of month" (field 3) and "day of week" (field 5) are restricted (not "*"), then one or both must match the current day.[5]

