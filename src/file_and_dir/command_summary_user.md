# 命令总结-用户管理命令-用户(useradd、userdel、passwd、chage)

# 1.	useradd
## 1.1.	说明

useradd - create a new user or update default new user information 

#创建新的用户或更新默认用户信息
```
useradd [-u UID] [-g 初始群组] [-G 次要群组] [-mM]\
>  [-c 说明栏] [-d 家目录绝对路径] [-s shell] 使用者账号名
选项与参数：
-u, --uid UID  ：后面接的是 UID ，是一组数字。直接指定一个特定的 UID 给这个账号；
-g, --gid GROUP  ：初始化群组，该群组的 GID 会被放置到 /etc/passwd 的第四个字段内。
-G, --groups GROUP1[,GROUP2,...[,GROUPN]]]  ：后面接的组名则是这个账号还可以加入的群组。每个用户组用,分隔。
这个选项与参数会修改 /etc/group 内的相关数据喔！
-M  ：强制！不要创建用户家目录！(系统账号默认值)
-m, --create-home  ：强制！要创建用户家目录！(一般账号默认值)
-c, --comment COMMENT  ： /etc/passwd 的第五列(用户信息说明)的说明内容。
-d, --home HOME_DIR  ：指定某个目录成为家目录，而不要使用默认值。务必使用绝对路径！
-r  ：创建一个系统的账号，这个账号的 UID 会有限制 (参考 /etc/login.defs)
-s, --shell SHELL  ：后面接一个 shell ，若没有则默认是 /bin/bash。
-e, --expiredate EXPIRE_DATE  ：The date on which the user account will be disabled. The date is specified in the format YYYY-MM-DD.，账号失效日，格式为”YYYY-MM-DD”, shadow 第八字段。
-f, --inactive INACTIVE  ：The number of days after a password expires until the account is permanently disabled. 后面接 shadow 的第七字段项目，指定口令是否会失效。0为立刻失效，-1 为永远不失效(口令只会过期而强制于登陆时重新配置而已。)
```

## 1.2.	实例
范例一：完全参考默认值创建一个用户，名称为 vbird1
```
[root@stu412 ~]# useradd vbird1
[root@stu412 ~]# ll -d /home/vbird1
drwx------ 2 vbird1 vbird1 4096 Jun 22 17:31 /home/vbird1
# 默认会创建用户家目录，且权限为 700 ！

[root@stu412 ~]# grep vbird1 /etc/passwd /etc/shadow /etc/group
/etc/passwd:vbird1:x:508:508::/home/vbird1:/bin/bash
/etc/shadow:vbird1:!!:15513:0:99999:7:::
/etc/group:vbird1:x:508:    <==默认会创建一个与账号一模一样的群组名


使用"useradd 账号"来创建使用者即可。 CentOS 这些默认值主要会帮我们处理几个项目：
(1)	在 /etc/passwd 里面创建一行与账号相关的数据，包括创建 UID/GID/家目录等；
(2)	在 /etc/shadow 里面将此账号的口令相关参数填入，但是尚未有口令；
(3)	在 /etc/group 里面加入一个与账号名称一模一样的组名；
(4)	在 /home 底下创建一个与账号同名的目录作为用户家目录，且权限为 700

由于在 /etc/shadow 内仅会有口令参数而不会有加密过的口令数据，因此我们在创建使用者账号时， 还需要使用"passwd 账号"来给予口令才算是完成了用户创建的流程。
```
范例二：假设我已知道我的系统当中有个组名为 users ，且 UID 700并不存在，请用users为初始群组，以及 uid 为 700 来创建一个名为 vbird2 的账号
```
[root@stu412 ~]# userdel -r vbird2
[root@stu412 ~]# useradd -u 700 -g users vbird2
[root@stu412 ~]# ll -d /home/vbird2
drwx------ 2 vbird2 users 4096 Jul  3 06:33 /home/vbird2
[root@stu412 ~]# grep vbird2 /etc/passwd /etc/shadow /etc/group
/etc/passwd:vbird2:x:700:100::/home/vbird2:/bin/bash
/etc/shadow:vbird2:!!:15523:0:99999:7:::
#UID 与初始化群组改变成我们需要的了！
```
范例三：创建一个系统账号，名称为 vbird3
```
[root@stu412 ~]# useradd -r vbird3
[root@stu412 ~]# ll -d /home/vbird3
ls: /home/vbird3: No such file or directory <==不会主动创建家目录

[root@stu412 ~]# grep vbird3 /etc/passwd /etc/shadow /etc/group
/etc/passwd:vbird3:x:101:103::/home/vbird3:/bin/bash
/etc/shadow:vbird3:!!:15523::::::
/etc/group:vbird3:x:103:
一般账号的应该是 500 号以后，用户自己创建的系统账号则一般是由 100 号以后起算的。 所以在这里我们加上 -r 这个选项以后，系统就会主动将账号与账号同名群组的 UID/GID 都指定小于 500 以下， 在本案例中则是使用 101(UID) 与 103(GID)！此外，由于系统账号主要是用来进行运行系统所需服务的权限配置， 所以系统账号默认都不会主动创建主文件夹的！
```
范例四：useradd的-g,-u参数
```
[root@stu412 ~]# groupadd -g 801 sa
groupadd: group sa exists		#组已经存在了
[root@stu412 ~]# groupadd -g 801 alex-qu
groupadd: GID 801 is not unique	#gid已经存在了

[root@stu412 ~]# groupadd -g 808 alex-qu
[root@stu412 ~]# useradd -g alex-qu -u901 quxl
useradd: UID 901 is not unique
[root@stu412 ~]# useradd -g alex-qu -u909 quxl
[root@stu412 ~]# grep quxl /etc/passwd
quxl:x:909:808::/home/quxl:/bin/bash
```
范例五：useradd 的-M,-s的例子
```
[root@stu412 ~]# grep alex /etc/passwd
alex:x:910:910::/home/alex:/sbin/nologin #不创建家目录，并禁止登录
范例五：useradd 的-e参数的例子
这个参数比较重要
#useradd tmpuser –e 01/19/12 #设置账户过期时间（2012-01-19）
[root@stu412 ~]# useradd  tmpuser -e 06/30/12
[root@stu412 ~]# passwd tmpuser
Changing password for user tmpuser.
New UNIX password:
BAD PASSWORD: it does not contain enough DIFFERENT characters
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
[root@stu412 ~]# date +%F
2012-07-03

tmpuser登录时提示：
Your account has expired; please contact your system administrator

---------------------------
[root@stu412 ~]# useradd  tmpuser1 -e 2012-06-30
[root@stu412 ~]# passwd tmpuser1
Changing password for user tmpuser1.
New UNIX password:
BAD PASSWORD: it does not contain enough DIFFERENT characters
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
[root@stu412 ~]# date +%F
2012-07-03
tmpuser1登录时提示：
Your account has expired; please contact your system administrator


用户过期时间到了但还没有失效：
(1)	通过-e设置后无法远程登录ssh连接，但是可以su切换，账户并未锁定。
(2)	账户过期时间和系统时间，需相差2天。
```
## 1.3.	useradd –D选项
```
当useradd加-D选项时，其实际效果是改变配置文件/etc/default/useradd文件的默认值。
可用选项为∶

-b default_home
定义使用者所属目录的前一个目录。使用者名称会附加在default_home后面用来
建立新使用者的目录。当然使用-d后则此选项无效。
-e default_expire_date
使用者帐号停止日期。

-f default_inactive
帐号过期几日后停权。

-g default_group
新帐号起始群组名或ID。群组名须为现有存在的名称。群组ID也须为现有存
在的群组。

-s default_shell
使用者登入后使用的 shell 名称。往后新加入的帐号都将使用此 shell.

如不指定任何参数，useradd 显示目前预设的值。

显示useradd 的默认值：
[root@stu412 ~]# useradd -D
GROUP=100					<==默认的群组
HOME=/home				<==默认的家目录所在目录
INACTIVE=-1				<==口令失效日，在 shadow 内的第 7 栏
EXPIRE=					<==账号失效日，在 shadow 内的第 8 栏
SHELL=/bin/bash			<==默认的 shell
SKEL=/etc/skel			<==用户家目录的内容数据参考目录
CREATE_MAIL_SPOOL=yes   <==是否主动帮使用者创建邮件信箱(mailbox)
```
## 1.4.	生产环境中创建用户的完整命令例子
```
#groupadd –g 801 sa				#添加组

#useradd –g sa –u 901 ett		#添加用户及指定其组

#echo "sadasdasdasd" | passwd ett –stdin	#设置密码

#echo "ett ALL=(ALL)		NOPASSWD:ALL">>/etc/sudoers	#设置sudo

#清除记录
#visudo –c
#history -c
```
## 2.	userdel
### 2.1.	说明
userdel - delete a user account and related files  #删除用户账户和其相关文件
```
语法：
# userdel [-r] username
选项与参数：
-r, --remove  ：连同用户的家目录也一起删除,但属于用户的其它文件或目录是没有被删除的。

这个功能目的在删除用户的相关数据，而用户的数据有：
(1)	用户账号/口令相关参数：/etc/passwd, /etc/shadow
(2)	用户组相关参数：/etc/group, /etc/gshadow
(3)	用户个人文件数据： /home/username, /var/spool/mail/username..
```

总结：

一般生产环境中，当无法确定被删除用户家目录等是否有用或者有不规范用户已在家目录下跑了脚本或程序的时候，就不要使用“userdel –r 用户名”这样的危险行为，而是直接使用"userdel 用户名"删除即可。

我们还可以直接使用vi编辑/etc/passwd，找到要处理的用户，先注释一段时间，确认真的没有问题了，然后再清除其家目录。注释的作用和userdel命令删除的效果一样，就是实现了被注释的用户无法登录，一旦发现问题，我们可以进行恢复。对于上千台服务器运维的情况，我们可以使用ldap等服务实现账户统一认证，批量添加删除管理。

## 2.2.	实例
范例一：删除 tmpuser2，连同家目录一起删除
```
[root@stu412 ~]# userdel -r tmpuser1
总结：在生产环境中，请不要轻易使用-r参数，如果非要删除家目录，请在删除前备份文件。
```
范例二：手动删除指定账户tmpuser
```
[root@stu412 tmp]# /bin/cp /etc/passwd /etc/passwd.bak #备份
[root@stu412 tmp]# grep qinqin2 /etc/passwd
qinqin2:x:702:702::/home/qinqin2:/bin/bash
[root@stu412 tmp]# sed -i 's#qinqin2#\#qinqin2#g' /etc/passwd #注释
[root@stu412 tmp]# grep qinqin2 /etc/passwd
#qinqin2:x:702:702::/home/#qinqin2:/bin/bash
[root@stu412 tmp]# sed -i 's#\#qinqin2#qinqin2#g' /etc/passwd #还原
[root@stu412 tmp]# grep qinqin2 /etc/passwd
qinqin2:x:702:702::/home/qinqin2:/bin/bash

[root@stu412 ~]# /bin/cp /etc/passwd /etc/passwd.bak				#备份
[root@stu412 ~]# grep tmpuser /etc/passwd
tmpuser:x:911:911::/home/tmpuser:/bin/bash
[root@stu412 ~]# sed -i 's#tmpuser#\#tmpuser#g' /etc/passwd		#注释
[root@stu412 ~]# grep tmpuser /etc/passwd
#tmpuser:x:911:911::/home/#tmpuser:/bin/bash
[root@stu412 ~]#
[root@stu412 ~]# sed -i 's#\#tmpuser#tmpuser#g' /etc/passwd		#还原
[root@stu412 ~]# grep tmpuser /etc/passwd
tmpuser:x:911:911::/home/tmpuser:/bin/bash
```
总结：直接在/etc/passwd中注释或删除用户的记录的方法也是生产环境中常用的方法，但是在操作时一定要小心。当然，操作前备份也是必要的。

# 3.	passwd
## 3.1.	语法
```
# passwd [--stdin]  <==所有人都可以用来改自己的口令
# passwd [-d] [-l] [-u] [--stdin] [-S] \
>  [-n 日数mindays] [-x 日数maxdays] [-w 日数warndays] [-i 日期inactivedays] 账号 <==root 功能

选项与参数：
--stdin ：可以通过前一个管线的数据，作为口令输入，对 shell脚本有帮助！
-d , --delete ：删除用户密码，仅能以root权限操作。
-l  ：是 Lock 的意思，会将 /etc/shadow 第二栏最前面加上 ! 使口令失效；
-u  ：与 -l 相对，是 Unlock 的意思！
-S ,--status：列出口令相关参数，即 shadow 文件内的大部分信息。
-n ,--minmun=DAYS：后面接天数，shadow 的第 4 字段，两次修改密码的最小天数
-x ,--maximum=DAYS：后面接天数，shadow 的第 5 字段，两次修改密码的最大天数
-w ,--warning=DAYS：后面接天数，shadow 的第 6 字段，密码过期前多少天的提醒用户
-i ,--inactice=DAYS：在密码过期后多少天，用户被禁掉，仅能以root操作。

普通用户只能修改自己的密码,root可以修改所有用户的密码。
提示：在多人公用一个账户时，可以用-n参数锁定密码，但一般情况不会有此需求。
```
## 3.2.	实例
范例一：请 root 给予 vbird2 口令
```
[root@stu412 ~]# passwd vbird2
Changing password for user vbird2.
New UNIX password: 					<==这里直接输入新的口令，屏幕不会有任何反应
BAD PASSWORD: it is WAY too short <==口令太简单或过短的错误！
Retype new UNIX password:  		 <==再输入一次同样的口令
passwd: all authentication tokens updated successfully.  <==竟然还是成功修改了！
```
#当我们要给予用户口令时，通过 root 来配置即可。 root 可以配置各式各样的口令，系统几乎一定会接受！

范例二：用vbird2登陆后，修改vbird2自己的口令
```
[vbird2@stu412 ~]$ passwd   <==后面没有加账号，就是改自己的口令！
Changing password for user vbird2.
Changing password for vbird2
(current) UNIX password: 	<==这里输入『原有的旧口令』
New UNIX password:			<==这里输入新口令
BAD PASSWORD: it is based on a dictionary word <==口令检验不通过，请再想个新口令
New UNIX password:			<==这里再想个来输入吧
Retype new UNIX password: 	<==通过口令验证！所以重复这个口令的输入
passwd: all authentication tokens updated successfully. <==是否成功看关键词
#要帮一般账号创建口令需要使用"passwd 账号 "的格式，使用" passwd "表示修改自己的口令！
```
范例三：使用 --stdin实现非交互式批量设置或修改密码
```
[root@stu412 ~]# echo "vbird2" | passwd --stdin vbird2
Changing password for user vbird2.
passwd: all authentication tokens updated successfully.
[root@stu412 ~]# history –c
# 将上面的历史记录清空，上面设置密码虽然不需要交互了，但是密码 会以明文的方式保存在历史记录里，这点需要大家注意一下。一般批量设置密码分发给管理员后，要强制大家更改密码。
```
范例四：管理 vbird2 的口令使具有60天必须修改密码、过期10天后密码失效的配置
```
[root@stu412 ~]# passwd -S vbird2
vbird2 LK 2012-07-02 0 99999 7 -1 (Password locked.)
# 上面说明口令创建时间 (2012-07-02)、0 最小天数、99999 变更天数、7 警告日数
# 与口令不会失效 (-1) 。

[root@stu412 ~]# passwd -x 60 -i 10 vbird2
Adjusting aging data for user vbird2.
passwd: Success
[root@stu412 ~]# passwd -S vbird2
vbird2 LK 2012-07-02 0 60 7 10 (Password locked.)
```
范例五：让 vbird2 的账号失效，查看完毕后再让她有效
```
如何让某个账号暂时无法使用口令登录？
[root@stu412 ~]# passwd -l vbird2
Locking password for user vbird2.
passwd: Success
[root@stu412 ~]# passwd -S vbird2
vbird2 LK 2012-05-09 0 60 7 10 (Password locked.)
# 嘿嘿！状态变成" LK, Lock "了啦！无法登陆喔！

[root@stu412 ~]# grep vbird2 /etc/shadow
vbird2:!!$1$V5074DcN$tWpkJMtjdqshPkdzivQv00:15469:0:60:7:10::
# 其实只是在这里加上 !! 而已！知道这个后，可以手动修改/etc/shadow文件实现lock、unlock功能

[root@stu412 ~]#  passwd -u vbird2
Unlocking password for user vbird2.
passwd: Success.
[root@stu412 ~]# grep vbird2 /etc/shadow
vbird2:$1$V5074DcN$tWpkJMtjdqshPkdzivQv00:15469:0:60:7:10::
# 口令字段恢复正常！
疑问：被锁定的用户不能更改密码，那么可否通过远程ssh连接呢？
[root@stu412 ~]# passwd -l vbird2
Locking password for user vbird2.
passwd: Success
[root@stu412 ~]# passwd -S vbird2
vbird2 LK 2012-07-03 0 60 7 10 (Password locked.)
#状态变成" LK, Lock "！无法登陆了。
[root@stu412 ~]# grep vbird2 /etc/shadow
vbird2:!!$1$Op6NmFe6$zCHWhxaNlG/hRu38TxlIV.:15524:0:60:7:10::
#密码前加上!! 而已！知道这个后，可以手动修改/etc/shadow文件实现lock、unlock功能
[root@stu412 ~]# passwd -u vbird2
Unlocking password for user vbird2.
passwd: Success.
[root@stu412 ~]# grep vbird2 /etc/shadow
vbird2:$1$Op6NmFe6$zCHWhxaNlG/hRu38TxlIV.:15524:0:60:7:10::
# 口令字段恢复正常！
```
范例六：-d参数清除vbird2密码，然后通过-S参数来查看
```
[root@stu412 ~]# passwd -S vbird2
vbird2 PS 2012-07-03 0 60 7 10 (Password set, MD5 crypt.)
[root@stu412 ~]# passwd -d vbird2
Removing password for user vbird2.
passwd: Success
[root@stu412 ~]# passwd -S vbird2
vbird2 NP 2012-07-03 0 60 7 10 (Empty password.)
```
范例七：批量添加用户和设置用户密码
```
#!/bin/sh
#author:oldboy
userchars="qinqin";
for num in `seq 3`
do
useradd $userchars$num
passwd=`date|md5sum|cut -c3-20`
echo "$passwd"|passwd --stdin $userchars$num
echo -e "user:$userchars$num \tpasswd:$passwd">>/tmp/user.log
sleep 1
done
echo ----------
cat /tmp/user.log
```
提示：linux里也有相应的的命令（newusers –update and create new users in batch）和(chpasswd –update passwords in batch mode)可以实现批量添加并设置密码。由于生产场景中，不经常使用，并且使用起来也不简单，这里就不多介绍了。有兴趣的，可以自行man newusers和man chpasswd。
## 3.3.	passwd总结
在实际工作中，最常用的用法就是直接使用passwd加用户名和修改密码，其次使用--stdin参数批量无交互设置密码，其他的参数用的很少(如-l,-u,-S等)。

在生产场景中，我们设置密码时，应该尽可能的复杂且无规律，但又利于记忆。比较好的密码是数字字母（包括大小写及特殊符号的组合），并且8位以上。比如：曾经使用的密码"IAM33oldboy",意思是我是33岁的oldboy,比较复杂但又利于自我记忆。(提示：引号也是密码的一部分)。或者这样设置密码"oldBOY@)!@)!@#"看着复杂吧，其实oldBOY后面的特殊字符就是20120123(同时按shift键输入的结果),总之，实际工作中系统安全是非常重要的环节，而密码的设置方法和策略更是重中之重。
# 4.	chage
## 4.1.	说明
```
功能：chage - change user password expiry information	#修改帐号和密码的有效期限
#chage [选项] 用户名
在LINUX系统上，密码时效是通过chage命令来管理的。
参数意思：
-m ,--mindays 最小天数：密码可更改的最小天数。为0代表任何时候都可以更改密码。两次修改密码之间相距的最小天数。
-M ,--maxdays 最大天数：密码保持有效的最大天数。两次修改密码相距的最大天数。
-W ,--warnings警告天数：用户密码到期前，提前收到警告信息的天数。
-E ,--expiredate 过期日期：帐号到期的日期。0表示立即过期，-1表示永不过期。
-d ,--lastday 最近日期 ：上一次更改的日期
-I, --inactive INACTIVE：密码过期后，锁定帐号的天数。如果一个密码已过期这些天，那么此帐号将不可用。
-l ,--list：Show account aging information.列出用户的以及密码的有效期限。由非特权用户来确定他们的密码或帐号何时过期。

阿烈：
-m 在此设定的天数内密码不可改;
-M 在此设定的天数内，用户未登录系统修改密码，其后登录时要即时修改密码才可登录。
-I 密码超过-M设定的有效期后，并在-i设定的天数内未修改密码，则帐号停用。
-E 帐号到期的日期。与前面的-m,-M,-i无太大的关联。
```
## 1.2.	范例
范例一：查看设定
```
root或普通用户都可以使用命令 "chage -l 用户" 或 "chage –list 用户" 来查看指定用户或自己帐户的密码有效期设置：
[root@stu412 ~]# chage -l quxl
Last password change                                    : Jul 02, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```
范例二：强制用户登录时修改口令
```
[root@stu412 ~]# chage -d 0 quxl
#用户quxl登录时会提示以下信息
You are required to change your password immediately (root enforced)
Last login: Tue Jul  3 21:46:31 2012 from 192.168.84.1
WARNING: Your password has expired.
You must change your password now and login again!
Changing password for user quxl.
Changing password for quxl
(current) UNIX password:
```
范例三：设定密码有效期警告日数
```
一般 GNU/Linux 都会缺省使用者密码有效期警告日数为 7，即在密码最长有效期截止前 7 日，每次用户登录都会发出密码有效期将过期的警告，要求使用者尽快更改密码。
Warning: your password will expire in 3 days
Last login: Fri May  4 07:11:50 2012 from 192.168.239.1
[quxl@stu412 ~]$
超级使用者 root 可以使用命令 chage -W 日数 使用者 或 chage --warndays 日数 使用者 来为个别使用者密码设定密码有效期警告日数：
chage -W 5 quxl
```
范例四：设置账户有效期,-E参数
```
[root@stu412 ~]# chage -E 2012-07-05 quxl
[root@stu412 ~]# chage -l quxl           
Last password change                                    : password must be changed
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Jul 05, 2012
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
过期后，重新登录
Your account has expired; please contact your system administrator

即时锁定使用者帐户，在您开通前不容许使用者登入
passwd -l quxl  	#锁定
passwd -u quxl	#解锁

usermod -L quxl	#锁定
usermod -U quxl	#解锁
```
范例五：取消账户有效期
```
一般使用者缺省都没有有效日期，即使用者可以永久被使用。如果您已设定了使用者有效日期，可以使用命令 chage -E -1 使用者 或 chage --expiredate -1 使用者 取消:
[root@stu412 ~]# chage -l quxl
Last password change                                    : Jul 03, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Jul 05, 2012
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 5
[root@stu412 ~]# chage -E -1 quxl
[root@stu412 ~]# chage -l quxl   
Last password change                                    : Jul 03, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 5
[root@stu412 ~]#
```
范例六：设定密码最长有效期
```
超级使用者 root 可以使用命令 chage -M 日数 使用者 或 chage --maxdays 日数 使用者 来为个别使用者密码设定一个最长有效日数：
[root@stu412 ~]# chage -M 30 quxl
[root@stu412 ~]# chage -l quxl   
Last password change                                    : Jul 03, 2012
Password expires                                        : Aug 02, 2012
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 30
Number of days of warning before password expires       : 5
[root@stu412 ~]# chage -M -1 quxl  		#取消密码最长有效期
[root@stu412 ~]# chage -l quxl      
Last password change                                    : Jul 03, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : -1
Number of days of warning before password expires       : 5
以上命令将使用者 quxl的密码最长有效期设定为30日。当使用者登录时，如果其密码最后更改的日期离登录日子超过所设定的密码最长有效期 (例子为30日) ，使用者必须要更改密码才可登入。
一般使用者缺省是没有密码最长有效期的，即是说他们的密码可以永久不用更改。当然，定期更改密码对系统会比效安全。如果您己设定了密码最长有效期，可以使用命令 chage -M -1 使用者 或 chage --maxdays -1 使用者 来取消:
```
范例七：设定密码最短有效期
```
超级使用者 root 可以使用命令 chage -m 日数 使用者 或 chage --mindays 日数 使用者 来为个别使用者密码设定一个最短有效日数。
以上命令将使用者 quxl的密码最短有效期设定为 5 日。当使用者企图更改密码，系统会检查其密码最后更改的日期。如果离当日小于所设定的密码最短有效期 (例子为 5 日) ，系统会拒绝使用者更改密码。
一般使用者的密码最短有效期缺省为 0，即使用者可以随时更改密码。如果您己设定了密码最短有效期，可以使用命令 chage -m 0 使用者 或 chage --mindays 0 使用者 来取消:
[root@stu412 ~]# chage -m 5 quxl		#设定密码最短有效期
[root@stu412 ~]# chage -l quxl  
Last password change                                    : Jul 03, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 5
Maximum number of days between password change          : -1
Number of days of warning before password expires       : 5
[root@stu412 ~]# chage -m 0 quxl    #取消密码最短有效期
[root@stu412 ~]# chage -l quxl    	
Last password change                                    : Jul 03, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : -1
Number of days of warning before password expires       : 5
```
范例八：设定使用者不活跃限期
```
当使用者的密码超过其最长有效期，系统会在其登录时强迫他更改密码才可以登入和工作。作为超级使用者 root 的您亦可以设定一个限期使用者要在多少日内登入和更改密码，否则停用使用者帐户。超级使用者 root 使用命令 chage -I 日数 使用者 或 chage --inactive 日数 使用者 或 usermod -f 日数 使用者 来为个别使用者设定一个不活跃限期：
chage -I 3 quxl
以上命令将使用者 quxl的不活跃限期设定为 3 日。当使用者的密码而超过 chage -M 所设定的最长有效期，而使用者在不活跃限期 (例子为 3 日) 内未有更改密码并成功登入，系统将视使用者为不活跃并停用该使用者帐户。帐户被停用后，使用者将无法登入，必须络联并要求系统管理员开通帐户。
一般使用者缺省是没有不活跃限期的，即是说他们可以随时登入更改密码。当然，设定不活跃限期对系统会比效安全。如果您已设定了不活耀限期，可以使用命令 chage -I -1 使用者 或 chage --inactive -1 使用者 来取消:
chage -I -1 quxl
```
范例九：设定密码最后更改日期
```
使用者密码每次被更改时，系统都会把当日日期记录在 /etc/shadow 档案中，让其可以计算密码最长和最短有效期、警告日子和使用者不活跃限期等。作为超级使用者 root 的您其实可以使用命令 chage -d 日期 使用者 或 chage --lastday 日期 使用者 来设定个别使用者的最后更改日期 (日期的格式一般为 YYYY-MM-DD)：
[root@stu412 ~]# chage -l quxl  
Last password change                                    : Jul 03, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : -1
Number of days of warning before password expires       : 5
[root@stu412 ~]# chage -d 2012-05-13 quxl	#设定密码最后更改日期
[root@stu412 ~]# chage -l quxl           
Last password change                                    : May 13, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : -1
Number of days of warning before password expires       : 5
```
范例十：开通因不活跃而被停用的帐户
```
当某使用者的密码过期，而他又没有在不活期内登入并更改密码，系统将视他为不活跃使用者并停用其使用帐户。他必须请求系统管理员开通其帐户才可以登入工作。作为超级使用者 root 的您如果收到这类请求，一般有以下两种方法开通帐户:
(1)	使用:passwd 使用者
命令为使用者重新设定一个初始密码，密码的最后更改日期将被自动更新为当日，密码有效期等设定将会从新计算。使用者需要使用您设定的初始密码登入。
(2)	使用 chage -d 日期 使用者
改变使用者的密码最后更改日期，使用者可以使用其旧密码登入。
```
# 5.	id
## 5.1.	语法
```
id - print user identity  		#打印用户id信息
id [OPTION]... [USERNAME]

Print information for USERNAME, or the current user.
-a     ignore, for compatibility with other versions	#忽略其他版本的兼容性
-Z, --context		#只显示用户的安全信息
print only the security context of the current process
-g, --group		#显示用户所属群组的ID
print only the effective group ID
-G, --groups		#打印用户所有群组id
print all group IDs
-n, --name			#显示名称，用来代码数字,要和-ugG一起用才行
print a name instead of a number, for -ugG
-r, --real
print the real ID instead of the effective ID, with -ugG
-u, --user
print only the effective user ID
```

## 5.2.	实例
```
[root@stu412 ~]# id 				#显示root的id信息
uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel)
[root@stu412 ~]# id vbird2		#显示vbird2的id信息
uid=700(vbird2) gid=100(users) groups=100(users)

[root@stu412 ~]# id -Z
Sorry, --context (-Z) can be used only on a selinux-enabled kernel.
[root@stu412 ~]# id -g
0
[root@stu412 ~]# id -g vbird2
100
[root@stu412 ~]# id -G
0 1 2 3 4 6 10
-----------------------------
[root@stu412 ~]# id -n
id: cannot print only names or real IDs in default format
[root@stu412 ~]# id -nugG
id: cannot print "only" of more than one choice
[root@stu412 ~]# id –nu		#用户名
root
[root@stu412 ~]# id –ng		#属组
root
[root@stu412 ~]# id –nG		#所有用户组
root bin daemon sys adm disk wheel
-----------------------------
[root@stu412 ~]# id –u				#显示root用户uid
0
[root@stu412 ~]# id -u vbird2		#显示root用户uid
700
[root@stu412 ~]# id -r vbird2
id: cannot print only names or real IDs in default format
[root@stu412 ~]# id -nr
id: cannot print only names or real IDs in default format
[root@stu412 ~]# id -nur
root
```