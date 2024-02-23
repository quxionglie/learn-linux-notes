# Linux系统的用户和用户组管理

# 1.	账号管理
## 1.1.	管理用户命令汇总

| 命令       | 解释                                                                     |
|----------|------------------------------------------------------------------------|
| useradd  | 	添加用户                                                                  |   
| passwd   | 	为用户设置密码                                                               |   
| usermod  | 	修改用户的命令，如修改登录名，家目录等                                                   |   
| id       | 	查看用户的UID,GID及所归属的用户组                                                  |   
| su       | 	用户切换工具                                                                |   
| sudo	    | 通过另一个用户来执行命令                                                           |   
| visudo   | 	配置sudo权限的配置命令。也可以不用这个命令，直接用vi来编辑/etc/sudoers实现，但推荐用visudo来操作（会自动检查语法） |   
| pwcov    | 	同步用户从/etc/passwd到/etc/shadow                                          |   
| pwck	    | 检验用户配置文件/etc/passwd和/etc/shadow文件内容是否合法或完整                             |   
| pwunconv | 	是pwcov的逆向操作，是从/etc/shadow和/etc/passwd创建/etc/passwd，然后会删除/etc/shadow文件 |   
| chfn     | 	更改用户信息工具                                                              |   
| finger   | 	查看用户信息工具                                                              |   
| sudoedit | 	和sudo功能差不多                                                            |   

说明：绿色部分要掌握，剩下的命令了解即可。

## 1.2.	管理用户组命令汇总
```
命令	说明
groupadd	添加用户组
groupdel	删除用户组
groupmod	修改用户组信息
groups	显示用户所属的用户组
grpck
grpconv
grpunconv
说明：绿色部分要掌握，剩下的命令了解即可。
``` 
## 1.3.	/etc/skel目录

/etc/skel目录是用来存放新用户配置文件的目录,当我们添加新用户时，这个目录下的所有文件会自动复制到新添加的用户家目录下；默认情况下，/etc/skel目录下的所有文件都是隐藏文件(以点开头的文件);通过修改、添加、删除/etc/skel目录下的文件，我们可为新创建的用户提供统一、标准的、初始化用户环境。
/etc/skel目录的内容：
```
[root@stu412 data]# ls -al /etc/skel/
total 48
drwxr-xr-x  2 root root  4096 Jun  4 03:32 .
drwxr-xr-x 88 root root 12288 Jul  7 19:31 ..
-rw-r--r--  1 root root    33 Jan 22  2009 .bash_logout
-rw-r--r--  1 root root   176 Jan 22  2009 .bash_profile
-rw-r--r--  1 root root   124 Jan 22  2009 .bashrc
当我们用useradd或adduser命令时，linux系统会自动复制/etc/skel下的所有文件（包括隐藏文件）到新添加的家目录下。
[root@stu412 data]# echo 'testfile'>/etc/skel/testfile #在/etc/skel下创建文件
[root@stu412 data]# useradd skeluser
[root@stu412 data]# ls -l /home/skeluser/
total 4
-rw-r--r-- 1 skeluser skeluser 9 Jul  7 21:59 testfile
[root@stu412 data]# cat /home/skeluser/testfile 	#文件拷过来了，内容也一样
testfile
[root@stu412 data]# ls -al /home/skeluser/
total 28
drwx------  2 skeluser skeluser 4096 Jul  7 21:59 .
drwxr-xr-x 19 root     root     4096 Jul  7 21:59 ..
-rw-r--r--  1 skeluser skeluser   33 Jul  7 21:59 .bash_logout
-rw-r--r--  1 skeluser skeluser  176 Jul  7 21:59 .bash_profile
-rw-r--r--  1 skeluser skeluser  124 Jul  7 21:59 .bashrc
-rw-r--r--  1 skeluser skeluser    9 Jul  7 21:59 testfile
提示：上述功能仅为功能举例，实际工作中可以考虑统一配置用户环境变量等，但一般中小公司，在生产环境一般不会随意改这个目录及文件内容，大家理解原理性知识即可。
```
## 1.4.	/etc/login.defs配置文件
/etc/login.defs文件是用来定义创建用户时，需要的一些用户的配置信息。如是否需要家目录，UID和GID的范围，用户及密码的有效期限等等。
```
[root@stu412 data]# cat cat /etc/login.defs
cat: cat: No such file or directory
# *REQUIRED*
#   Directory where mailboxes reside, _or_ name of file, relative to the
#   home directory.  If you _do_ define both, MAIL_DIR takes precedence.
#   QMAIL_DIR is for Qmail
#
#QMAIL_DIR      Maildir
MAIL_DIR        /var/spool/mail	#创建用户时，要在目录/var/spool/mail中创建一个用户mail文件
#MAIL_FILE      .mail

# Password aging controls:
#
#       PASS_MAX_DAYS   Maximum number of days a password may be used.
#       PASS_MIN_DAYS   Minimum number of days allowed between password changes.
#       PASS_MIN_LEN    Minimum acceptable password length.
#       PASS_WARN_AGE   Number of days warning given before a password expires.
#
PASS_MAX_DAYS   99999	#用户密码最长可使用的天数
PASS_MIN_DAYS   0			#更换密码的最小天数
PASS_MIN_LEN    5			#密码的最小长度
PASS_WARN_AGE   7			#密码失效前提前多少天开始警告用户

#
# Min/max values for automatic uid selection in useradd
#
UID_MIN                   500		#uid最小值
UID_MAX                 60000		#uid最大值

#
# Min/max values for automatic gid selection in groupadd
#
GID_MIN                   500		#gid最小值
GID_MAX                 60000		#gid最大值

#
# If defined, this command is run when removing a user.
# It should remove any at/cron/print jobs etc. owned by
# the user to be removed (passed as the first argument).
#
#USERDEL_CMD    /usr/sbin/userdel_local

#
# If useradd should create home directories for users by default
# On RH systems, we do. This option is overridden with the -m flag on
# useradd command line.
#
CREATE_HOME     yes	#是否允许创建家目录

# The permission mask is initialized to this value. If not specified,
# the permission mask will be initialized to 022.
UMASK           077

# This enables userdel to remove user groups if no members exist.
#
USERGROUPS_ENAB yes	#删除用户的同时删除用户组

# Use MD5 or DES to encrypt password? Red Hat use MD5 by default.
MD5_CRYPT_ENAB yes	#md5密码加密
```
## 1.5.	/etc/default/useradd
/etc/dedault/useradd文件是在使用useradd添加用户时的一个需要调用的一个默认的配置文件,可以使用useradd –D参数，这样的命令格式来修改文件里面的内容。也可以直接编辑修改。
```
[root@stu412 ~]# cat /etc/default/useradd
# useradd defaults file
GROUP=100
HOME=/home
INACTIVE=-1   	#是否使用账号过期停权，-1表示不启用
EXPIRE=			#账号终止日期，不设置表示不启用
SHELL=/bin/bash 	#新用户默认shell类型
SKEL=/etc/skel	#
CREATE_MAIL_SPOOL=yes #创建mail文件

[root@stu412 ~]# useradd –D	#跟上面是一样的效果
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```
修改参数值完后会直接生效！
# 2.	linux用户管理命令
## 2.1.	与用户管理相关的一些文件
### 2.1.1.	/etc/passwd和/etc/group
我们对linux的系统用户和用户进行添加、修改、删除的最终结果就是修改系统用户文件/etc/passwd和/etc/shadow以及用户组的/etc/group和文件/etc/gshadow。
### 2.1.2.	/etc/login.defs和/etc/default/useradd
/etc/login.defs文件是用来定义创建用户时，需要的一些用户的配置信息。如是否需要家目录，UID和GID的范围，用户及密码的有效期限等等。
      
/etc/dedault/useradd文件是在使用useradd添加用户时的一个需要调用的一个默认的配置文件,可以使用useradd –D参数，这样的命令格式来修改文件里面的内容。也可以直接编辑修改。
## 2.2.	useradd 添加用户命令
useradd命令不加参数选项，后面直接跟所添加的用户名时，系统首先会读取配置文件/etc/login.defs和/etc/default/useradd中所定义的参数或规则，根据设置的规则添加用户，同时会向/etc/passwd和/etc/group文件内添加新建用户和用户组记录。

当然/etc/passwd和/etc/group和加密信息文件/etc/shadow和/etc/gshadow也会同步生成记录，同时系统还会根据/etc/default/useradd文件中所配置的信息建立用户的家目录，并复制/etc/skel中的所有文件（包括隐藏的环境配置文件）到新用户家目录中。
### 2.2.1.	useradd语法
名称：
```
useradd - create a new user or update default new user information
```

#建立一个新用户或更新默认新用户信息
```
语法：
useradd [-c comment] [-d home_dir]
[-e expire_date] [-f inactive_time]
[-g initial_group] [-G group[,...]]
[-m [-k skeleton_dir] | -M] [-s shell]
[-u uid [ -o]] [-n] [-r] login

useradd -D [-g default_group] [-b default_home]
[-f default_inactive] [-e default_expire_date]
[-s default_shell]

描述：
When invoked without the -D option, the useradd command creates a new user account using the values specified on the command line and the default values from the system. Depending on command line options, the useradd command will update system files and may also create the new user'home directory and copy initial files. The version provided with Red Hat Linux will create a group for each user added to the system by default.
新用户建立
当不加 -D 参数, useradd 指令使用命令列来指定新帐号的设定值和使用系统上的预设值（如前面提到的/etc/login.defs和/etc/default/useradd等配置文件）。新使用者帐号将产生一些系统文件，如用户目录建立，拷备起始文件等，这些均可以利用命令列选项指定。此版本为RedHatLinux提供，可帮每个新加入的用户建立和用户同名的 group ,要达到这个目的，不能添加-n选项。

选项与参数：
参数选项(绿色部分必须掌握)	说明
-c, --comment COMMENT	/etc/passwd 的第五列(用户信息说明)的说明内容。
-d, --home HOME_DIR	指定某个目录成为家目录，而不要使用默认值。请使用绝对路径！
-e, --expiredate EXPIRE_DATE	The date on which the user account will be disabled. The date is specified in the format YYYY-MM-DD.
账号失效日，格式为”YYYY-MM-DD”, shadow 第八字段。
-f, --inactive INACTIVE  
The number of days after a password expires until the account is permanently disabled. 账号过期几日后永久停权。后面接 shadow 的第七字段项目，指定口令是否会失效。0为立刻失效，-1 关闭此功能，默认值为-1。
-g, --gid GROUP	初始化群组，group名称或以数字来做为用户登入起始用户组。用户组名称为系统现在存在的名称。用户组数字也须为现在存在的用户组。默认的用户组数字为1。
-G, --groups GROUP1[,GROUP2,...[,GROUPN]]]	定义此用户为多个为不同groups的成员。每个用户组用,分隔。用户组名同-g选项的限制。默认值为用户的起始用户组。
-m, --create-home 	用户目录不存在则自动建立！
-M  	不要创建用户家目录！优先于/etc/login.defs文件的设定
-n	默认情况用户的用户组与用户的名称会相同。如果命令加了-n参数，就不会生成和用户同名的用户组了。
-r	创建一个系统的账号，这个账号的 UID 会有限制 (参考 /etc/login.defs。注意useradd此用法所建立的账号不会建立用户家目录，也不会在乎/etc/login.defs的定义值。如果想要有家目录须额外指定-m参数，这是redhat 额外指定的选项。
-s, --shell SHELL	后面接一个 shell ，若没有则根据/etc/default/useradd的值预设。
-u, --uid UID
用户的id值。这个值必须是唯一的，除非用-o选项。数字不可为负值。
```

### 2.2.2.	更改用户默认设置useradd -D
```
当执行useradd加-D选项时，可以更改新建用户的默认配置值，或是由命令列编辑的方式更新预设值。
useradd –D其实际效果就是修改/etc/default/useradd文件的默认值。
参数选项(绿色部分必须掌握)	说明
-b HOME_DIR	定义用户所属目录的前一个目录。用户名称会附加在HOME_DIR后面用来建立新用户的目录。使用-d后此选项无效。
-e EXPIRE_DATE	The date on which the user account is disabled.
用户账号停止日期。
-f INACTIVE	The number of days after a password has expired before the account will be disabled.
账号过期几日后停。
-g, --gid GROUP	The group name or ID for a new user'initial group. The named group must exist, and a numerical group ID must have an existing entry.
新账号起始用户组名或ID。用户组名必须为现在存在的名称。用户ID也必须为现在存在的用户组。
-s, --shell SHELL	The name of the new user'login shell. The named program will be used for all future new user accounts.
用户登录后使用的shell名称。修改后新加入的用户都使用此shell类型，useradd –s 参数优先于此默认配置值。

相关文件：
/etc/passwd 	User account information.			#用户账号信息
/etc/shadow	Secure user account information.	#用户密码
/etc/group	Group account information.			#用户组
/etc/gshadow	Secure group account information.
/etc/default/useradd 	Default values for account creation.	#创建用户默认值
/etc/skel/	Directory containing default files.				#含有默认文件的目录
/etc/login.defs	Shadow password suite configuration.
2.2.3.	useradd实例
实例1：不加任何参数，直接执行useradd username添加用户
[root@stu412 ~]# useradd user01
[root@stu412 ~]# ls -ld /home/user01				#家目录存在
drwx------ 2 user01 user01 4096 Jul  8 08:44 /home/user01

[root@stu412 home]# grep user01 /etc/passwd		#查看用户信息
user01:x:916:916::/home/user01:/bin/bash

[root@stu412 home]# finger user01					#用finger查看用户信息
Login: user01                           Name: (null)
Directory: /home/user01                 Shell: /bin/bash
Never logged in.
No mail.
No Plan.
[root@stu412 home]# grep user01 /etc/shadow		#下面相关文件中都有相关记录
user01:!!:15529:0:99999:7:::
[root@stu412 home]# grep user01 /etc/group
user01:x:916:
[root@stu412 home]# grep user01 /etc/gshadow
user01:!::


实例2：useradd的-g、-u参数，执行useradd [参数] username 添加用户
[root@stu412 home]# groupadd -g 801 sa
groupadd: group sa exists		#组已经存在
[root@stu412 home]# groupadd -g 566 new-group		#添加新组
[root@stu412 home]# useradd -g new-group -u 966 user02
#创建用户user02,属于指定组new-group,指定uid为966,用户名为user02


生产环境中创建用户的完整命令例子
#groupadd –g 801 sa								#添加组
#useradd –g sa –u 901 ett						#添加用户及指定其组
#echo "sadasdasdasd" | passwd ett --stdin	#设置密码
#echo "ett ALL=(ALL)		NOPASSWD:ALL">>/etc/sudoers	#设置sudo
#清除记录
#visudo –c
#history -c

实例3：useradd的-M、-s参数
[root@stu412 home]# useradd user03 -M -s /sbin/nologin
#-M不创建家目录，-s指定登录后的shell,/sbin/nologin表示禁止登录。生产环境配置apache等服务时常用。
[root@stu412 home]# ls -l /home/		#找不到user03
total 40
drwx------ 2 mop    mop       4096 Jul  8 07:55 mop
drwx------ 2 mysql  mysql     4096 Jun 10 00:03 mysql
drwx------ 2 squid1 squid1    4096 Jun  9 17:06 squid1
drwx------ 2 squid2 squid2    4096 Jun  9 17:06 squid2
drwx------ 2 user01 user01    4096 Jul  8 08:44 user01
drwx------ 2 user02 new-group 4096 Jul  8 08:58 user02
drwx------ 2 vbird  vbird     4096 Jun 22 21:45 vbird
drwx------ 2 vbird1 vbird1    4096 Jun 22 17:31 vbird1
drwx------ 2 vbird2 users     4096 Jul  3 06:33 vbird2
drwx------ 2 www    www       4096 Jun  9 23:50 www

[root@stu412 home]# grep user03 /etc/passwd
user03:x:967:967::/home/user03:/sbin/nologin
[root@stu412 home]# su - user03			#不能切换用户
su: warning: cannot change directory to /home/user03: No such file or directory
This account is currently not available.

实例4：useradd的-e参数
-e设定账号什么时候过期。
[root@stu412 home]# date +%F
2012-07-08
[root@stu412 home]# useradd  tmpuser -e 07/07/12
[root@stu412 home]# su - tmpuser
[tmpuser@stu412 ~]$ pwd
/home/tmpuser

[root@stu412 home]# chage -l tmpuser
Last password change                                    : Jul 08, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Jul 07, 2012		#账号过期日期
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7

----------------
[root@stu412 home]# useradd  tmpuser2 -e 07/05/12		#添加用户tmpuser2
[root@stu412 home]# passwd tmpuser2
Changing password for user tmpuser2.
New UNIX password:
BAD PASSWORD: it does not contain enough DIFFERENT characters
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
[root@stu412 home]# date +%F
2012-07-08
[root@stu412 home]# su - tmpuser2
[tmpuser2@stu412 ~]$
但使用ssh登录tmpuser2时，提示：
Your account has expired; please contact your system administrator

用户过期时间到了但还没有失效：
(1)	通过-e设置后无法远程登录ssh连接，但是可以su切换，账户并未锁定。
(2)	账户过期时间和系统时间，需相差2天。

实例5：useradd的-c、-u、-G、-s、-d多个参数组合例子
添加用户user007，并设置其用户注释信息为"add user007"，UID为806，归属用户组root,oldboy、sa，其shell类型为/bin/sh，并设置家目录为/ user007。
[root@stu412 ~]# useradd -c "add user007" -u 806 -G root,oldboy,sa -s /bin/sh -d /user007 user007
[root@stu412 ~]# grep user007 /etc/passwd	#passwd有相关记录
user007:x:806:806:add user007:/user007:/bin/sh
[root@stu412 ~]# ls -ld /user007/
drwx------ 2 user007 user007 4096 Jul  8 09:50 /user007/
[root@stu412 ~]# finger user007
Login: user007                          Name: add user007
Directory: /user007                     Shell: /bin/sh
Never logged in.
No mail.
No Plan.
[root@stu412 ~]# id user007		#查看用户id信息
uid=806(user007) gid=806(user007) groups=806(user007),0(root),801(sa),970(oldboy)
#添加新用户时，不使用-n参数，则自动创建user007组。
```
### 2.2.4.	useradd -D实例
```
实例6：不加任何参数执行useradd –D,直接显示/etc/default/useradd的值
[root@stu412 ~]# useradd -D
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes


实例7：添加用户时默认shell类型修改为/bin/sh
[root@stu412 ~]# cat /etc/shells
/bin/sh
/bin/bash
/sbin/nologin
/bin/tcsh
/bin/csh
/bin/ksh
[root@stu412 ~]# grep SHELL /etc/default/useradd
SHELL=/bin/bash
[root@stu412 ~]# useradd -D -s /bin/sh
[root@stu412 ~]# grep SHELL /etc/default/useradd
SHELL=/bin/sh

[root@stu412 ~]# useradd user05
[root@stu412 ~]# grep user05 /etc/passwd	#shell已经修改了
user05:x:970:971::/home/user05:/bin/sh

[root@stu412 ~]# useradd -D -s /bin/bash　#修改回去
[root@stu412 ~]# grep SHELL /etc/default/useradd
SHELL=/bin/bash
提示：这里修改配置文件的默认值，仅对建立的新用户生效，和老用户无关。
```
### 2.3.	groupadd添加用户组
与groupadd命令相关的文件有：

    /etc/group      用户组相关文件
    /etc/gshadow    用户组加密相关文件

提示：groupdel比较简单，工作中使用的频率也非常少，会简单应用就可以了。

### 2.3.1.	语法
groupadd - create a new group 			#创建新的用户组

```
# groupadd [-g gid] [-r] [-f] 组名
选项与参数：
参数选项(绿色要掌握)	说明
-g GID	The numerical value of the group’s ID. This value must be unique, unless the -o option is used. The value must be non-negative. The default is to use the smallest ID value greater than 500 and greater than every other group. Values between 0 and 499 are typically reserved for system accounts.
#后面是gid的值。除非使用-o选项，否则值必须唯一。不能使用负值。默认使用最小id值要大于500并且大于其它用户组。0至499值通常赋予系统账户。
-r	创建系统群组！与 /etc/login.defs 内的 GID_MIN 有关。
-f	强制覆盖一个已经存在的用户组账户。
[root@stu412 ~]# groupadd ett
groupadd: group ett exists
[root@stu412 ~]# groupadd -f ett
-o	This option permits to add group with non-unique GID.
组id不必唯一。
```

### 2.3.2.	实例
```
[root@stu412 ~]# groupadd -g 805 group1
[root@stu412 ~]# tail -1 /etc/group
group1:x:805:
[root@stu412 ~]# tail -1 /etc/gshadow
group1:!::
[root@stu412 ~]# groupadd  group2
[root@stu412 ~]# tail -1 /etc/group
group2:x:973:
[root@stu412 ~]# tail -1 /etc/gshadow
group2:!::
```
## 2.4.	passwd用户密码相关
普通用户和超级用户都可以使用passwd命令，但普通用户只能修改自身的用户密码，超级用户root 可以设置和修改所有用户的密码。
passwd不加任何参数时，则表示修改当前登录用户的密码。
```
[root@stu412 ~]# passwd		#root修改自己的密码
Changing password for user root.
New UNIX password:
BAD PASSWORD: it is based on a dictionary word
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
[root@stu412 ~]# passwd user01	#root修改user01的密码
Changing password for user user01.
New UNIX password:
BAD PASSWORD: it does not contain enough DIFFERENT characters
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
提示：root修改普通用户的密码，不需要输入用户的旧密码。

[user01@stu412 ~]$ passwd			#user01修改自己的密码
Changing password for user user01.
Changing password for user01
(current) UNIX password:
New UNIX password:
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
```
### 2.4.1.	语法
passwd [-k] [-l] [-u [-f]] [-d] [-n mindays] [-x maxdays] [-w warndays] [-i inactivedays] [-S] [--stdin] [username]

```
参数选项(绿色部分必须掌握)	说明
-k, --keep-token	keep their non-expired tokens as before.
保留即将过期的用户在期满后仍能使用
-d, --delete	This  is a quick way to delete a password for an account. It will set the named account passwordless. (root only)
删除用户密码，仅能以root权限操作
-l, --lock	lock the specified account. (root only)
锁住用户无权更改其密码，仅能以root权限操作。会将 /etc/shadow 第二栏最前面加上 ! 使口令失效；
－u, --unlock	it will unlock the account password by removing the ! prefix.(root only)
解除锁定
-f, --force	强制操作(root only)
-x, --maxinum=DAYS	This will set the number of days in advance the user will begin receiving warnings that her password will  expire,if the user'account supports password lifetimes. (root only).
两次密码修改的最大天数，后面接数字；
-n, --minmun=DAYS	This will set the minimum password lifetime, in days, if the user'account supports password  lifetimes.   Available to root only.
两次密码修改的最小天数，后面接数字；
-w ,--warning=DAYS	This will set the number of days in advance the user will begin receiving warnings that her password will  expire,if the user' account supports password lifetimes.  Available to root only.
密码过期前多少天的提醒用户
-i ,--inactice=DAYS	This will set the number of days which will pass before an expired password for this account will be taken to mean　that the account is inactive and should be disabled, if the user'account supports password lifetimes.  Available　to root only.
在密码过期后多少天，用户被禁掉，仅能以root操作。
-S ,--status	This  will output a short information about the status of the password for a given account. Available to root user
查询用户密码状态
only.
--stdin	This option is used to indicate that passwd should read the new password from standard input, which can be a pipe.
从stdin输入密码
```
### 2.4.2.	实例
```
实例1：使用-l锁定用户user01,使之不能修改密码，然后使用-u参数解除锁定
[root@stu412 ~]# passwd -S user01
user01 PS 2012-07-08 0 99999 7 -1 (Password set, MD5 crypt.)
[root@stu412 ~]# grep user01 /etc/shadow
user01:$1$7RjEBY8f$/L8ZEwjrntlUDCDOom8XC.:15529:0:99999:7:::
[root@stu412 ~]# passwd -l user01		#锁定用户user01
Locking password for user user01.
passwd: Success

[user01@stu412 ~]$ passwd				#user01不能修改自己的密码
Changing password for user user01.
Changing password for user01
(current) UNIX password:
passwd: Authentication token manipulation error

[root@stu412 ~]# grep user01 /etc/shadow	#密码前多了两个!!
user01:!!$1$7RjEBY8f$/L8ZEwjrntlUDCDOom8XC.:15529:0:99999:7:::

[root@stu412 ~]# passwd -u user01		#解除锁定
Unlocking password for user user01.
passwd: Success.
[root@stu412 ~]# grep user01 /etc/shadow
user01:$1$7RjEBY8f$/L8ZEwjrntlUDCDOom8XC.:15529:0:99999:7:::  #!!已经消失了

[user01@stu412 ~]$ passwd				#user01可以修改自己的密码了
Changing password for user user01.
Changing password for user01
(current) UNIX password:
New UNIX password:


实例2：-d参数清除user01密码，然后使用-s来查看
[root@stu412 ~]# passwd -d user01
Removing password for user user01.
passwd: Success
[root@stu412 ~]# passwd -S user01
user01 NP 2012-07-08 0 99999 7 -1 (Empty password.)

实例3：组合参数-x –n –w –i控制密码时效的例子
[root@stu412 ~]# date +%F
2012-07-08
[root@stu412 ~]# chage -l user01
Last password change                                    : Jul 08, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0 #可以随时修改密码
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7	#过期前7天提醒用户
要求user01用户7天内不能修改密码，60天以后必须要修改密码，过期前10天通过user01用户，过期后30天后禁止登录。
[root@stu412 ~]# passwd -n 7 -x 60 -w 10 -i 30 user01
#chage –m 7 –M 60 –W 10 –I 30 user01 也能实现同样的功能
Adjusting aging data for user user01.
passwd: Success
[root@stu412 ~]# chage -l user01
Last password change                                    : Jul 08, 2012 #2012-07-08
Password expires                                        : Sep 06, 2012  #2012-09-06
Password inactive                                       : Oct 06, 2012  #2012-10-06
Account expires                                         : never
Minimum number of days between password change          : 7  #7天内不能修改密码
Maximum number of days between password change          : 60 #60天以后必须要修改密码
Number of days of warning before password expires       : 10 #过期前10天通过用户

实例3：用--stin参数实现非交互式的批量设置或修改密码
[root@stu412 ~]# echo "123456" | passwd --stdin user01 #修改user01的密码为123456
Changing password for user user01.
passwd: all authentication tokens updated successfully.

[root@stu412 ~]# history | tail
1100  grep user01 /etc/shadow
1101  passwd -d user01
1102  passwd -S user01
1103  passwd user01
1104  date +%F
1105  chage -l user01
1106  passwd -n 7 -x 60 -w 10 -i 30 user01
1107  chage -l user01
1108  echo "123456" | passwd --stdin user01		#历史命令中会存在记录
1109  history | tail
[root@stu412 ~]# history –c		#清除历史记录
#上面设置的密码虽然不需要交互，但密码会以明文的方式保存在历史记录里。一般批量设置密码分发给管理员后，要强制大家更改密码。
[root@stu412 ~]# cat us.sh #批量添加用户和设置密码脚本
#!/bin/sh
userchars="quxl";
for num in `seq 3`
do
useradd $userchars$num
passwd=`date|md5sum|cut -c3-20`
echo "$passwd" | passwd --stdin $userchars$num
echo -e "user:$userchars$num \tpasswd:$passwd">>/tmp/user.log
sleep 1
done
echo ----------
cat /tmp/user.log

[root@stu412 ~]# sh us.sh
Changing password for user quxl1.
passwd: all authentication tokens updated successfully.
Changing password for user quxl2.
passwd: all authentication tokens updated successfully.
Changing password for user quxl3.
passwd: all authentication tokens updated successfully.
----------
user:quxl1      passwd:7330e378f3fa9094b7
user:quxl2      passwd:80dd35e8b6dc97fb93
user:quxl3      passwd:553d842ced02c3e6a7

[root@stu412 ~]# cat /etc/passwd | tail	#查看生成的用户
user01:x:916:916::/home/user01:/bin/bash
user02:x:966:566::/home/user02:/bin/bash
user03:x:967:967::/home/user03:/sbin/nologin
tmpuser:x:968:968::/home/tmpuser:/bin/bash
tmpuser2:x:969:969::/home/tmpuser2:/bin/bash
user007:x:806:806:add user007:/user007:/bin/sh
user05:x:970:971::/home/user05:/bin/sh
quxl1:x:971:974::/home/quxl1:/bin/bash
quxl2:x:972:975::/home/quxl2:/bin/bash
quxl3:x:973:976::/home/quxl3:/bin/bash
```
提示：linux里也有相应的的命令（newusers –update and create new users in batch）和(chpasswd –update passwords in batch mode)可以实现批量添加并设置密码。由于生产场景中，不经常使用，并且使用起来也不简单，这里就不多介绍了。有兴趣的，可以自行man newusers和man chpasswd。
### 2.4.3.	passwd总结
在实际工作中，最常用的用法就是直接使用passwd加用户名和修改密码，其次使用—-stdin参数批量无交互设置密码，其他的参数用的很少(如-l,-u,-S等)。

在生产场景中，我们设置密码时，密码应该尽可能的复杂且无规律，但又利于记忆。比较好的密码是数字字母（包括大小写及特殊符号的组合），并且8位以上。比如：曾经使用的密码”IAM33oldboy”,意思是我是33岁的oldboy,比较复杂但又利于自我记忆。(提示：引号也是密码的一部分)。或者这样设置密码”oldBOY@)!@)!@#”看着复杂吧，其实oldBOY后面的特殊字符就是20120123(同时按shift键输入的结果),总之，实际工作中系统安全是非常重要的环节，而密码的设置方法和策略更是重中之重。

## 2.5.	chage修改用户密码有效期限

chage - change user password expiry information 修改用户密码有效期限

### 2.5.1.	语法
```
chage [options] user
chage [选项] 用户名

参数选项(绿色部分要掌握)	说明
-d, --lastday LAST_DAY	Set the number of days since January 1st, 1970 when the password was last changed. The date may also be expressed in the format YYYY-MM-DD (or the format more commonly used in your area).
-E, --expiredate EXPIRE_DATE	帐号到期的日期。
-I, --inactive INACTIVE	密码超过-M设定的有效期后，并在-i设定的天数内未修改密码，则帐号停用。
-l ,--list	Show account aging information.列出用户的以及密码的有效期限。
-m, --mindays MIN_DAYS	两次修改密码之间相距的最小天数。为0代表任何时候都可以更改密码。
-M, --maxdays MAX_DAYS	两次修改密码相距的最大天数。
-W, --warndays WARN_DAYS	用户密码到期前，提前收到警告信息的天数。
```

### 2.5.2.	实例
```
实例1：使用-l显示用户信息
[root@stu412 ~]# chage -l user01
Last password change                                    : Jul 08, 2012
Password expires                                        : Sep 06, 2012
Password inactive                                       : Oct 06, 2012
Account expires                                         : never
Minimum number of days between password change          : 7
Maximum number of days between password change          : 60
Number of days of warning before password expires       : 10


实例2：组合参数-m –M –W –I控制密码时效的例子(如passwd命令实例3)
要求user02用户7天内不能修改密码，60天以后必须要修改密码，过期前10天通过user02用户，过期后30天后禁止登录。
[root@stu412 ~]# date +%F
2012-07-08
[root@stu412 ~]# chage -l user02
Last password change                                    : Jul 08, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
[root@stu412 ~]# chage -m 7 -M 60 -W 10 -I 30 user02
[root@stu412 ~]# chage -l user02
Last password change                                    : Jul 08, 2012
Password expires                                        : Sep 06, 2012
Password inactive                                       : Oct 06, 2012
Account expires                                         : never
Minimum number of days between password change          : 7
Maximum number of days between password change          : 60
Number of days of warning before password expires       : 10


实例3：-E参数修改账户有效期
[root@stu412 ~]# chage -E 06/26/12 user02 #等同usermod –e 06/26/12 user02
[root@stu412 ~]# chage -l user02
Last password change                                    : Jul 08, 2012
Password expires                                        : Sep 06, 2012
Password inactive                                       : Oct 06, 2012
Account expires                                         : Jun 26, 2012
Minimum number of days between password change          : 7
Maximum number of days between password change          : 60
Number of days of warning before password expires       : 10
```
### 2.5.3.	总结
在平时生产环境中，偶尔会用chage的-l和-E参数，其它的参数就很少用了。

设置密码时效有利有弊。优点是可以防止运维人员离职后还可以登录系统。密码时效可强制系统管理人员修改定期密码，提升系统安全性。缺点是本该保留的用户不能登录了。

大规模运维环境中，使用LDAP服务对linux账户统一认证，批量管理，也是不错的方法。

## 2.6.	userdel删除用户
相关文件:/etc/passwd, /etc/shadow，/etc/group　
### 2.6.1.	语法
```
名称：	userdel - delete a user account and related files
#删除用户账户及相关文件
语法：userdel [options] LOGIN
描述：The userdel command modifies the system account files, deleting all entries that refer to login_name. The named user must exist
userdel命令会修改用户账户文件，删除关联到用户名的所有实体文件。用户名必须要存在。

选项与参数：
-r, --remove  ：连同用户的家目录也一起删除,但属于用户的其它文件或目录是没有被删除的。
```
### 2.6.2.	实例
```
实例1：删除用户quxl1
[root@stu412 ~]# grep quxl1 /etc/passwd
quxl1:x:971:974::/home/quxl1:/bin/bash
[root@stu412 ~]# userdel quxl1
[root@stu412 ~]# ls -l /home/
total 64
drwx------ 2 mop      mop       4096 Jul  8 07:55 mop
drwx------ 2 mysql    mysql     4096 Jun 10 00:03 mysql
drwx------ 2      971       974 4096 Jul  8 13:46 quxl1	#quxl1家目录还存在
drwx------ 2 quxl2    quxl2     4096 Jul  8 13:46 quxl2
drwx------ 2 quxl3    quxl3     4096 Jul  8 13:46 quxl3
drwx------ 2 squid1   squid1    4096 Jun  9 17:06 squid1
drwx------ 2 squid2   squid2    4096 Jun  9 17:06 squid2
drwx------ 2 tmpuser  tmpuser   4096 Jul  8 09:13 tmpuser
drwx------ 2 tmpuser2 tmpuser2  4096 Jul  8 09:44 tmpuser2
drwx------ 2 user01   user01    4096 Jul  8 11:52 user01
drwx------ 2 user02   new-group 4096 Jul  8 08:58 user02
drwx------ 2 user05   user05    4096 Jul  8 10:03 user05
drwx------ 2 vbird    vbird     4096 Jun 22 21:45 vbird
drwx------ 2 vbird1   vbird1    4096 Jun 22 17:31 vbird1
drwx------ 2 vbird2   users     4096 Jul  3 06:33 vbird2
drwx------ 2 www      www       4096 Jun  9 23:50 www

实例2：userdel [-r] 用户名 方式删除
userdel –r表示在删除用户的同时，一并把用户的家目录及本地邮件存储的目录和文件也一同删除。
在生产环境中，请不要轻易使用-r参数，如果非要删除家目录，请在删除前备份文件。

[root@stu412 ~]# mkdir /user05	#测试看，等下user05删除了，此目录是否存在
[root@stu412 ~]# chown -R user05.user05 /user05
[root@stu412 ~]# ls -ld /home/user05
drwx------ 2 user05 user05 4096 Jul  8 10:03 /home/user05
[root@stu412 ~]# userdel -r user05
[root@stu412 ~]# ls -ld /user05
#还存在，但用户和用户组处显示了数字。说明用户相关的文件和目录未被删除！
drwxr-xr-x 2 970 971 4096 Jul  8 15:32 /user05
[root@stu412 ~]# ls -ld /home/user05
ls: /home/user05: No such file or directory


范例3：手动删除指定账户tmpuser
[root@stu412 ~]# /bin/cp /etc/passwd /etc/passwd.bak				#备份
[root@stu412 ~]# grep tmpuser /etc/passwd
tmpuser:x:968:968::/home/tmpuser:/bin/bash
[root@stu412 ~]# sed -i 's#tmpuser#\#tmpuser#g' /etc/passwd		#注释
[root@stu412 ~]# grep tmpuser /etc/passwd
#tmpuser:x:968:968::/home/#tmpuser:/bin/bash  
[root@stu412 ~]# sed -i 's#\#tmpuser#tmpuser#g' /etc/passwd		#还原
[root@stu412 ~]# grep tmpuser /etc/passwd
tmpuser:x:968:968::/home/tmpuser:/bin/bash
```
直接在/etc/passwd中注释或删除用户的记录的方法也是生产环境中常用的方法，但是在操作时一定要小心。当然，操作前备份也是必要的。
### 2.6.3.	总结
一般生产环境中，当无法确定被删除用户家目录等是否有用或者有不规范用户已在家目录下跑了脚本或程序的时候，就不要使用“userdel –r 用户名”这样的危险行为，而是直接使用"userdel 用户名"删除即可。

我们还可以直接使用vi编辑/etc/passwd，找到要处理的用户，先注释一段时间，确认真的没有问题了，然后再清除其家目录。注释的作用和userdel命令删除的效果一样，就是实现了被注释的用户无法登录，一旦发现问题，我们可以进行恢复。对于上千台服务器运维的情况，我们可以使用ldap等服务实现账户统一认证，批量添加删除管理。

## 2.7.	groupdel删除用户组
```
名称：groupdel - delete a group #删除用户组，并要求用户必须是已经存在的。
语法：groupdel group
描述：The groupdel command modifies the system account files, deleting all entries that refer to group. The named group must exist.
You must manually check all file systems to insure that no files remain with the named group as the file group ID.

[root@stu412 ~]# groupadd newg
[root@stu412 ~]# grep newg /etc/group
newg:x:977:
[root@stu412 ~]# grep newg /etc/gshadow
newg:!::
[root@stu412 ~]# groupdel newg
[root@stu412 ~]# grep newg /etc/gshadow
[root@stu412 ~]# grep newg /etc/group

groupdel比较简单，工作中使用的频率也非常少，大家会以上的简单应用就可以。
```
## 2.8.	chfn修改finger信息
这个命令在生产环境很少用，大家了解即可。
```
chfn - change your finger information #修改finger信息

语法：
chfn [ -f full-name ] [ -o office ] [ -p office-phone ] [ -h home-phone ] [ -u ] [ -v ] [ username ]

描述：
chfn  is used to change your finger information.  This information is stored in the /etc/passwd file, and is displayed by
the finger program.  The Linux finger command will display four pieces of information that can be changed by chfn :  your
real name, your work room and phone, and your home phone.

COMMAND LINE
Any  of  the  four pieces of information can be specified on the command line.  If no information is given on the command
line, chfn enters interactive mode.

INTERACTIVE MODE
In interactive mode, chfn will prompt for each field.  At a prompt, you can enter the  new  information,  or  just  press
return to leave the field unchanged.  Enter the keyword "none" to make the field blank.

选项：
-f, --full-name
Specify your real name.
-o, --office
Specify your office room number.
-p, --office-phone
Specify your office phone number.
-h, --home-phone
Specify your home phone number.
-u, --help
Print a usage message and exit.
-v, --version
Print version information and exit.



[root@stu412 ~]# finger user01
Login: user01                           Name: (null)
Directory: /home/user01                 Shell: /bin/bash
Never logged in.
No mail.
No Plan.
[root@stu412 ~]# chfn user01
Changing finger information for user01.
Name []: user01
Office []: user-office
Office Phone []: 150000^H
Control characters are not allowed.
Office Phone []: ^[[A^[[A
Control characters are not allowed.
Office Phone []: 15900000000
Home Phone []: 15900000000

Finger information changed.
[root@stu412 ~]# finger user01
Login: user01                           Name: user01
Directory: /home/user01                 Shell: /bin/bash
Office: user-office, +1-590-000-0000    Home Phone: +1-590-000-0000
Never logged in.
No mail.
No Plan.
```
## 2.9.	chsh修改用户shell类型
```
chsh主要用来更改用户登录的shell,除root可以使用外，普通用户也可以使用。此命令了解即可。
chsh - change your login shell
语法：
chsh [ -s shell ] [ -l ] [ -u ] [ -v ] [ username ]
描述：
chsh is used to change your login shell.  If a shell is not given on the command line, chsh prompts for one.
选项：
-s, --shell
Specify your login shell.
-l, --list-shells
Print the list of shells listed in /etc/shells and exit.
-u, --help
Print a usage message and exit.
-v, --version
Print version information and exit.


[root@stu412 ~]# chsh –l	#列举shell类型
/bin/sh
/bin/bash
/sbin/nologin
/bin/tcsh
/bin/csh
/bin/ksh

[root@stu412 ~]# finger user02
Login: user02                           Name: (null)
Directory: /home/user02                 Shell: /bin/bash
Never logged in.
No mail.
No Plan.
[root@stu412 ~]# chsh -s /sbin/nologin user02	#修改user02的shell类型
Changing shell for user02.
Shell changed.
[root@stu412 ~]# finger user02
Login: user02                           Name: (null)
Directory: /home/user02                 Shell: /sbin/nologin
Never logged in.
No mail.
No Plan.
```
## 2.10.	usermod修改用户信息
usermod相关文件：/etc/passwd,/etc/shadow,/etc/group

在众多命令中，usermod是一个不经常使用。但是是一个功能强大的命令，我们应该掌握此命令。

### 2.10.1.	语法
```
名称：usermod - modify a user account
语法：usermod [options] LOGIN
描述：The usermod command modifies the system account files to reflect the changes that are specified on the command line.

选项参数：
选项参数(绿色部分要掌握)	注释说明
-c, --comment COMMENT	The new value of the user's password file comment field. It is normally modified using the chfn(1) utility.
添加/etc/passwd的注解说明栏（第5栏）。-c参数也可以用chfn实现。
-d, --home HOME_DIR	The user' new login directory. If the -m option is given the contents of the current home directory will be moved to the new home directory, which is created if it does not already exist.
更新用户新的家目录。如果给定-m选项，用户旧的家目录会搬到新的家目录去，如旧的家目录不存在则建个新的。
-e, --expiredate EXPIRE_DATE	The date on which the user account will be disabled. The date is specified in the format YYYY-MM-DD.
用户账户失效日期，格式YYYY-MM-DD
-f, --inactive INACTIVE	The number of days after a password expires until the account is permanently disabled. A value of 0 disables the account as soon as the password has expired, and a value of -1 disables the feature. The default value is -1.
账号过期几日后永久停权。当值为0时则立刻被停权，为-1时关闭此功能。默认值为-1。
-g, --gid GROUP	The group name or number of the user new initial login group. The group name must exist. A group number must refer  to an already existing group. The default group number is 1.
更新用户新的起始登入用户组。用户名须已存在。用户组ID必须参照既有的用户组。用户组ID默认值为1。
-G, --groups GROUP1[,GROUP2,...[,GROUPN]]]	定义用户一堆组的成员。每个组用,分开。用户组名同-g选项的限制。
-l, --login NEW_LOGIN	修改用户login时的名称为login_name。其余信息不变。
-s, --shell SHELL	The name of the user's new login shell. Setting this field to blank causes the system to select the default login shell.
指定新登入shell。如果此栏为空，系统则选用系统默认shell
-u, --uid UID	指定用户UID值。除非接-o参数（如:usermod –u 505 –o oldboy）,否则ID值必须是唯一的数字（不能为负数）。
-L	冻结用户的密码，使之无法登录。实际是间接修改/etc/shadow的密码栏，在密码栏开头加上"!"号，表示冻结。与usermod –e,useradd –e,chage –E或passwd –l等类似。
-U	取消冻结用户的密码，使之恢复登录。
```
### 2.10.2.	实例
```
实例1：使用不同的方法修改/etc/passwd中用户的说明栏。
[root@stu412 ~]# tail -1 /etc/passwd
user007:x:806:806:add user007:/user007:/bin/sh
[root@stu412 ~]# usermod -c usemod user007		#usermod用法
[root@stu412 ~]# tail -1 /etc/passwd
user007:x:806:806:usemod:/user007:/bin/sh

[root@stu412 ~]# chfn -f chfn user007			#chfn用法
Changing finger information for user007.
Finger information changed.
[root@stu412 ~]# tail -1 /etc/passwd
user007:x:806:806:chfn:/user007:/bin/sh

实例2：借用useradd的实例５来测试usermod的-c,-u,-G,-s ,-d等参数。
实例3：useradd的-c、-u、-G、-s、-d多个参数组合例子
添加用户user007，并设置其用户注释信息为"add user007"，UID为806，归属用户组root,oldboy、sa，其shell类型为/bin/sh，并设置家目录为/ user007。
[root@stu412 ~]# useradd -c "add user007" -u 806 -G root,oldboy,sa -s /bin/sh -d /user007 user007
[root@stu412 ~]# grep user007 /etc/passwd	#passwd有相关记录
user007:x:806:806:add user007:/user007:/bin/sh
[root@stu412 ~]# ls -ld /user007/
drwx------ 2 user007 user007 4096 Jul  8 09:50 /user007/
[root@stu412 ~]# finger user007
Login: user007                          Name: add user007
Directory: /user007                     Shell: /bin/sh
Never logged in.
No mail.
No Plan.
[root@stu412 ~]# id user007		#查看用户id信息
uid=806(user007) gid=806(user007) groups=806(user007),0(root),801(sa),970(oldboy)
#添加新用户时，不使用-n参数，则自动创建user007组。
现用户信息修改为oldBoy,UID修改为1806,归属修改为用户组root,sa成员。shell修改为/bin/tcsh,家目录修改为/tmp/user007。
[root@stu412 ~]# usermod -c oldboy -u 1806 -G root,sa -s /bin/tcsh -d /tmp/user007 user007
[root@stu412 ~]# id user007
uid=1806(user007) gid=806(user007) groups=806(user007),0(root),801(sa)
[root@stu412 ~]# grep user007 /etc/passwd
user007:x:1806:806:oldboy:/tmp/user007:/bin/tcsh
[root@stu412 ~]# finger user007
Login: user007                          Name: oldboy
Directory: /tmp/user007                 Shell: /bin/tcsh
Never logged in.
No mail.
No Plan.


实例3：使用户在2012-01-22后过期。
[root@stu412 ~]# usermod -e 01/22/12 tmpuser
[root@stu412 ~]# chage -l tmpuser
Last password change                                    : Jul 08, 2012
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : Jan 22, 2012 #结果
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7

实例4：冻结用户的密码。
[root@stu412 ~]# grep testuser /etc/shadow
testuser:$1$APD36v7C$.CbUHKSO4RBepm01WIlAc.:15529:0:99999:7:::
[root@stu412 ~]# usermod -L testuser		#冻结
[root@stu412 ~]# grep testuser /etc/shadow
testuser:!$1$APD36v7C$.CbUHKSO4RBepm01WIlAc.:15529:0:99999:7:::
[root@stu412 ~]# usermod -U testuser		#解冻
[root@stu412 ~]# grep testuser /etc/shadow
testuser:$1$APD36v7C$.CbUHKSO4RBepm01WIlAc.:15529:0:99999:7:::
```
## 2.11.	用户查询相关命令id、finger、users、w、who、last、lastlog、groups
### 2.11.1.	id命令
```
id 这个命令则可以查询某人或自己的相关 UID/GID 等等的信息
总结：在生产场景中最常用的方法就是”id 用户名”或”id”的方法，读者要掌握。

语法：id [OPTION]... [USERNAME]

实例1：查询自身的相关信息
[root@stu412 ~]# id
uid=0(root) gid=0(root) groups=0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),10(wheel)


实例2：id后面接用户名
[root@stu412 ~]# id testuser
uid=1807(testuser) gid=1807(testuser) groups=1807(testuser)
[root@stu412 ~]# id user007
uid=1806(user007) gid=806(user007) groups=806(user007),0(root),801(sa)
```
### 2.11.2.	finger命令
```
finger - user information lookup program
finger侧重于用户信息的查看，包括用户名，家目录，登录shell类型，用户真实姓名等。
语法：finger [-lmsp] [user ...] [user@host ...]
参数选项(绿色部分必须掌握)	说明
-l	采用长格式(默认)，显示由-s选项所包含的所有信息。
-m	禁止对用户真实名字进行匹配
-p	把.plan和.project文件中的内容省略。
-s 	显示短格式

实例1：不接任何参数,默认即是加了-s参数
[root@stu412 ~]# finger
Login     Name       Tty      Idle  Login Time   Office     Office Phone
root      root       pts/0          Jul  8 20:17 (192.168.65.1)
[root@stu412 ~]# finger -s
Login     Name       Tty      Idle  Login Time   Office     Office Phone
root      root       pts/0          Jul  8 20:17 (192.168.65.1)
#	Tty 	登录终端
#	Idle   空闲时间


实例2：-l参数实例
[root@stu412 ~]# finger -l
Login: root                             Name: root
Directory: /root                        Shell: /bin/bash
On since Sun Jul  8 20:17 (CST) on pts/0 from 192.168.65.1
New mail received Sun Jul  8 21:21 2012 (CST)
Unread since Sat Jul  7 15:46 2012 (CST)
No Plan.


实例3：finger与w、who、last、lastlog对比
[root@stu412 ~]# finger
Login     Name       Tty      Idle  Login Time   Office     Office Phone
root      root       pts/0          Jul  8 20:17 (192.168.65.1)
[root@stu412 ~]# w
21:37:03 up  1:21,  1 user,  load average: 0.00, 0.14, 0.14
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.65.1     20:17    1.00s  0.21s  0.01s w
[root@stu412 ~]# who
root     pts/0        2012-07-08 20:17 (192.168.65.1)
[root@stu412 ~]# last
root     pts/0        192.168.65.1     Sun Jul  8 20:17   still logged in   
reboot   system boot  2.6.18-238.el5   Sun Jul  8 20:16          (01:20)    
root     pts/0        192.168.65.1     Sun Jul  8 11:57 - crash  (08:19)    
root     pts/1        192.168.65.1     Sat Jul  7 23:03 - crash  (21:12)    
root     pts/1        192.168.65.1     Sat Jul  7 20:49 - 21:56  (01:06)
…省略…
root     tty1                          Mon Jun  4 03:38 - crash (5+12:12)   
reboot   system boot  2.6.18-238.el5   Mon Jun  4 03:38         (5+20:44)

wtmp begins Mon Jun  4 03:38:13 201
[root@stu412 ~]# lastlog
Username         Port     From             Latest
root             pts/0    192.168.65.1     Sun Jul  8 20:17:00 +0800 2012
bin                                        **Never logged in**
daemon                                     **Never logged in**
adm                                        **Never logged in**
…省略…
```
### 2.11.3.	w,who,users,last,lstalog命令
```
w、who和users几个命令工具，一般是用来查询已登录当前主机的用户信息，finger也有此功能，而last,lastlog可以查看更详细的登录信。不同命令的侧重点有差别，大家可仔细对比一下。
总结：这几个命令有很多相似的地方。在生产场景中，这几个命令会经常用到，但使用的方法一般就是仅仅执行命令本身而已（极少带参数），读者在实际的工作中，可以根据需求，选择习惯使用的命令或综合使用。
#w - Show who is logged on and what they are doing.
# 显示已经登录的用户，并且都做了什么的信息,查看的信息与/var/run/utmp有关。
[root@stu412 ~]# w
21:46:19 up  1:30,  1 user,  load average: 0.00, 0.01, 0.06
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.65.1     20:17    0.00s  0.20s  0.00s w
# 第一行显示目前的时间、启动 (up) 多久，几个用户在系统上平均负载等；
# 第二行只是各个项目的说明，
# 第三行以后，每行代表一个使用者。如上所示，root 登陆并取得终端机名 pts/1 之意。

#who - show who is logged on
#显示哪些用户在登录，终端及登录时间，来源主机。
[root@stu412 ~]# who
root     pts/0        2012-07-08 20:17 (192.168.65.1)

# users - print the user names of users currently logged in to the current host
# 仅显示哪些用户在登录
[root@stu412 ~]# users
root

#finger不加参数也表示登录用户的相关信息，但这个命令还可以显示其它未登录的用户信息
[root@stu412 ~]# finger
Login     Name       Tty      Idle  Login Time   Office     Office Phone
root      root       pts/0          Jul  8 20:17 (192.168.65.1)

# last, lastb - show listing of last logged in users
#显示已登录的用户列表及登录时间等,与/var/log/wtmp及/var/log/btmp两个文件有关
[root@stu412 ~]# last
root     pts/0        192.168.65.1     Sun Jul  8 20:17   still logged in   
reboot   system boot  2.6.18-238.el5   Sun Jul  8 20:16          (01:20)    
root     pts/0        192.168.65.1     Sun Jul  8 11:57 - crash  (08:19)    
root     pts/1        192.168.65.1     Sat Jul  7 23:03 - crash  (21:12)    
root     pts/1        192.168.65.1     Sat Jul  7 20:49 - 21:56  (01:06)
…省略…
root     tty1                          Mon Jun  4 03:38 - crash (5+12:12)   
reboot   system boot  2.6.18-238.el5   Mon Jun  4 03:38         (5+20:44)

wtmp begins Mon Jun  4 03:38:13 201

#lastlog - reports the most recent login of all users or of a given user
# 报告最近的所有系统用户的登录信息
[root@stu412 ~]# lastlog
Username         Port     From             Latest
root             pts/0    192.168.65.1     Sun Jul  8 20:17:00 +0800 2012
bin                                        **Never logged in**
daemon                                     **Never logged in**
adm                                        **Never logged in**
…省略…
```
### 2.11.4.	groups命令
```
groups - print the groups a user is in
语法：groups　用户名

[root@stu412 ~]# groups
root bin daemon sys adm disk wheel
[root@stu412 ~]# groups user007
user007 : user007 root sa



[user007@stu412 ~]$ groups
user007 root sa
[user007@stu412 ~]$ touch file
[user007@stu412 ~]$ ls -l file 	#file文件的用户组为user007
-rw-rw-r-- 1 user007 user007 0 Jul  8 22:00 file
[user007@stu412 ~]$ newgrp root
[user007@stu412 ~]$ ls -l file 	#file文件的用户组为user007,未修改
-rw-rw-r-- 1 user007 user007 0 Jul  8 22:00 file
[user007@stu412 ~]$ groups 		#第一位是root的了
root sa user007
[user007@stu412 ~]$ touch file2
[user007@stu412 ~]$ ll
total 0
-rw-rw-r-- 1 user007 user007 0 Jul  8 22:00 file
-rw-r--r-- 1 user007 root    0 Jul  8 22:01 file2	#file2的用户组是root了
一个用户可以同时属于多个用户组，但是，在创建文件或目录时，文件所归属的用户组，在默认情况下为用户的有效用户组。一般在生产环境中这样的修改比较少见，因此对于newgrp命令，读者有印象就可以了。大家可以根据自己的习惯选择id或groups命令来查询用户组的相关命令。
```
