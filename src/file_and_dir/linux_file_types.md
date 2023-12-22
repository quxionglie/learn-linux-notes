# linux文件类型总结

# 1.	概述

Linux文件类型常见的有：普通文件、目录、字符设备文件、块设备文件、符号链接文件等

一切设备(目录，普通文件等)皆文件。

文件类型有：
```
ls –l 第一列的第一个字符，表示文件类型。
d：      目录
-：      普通文件
l：      符号链接文件
b、c：    块设备，其它外围设备。
s、P：    数据结构和管道
```
## 1.1.	普通文件
```
[root@stu412 ~]# ls -lh install.log
-rw-r--r-- 1 root root 18K Jun  4 03:35 install.log
#用 ls -lh 来查看某个文件的属性，可以看到有类似 -rw-r--r-- ，
#值得注意的是第一个符号是 - ，这样的文件在Linux中就是普通文件。
#这些文件一般是用一些相关的应用程序创建，比如图像工具、文档工具、归档工具... .... 或 cp工具等。#这类文件的删除方式是用rm 命令；
```
## 1.2.	目录
```
[root@stu412 ~]# ls -lh
total 106M
-rw------- 1 root root  964 Jun  4 03:35 anaconda-ks.cfg
drwxr-xr-x 2 root root 4.0K Jun 22 08:33 destination
-rwx------ 1 root root   46 Jun 11 04:27 file.py
-rw-r--r-- 1 root root  18K Jun  4 03:35 install.log
-rw-r--r-- 1 root root 3.9K Jun  4 03:35 install.log.syslog
-rwxr--r-- 1 root root  82M Jun 10 00:09 jdk-6u26-linux-i586.bin
-rw-r--r-- 1 root root   29 Jun 11 04:22 multi_blanks.txt
-rw-r--r-- 1 root root  24M Jun  9 23:22 mysql-5.1.62.tar.gz
-rw-r--r-- 1 root root 677K Apr 12 21:05 nginx-1.0.15.tar.gz
drwxr-xr-x 2 root root 4.0K Jun 28 07:32 test
#类似 drwxr-xr-x ，这样的文件就是目录，目录在Linux是一个比较特殊的文件。
#注意它的第一个字符是d。
#创建目录的命令可以用 mkdir 命令，或cp命令，
#cp可以把一个目录复制为另一个目录。
#删除用rm 或rmdir命令。
```
## 1.3.	字符设备或块设备文件
```
[root@stu412 ~]# ls -la /dev/tty
crw-rw-rw- 1 root tty 5, 0 Jun 28 20:38 /dev/tty
[root@stu412 ~]# ls -la /dev/sda1   
brw-r----- 1 root disk 8, 1 Jun 28 20:38 /dev/sda1
/dev/tty的属性是 crw-rw-rw- ，注意前面第一个字符是 c ，这表示字符设备文件。比如猫等串口设备
/dev/hda1 的属性是 brw-r----- ，注意前面的第一个字符是b，这表示块设备，比如硬盘，光驱等设备；
这个种类的文件，是用mknode来创建，用rm来删除。目前在最新的Linux发行版本中，我们一般不用自己来创建设备文件。因为这些文件是和内核相关联的。
```
## 1.4.	套接口文件
```
当我们启动MySQL服务器时，会产生一个mysql.sock的文件。
[root@stu412 ~]# ls -lh /tmp/mysql.sock
srwxrwxrwx 1 mysql mysql 0 Jun 29 07:33 /tmp/mysql.sock
注意这个文件的属性的第一个字符是 s。我们了解一下就行了。
```
## 1.5.	符号链接文件
```
[root@stu412 data]# ls -lh resin
lrwxrwxrwx 1 root root 12 Jun 10 00:41 resin -> resin-3.1.12
当我们查看文件属性时，会看到有类似 lrwxrwxrwx,注意第一个字符是l，这类文件是链接文件。是通过ln -s 源文件名 新文件名 。
```
# 2.	find type
```
-type c
File is of type c:
b      block (buffered) special	            #设备文件
c      character (unbuffered) special       #设备文件
d      directory                            #目录
p      named pipe (FIFO)                    #命名管道
f      regular file                         #普通文件
l      symbolic link; this is never true if the -L option or the -follow option  is  in  effect,
unless  the symbolic link is broken.  If you want to search for symbolic links when -L is
in effect, use -xtype.
#链接文件
s      socket                               #socket文件
D      door (Solaris)
```