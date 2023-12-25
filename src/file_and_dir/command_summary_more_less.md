# 命令总结-文件查看与处理命令(more、less、tree、chattr、lsattr)


# 1.	more(一页一页翻动)
```
[root@stu412 ~]# more /etc/man.config
#
# Generated automatically from man.conf.in by the
# configure script.
#
# man.conf from man-1.6d
#
…省略…
# If no catdir is given, it is assumed to be equal to the mandir
# (so that this dir has both man1 etc. and cat1 etc. subdirs).
--More--(16%)		<== 重点在这一行
如果 more 后面接的文件长度大于屏幕输出的行数时， 就会出现类似上面的图示。重点在最后一行，最后一行会显示出目前显示的百分比， 而且还可以在最后一行输入一些有用的指令！在 more 执行过程中，有几个按键可以按的：
空格键 (space)	：向下翻一页；
Enter         	：向下翻"一行"；
/字符串        	：在这个显示的内容当中，向下搜索"字符串"；
:f            	：立刻显示出文件名以及目前显示的行数；
q             	：代表立刻离开 more ，不再显示该文件内容。

搜索MANPATH字符串
[root@stu412 ~]# more /etc/man.config
#
# Generated automatically from man.conf.in by the
# configure script.
#
# man.conf from man-1.6d
#
…省略…
/MANPATH <== 输入了 / 之后，光标就会自动跑到最下面一行等待输入！
输入了 / 之后，光标就会跑到最下面一行，并且等待您的输入， 您输入了字符串之后，按回车， more 就会开始向下搜寻该字符串。
重复搜寻同一个字符串， 可以直接按下 n 即可！
```
# 2.	less(一页一页翻动)
```
less有更多的"搜索"功能！不止可以向下搜索，也可以向上搜索。
基本上，可以输入的指令有：
空格键       ：向下翻动一页；
[pagedown] ：向下翻动一页；
[pageup]    ：向上翻动一页；
/字符串      ：向下搜索"字符串"的功能；
?字符串     ：向上搜索"字符串"的功能；
n         ：重复前一个搜索 (与 / 或 ? 有关！)
N         ：反向的重复前一个搜索 (与 / 或 ? 有关！)
q         ：离开 less 这个程序；
```
# 3.	tree
```
tree命令详解：
-a 显示所有文件和目录。
-A 使用ASNI绘图字符显示树状图而非以ASCII字符组合。
-C 在文件和目录清单加上色彩，便于区分各种类型。
-d 显示目录名称而非内容。
-D 列出文件或目录的更改时间。
-f 在每个文件或目录之前，显示完整的相对路径名称。
-F 在执行文件，目录，Socket，符号连接，管道名称名称，各自加上"*","/","=","@","|"号。
-g 列出文件或目录的所属群组名称，没有对应的名称时，则显示群组识别码。
-i 不以阶梯状列出文件或目录名称。
-I 不显示符合范本样式的文件或目录名称。
-l 如遇到性质为符号连接的目录，直接列出该连接所指向的原始目录。
-n 不在文件和目录清单加上色彩。
-N 直接列出文件和目录名称，包括控制字符。
-p 列出权限标示。
-P 只显示符合范本样式的文件或目录名称。
-q 用"?"号取代控制字符，列出文件和目录名称。
-s 列出文件或目录大小。
-t 用文件和目录的更改时间排序。
-u 列出文件或目录的拥有者名称，没有对应的名称时，则显示用户识别码。
-x 将范围局限在现行的文件系统中，若指定目录下的某些子目录，其存放于另一个文件系统上，则将该子目录予以排除在寻找范围外。
```

```
[root@stu412 ~]# tree
.
|-- anaconda-ks.cfg
|-- destination
|   |-- file
|   |-- file1
|   `-- file2
|-- file.py
|-- install.log
|-- install.log.syslog
|-- jdk-6u26-linux-i586.bin
|-- multi_blanks.txt
|-- mysql-5.1.62.tar.gz
|-- nginx-1.0.15.tar.gz
`-- test
`-- file

[root@stu412 ~]# tree –d #只显示目录
.
|-- destination
`-- test

2 directories
[root@stu412 ~]# tree -f
.
|-- ./anaconda-ks.cfg
|-- ./destination
|   |-- ./destination/file
|   |-- ./destination/file1
|   `-- ./destination/file2
|-- ./file.py
|-- ./install.log
|-- ./install.log.syslog
|-- ./jdk-6u26-linux-i586.bin
|-- ./multi_blanks.txt
|-- ./mysql-5.1.62.tar.gz
|-- ./nginx-1.0.15.tar.gz
`-- ./test
`-- ./test/file
[root@stu412 ~]# tree –p #显示权限
.
|-- [-rw-------]  anaconda-ks.cfg
|-- [drwxr-xr-x]  destination
|   |-- [-rw-r--r--]  file
|   |-- [-rw-r--r--]  file1
|   `-- [-rw-r--r--]  file2
|-- [-rwx------]  file.py
|-- [-rw-r--r--]  install.log
|-- [-rw-r--r--]  install.log.syslog
|-- [-rwxr--r--]  jdk-6u26-linux-i586.bin
|-- [-rw-r--r--]  multi_blanks.txt
|-- [-rw-r--r--]  mysql-5.1.62.tar.gz
|-- [-rw-r--r--]  nginx-1.0.15.tar.gz
`-- [drwxr-xr-x]  test
`-- [-rw-r--r--]  file

2 directories, 12 files
```

# 4.	chattr(配置文件系统属性)
## 4.1.	说明：
```
chattr - change file attributes on a Linux second extended file system
修改ext2和ext3文件系统属性。

语法格式：
chattr [-RV][-v<版本编号>][-+=AacDdijsSu][文件或目录]
常用参数说明：
　　-R：递归处理所有的文件及子目录。
   -V：详细显示修改内容，并打印输出。
　　-：失效属性。
　　+：激活属性。
　  = ：指定属性。　
　　A：Atime，告诉系统不要修改对这个文件的最后访问时间。
　　S：Sync，一旦应用程序对这个文件执行了写操作，使系统立刻把修改的结果写到磁盘。
　　a：Append Only，系统只允许在这个文件之后追加数据，不允许任何进程覆盖或截断这个文件。如果目录具有这个属性，系统将只允许在这个目录下建立和修改文件，而不允许删除任何文件。
　　i：Immutable，系统不允许对这个文件进行任何的修改。如果目录具有这个属性，那么任何的进程只能修改目录之下的文件，不允许建立和删除文件。
　　D：检查压缩文件中的错误。
　　d：No dump，在进行文件系统备份时，dump程序将忽略这个文件。
　　C：Compress，系统以透明的方式压缩这个文件。从这个文件读取时，返回的是解压之后的数据；而向这个文件中写入数据时，数据首先被压缩之后才写入磁盘。
　　s：Secure Delete，让系统在删除这个文件时，使用0填充文件所在的区域。
u：Undelete，当一个应用程序请求删除这个文件，系统会保留其数据块以便以后能够恢复删除这个文件。
```
## 4.2.	实例
### 4.2.1.	防止系统中某个关键文件被修改,i属性
```
[root@stu412 ~]# cd /tmp
[root@stu412 tmp]# touch attrtest
[root@stu412 tmp]# chattr +i attrtest
[root@stu412 tmp]# rm attrtest	#连 root 也无法将这个文件删除！
rm: remove write-protected regular empty file `attrtest'? y
rm: cannot remove `attrtest': Operation not permitted
[root@stu412 tmp]# chattr -i attrtest 	#解除i设定
[root@stu412 tmp]# rm attrtest          	
rm: remove regular empty file `attrtest'? y
#rm mv rename等命令操作于该文件，都是得到Operation not permitted 的结果
```
### 4.2.2.	让某个文件只能往里面追加内容，不能删除
```
#一些日志文件适用于这种操作
[root@stu412 tmp]# touch /var/t.log
[root@stu412 tmp]# chattr +a /var/t.log
[root@stu412 tmp]# echo "data">/var/t.log  
-bash: /var/t.log: Operation not permitted
[root@stu412 tmp]# echo "data">>/var/t.log
```
# 5.	lsattr(查看文件系统属性)
```
# lsattr [-aR] 文件或目录
参数：
-a ：将隐藏文件的属性也显示出来；
-R ：连同子目录的数据也一并列出来！

[root@stu412 tmp]# touch file3
[root@stu412 tmp]# lsattr file3
------------- file3
[root@stu412 tmp]# chattr +i file3
[root@stu412 tmp]# lsattr file3   
----i-------- file3
[root@stu412 tmp]# chattr +a file3
[root@stu412 tmp]# lsattr file3   
----ia------- file3
[root@stu412 tmp]# chattr -ai file3
[root@stu412 tmp]# lsattr file3    
------------- file3
```
