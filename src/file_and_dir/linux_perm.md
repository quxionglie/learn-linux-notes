# Linux文件和目录的属性及权限

# 1.	linux中的文件
## 1.1.	文件属性概述
文件或目录的属性主要包括：索引节点(inode)、类型、权限、链接数、所属用户和用户组，最新修改时间等
```
[root@stu412 test]# ls -lhi
total 24M
1867903 drwxr-xr-x 2 root root 4.0K Jun 29 21:59 dir
1835928 -rw-r--r-- 1 root root  24M Jun 29 21:59 mysql-5.1.62.tar.gz
1835284 -rw-r--r-- 1 root root  118 Jun 29 21:59 pay.txt


第1列 		inode节点号
第2列		文件类型及权限
第3列		硬链接个数
第4列		所属用户
第5列		所属用户组
第6列		文件大小
第7,8,9列	修改时间
第10列		实际的文件或目录名
```
## 1.2.	文件属性举例说明
```
[root@stu412 test]# touch oldboy
[root@stu412 test]# echo "I am oldboy">oldboy
[root@stu412 test]# cat oldboy
I am oldboy
[root@stu412 test]# ls -lhi oldboy
1836312 -rw-r--r-- 1 root root 12 Jun 29 22:13 oldboy
Inode索引节点编号：1836312
文件类型：-,这是一个普通文件。
文件权限：rw-r--r--,表示文件属主可读，可写，可执行。
硬链接个数：1,表示oldboy这个文件没有其它的硬链接。
文件属主：root,第一个root;
文件属组：root，第二个root
文件大小：12个字节。
文件修改时间：文件被最后修改的时间(包括文件创建、内容更新、文件名更新等),可用如下命令查看文件的修改、访问、创建的时间;
[root@stu412 test]# stat oldboy
File: `oldboy'
Size: 12              Blocks: 8          IO Block: 4096   regular file
Device: 802h/2050d      Inode: 1836312     Links: 3
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2012-06-29 23:04:40.000000000 +0800
Modify: 2012-06-29 23:04:40.000000000 +0800
Change: 2012-06-29 23:05:32.000000000 +0800
#stat命令可查看更多文件信息
```
# 2.	索引节点inode
## 2.1.	inode概述
inode中文意思是索引节点。每个存储设备或存储设备的分区被格式化为文件系统之后，都应该有两部分：inode,Block。Block存储数据用；inode用来存文件大小、属主、归属用户组、权限等数据信息的。

inode为每个文件进行信息索引，所以有inode数值。操作系统根据指令，能通过inode值最快的找到相应的文件。

打比方：inode 书的目录,Block书中每一页内容。

ls –i 可查看inode值。

```
[root@stu412 test]# ls -i oldboy
1836312 oldboy
[root@stu412 test]# ls -li oldboy
1836312 -rw-r--r-- 1 root root 12 Jun 29 22:13 oldboy
```
## 2.2.	inode值相同的文件是硬链接文件
inode值相同的文件是硬链接文件。不同的文件，inode的值可能是相同的，一个node值可以对应多个文件，链接文件是通过ln命令来创建的。
## 2.3.	硬链接原理及示例
```
#ln 原文件 目录文件
#注意目标文件不需要提前创建
[root@stu412 test]# touch oldboy
[root@stu412 test]# ls -li oldboy
1836312 -rw-r--r-- 1 root root 12 Jun 29 23:04 oldboy
[root@stu412 test]# ln oldboy  oldboy_hard_link #创建硬链接
[root@stu412 test]# ls -li oldboy
1836312 -rw-r--r-- 2 root root 12 Jun 29 23:04 oldboy
[root@stu412 test]# ls -li oldboy*
1836312 -rw-r--r-- 2 root root 12 Jun 29 23:04 oldboy
1836312 -rw-r--r-- 2 root root 12 Jun 29 23:04 oldboy_hard_link
[root@stu412 test]# ln oldboy  oldboy_hard_link1 #创建硬链接
[root@stu412 test]# ls -li oldboy*
1836312 -rw-r--r-- 3 root root 12 Jun 29 23:04 oldboy
1836312 -rw-r--r-- 3 root root 12 Jun 29 23:04 oldboy_hard_link
1836312 -rw-r--r-- 3 root root 12 Jun 29 23:04 oldboy_hard_link1
每次为oldboy创建一个硬链接，每次链接数都会加1。
互为硬链接的文件inode值相同。也就是说对应的实际数据是同一份。                                                                            
修改硬链接文件的内容，其它硬链接的内容也会变化。
提示：目录不能建硬链接，只有文件才能建硬链接。
[root@stu412 test]# mkdir mydir
[root@stu412 test]# ln mydir hard_dir
ln: `mydir': hard link not allowed for directory

#将oldboy删除，确认oldboy_hard_link是否能看到内容！
[root@stu412 test]# ls -lhi oldboy*
1836312 -rw-r--r-- 3 root root 12 Jun 29 23:04 oldboy
1836312 -rw-r--r-- 3 root root 12 Jun 29 23:04 oldboy_hard_link
1836312 -rw-r--r-- 3 root root 12 Jun 29 23:04 oldboy_hard_link1
[root@stu412 test]# cat oldboy #查看内容
I am oldboy
[root@stu412 test]# cat oldboy_hard_link
I am oldboy
[root@stu412 test]# cat oldboy_hard_link1
I am oldboy
[root@stu412 test]# rm -rf oldboy
[root@stu412 test]# cat oldboy_hard_link
I am oldboy
[root@stu412 test]# cat oldboy_hard_link1
I am oldboy
[root@stu412 test]# rm -f oldboy_hard_link1
[root@stu412 test]# cat oldboy_hard_link
I am oldboy
[root@stu412 test]# ls -lhi oldboy*
1836312 -rw-r--r-- 1 root root 12 Jun 29 23:04 oldboy_hard_link
```
## 2.4.	软链接的原理及示例
#ln –s 源文件或目录 目标文件或目录
软链接文件只是其原文件的一个标记。当我们删除原文件后，软链接文件不能独立存在了，虽然只会保留文件名（失效后会红色闪烁状），但我们看不到软链接文件的内容了。
```
[root@stu412 test]# touch file
[root@stu412 test]# ls -li file
1836313 -rw-r--r-- 1 root root 0 Jun 30 07:11 file
[root@stu412 test]# ln -s file file_soft_link
[root@stu412 test]# ls -li file*
1836313 -rw-r--r-- 1 root root 0 Jun 30 07:11 file
1836314 lrwxrwxrwx 1 root root 4 Jun 30 07:12 file_soft_link -> file

#目录操作示例
[root@stu412 test]# mkdir testdir
[root@stu412 test]# ls -lid testdir/
1867905 drwxr-xr-x 2 root root 4096 Jun 30 07:14 testdir/
[root@stu412 test]# ln -s testdir testdir_soft_link
[root@stu412 test]# ls -lid testdir*
1867905 drwxr-xr-x 2 root root 4096 Jun 30 07:14 testdir
1836315 lrwxrwxrwx 1 root root    7 Jun 30 07:14 testdir_soft_link -> testdir

对比文件file与其软链接file_soft_link文件：
(1)	inode值不同
(2)	文件类型不一样。file的-普通文件，而file_soft_link的l代表链接文件。
(3)	读写权限不一样。file是rw-r—r--，而file_soft_link是rwxrwxrwx。
(4)	两个文件的硬链接数相同，都是1。
(5)	两个文件的属主和用户组都是一样的。
(6)	两个文件创建或修改的时间列不同。

提示：修改软链接的内容就是修改原文件的内容，原文件的属性会改变，但软链接文件的属性不会改变。
删除原文件后，软链接文件会出现红色闪烁。
```
# 3.	文件类型
参考： Linux系统中的文件类型和文件扩展名

# 4.	linux中文件的权限
## 4.1.	文件权限概述
9个权限位,每三位分为一组。分别表示owner,group,other用户的权限。
```
rwxr--r--
r读
w写
x执行
- 不可读，不可写，不可执行
```
## 4.2.	权限位说明
```
普通文件
r 可阅读文件内容的权限;
w 新增、修改文件内容的权限；（特别提示：删除、修改、移动目录内文件的权限受父目录的权限控制）；
x 文件可被执行的权限

目录
x 进入该目录成为工作目录的权限;
r 读取目录结构列表的权限;
w 更改目录结构的权限，也就是有下面一些权限：
(1)	新建新的文件与目录;
(2)	删除已存在的文件与目录（不论该文件的权限为何）;
(3)	将已存在的文件或目录进行重命名；
(4)	转移该目录内的文件、目录位置;
总之目录的w权限与该目录下面的文件名变动有关。

对比
r 读
文件：有阅读文件内容权限
目录：浏览目录的权限(注意：与进入目录权限不同)

w 写
文件：新增修改文件内容（注意：删除、修改、移动目录内文件和文件本身属性无关）
目录：表示具有删除、移动、修改目录内文件的权限。如果要在目录中创建文件或目录必须有x权限。

x 执行
文件：执行文件的权限
目录：进入目录的权限。

- 无任何权限
  特别注意：当删除或移动一个文件或目录，仅与该文件与目录的上一层目录有关,与该文件本身的属性无关。对文件来说，写文件是修改文件，而不是删除文件，因此写文件与该文件的本身属性有关。

提示：查看文件的属性用ls –l文件名或目录名;仅查看目录的属性：ls –d 目录
[root@stu412 test]# ls -l file
-rw-r--r-- 1 root root 0 Jun 30 07:11 file
[root@stu412 test]# ls -d mydir
mydir
[root@stu412 test]# ls -ld mydir
drwxr-xr-x 2 root root 4096 Jun 29 23:16 mydir

```
## 4.3.	改变权限属性命令chmod
chmod改变文件或目录权限的命令，但只有文件属主和超级用户root才有这种权限。

chmod修改权限两种方式：
(1)	通过字母或操作符表达式
(2)	通过数字

对于目录权限的设置，要用到-R参数；

和数字权限方法一样，如果我们为一个目录及其下的子目录或文件设置相同的属性，就可以用-R参数。

### 4.3.1.	举例：
```

[root@stu412 test]# touch ett.txt
[root@stu412 test]# touch oldboy.txt
[root@stu412 test]# ls -lh ett.txt oldboy.txt
-rw-r--r-- 1 root root 0 Jun 30 07:42 ett.txt
-rw-r--r-- 1 root root 0 Jun 30 07:42 oldboy.txt
[root@stu412 test]# chmod 755 ett.txt
[root@stu412 test]# chmod u+x,og+x oldboy.txt
[root@stu412 test]# ls -lh ett.txt oldboy.txt
-rwxr-xr-x 1 root root 0 Jun 30 07:42 ett.txt
-rwxr-xr-x 1 root root 0 Jun 30 07:42 oldboy.txt
#两种方法(数字方法，字符式方法)虽然语法不同，但是都能达到相同的目的。
```

### 4.3.2.	数字权限方法
```

chmod [数字组合] 文件名
r	4
w	2
x	1
-	0

如：rwxr-xr-x => rwx=4+2+1=7 , r-x=4+0+1=5,故rwxr-xr-x=755。
每个三位的权限代码组合：
0	---
1	--x
2	–w-
3	-wx
4	r--
5	r-x
6	rw-
7	rwx
[root@stu412 test]# ls -l oldboy.txt
-rwx--x--- 1 root root 0 Jun 30 07:42 oldboy.txt


如果想改变的仅仅是打开目录的权限,使用chmod命令时不用加任何参数。如果想把目录以下的所有文件或子目录也同时改变，需要使用-R参数。
[root@stu412 test]# ls -ld mydir
drwxr-xr-x 3 root root 4096 Jun 30 08:48 mydir
[root@stu412 test]# ls -lr mydir
total 4
drwxr-xr-x 2 root root 4096 Jun 30 08:48 dir2
[root@stu412 test]# chmod 644 mydir #修改权限
[root@stu412 test]# ls -ld mydir
drw-r--r-- 3 root root 4096 Jun 30 08:48 mydir
[root@stu412 test]# ls -lr mydir #确认一下子目录改变了吗？
total 4
drwxr-xr-x 2 root root 4096 Jun 30 08:48 dir2

#mydir与dir2都要修改，使用-R参数
[root@stu412 test]# chmod 700 -R mydir
[root@stu412 test]# ls -ld mydir/
drwx------ 3 root root 4096 Jun 30 08:48 mydir/
[root@stu412 test]# ls -lr mydir/
total 4
drwx------ 2 root root 4096 Jun 30 08:48 dir2
4.3.3.	字符串权限表示法
chmod [用户类型] [+][-][=] 权限字符 文件名
用户或用户组定义：u 属主，g 所属用户组, o其它用户，a 全部，包括（ugo）。
权限定义： r 读，w 写，x 执行。
权限增减字符：+ 添加某个权限; - 取消某个权限; = 赋予给定权限并取消其它权限。
[root@stu412 mydir]# ls -l ett.txt
-rw-r--r-- 1 root root 0 Jun 30 09:14 ett.txt
[root@stu412 mydir]# chmod a+x ett.txt 		#加上执行权限x
[root@stu412 mydir]# ls -l ett.txt
-rwxr-xr-x 1 root root 0 Jun 30 09:14 ett.txt

[root@stu412 mydir]# chmod ugo-x ett.txt    #减去执行权限x
[root@stu412 mydir]# ls -l ett.txt
-rw-r--r-- 1 root root 0 Jun 30 09:14 ett.txt

[root@stu412 mydir]# chmod u=x ett.txt
[root@stu412 mydir]# ls -l ett.txt 			 #设置属主仅有执行权限
---xr--r-- 1 root root 0 Jun 30 09:14 ett.txt

[root@stu412 mydir]# chmod u=rwx,g=x,o=x ett.txt
[root@stu412 mydir]# ls -l ett.txt
-rwx--x--x 1 root root 0 Jun 30 09:14 ett.txt

[root@stu412 mydir]# chmod g=u ett.txt  		#设置g的权限为属主u的权限
[root@stu412 mydir]# ls -l ett.txt
-rwxrwx--x 1 root root 0 Jun 30 09:14 ett.txt
```

## 4.4.	默认权限分配的命令umask
umask是通过八进制的数值定义创建文件或目录的默认权限。umask表示的是禁止的权限。
文件的权限就是666减去umask的掩码数值。666是文件的起始权限值。
目录的权限就是777减去umask的掩码数值。777是目录的起始权限值。
umask默认是022，故新建文件的权限是666-022=644，新建目录的权限是777-022=755。
```

[root@stu412 tmp]# touch file
[root@stu412 tmp]# mkdir dir
[root@stu412 tmp]# umask
0022
[root@stu412 tmp]# ls -l
total 4
drwxr-xr-x 2 root root 4096 Jun 30 10:23 dir	#对应权限为755
-rw-r--r-- 1 root root    0 Jun 30 10:23 file	#对应权限为644

[root@stu412 tmp]# umask 044						#修改umask为044
[root@stu412 tmp]# touch file_umask
[root@stu412 tmp]# mkdir dir_umask
[root@stu412 tmp]# ls -l
total 8
drwxr-xr-x 2 root root 4096 Jun 30 10:23 dir
drwx-wx-wx 2 root root 4096 Jun 30 10:24 dir_umask
-rw-r--r-- 1 root root    0 Jun 30 10:23 file
-rw--w--w- 1 root root    0 Jun 30 10:23 file_umask

[root@stu412 tmp]# umask 022

Linux系统用户的家目录的权限是通过在配置文件中指定，比如Centos中用的/etc/login.defs文件。
[root@stu412 tmp]# cat /etc/login.defs
…略…
#
# If useradd should create home directories for users by default
# On RH systems, we do. This option is overridden with the -m flag on
# useradd command line.
#
CREATE_HOME     yes

# The permission mask is initialized to this value. If not specified,
# the permission mask will be initialized to 022.
UMASK           077
…略…

创建用户时，他的家目录umask的数值是077,则home目录的用户家目录的权限为777-077=700。
提示：生产环境中umask的使用并不多见。umask了解即可。
[root@stu412 tmp]# ls -l /home/
total 28
drwx------ 2 mysql   mysql   4096 Jun 10 00:03 mysql
drwx------ 2 squid1  squid1  4096 Jun  9 17:06 squid1
drwx------ 2 squid2  squid2  4096 Jun  9 17:06 squid2
drwx------ 2 user001 user001 4096 Jun  9 17:02 user001
drwx------ 2 user099 user099 4096 Jun  9 17:02 user099
drwx------ 2 user100 user100 4096 Jun  9 17:02 user100
drwx------ 2 www     www     4096 Jun  9 23:50 www
```

# 5.	setuid和setgid位
特别提示：本部分仅为了解内容

setuid和setgid功能不错，但会带来安全隐患。

## 5.1.	setuid和setgid介绍
```
setuid和setgid位是让普通用户可以以root用户的角色运行只有root才能运行的程序或命令。（注意与su,sudo的区别）。
普通用户是无法修改文件/etc/passwd的，但为什么普通用户能修改自已的密码呢？
[root@stu412 ~]# ls -l /etc/passwd
-rw-r--r-- 1 root root 2486 Jul  4 07:34 /etc/passwd
[root@stu412 ~]# ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 23420 Aug 11  2010 /usr/bin/passwd
[root@stu412 ~]# chmod 4755 /usr/bin/passwd
```

上面的s就是setuid位。

```
[root@stu412 ~]# chmod 755 /usr/bin/passwd 		#修改权限

[user1@stu412 ~]$ passwd
Changing password for user user1.
Changing password for user1
(current) UNIX password:
passwd: Authentication token manipulation error		#不能修改密码

[root@stu412 ~]# chmod 4755 /usr/bin/passwd				#权限改回来

[user1@stu412 ~]$ passwd
Changing password for user user1.
Changing password for user1
(current) UNIX password:
New UNIX password:
Retype new UNIX password:
passwd: all authentication tokens updated successfully.
```
## 5.2.	setuid和setgid实例应用
setuid位使用八进制的4000, setgid 使用八进制的2000。 如chmod 4755 /bin/rm就是设置setuid位。
## 5.3.	setuid和setgid设置说明
chmod 使用u+s或u-s来增减setuid位，同理我们可以通过g+s或g-s来设置setgid位。
# 6.	粘贴位
在一个目录上设了sticky位后，（如/home，权限为1777)所有的用户都可以在这个目录下创建文件，但只能删除自己创建的文件(root除外)，这就对所有用户能写的目录下的用户文件启到了保护的作用。
即当一个目录被设置为"粘着位"(用chmod a+t),则该目录下的文件只能由

一、超级管理员root删除

二、该目录的所有者删除

三、该文件的所有者删除

也就是说,即便该目录是任何人都可以写,但也只有文件的属主才可以删除文件。

粘贴位是使用1000来表示的。语法表示：o+t表示设置粘贴位,o-t表示取消粘贴位。

设置：
```
chmod 777 abc
chmod +t abc   
等价于chmod 1777 abc
```
系统是这样规定的, 假如本来在该位上有x, 则这些特别标志 (suid, sgid, sticky) 显示为小写字母 (s, s, t). 否则, 显示为大写字母 (S, S, T) 。
# 7.	文件或目录的归属关系
      文件或目录的归属关系主要定义文件或目录归属哪个用户及哪个用户组所有。
## 7.1.	改变文件所属关系命令chown
```
当我们要改变一个文件的属组，我们所使用的用户必须是该文件的属主而且同时是目标属组成员或超级用户。只有超级用户才能改变文件的属主。
#chown [选项]… [所有者][:[组]] 文件
[root@stu412 ~]# ls -ld /user1
drwxr-xr-x 2 user1 user1 4096 Jul  4 20:17 /user1
[root@stu412 ~]# chown user1:root /user1  #:也可以为.号
[root@stu412 ~]# ls -ld /user1
drwxr-xr-x 2 user1 root 4096 Jul  4 20:17 /user1

[root@stu412 ~]# chown user1 /user1		#只修改用户
[root@stu412 ~]# chown .root /user1		#只修改用户组
注：要修改的用户和组必须是系统中已经存在的。

-R参数：改变目录下所有文件和目录的所有者和组。
说明：chown所接的新的属主和新的属组之间应该以.或:连接，属主和属组任意之一可以为空。如果属主为空，应该是 :属组 ,如果属组为空，就不必要.或:了。
```
## 7.2.	改变文件的属组命令chgrp
chgrp [参数选项]… 组 文件…

chown的子组

## 7.3.	文件属主和属主的特殊情况
```
[root@stu412 ~]# ls -ld /user2
drwxr-x-wx 2 user2 user2 4096 Jul  4 22:39 /user2
[root@stu412 ~]# userdel user2
[root@stu412 ~]# ls -ld /user2
drwxr-x-wx 2 914 914 4096 Jul  4 22:39 /user2
```
系统中不存在与之对应的用户，导致的(删除了用户但未删除其目录或文件)。

提示：删除用户时可以执行userdel –r user2连同家目录一起删除。

 
