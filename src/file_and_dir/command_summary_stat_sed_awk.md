# 命令总结(stat、sed、awk)


# 1.	stat
## 1.1.	说明
```
stat - display file or file system status #显示文件或文件系统状态
语法：stat [OPTION] FILE...
-c  --format=FORMAT
use the specified FORMAT instead of the default; output a newline after each use of FORMAT

--printf=FORMAT
like  --format, but interpret backslash escapes, and do not output a mandatory trailing newline.  If you
want a newline, include \n in FORMAT.

#有效的格式
The valid format sequences for files (without --file-system):
%a     Access rights in octal #10进制的权限，如644
%A     Access rights in human readable form #人类可读的方式显示权限，如-rw-r--r--

%b     Number of blocks allocated (see %B)
%B     The size in bytes of each block reported by %b
%d     Device number in decimal
%D     Device number in hex
%f     Raw mode in hex

%F     File type #文件类型
%g     Group ID of owner 		#拥有者组id
%G     Group name of owner	#拥有者组名
%h     Number of hard links  #硬链接数
%i     Inode number 	#inode值
%n     File name		#文件名称

%N     Quoted file name with dereference if symbolic link
%o     I/O block size
%s     Total size, in bytes
%t     Major device type in hex
%T     Minor device type in hex

%u     User ID of owner 		#用户id
%U     User name of owner	#用户名

%x     Time of last access 	#最后访问时间
%X     Time of last access as seconds since Epoch
%y     Time of last modification	#最后修改时间
%Y     Time of last modification as seconds since Epoch
%z     Time of last change			#最后修改时间
%Z     Time of last change as seconds since Epoch
```       
# 1.2.	范例
范例1：不带参数显示文件信息
```
[root@stu412 test]# stat file
File: `file'
Size: 9               Blocks: 8          IO Block: 4096   regular file
Device: 802h/2050d      Inode: 1836312     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2012-06-27 13:00:53.000000000 +0800
Modify: 2012-06-27 13:01:14.000000000 +0800
Change: 2012-06-27 13:01:14.000000000 +0800
```
范例2：以十进制查看权限,如权限rwx------显示为700
```
[root@stu412 test]# stat -c '%a' file
644
```
范例3：查询目录下最大的文件
```
# find / -type f -exec stat -c "%s %n" {} \; | sort -nr | head -1
```

范例4：查询文件拥有者的用户id和用户名
```
[root@stu412 test]# stat -c "%u %U" file
0 root
```
范例5：查询文件最后访问时间
```
[root@stu412 test]# stat -c "%x" file        
2012-06-27 21:31:27.000000000 +0800
```
# 2.	sed
## 2.1.	说明
```
# sed [-nefr] [操作]
参数：
-n  ：使用安静(silent)模式。在一般 sed 的用法中，所有来自STDIN的数据一般都会被列出到屏幕上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者操作)才会被列出来。
-e  ：直接在命令列模式上进行sed的操作编辑；
-f  ：直接将sed的操作写在一个文件内， -f filename 则可以执行 filename 内的sed操作；
-r  ：sed的操作支持的是扩展正则表达式的语法。(默认是基础正则表达式语法)
-i  ：直接修改读取的文件内容，而不是由屏幕输出。

操作说明：  [n1[,n2]]function
n1, n2 ：不一定存在，一般代表"选择进行操作的行数"，举例来说，如果我的操作是需要在10到20行之间进行的，则"10,20[操作行为]"

function 有下面这些：
a   ：新增，a 的后面可以接字符串，而这些字符串会在新的一行出现(目前的下一行)。
c   ：替换，c 的后面可以接字符串，这些字符串可以替换 n1,n2 之间的行！
d   ：删除，因为是删除，所以 d 后面通常不接任何内容；
i   ：插入，i 的后面可以接字符串，而这些字符串会在新的一行出现(目前的上一行)；
p   ：打印，即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运作。
s   ： 替换，可以直接进行替换的工作！通常这个s的操作可以搭配正则表达式！例如 1,20s/old/new/g ！
```
## 2.2.	范例

范例1：将/etc/passwd的内容列出，并且需要打印行号，同时，请将第 2~5 行删除！
```
[root@stu412 test]# nl /etc/passwd | sed '2,5d'
1  root:x:0:0:root:/root:/bin/bash
6  sync:x:5:0:sync:/sbin:/bin/sync
7  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
8  halt:x:7:0:halt:/sbin:/sbin/halt
.....(后面省略).....
# 因为2-5行删除了，所以显示的数据中，就没有 2-5 行。
# 另外，注意一下，原本应该是要下达 sed -e 才对，没有 -e 也行！
# 同时也要注意的是， sed 后面接的操作，请务必以 '' 两个单引号括住！
# 如果只要删除第 2 行，可以使用 nl /etc/passwd | sed '2d'
# 至于第3行到最后一行，则是 nl /etc/passwd | sed '3,$d'
```
范例2：承上题，在第二行后(即是加在第三行)加上"drink tea?"字样！
```
[root@stu412 test]# nl /etc/passwd | sed '2a drink tea'
1  root:x:0:0:root:/root:/bin/bash
2  bin:x:1:1:bin:/bin:/sbin/nologin
drink tea
3  daemon:x:2:2:daemon:/sbin:/sbin/nologin
4  adm:x:3:4:adm:/var/adm:/sbin/nologin
.....(后面省略).....

[root@stu412 test]# nl /etc/passwd | sed '2i drink tea'
1  root:x:0:0:root:/root:/bin/bash
drink tea
2  bin:x:1:1:bin:/bin:/sbin/nologin
3  daemon:x:2:2:daemon:/sbin:/sbin/nologin
.....(后面省略).....
```

范例3：在第二行后面加入两行字，例如"Drink tea or .....""drink beer?"
```
[root@stu412 test]# nl /etc/passwd | sed '2a Drink tea or ......\
> drink beer ?'
1  root:x:0:0:root:/root:/bin/bash
2  bin:x:1:1:bin:/bin:/sbin/nologin
Drink tea or ......
drink beer ?
3  daemon:x:2:2:daemon:/sbin:/sbin/nologin
4  adm:x:3:4:adm:/var/adm:/sbin/nologin
.....(后面省略).....
# 我们可以新增不只一行喔！可以新增好几行，但是每一行之间都必须要以反斜杠 \ 来进行新行的增加！
```
范例4：将第2-5行的内容替换成为"No 2-5 number"
```
[root@stu412 test]# nl /etc/passwd | sed '2,5c No 2-5 number'
1  root:x:0:0:root:/root:/bin/bash
No 2-5 number
6  sync:x:5:0:sync:/sbin:/bin/sync
7  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
.....(后面省略).....
```
范例5：仅列出第5-7行
```
[root@stu412 test]# nl /etc/passwd | sed -n '5,7p'
5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
6  sync:x:5:0:sync:/sbin:/bin/sync
7  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
[root@stu412 test]#
# 为什么要加 -n 的参数呢？执行 sed '5,7p' 就知道了！(5-7行会重复输出)
# 有没有加上 -n 的参数时，输出的数据可是差很多的！
[root@stu412 test]# nl /etc/passwd | sed  '5,7p'  
1  root:x:0:0:root:/root:/bin/bash
2  bin:x:1:1:bin:/bin:/sbin/nologin
3  daemon:x:2:2:daemon:/sbin:/sbin/nologin
4  adm:x:3:4:adm:/var/adm:/sbin/nologin
5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
6  sync:x:5:0:sync:/sbin:/bin/sync
6  sync:x:5:0:sync:/sbin:/bin/sync
7  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
7  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
8  halt:x:7:0:halt:/sbin:/sbin/halt
9  mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
10  news:x:9:13:news:/etc/news:
.....(后面省略).....
```
范例6：我们可以使用ifconfig 来列出 IP ，若仅要eth0的IP时？
```
[root@stu412 test]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:2B:58:FA  
inet addr:192.168.84.128  Bcast:192.168.84.255  Mask:255.255.255.0
UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
RX packets:7168 errors:0 dropped:0 overruns:0 frame:0
TX packets:7338 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:1603536 (1.5 MiB)  TX bytes:870607 (850.2 KiB)
Interrupt:67 Base address:0x2000
[root@stu412 test]# ifconfig eth0 | grep 'inet ' | sed 's/^.*addr://g' | \
> sed 's/Bcast.*$//g'
192.168.84.128
```
范例7：将 /etc/man.config文件的内容中，有MAN的设置就取出来，但不要注释。
```
[root@stu412 test]# cat /etc/man.config | grep 'MAN'| sed 's/#.*$//g' | \
> sed '/^$/d'
# 每一行中，若有#表示该行为注释，但是要注意的是，有时候，注释并不是写在第一个字符，
# 而是写在某个命令后面，如"shutdown -h now # 这个是关机的命令"，注释 # 就在命令的后面了。
# 因此，我们才会使用到 #.*$ 这个正则表达式！
```
范例8：利用sed直接在~/.bashrc最后一行加入"# This is a test"
```
[root@stu412 test]# sed -i '$a # This is a test'  ~/.bashrc
#  -i 参数可以直接修改后面接的文件内容！而不是由屏幕输出。
# 至于那个 $a  则代表最后一行才新增的意思。
[root@stu412 test]# cat ~/.bashrc | tail -5
# Source global definitions
if [ -f /etc/bashrc ]; then
. /etc/bashrc
fi
# This is a test
```
范例9：第N处才开始替换
```
[root@stu412 test]# echo this thisthisthis | sed 's/this/THIS/g' #/g会替换每一处
THIS THISTHISTHIS
[root@stu412 test]# echo this thisthisthis | sed 's/this/THIS/2g'#第二处才开始替换
this THISTHISTHIS
[root@stu412 test]# echo this thisthisthis | sed 's/this/THIS/3g'
this thisTHISTHIS
[root@stu412 test]# echo this thisthisthis | sed 's/this/THIS/4g'
this thisthisTHIS
```
范例10：移除空白行
```
[root@stu412 test]# cat file
1

2


3
4
5
[root@stu412 test]# sed '/^$/d' file #空白行中，行尾标记紧随着行首标志
1
2
3
4
5
```
范例11：已匹配字符标志&
```
[root@stu412 test]# echo this is an example | sed 's/\w\+/[&]/g'
[this] [is] [an] [example]
#\w\+匹配每一个单词，然后我们用[&]替换它。
```
范例12：字串匹配标志\1
```
[root@stu412 test]# echo this is digit 7 in a number | sed 's/digit \([0-9]\)/\1/'
this is 7 in a number

#两个子串位置互换,第一个字串标记\1, 第二个字串标记\2,依此类推
[root@stu412 test]# echo seven RIGHT | sed 's#\(\w\+\) \(\w\+\)#\2 \1#'
RIGHT seven
```
范例13：组合多个表达式
```
一次执行多个命令的方式有三种：
(1) sed 'cmd1; cmd2'     			(使用;号把命令隔开，注意前面不加-e参数)
(2) sed -e 'cmd1' -e 'cmd2'        (使用多个-e参数)
(3) sed  'cmd1' | sed   'cmd2'
```
# 3.	awk
## 3.1.	说明
sed 常用于整行的处理， awk 则较倾向于一行当中分成数个"字段"来处理。 因此，awk 相当的适合处理小型的数据数据处理！awk 通常执行的模式是：
```
# awk [option] 'BEGIN {actions} pattern1 { actions } ... patternN { actions } END { actions }'   filename
常用的option选项有：
① -F fs : 使用fs作为输入记录的字段分隔符，如果省略该选项，awk使用环境变量IFS的值。
② -f filename : 从文件filename中读取awk_script（即patternX { actions }）。
③ -v var=value : 为awk_script设置变量。
一个awk脚本通常由3部分组成:BEGIN语句块、END语句块和能够使用模式匹配的通用语句块。这3个部分是可选的，它们中的任何一个部分都可以不出现在脚本中。脚本通常会包含在单引号或双引号中。
pattern语句中的通用语句是可选的，如果不提供，则默认是执行{print}，打印每一个读取到的行。
# awk 'BEGIN{ i=0 } {i++} END {print i}' file

#执行过程
① awk执行BEGIN指定的actions。
② awk从输入文件中读取一行，称为一条输入记录。(如果输入文件省略，将从标准输入读取)。
③ awk将读入的记录分割成字段，将第1个字段放入变量$1中，第2个字段放入$2，以此类推。$0表示整条记录。字段分隔符使用shell环境变量IFS或由参数指定。
④ 把当前输入记录依次与每一个awk_cmd中pattern比较，看是否匹配，如果相匹配，就执行对应的actions。如果不匹配，就跳过对应的actions，直到比较完所有的awk_cmd。
⑤ 当一条输入记录比较了所有的awk_cmd后，awk读取输入的下一行，继续重复步骤③和④，这个过程一直持续，直到awk读取到文件尾。
⑥ 当awk读完所有的输入行后，就执行END相应的actions。
awk 可以处理后续接的文件，也可以读取来自前个命令的标准输出。 awk 主要是处理"每一行字段内的数据"，而默认的"字段的分隔符为 "空格键" 或 "[tab]键" "！
整个 awk 的处理流程是：
(1)	读入第一行，并将第一行的资料填入 $0, $1, $2.... 等变数当中；
(2)	依据 "条件类型" 的限制，判断是否需要进行后面的 "动作"；
(3)	做完所有的动作与条件类型；
(4)	若还有后续的"行"的数据，则重复上面 1~3 的步骤，直到所有的数据都读完为止。

awk是"以行为一次处理的单位"， 而"以字段为最小的处理单位"
变量名称	代表意义
NF	每一行 ($0) 拥有的字段总数
NR	目前 awk 所处理的是"第几行"数据
FS	目前的分隔字符，默认是空格键
$0	当前行的文本
$1	第一个字段的内容
$2	第二个字段的内容

注意， awk 后续的所有动作以 ' 括住， 所以，内容如果想要以print打印时，记得，非变量的文字部分，，都需要使用双引号来括起来！)
[root@stu412 test]# last | awk '{print $1 "\t lines: " NR "\t columes: " NF}'
root     lines: 1        columes: 10
root     lines: 2        columes: 10
...
```
## 3.2.	范例
范例1：特殊变量的使用！
```
[root@stu412 test]# cat file
line1 f2 f3
line2 f4 f5
line3 f6 f7
[root@stu412 test]# awk '{print "Line no:"NR",No of fields:"NF, "$0="$0, "$1="$1,"$2="$2,"$3="$3}' file
Line no:1,No of fields:3 $0=line1 f2 f3 $1=line1 $2=f2 $3=f3
Line no:2,No of fields:3 $0=line2 f4 f5 $1=line2 $2=f4 $3=f5
Line no:3,No of fields:3 $0=line3 f6 f7 $1=line3 $2=f6 $3=f7
#我们可以用$NF打印最后一个字段，用$(NF-1)打印倒数第二个字段,依次类推。

[root@stu412 test]# seq 5 | awk 'BEGIN{ sum=0; print "Summation:" }
> { print $1"+"; sum+=$1 } END { print "=="; print sum }'
Summation:
1+
2+
3+
4+
5+
==
15
```
范例2：使用外部变量！-v参数

```
[root@stu412 ~]# VAR=10000
[root@stu412 ~]# echo | awk -v VARIABLE=$VAR '{ print VARIABLE }'
10000

#传递多个外部变量
[root@stu412 ~]# var1="Variable1" ; var2="Variable2"
[root@stu412 ~]# echo | awk '{ print v1,v2 }' v1=$var1 v2=$var2
Variable1 Variable2
```
范例3：过滤awk处理的行
```
$ awk 'NR < 5'		# 行号小于5的行
$ awk 'NR==1,NR==4'	#行号在1到4之间的行
$ awk '/linux/'		# 包含linux的行
$ awk '!/linux/'		# 不包含linux的行

[root@stu412 ~]# seq 10 | awk 'NR < 5'
1
2
3
4
[root@stu412 ~]# seq 10 | awk 'NR==1,NR==4'
1
2
3
4
[root@stu412 ~]# seq 10 | awk '/3/'
3
[root@stu412 ~]# seq 10 | awk '!/3/'
1
2
4
5
6
7
8
9
10
```
范例4：设置字段定界符
```
#使用-F "delimiter"指定定界符
[root@stu412 ~]# awk -F: '{print $NF}' /etc/passwd
/bin/bash
/sbin/nologin
/sbin/nologin
...
#BEGIN中指定定界符
[root@stu412 ~]# awk 'BEGIN { FS=":" } { print $NF }' /etc/passwd
/bin/bash
/sbin/nologin
/sbin/nologin
...
```

