# linux下软链接和硬链接的区别

# 1.	软链接和硬链接的区别总结
在linux系统中，链接分两种 ：一种被称为硬链接（Hard Link），另一种被称为符号链接或软链接（Symbolic Link）。

1)默认不带参数情况下，ln命令创建的是硬链接。

2)硬链接文件与源文件的inode节点号相同，而软链接文件的inode节点号与源文件不同。

3)ln命令不能对目录创建硬链接，但可以创建软链接，对目录的软链接会经常被用到。

4)删除软链接文件,对源文件及硬链接文件无任何影响；

5)删除文件的硬链接文件，对源文件及软链接文件无任何影响；

6)删除链接文件的原文件，对硬链接文件无影响，会导致其软链接失效（红底白字闪烁状）；

7)同时删除原文件及其硬链接文件，整个文件才会被真正的删除。

8)很多硬件设备中的快照功能，使用的就类似硬链接的原理。

9)软连接可以跨文件系统，硬链接不可以跨文件系统。

# 2.	链接的概念
硬链接				Hard Link

软链接或符号链接	Symbolic Link

ln不带参数创建的链接是硬链接

## 2.1.	硬链接
硬链接是指通过索引节点(Inode Index)来进行链接。在linux文件系统中，保存在磁盘分区中的文件不管是什么类型都会给它分配一个编号，这个编号称为索引节点编号（Inode Index）或者Inode。

多个文件名指向同一个索引节点（Inode）是正常且允许的。一般这种链接就称为硬链接。硬链接的作用之一是允许一个文件拥有多个有效路径名，这样用户就可以建立硬链接到重要的文件，以防止误删数据。

因为文件系统的原理是，只要文件的索引节点（Inode Index）还有一个以上的链接（仅仅删除了该文件指向），只删除其中一个链接并不影响索引节点和其它的链接（即数据文件实体并未被删除），只有当最后一个链接被删除后，此时如果有新数据要存储到硬盘时，被删除文件的数据块及目录才会被释放，空间被新数据占用覆盖。此时数据再也无法找回了。也就是说，在linux系统中，删除文件（目录）的条件是与之相关的所有硬链接文件均被删除（与进程的占用也有关）。
硬链接相当于文件的另外一个入口。

## 2.2.	软链接
软链接类似windows的快捷方式。

# 3.	示例演示
## 3.1.	文件示例
```
[root@n1 ~]# mkdir test
[root@n1 ~]# cd test/
[root@n1 test]# touch file
[root@n1 test]# ls
file
[root@n1 test]# ls -ld
drwxr-xr-x 2 root root 4096 Jun 23 20:36 .
[root@n1 test]# ls -ld file
-rw-r--r-- 1 root root 0 Jun 23 20:36 file
[root@n1 test]# ln file file_hard_file 	#创建硬链接文件
[root@n1 test]# ls -ld file
-rw-r--r-- 2 root root 0 Jun 23 20:36 file
[root@n1 test]# ln -s file file_soft_link #创建软链接
[root@n1 test]# ls -ld file
-rw-r--r-- 2 root root 0 Jun 23 20:36 file
[root@n1 test]# ls -ld *
-rw-r--r-- 2 root root 0 Jun 23 20:36 file
-rw-r--r-- 2 root root 0 Jun 23 20:36 file_hard_file
lrwxrwxrwx 1 root root 4 Jun 23 20:38 file_soft_link -> file
[root@n1 test]# ls -li *
1671174 -rw-r--r-- 2 root root 0 Jun 23 20:36 file
1671174 -rw-r--r-- 2 root root 0 Jun 23 20:36 file_hard_file
1671175 lrwxrwxrwx 1 root root 4 Jun 23 20:38 file_soft_link -> file
#硬链接的节点编号是一样的，软链接文件的inode节点号与原文件不一样
总结：硬链接的节点编号是一样的，软链接文件的inode节点号与原文件不一样
```
3.2.	目录示例
```
[root@n1 test]# mkdir testdir
[root@n1 test]# ln testdir testdir_hard_link  
ln: `testdir': hard link not allowed for directory    #目录无法创建硬链接
[root@n1 test]# ln -s testdir testdir_soft_link   #但目录可以创建软链接
[root@n1 test]# ls -l
total 4
-rw-r--r-- 2 root root    0 Jun 23 20:36 file
-rw-r--r-- 2 root root    0 Jun 23 20:36 file_hard_file
lrwxrwxrwx 1 root root    4 Jun 23 20:38 file_soft_link -> file
drwxr-xr-x 2 root root 4096 Jun 23 20:42 testdir
lrwxrwxrwx 1 root root    7 Jun 23 20:42 testdir_soft_link -> testdir
[root@n1 test]# ls -li
total 4
1671174 -rw-r--r-- 2 root root    0 Jun 23 20:36 file
1671174 -rw-r--r-- 2 root root    0 Jun 23 20:36 file_hard_file
1671175 lrwxrwxrwx 1 root root    4 Jun 23 20:38 file_soft_link -> file
1671176 drwxr-xr-x 2 root root 4096 Jun 23 20:42 testdir
1671177 lrwxrwxrwx 1 root root    7 Jun 23 20:42 testdir_soft_link -> testdir
总结：ln不能对目录建硬链接，但可以创建软链接。目录软链接在生产运维场景中常用。
```
3.3.	删除示例
```
[root@n1 test]# echo "oldboyfile " > file
[root@n1 test]# cat file
oldboyfile
[root@n1 test]# cat file_hard_file
oldboyfile
[root@n1 test]# cat file_soft_link
oldboyfile
[root@n1 test]# rm -f file #删除原始文件，其实就是删除了一个文件的硬链接。
[root@n1 test]# ls -lirt
total 8
1671175 lrwxrwxrwx 1 root root    4 Jun 23 20:38 file_soft_link -> file
1671176 drwxr-xr-x 2 root root 4096 Jun 23 20:42 testdir
1671177 lrwxrwxrwx 1 root root    7 Jun 23 20:42 testdir_soft_link -> testdir
1671174 -rw-r--r-- 1 root root   12 Jun 23 20:47 file_hard_file
[root@n1 test]# cat file_hard_file #硬链接不受影响
oldboyfile
[root@n1 test]# cat file_soft_link #软链接失效
cat: file_soft_link: No such file or directory
```


总结：删除原文件file后，其硬链接不受影响，但其软链接失效


# 4.	链接总结
## 4.1.	有关文件
(1)	删除软链接file_soft_link后，对file，file_hard_file无影响

(2)	删除硬链接file_hard_link后，对file，file_soft_link无影响

(3)	删除原文件file，对硬链接file_hard_link无影响，导致软链接file_soft_link失效。

(4)	同时删除原文件file、硬链接file_hard_link时，整个文件会真正的被删除。

(5)	很多硬件设备中的快照功能，就是利用了硬链接的原理。

## 4.2.	有关目录
(1)	目录不可以创建硬链接，但可以创建软链接。

(2)	目录软链接是生产环境常用技巧。

# 5.	链接知识拓展
## 5.1.	软链接的生产使用案例
编译apachel软件时，编译路径有版本号/application/apache2.2.21,而在访问目录时又希望简便，就可以建立简单的软链接路径文件 ln –s /application/apache2.2.21 /application/apache来达到方便访问的目的。
## 5.2.	硬链接的生产使用案例
硬件存储的快照功能，或者为备份数据建多个硬链接，防止误删除数据。
