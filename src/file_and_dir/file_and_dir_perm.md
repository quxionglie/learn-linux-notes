# Linux文件和目录权限实战讲解
 
# 1.	 linux文件及目录权限精华总结
## 1.1.	普通文件rwx说明
r 可阅读文件内容的权限;

w 新增、修改文件内容的权限；（特别提示：删除、修改、移动目录内文件的权限受父目录的权限控制）；

x 文件可被执行的权限
## 1.2.	目录rwx权限说明
 x 进入该目录成为工作目录的权限;

 r 读取目录结构列表的权限;

 w 更改目录结构的权限，也就是有下面一些权限：

 - (1)	新建新的文件与目录;
 - (2)	删除已存在的文件与目录（不论该文件的权限为何）;
 - (3)	将已存在的文件或目录进行重命名；
 - (4)	转移该目录内的文件、目录位置;

 总之目录的w权限与该目录下面的文件名变动有关。
## 1.3.	文件和目录rwx权限对比
- r 读
```
文件：有阅读文件内容权限
目录：浏览目录的权限(注意：与进入目录权限不同)
```

- w 写
```
文件：新增修改文件内容（注意：删除、修改、移动目录内文件和文件本身属性无关）
目录：表示具有删除、移动、修改目录内文件的权限。如果要在目录中创建、移动、删除文件或目录必须有x权限。
```
- x 执行
```
文件：执行文件的权限
目录：进入目录的权限。
```

- 无任何权限

特别注意：当删除或移动一个文件或目录时，仅与该文件与目录的上一层目录有关,与该文件本身的属性无关。对文件来说，写文件是修改文件，而不是删除文件，因此写文件与该文件的本身属性有关。


# 2.	测试文件及目录的前期准备
## 2.1.	添加两个普通用户：user1, user2
```
[root@n1 ~]# useradd user1
[root@n1 ~]# useradd user2
```      
## 2.2.	建立两个目录，并设置归属用户和组
```
[root@n1 ~]# mkdir /user1
[root@n1 ~]# mkdir /user2
[root@n1 ~]# chown user1.user1 /user1	#修改属主和用户组
[root@n1 ~]# chown user2.user2 /user2
```      
## 2.3.	/user1, /user2目录下分别建file文件
```
[root@n1 ~]# touch /user1/file
[root@n1 ~]# touch /user2/file

#查看新建目录和文件的权限
[root@n1 ~]# ls -ld /user1 /user2
drwxr-xr-x 2 user1 user1 4096 Jul  4 20:17 /user1		#目录默认的权限是755
drwxr-xr-x 2 user2 user2 4096 Jul  4 20:18 /user2
[root@n1 ~]# ls -l /user1/file /user2/file
-rw-r--r-- 1 root root 0 Jul  4 20:17 /user1/file		#文件默认的权限是644
-rw-r--r-- 1 root root 0 Jul  4 20:18 /user2/file
```

# 3.	测试user1用户浏览非自己拥有的目录/user2的权限
```
#用户user1对目录/user2来说属于其它组，所以只看后三位的权限r-x。所以user1对目录/user2有读(浏览目录)和执行(进入目录)的权限。
[user1@stu412 ~]$ ls -ld /user2
drwxr-xr-x 2 user2 user2 4096 Jul  4 20:18 /user2
[user1@stu412 ~]$ ls -l /user2 	#用户user1，可以浏览/user2的文件
total 0
-rw-r--r-- 1 root root 0 Jul  4 20:18 file
[user1@stu412 ~]$ cd /user2		#用户user1，可以进入目录/user2
[user1@stu412 user2]$

#user1删除非自身属主的文件权限
[user1@stu412 user2]$ rm -f file
rm: cannot remove `file': Permission denied
[root@n1 ~]# chmod 777 /user2/file 	#权限修改为777看
[root@n1 ~]# ls -l /user2
total 0
-rwxrwxrwx 1 root root 0 Jul  4 20:18 file
[user1@stu412 user2]$ rm -f file 			#还是权限不够
rm: cannot remove `file': Permission denied
#删除或移动一个文件时，与该文件的上层目录有关，与文件本身的属性无关。即使文件的权限是777也不可以。

[root@n1 ~]# chmod 755 /user2
[root@n1 ~]# chmod o+w  /user2
[root@n1 ~]# ls -ld /user2    
drwxr-xrwx 2 user2 user2 4096 Jul  4 20:18 /user2
[root@n1 ~]# ls -l /user2     
total 0
-rw-r--r-- 1 root root 0 Jul  4 20:18 file

[user1@stu412 ~]$ ls -ld /user2
drwxr-xrwx 2 user2 user2 4096 Jul  4 20:18 /user2
[user1@stu412 ~]$ ls -l /user2
total 0
-rw-r--r-- 1 root root 0 Jul  4 20:18 file
[user1@stu412 ~]$ cd /user2
[user1@stu412 user2]$ rm -f file 		#删除成功
[user1@stu412 user2]$

[root@n1 ~]# cd /user2
[root@n1 user2]# touch file2
[root@n1 user2]# chmod 000 file2		#设置file2无任何权限
[root@n1 user2]# ls -l /user2      
total 0
---------- 1 root root 0 Jul  4 22:14 file2
[user1@stu412 user2]$ ls -l /user2  
total 0
---------- 1 root root 0 Jul  4 22:14 file2
[user1@stu412 user2]$ rm -f file2		#也能删除成功
[user1@stu412 user2]$ ls -l /user2
total 0
[user1@stu412 user2]$

#测试user1仅有w权限是否能删除/user2内的文件
[root@n1 /]# chmod o=w /user2		#其它用户仅有w权限
[root@n1 /]# ls -ld /user2   
drwxr-x-w- 2 user2 user2 4096 Jul  4 22:22 /user2
[root@n1 /]# ls -l /user2
total 0
-rw-r--r-- 1 root root 0 Jul  4 22:22 file

[user1@stu412 ~]$ ls -l /user2
ls: /user2: Permission denied
[user1@stu412 ~]$ cd  /user2  
-bash: cd: /user2: Permission denied
[user1@stu412 ~]$ rm -f /user2/file	#仅有w权限，user1是无法删除/user2/file的
rm: cannot remove `/user2/file': Permission denied

#user1有rw权限看是否能删除/user2内的文件
[root@n1 /]# chmod 756 /user2
[root@n1 /]# ls -ld /user2
drwxr-xrw- 2 user2 user2 4096 Jul  4 22:22 /user2

[user1@stu412 ~]$ ls -ld /user2/
drwxr-xrw- 2 user2 user2 4096 Jul  4 22:22 /user2/
[user1@stu412 ~]$ ls -l /user2/  
total 0
?--------- ? ? ? ?            ? file
[user1@stu412 ~]$ rm -f /user2/file #仅有rw权限，user1依然无法删除/user2/file
rm: cannot remove `/user2/file': Permission denied

#测试user1仅有wx权限看是否能删除/user2内的文件
[root@n1 /]# chmod 753 /user2
[root@n1 /]# ls -ld /user2
drwxr-x-wx 2 user2 user2 4096 Jul  4 22:22 /user2
[root@n1 /]# ls -l /user2
total 0
-rw-r--r-- 1 root root 0 Jul  4 22:22 file

[user1@stu412 ~]$ ls -ld /user2/    
drwxr-x-wx 2 user2 user2 4096 Jul  4 22:22 /user2/
[user1@stu412 ~]$ ls -l /user2/    
ls: /user2/: Permission denied
[user1@stu412 ~]$ cd /user2
[user1@stu412 user2]$ rm -f file	#删除成功
[user1@stu412 user2]$
```

结论：

1）	删除或移动一个文件，与该文件的上层目录的权限有关，与该文件本身的属性无关，即使是777也不可能删除或移动!

2）	对于目录，可写w表示具有修改或删除目录内文件的权限，但必须同时有x权限才可以。
