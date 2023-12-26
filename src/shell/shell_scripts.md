# shell脚本编程精讲

# 1.  shell介绍
## 1.1.    常用操作系统默认shell
```
Linux是Bourne Again Shell (bash)
Solaris和FreeBSD是Bourne Shell (sh)
AIX是Korn Shell(ksh)
HP-UX缺省的是POSIX shell(sh)
```
## 1.2.    shell脚本建立和执行
脚本开头(第一行)

一个规范的shell脚本的第一行会指出由哪个程序(解释器)来执行脚本中的内容,linux中一般为

#!/bin/bash或#!/bin/sh

sh和bash的区别:sh为bash的软链接，推荐标准写法：#!/bin/bash。
```
shell脚本执行的三种方法：
(1) bash script-name或sh script-name
(2) path/script-name或./script-name
(3) source script-name或 . script-name
```
说明：
第一种方法是当脚本本身没有可执行权限时常用的方法。推荐用bash执行。

第二种方法是需先将脚本文件的权限改为可执行(加x位,chmod u+x script-name或chmod 755 script-name),然后通过脚本路径就可以执行了。

第三种方法所执行的脚本中(如sun.sh)的语句会作为父shell脚本(如father.sh)进程的一部分执行，因此可将sun.sh自身脚本中的变量函数等返回值传递到当前父shell脚本father.sh中使用。

```
[root@test ~]# echo "userdir=`pwd`">test.sh
[root@test ~]# cat test.sh 
userdir=/root
[root@test ~]# sh test.sh 
[root@test ~]# echo $userdir  #此处为空值

[root@test ~]#

[root@test ~]# source test.sh 
[root@test ~]# echo $userdir
/root
```
通过source或.点号执行过的脚本，在脚本执行结束后的变量(包括函数)值在当前shell中依然存在，而sh和bash则不行。

## 1.3.    shell脚本开发基本规范及习惯
(1) 开头指定脚本解释器

#!/bin/bash或#!/bin/bash

(2) 开头加版本版权等信息
```
#Date:
#Author:
#Mail:
#Funtion:
#Version:
```

提示：可配置vim编辑器后自动加上以上信息

(3) 脚本中不用中文注释

(4) 脚本以.sh为扩展名

(5) 代码书写优秀习惯
```
   成对的内容一次写出来
   []中括号两端要有空格，书写时即可留出空格[  ]
   流程控制一次书写完，再添加内容。
```
# 2.  shell变量基础及深入
## 2.1.    变量类型
两类：环境变量(全局变量)和局部变量
## 2.2.    环境变量
环境变量定义Shell运行的环境。可用于所有子进程，这包括编辑器、脚本和应用。

环境变量用于所有用户进程（经常称为子进程）。登录进程称为父进程。s h e l l中执行的用户进程均称为子进程。不像本地变量（只用于现在的s h e l l）环境变量可用于所有子进程，这包括编辑器、脚本和应用。

环境变量可以在命令行中设置，但用户注销时这些值将丢失，因此最好在. profile文件中定义。系统管理员可能在/etc/profile文件中已经设置了一些环境变量。将之放入profile文件意味着每次登录时这些值 都将被初始化。

传统上，所有环境变量均为大写。环境变量应用于用户进程前，必须用export命令导出。


## 2.3.    自定义环境变量
如果想设置环境变量，就要在给变量赋值之后或设置变量时使用export命令，带-x选项的declare内置命令也可完成同样的功能。

格式：
(1) export 变量名=value

(2) 变量名=value; export 变量名 

(3) declare -x 变量名=value

## 2.4.    显示或取消环境变量
```
#echo显示
[root@test ~]# echo $HOME
/root
[root@test ~]# echo $UID
0
[root@test ~]# echo $PWD
/root
[root@test ~]# echo $SHELL
/bin/bash
[root@test ~]# echo $USER
root

#env或set显示系统默认的环境变量
[root@test ~]# env
HOSTNAME=test
TERM=vt100
SHELL=/bin/bash
HISTSIZE=1000
SSH_CLIENT=192.168.65.1 50140 22
SSH_TTY=/dev/pts/3
USER=root
LS_COLORS=no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:bd=40;33;01:cd=40;33;01:or=01;05;37;41:mi=01;05;37;41:ex=01;32:*.cmd=01;32:*.exe=01;32:*.com=01;32:*.btm=01;32:*.bat=01;32:*.sh=01;32:*.csh=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tz=01;31:*.rpm=01;31:*.cpio=01;31:*.jpg=01;35:*.gif=01;35:*.bmp=01;35:*.xbm=01;35:*.xpm=01;35:*.png=01;35:*.tif=01;35:
MAIL=/var/spool/mail/root
PATH=/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/mysql/bin:/root/bin
INPUTRC=/etc/inputrc
PWD=/root
LANG=en_US.UTF-8
SHLVL=1
HOME=/root
LOGNAME=root
CVS_RSH=ssh
SSH_CONNECTION=192.168.65.1 50140 192.168.65.151 22
LESSOPEN=|/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env

[root@test ~]# set
BASH=/bin/bash
BASH_ARGC=()
BASH_ARGV=()
BASH_LINENO=()
BASH_SOURCE=()
BASH_VERSINFO=([0]="3" [1]="2" [2]="25" [3]="1" [4]="release" [5]="i686-redhat-linux-gnu")
BASH_VERSION='3.2.25(1)-rele
…省略…

使用unset取消本地变量和环境变量
[root@test ~]# echo $USER
root
[root@test ~]# unset USER
[root@test ~]# echo $USER

[root@test ~]#
```
## 2.5.    本地变量
本地变量在用户当前的Shell生存期的脚本中使用。

普通字符串变量的定义：
```
name=value
name='value'
name="value"
```

```
[root@test ~]# a=192.168.1.1
[root@test ~]# b='192.168.1.1'
[root@test ~]# c="192.168.1.1"
[root@test ~]# echo "a=$a"
a=192.168.1.1
[root@test ~]# echo "b=$b"
b=192.168.1.1
[root@test ~]# echo "c=${c}"
c=192.168.1.1


[root@test ~]# a=192.168.1.1-$a
[root@test ~]# b='192.168.1.1-$a'
[root@test ~]# c="192.168.1.1-$a"
[root@test ~]# echo "a=$a"
a=192.168.1.1-192.168.1.1
[root@test ~]# echo "b=$b"
b=192.168.1.1-$a
[root@test ~]# echo "c=${c}"
c=192.168.1.1-192.168.1.1-192.168.1.1
```

注意单引号、双引号、不加引号的区别。

(1)单引号：
将单引号内的内容原样输出，或者描述为单引号里面看到的是什么就会输出什么。

(2)双引号：
把双引号内的内容输出出来；如果内容中有命令、变量等，会先把变量、命令解析出结果，然后在输出最终内容来。

(3)不加引号：
不会将含有空格的字符串视为一个整体输出, 如果内容中有命令、变量等，会先把变量、命令解析出结果，然后再输出最终内容来。

如果字符串中带有空格等特殊字符，则不能完整的输出，需要改加双引号，一般连续的字符串，数字，路径等可以用。

```
自定义变量的建议：
(1) 纯数字(不带空格)，定义可以不加引号
(2) 没特殊情况，字符串一般用双引号定义，特别是多个字符串中间有空格时。
(3) 变量内容需要原样输出，要用单引号。

变量命名规范：
(1) 命名要统一，使用全部大写字母，如APACHE_ERR_NUM，语义要清晰，能够正确表达变量内容的含义，过长单词可用前几个单词代替。多个单词连接可用"_"号连接，最好以${APACHE_ERR_NUM}或"${APACHE_ERR_NUM}"引用变量。
(2) 避免无意义字符或数字。
(3) 全局变量命名要用大写，使用时使用{}大括号括起来。
(4) 局部变量要以local方式进行声明(如local i)，使之在函数作用域内有效,防止变量在函数中的命名与变量外部程序中变量重名造成程序异常。
(5) 变量合并：当某些变量或配置项要组合起来才有意义时，如文件路径和文件名称，建议要将组合的变量合并到一起赋值给一个新的变量，这样既方便之后的调用，也为以后进行修改提供了方便。
VERSION="2.2.22"
SOFTWARE_NAME="httpd"
SOFTWARE_FULLNAME="${SOFTWARE_NAME}-${VERSION}.tar.gz"
(6) 变量定义总结：多学习系统自带的/etc/init.dfunction函数库脚本定义思路。
```
## 2.6.    shell特殊变量
```
(1) 位置变量
$0  当前执行的脚本名字
$n  当前脚本的第n个参数,n=1..9,如果n>9,用大括号括起来：${10}
$*  当前shell的所有参数 $1 $2 $3 …
$#  当前shell参数的总个数
$@  程序的所有参数"$1" "$2" "$3" "…"
 
(2) 进程状态变量
$$  获取当前shell的进程号(PID)
$!  执行上一个指令的PID
$?  获取执行上一个指令的返回值(0成功，非零为失败) 
$_  在此之前执行的命令或脚本的最后一个参数。
```

```
[root@test ~]# cat var.sh 
echo '$0 :' $0
echo '$n :' '$1'=$1 '$2'=$2 '$3'=$3
echo '$* :' $*
echo '$# :' $#
echo '$$ :' $$

sleep 2 &
echo '----' 
echo '$! :' $!
echo '$? :' $?
echo '$@ :' $@
echo '$_ :' $_
[root@test ~]# sh var.sh p1 p2 p3
$0 : var.sh
$n : $1=p1 $2=p2 $3=p3
$* : p1 p2 p3
$# : 3
$$ : 17124
----
$! : 17125
$? : 0
$@ : p1 p2 p3
$_ : p3

portmap使用实例
[root@test ~]# cat /etc/init.d/portmap 
#! /bin/sh
#
# portmap       Start/Stop RPC portmapper
#
# chkconfig: 345 13 87
# description: The portmapper manages RPC connections, which are used by \
#              protocols such as NFS and NIS. The portmap server must be \
#              running on machines which act as servers for protocols which \
#              make use of the RPC mechanism.
# processname: portmap


# This is an interactive program, we need the current locale
[ -f /etc/profile.d/lang.sh ] && . /etc/profile.d/lang.sh
# We can't Japanese on normal console at boot time, so force LANG=C.
if [ "$LANG" = "ja" -o "$LANG" = "ja_JP.eucJP" ]; then
    if [ "$TERM" = "linux" ] ; then
        LANG=C
    fi
fi

# Source function library.
. /etc/init.d/functions

# Get config.
if [ -f /etc/sysconfig/network ]; then
    . /etc/sysconfig/network
else
    echo $"Networking not configured - exiting"
    exit 1
fi

prog="portmap"

# Check that networking is up.
if [ "$NETWORKING" = "no" ]; then
        exit 0
fi

[ -f /sbin/portmap ] || exit 0

[ -f /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

RETVAL=0

start() {
        echo -n $"Starting $prog: "
        daemon portmap $PMAP_ARGS
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/portmap
        return $RETVAL
}


stop() {
        echo -n $"Stopping $prog: "
        killproc portmap
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/portmap
        return $RETVAL
}

restart() {
        pmap_dump > /var/run/portmap.state
        stop
        start
        pmap_set < /var/run/portmap.state
        rm -f /var/run/portmap.state
}

# See how we were called.
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status portmap
        ;;
  restart|reload)
        restart
        ;;
  condrestart)
        [ -f /var/lock/subsys/portmap ] && restart || :
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|reload|condrestart}"
        exit 1
esac

exit $?
```
## 2.7.    bash内部变量
```
有些内部命令在目录列表时是看不见的，它们由shell本身提供，常用的内部命令有：echo,eval,exec,export,readonly,read,shift,wait,exit和点(.)。
(1) echo arg
在屏幕上显示出由arg指定的字串。

(2) eval args
当Shell程序执行到eval语句时，Shell读入参数args，并将它们组合成一个新的命令，然后执行。

(3) exec 命令参数
当Shell执行到exec语句时，不会去创建新的子进程，而是转去执行指定的命令，当指定的命令执行完时，该进程（也就是最初的 Shell）就终止了，所以Shell程序中exec后面的语句将不再被执行。

(4) export  变量名=value
Shell可以用export把它的变量向下带入子Shell，从而让子进程继承父进程中的环境变量。但子Shell不能用export把它 的变量向上带入父Shell。
注意：不带任何变量名的export语句将显示出当前所有的export变量。

(5) readonly 变量名
将一个用户定义的Shell变量标识为不可变。不带任何参数的readonly命令将显示出所有只读的Shell变量。

(6) read 变量名表
从标准输入设备读字符串，传给指定变量。

(7) shift 语句
shift语句按如下方式重新命名所有的位置参数变量，即$2成为$1，$3成为$2…在程序中每使用一次shift语句，都使所有的位置参 数依次向左移动一个位置，并使位置参数$#减1，直到减到0为止。
```

## 2.8.    变量子串的常用操作
```
${#string}  返回$string的长度
${string:position}  在$string中,从位置$position开始提取子串
${string:position:length}   在$string中,从位置$position开始提取长度为$length的子串
${string#substring} 从变量$string的开头,删除最短匹配$substring的子串
${string##substring}    从变量$string的开头,删除最长匹配$substring的子串
${string%substring} 从变量$string的结尾,删除最短匹配$substring的子串
${string%%substring}    从变量$string的结尾,删除最长匹配$substring的子串
${string/substring/replacement} 使用$replacement,来代替第一个匹配的$substring
${string//substring/replacement}    使用$replacement,代替所有匹配的$substring
${string/#substring/replacement}    如果$string的前缀匹配$substring,那么就用$replacement来代替匹配到的$substring
${string/%substring/replacement}    如果$string的后缀匹配$substring,那么就用$replacement来代替匹配到的$substring
```

```
[root@test ~]# OLDBOY="I am oldboy"
[root@test ~]# echo ${OLDBOY}
I am oldboy
[root@test ~]# echo ${#OLDBOY}      #显示长度
11
[root@test ~]# echo ${OLDBOY:2}     #取第二个字符以后的内容
am oldboy
[root@test ~]# echo ${OLDBOY:2:2}   #取第二个字符以后取两个字符的内容
am
[root@test ~]# echo ${OLDBOY#I am}  #删除最短匹配的I am 字串
oldboy
[root@test ~]# echo ${OLDBOY#I am old}
boy
[root@test ~]# echo ${OLDBOY##I am old}
boy
[root@test ~]# echo ${OLDBOY%oldboy}
I am
[root@test ~]# echo ${OLDBOY%%boy}
I am old

[root@test ~]#
```

补充：

(1) 条件变量替换：

${value:-word}

当变量未定义或为空时，返回word的内容，否则返回变量的内容。
```
[root@test ~]# result=${test:-UNSET}
[root@test ~]# echo $result
UNSET
[root@test ~]# test=''
[root@test ~]# result=${test:-UNSET}
[root@test ~]# echo $result
UNSET
[root@test ~]# test='123'
[root@test ~]# result=${test:-UNSET}
[root@test ~]# echo $result
123
(2) ${value:=word}
```
与前者类似,只是若变量未定义或者值为空时,在返回word的值的同时将word赋值给value

(3) ${value:?message}

若变量以赋值的话,正常替换.否则将消息message送到标准错误输出(若此替换出现在Shell程序中,那么该程序将终止运行)

## 2.9.    变量的数值计算
数值计算常用命令：(()), let, expr, bc, $[]

(1) (())的用法(此法很常用)

执行简单的整数运算，只需将特定的算术表达式用"$(("和"))"括起。
```
[root@test ~]# ((a=1+2**3-4%3))
[root@test ~]# echo $a
8
[root@test ~]# a=$((1+2))
[root@test ~]# echo $a
3
[root@test ~]# echo $((1+2+3))
6
[root@test ~]# echo ((1+2+3))
-bash: syntax error near unexpected token `('
[root@test ~]# 
[root@test ~]# echo $a
3
[root@test ~]# echo $((a+=1))
4
[root@test ~]# echo $((a++))
4
[root@test ~]# echo $((3>2))
1
[root@test ~]# echo $((3<2))
0
[root@test ~]# echo $((3==2))
0
[root@test ~]# echo $((3!=2))
1
```
提示：

1.**为幂运算: %为取模运算(就是除法当中取余数)，加减乘除我就不细说了吧。

2.上面涉及到的参数必须为整数（整型）。不能是小数（符点数）或者字符串。bc命令可以进行浮点数运算，但一般较少用到，下文会提到。提醒下，你可以直接在shell脚本中使用上述命令进行计算。

3.echo $((a++))和echo $((a--)) 表示先输出a自身的值，然后在进行++ --的运算，echo $((++a)) 和echo $((--a))表示先进行++ --的运算，在输出a自身的值。
```
[root@test ~]# a=2
[root@test ~]# b=3
[root@test ~]# echo " a+b=$(($a+$b))"
 a+b=5

(2) let用法
let 表达式
[root@test ~]# i=2
[root@test ~]# i=i+8
[root@test ~]# echo $i
i+8

[root@test ~]# i=2
[root@test ~]# let i=i+8
[root@test ~]# echo $i
10
提示：let i=i+8 等同于((i=i+8)),但后者效率更高。
(3) expr- evaluate expressions命令用法
[root@test ~]# expr 2 + 2
4
[root@test ~]# expr 2+2
2+2
[root@test ~]# expr 2*2
2*2
[root@test ~]# expr 2 * 2
expr: syntax error
[root@test ~]# expr 2 \* 2
4
[root@test ~]# expr 2\*2
2*2
[root@test ~]# expr 2 % 2
0
[root@test ~]# expr 2%2
2%2
提示：
   运算符左右都有空格;
   使用*时必须用反斜线屏蔽其特定含义。

#循环时自增
[root@test ~]# i=0
[root@test ~]# i=`expr $i + 1`
[root@test ~]# echo $i
1

#expr $[$a+$b]表达式
[root@test ~]# expr $[2+3]
5
[root@test ~]# expr $[2*3]
6
[root@test ~]# a=3
[root@test ~]# b=5
[root@test ~]# expr $[$a+$b]
8
[root@test ~]# expr $[$a*$b]
15
 

(4) bc命令用法

[root@test ~]# echo 3.5+5|bc
8.5
[root@test ~]# echo 3.5*5.2|bc
18.2
[root@test ~]# echo 3.52*5.21|bc
18.33
[root@test ~]# echo "3.52*5.21"|bc
18.33
[root@test ~]# echo "scale=1;3.52*5.21"|bc  #精度只对除法有效
18.33
[root@test ~]# echo "13.52/5.21"|bc
2
[root@test ~]# echo "scale=1;13.52/5.21"|bc
2.5
[root@test ~]# echo "obase=2;2" | bc
10
[root@test ~]# echo "obase=16;20" | bc      #10进制20转换成16进制
14


直接使用整数计算：
[root@test ~]# typeset -i a=1 b=3
[root@test ~]# a=a+b
[root@test ~]# echo $a
4

(5) $[]运算
[root@test ~]# echo $[2+3]
5
[root@test ~]# echo $[2*3]
6


Shell变量的输入
Read语法格式：
read [参数] [变量名]
常用参数：
-p prompt:设置提示信息
-t timeout 设置输入等待的时间，单位默认为秒。
[root@test ~]# read -p "please input two number:" a1 a2
please input two number:3 4
[root@test ~]# echo $a1 $a2
3 4
[root@test ~]#

[root@test ~]# read -t 5 -p "please input two number:" a1 a2 #5秒不输入则退出
please input two number:[root@test ~]#
```
# 3.  条件测试
## 3.1.    测试语句
### 3.1.1.  条件测试语法
```
语法说明：
格式1：test <测试表达式>
格式2：[ <测试表达式> ]
格式3：[[ <测试表达式> ]]
说明：
格式1和格式2是等价的
格式3为扩展的test命令,有网友推荐格式3,老男孩习惯使用格式2。
提示：
1.  在[[]]中可以使用通配符进行模式匹配。
2.  &&、||、>、<等操作符可以应用于[[]]中，但不能应用于[]中。
3.  对整数进行关系运算，也可以使用shell的算术运算符(())。
```

```
语法举例：
格式1：test <测试表达式>
[root@test ~]# test -f file && echo true || echo false
false
[root@test ~]# touch file
[root@test ~]# test -f file && echo true || echo false
true
#测试!用法
[root@test ~]# test ! -f file && echo true || echo false
false


格式2：[ <测试表达式> ]
[root@test ~]# rm -f file
[root@test ~]# [ -f file ] && echo 1 || echo 0
0
[root@test ~]# touch file
[root@test ~]# [ -f file ] && echo 1 || echo 0
1
[root@test ~]# [ ! -f file ] && echo 1 || echo 0
0

格式3：[[ <测试表达式> ]]
[root@test ~]# [[ ! -f file ]] && echo 1 || echo 0
0
[root@test ~]# [[ -f file ]] && echo 1 || echo 0
1
[root@test ~]# [[ -f file && -f folder ]] && echo 1 || echo 0
0
[root@test ~]# ls -l file
-rw-r--r-- 1 root root 0 Sep  8 16:52 file
[root@test ~]# [[ -f file && -f file2 ]] && echo 1 || echo 0
0
[root@test ~]# [ -f file && -f file2 ] && echo 1 || echo 0
-bash: [: missing `]'
0
[root@test ~]# [ -f file -a -f file2 ] && echo 1 || echo 0
0
```
### 3.1.2.  文件测试操作符
```
常用文件测试操作符
文件测试操作符 说明
-d pathname 当pathname 存在并且是一个目录时返回真
-e pathname 当由pathname 指定的文件或目录存在时返回真
-f filename 当filename 存在并且是普通文件时返回真
-r pathname 当由pathname 指定的文件或目录存在并且可读时返回真
-s filename 当filename 存在并且文件大小大于0 时返回真
-w pathname 当由pathname 指定的文件或目录存在并且可写时返回真
-x pathname 当由pathname 指定的文件或目录存在并且可执行时返回真
file1 -nt file2 file1 比file2 新时返回真
file1 -ot file2 file1 比file2 旧时返回真
```
 
### 3.1.3.  字符串测试操作符
```
操作符 说明
-z string   字符串string 为空串(长度为0)时返回真
-n string   字符串string 为非空串时返回真
str1 = str2 字符串str1 和字符串str2 相等时返回真
str1 == str2    同 =
str1 != str2    字符串str1 和字符串str2 不相等时返回真
str1 < str2 按字典顺序排序，字符串str1 在字符串str2 之前
str1 > str2 按字典顺序排序，字符串str1 在字符串str2 之后
if[ "$a"="$b" ],其中$a最好用""括起来。当然最好的方法就是if[ "${a}"="${b}" ]
```
### 3.1.4.  整数二元比较操作符
```
在[]中使用的操作符  在(())和[[]]中使用的操作符   说明
-eq ==  等于则返回真
-ne !=  不等于，则返回真
-lt >   小于，则返回真
-le >=  小于等于，则返回真
-gt <=  大于，则返回真
-ge <=  大于等于，则返回真
经过实践，"="和"!="在[]中使用不需要转义，包含">"和"<"的符号在[]中使用需要转义，对于数字不转义的结果未必会报错，但是结果可能不会对。
if[[ "$a"<"$b" ]], if[ "$a"\<"$b" ]
if[[ "$a">"$b" ]], if[ "$a"\>"$b" ]
if[[ "$a"="$b" ]], if[ "$a"="$b" ]
```

```
举例：二元数字比较
[root@test ~]# [ 2>1 ] && echo 1 || echo 0
0
[root@test ~]# [ 2<1 ] && echo 1 || echo 0
0
[root@test ~]# [  2 > 1 ] && echo 1 || echo 0
1
[root@test ~]# [  2 < 1 ] && echo 1 || echo 0   #不报错，但结果不对
1
[root@test ~]# [  2 \< 1 ] && echo 1 || echo 0
0
[root@test ~]# [  2 = 1 ] && echo 1 || echo 0
0
[root@test ~]# [  1 = 1 ] && echo 1 || echo 0
1


[root@test ~]# [[ 2 -gt 1 ]] && echo 1 || echo 0
1
[root@test ~]# [[ 2 -lt 1 ]] && echo 1 || echo 0
0

举例：二元字符比较
[root@test ~]# [ "a" > "bc" ] && echo 1 || echo 0
1
[root@test ~]# [ "a" < "bc" ] && echo 1 || echo 0
1
#上面条件不一样，但结果一样。虽然没报语法错误,显然结果不对。
[root@test ~]# [ "a" \> "bc" ] && echo 1 || echo 0
0
[root@test ~]# [ "a" \< "bc" ] && echo 1 || echo 0
1
#转义后结果正确了
```
### 3.1.5.  逻辑操作符
```
在[]中使用的操作符  在[[]]中使用的操作符    说明
-a  &&  逻辑与，操作符两边均为真，结果为真，否则为假。
-o  ||  逻辑或，操作符两边一边为真，结果为真，否则为假。
!   !   逻辑否，条件为假，结果为真。
```
### 3.2.    条件测试举例
```
[ -f "$file" ] && echo 1 || echo 0
if [ -f "$file" ] ; then echo 1; else echo 0; fi
#上面功能是等价的
#变量$file加了双引号，这是编程的好习惯，可以防止很多意外的发生。
```

### 3.2.1.  文件测试举例
```
[root@test ~]# file1=/etc/services ; file2=/etc/rc.local 
[root@test ~]# echo $file1 $file2
/etc/services /etc/rc.local

单条件文件测试：
[root@test ~]# [ -f "$file1" ] && echo 1 || echo 0  #文件存在且是普通文件
1
[root@test ~]# [ -d "$file1" ] && echo 1 || echo 0  #文件是不是目录
0
[root@test ~]# [ -s "$file1" ] && echo 1 || echo 0  #文件大小是否为0
1
[root@test ~]# [ -e "$file1" ] && echo 1 || echo 0  #文件是否存在
1

#如果变量不加双引号，结果可能不正确
[root@test ~]# echo $file7

[root@test ~]# [ -f $file7 ] && echo 1 || echo 0    #file7不存在还返回1
1
[root@test ~]# [ -f "$file7" ] && echo 1 || echo 0
0

#文件换成实体，加不加引号都是正确的
[root@test ~]# [ -f /etc/service ] && echo 1 || echo 0
0
[root@test ~]# [ -f /etc/services ] && echo 1 || echo 0
1
[root@test ~]# [ -f "/etc/service" ] && echo 1 || echo 0
0
[root@test ~]# [ -f "/etc/services" ] && echo 1 || echo 0
1

[root@test ~]# more /etc/init.d/nfs
…省略…
# Source networking configuration.
[ -f /etc/sysconfig/network ] && . /etc/sysconfig/network

# Check for and source configuration file otherwise set defaults
[ -f /etc/sysconfig/nfs ] && . /etc/sysconfig/nfs
…省略…



多条件文件测试：
-a 和 && , -o 和 || 、非(!)
[root@test ~]# [ -f "$file1" -o -e "$file2" ] && echo 1 || echo 0
1
[root@test ~]# [ -f "$file1" -a -e "$file2" ] && echo 1 || echo 0
1
[root@test ~]# [ -f "$file1" -a -e "$file3" ] && echo 1 || echo 0
0
[root@test ~]# [ -f "$file1" && -e "$file3" ] && echo 1 || echo 0
-bash: [: missing `]'
0

#-a 和 -o 用于[]
#&& 和 || 用于[[]]

[root@test ~]# [ 3 -ne 3 ] || {
> echo "a"
> echo "b"
> echo "c"
> }
a
b
c
[root@test ~]# [ 3 -ne 3 ] || { echo "a"; echo "b"; echo "c"; }
a
b
c
```

# 3.2.2.  字符串测试举例
```
单条件字符串测试
[root@test ~]# [ -n "$str" ] && echo 1 || echo 0
0
[root@test ~]# [ -z "$str" ] && echo 1 || echo 0
1
[root@test ~]# [ -z "$file1" ] && echo 1 || echo 0
0
[root@test ~]# [ -n "$file1" ] && echo 1 || echo 0
1

多条件字符串测试(略)
```
### 3.2.3.  整数测试举例

```
[root@test ~]# a1=10; a2=13
[root@test ~]# echo $a1 $a2
10 13
[root@test ~]# [ $a1 -eq $a2 ] && echo 1 || echo 0
0
[root@test ~]# [ $a1 -gt $a2 ] && echo 1 || echo 0
0
[root@test ~]# [ $a1 -lt $a2 ] && echo 1 || echo 0
1
[root@test ~]# [ $a1 -le $a2 ] && echo 1 || echo 0
1
[root@test ~]# [ $a1 -ge $a2 ] && echo 1 || echo 0
0
[root@test ~]# [ $a1 -ne $a2 ] && echo 1 || echo 0
1

[root@test ~]# a=0001
[root@test ~]# b=10
[root@test ~]# [ "$a" -ne "$b" ] && echo 1 || echo 0
1
[root@test ~]# [ "$a" -gt "$b" ] && echo 1 || echo 0
0
[root@test ~]# [ "$a" -lt "$b" ] && echo 1 || echo 0
1
#直接通过运算符比较
[root@test ~]# [[ $a1 = $a2 ]] && echo 1 || echo 0
0
[root@test ~]# [[ $a1 == $a2 ]] && echo 1 || echo 0
0
[root@test ~]# (( $a1 > $a2 )) && echo 1 || echo 0
0
```
### 3.2.4.  test命令测试的用法
```
[root@test ~]# echo $file1
/etc/services
[root@test ~]# test -z "$file1" || echo 0
0
[root@test ~]# test -z "$file3" || echo 0
[root@test ~]# test -z $a || echo 0
0
[root@test ~]# test -z $a $$ echo 1 || echo 0
-bash: test: too many arguments
0
[root@test ~]# test -z $a && echo 1 || echo 0
0
[root@test ~]# echo $a
0001
[root@test ~]# unset a
[root@test ~]# test -z $a && echo 1 || echo 0
1
[root@test ~]# test 1 -eq 1 && echo 1 || echo 0
1
[root@test ~]# test dd = ff && echo 1 || echo 0
0
[root@test ~]# test dd != ff && echo 1 || echo 0
1
```
### 3.2.5.  逻辑操作符举例
```
read m n
第一种写法：
if [ ${m} -eq 1 ] && [ ${n} -eq 2 ];then
    echo "good"
else
    echo "bad"
fi

第二种写法：
if [ ${m} -eq 1 -a ${n} -eq 2 ];then
    echo "good"
else
    echo "bad"
fi
 
第三种写法：
if [[ ${m} == 1 && ${n} == 2 ]];then
    echo "good"
else
    echo "bad"
fi

if [[ ${m} -eq 1 && ${n} -eq 2 ]];then
    echo "good"
else
    echo "bad"
fi


&& 与 -a 与逻辑符
[root@test ~]# read m n
1 2
[root@test ~]# echo $m $n
1 2
[root@test ~]# if [ ${m} -eq 1 ] && [ ${n} -eq 2 ];then
> echo "good"
> else
> echo "bad"
> fi
good
[root@test ~]# if [ ${m} -eq 1 -a ${n} -eq 2 ];then
> echo "good"
> else
> echo "bad"
> fi
good
[root@test ~]# if [[ ${m} == 1 && ${n} == 2 ]];then
> echo "good"
> else
> echo "bad"
> fi
good
[root@test ~]# if [[ ${m} -eq 1 && ${n} -eq 2 ]];then
> echo "good"
> else
> echo "bad"
> fi
good
```
# 4.  分支与循环结构
## 4.1.    if条件
### 4.1.1.  if条件语法
```
(1) 单分支结构
if [条件]
    then 
    指令集 
fi
或
if [条件];then 
    指令集 
fi
提示：分号相当于命令换行。
特殊写法：if [ -f "$file1" ];then echo 1;fi 


(2) 双分支结构
if 条件
    then 
    指令集 
else 
    指令集
fi
特殊写法：if [ -f "$file1" ];then echo 1 ;else echo 0;fi


(3) 多分支结构
if 条件
    then 
    指令集 
elif 条件
    then 
指令集
elif 条件
    then 
指令集
……
else 
    指令集
fi
```

### 4.1.2.  if条件举例
(1) 单分支结构
```
[root@test shell]# cat  if-single.sh 
#!/bin/bash
if [ 10 -lt 12 ]
        then
        echo "Yes, 10 is less than 12"
fi

echo "1.--------"
if [ "10" -lt "12" ]
    then
    echo "Yes, 10 is less than 12"
fi

echo "2.--------"
if [[ 10 < 12 ]];then
#if [[ 10<12 ]];then  #error
    echo "Yes, 10 is less than 12"
fi
[root@test shell]# sh if-single.sh 
Yes, 10 is less than 12
1.--------
Yes, 10 is less than 12
2.--------
Yes, 10 is less than 12
```
(2) 双分支结构
```
[root@test shell]# cat if-double1.sh 
#!/bin/bash
a=3
b=1
if [ $a -lt $b ]
        then
        echo "$a < $b"
else
        echo "$a >= $b"
fi
[root@test shell]# sh if-double1.sh 
3 >= 1
```
(3) 多分支结构
```
[root@test shell]# cat if-judenum1.sh 
#!/bin/bash
if [ $1 -gt $2 ]  
        then     
        echo "$1 > $2"
elif [ $1 -eq $2 ]  
        then      
        echo "$1 = $2"
else     
        echo "$1 < $2"
fi
[root@test shell]# sh if-judenum1.sh 1 2
1 < 2
[root@test shell]# sh if-judenum1.sh 11 11
11 = 11
[root@test shell]# sh if-judenum1.sh 11 12
11 < 12
[root@test shell]# sh if-judenum1.sh 
 >

#加了判断
[root@test shell]# cat if-judenum2.sh 
#!/bin/bash

print_error(){
        printf "input error!\n"
        echo -e "use eg. $0 num1 num2 "
        exit 1
}

if [[ $# != 2 ]] 
        then
        print_error
fi

[ -n "`echo $1|sed 's/[0-9]//g'`" -a -n "`echo $2|sed 's/[0-9]//g'`"  ] && \
echo "two args must be number" && exit 1

[ -n "`echo $1|sed 's/[0-9]//g'`" ] && echo "first args must be number" && exit 1
[ -n "`echo $2|sed 's/[0-9]//g'`" ] && echo "second args must be number" && exit 1
   

if [ $1 -gt $2 ]  
        then     
        echo "$1 > $2"
elif [ $1 -eq $2 ]  
        then      
        echo "$1 = $2"
else     
        echo "$1 < $2"
fi
[root@test shell]# sh if-judenum2.sh 
input error!
use eg. if-judenum2.sh num1 num2 
[root@test shell]# sh if-judenum2.sh 1 2
1 < 2
[root@test shell]# sh if-judenum2.sh 11 b
second args must be number
[root@test shell]# sh if-judenum2.sh 11a 22c
two args must be number
[root@test shell]# sh if-judenum2.sh 11a 22
first args must be number
```

扩展：判断字符串是否为数字?
```
方法1:sed加正则表达式
[ -n "`echo $1|sed 's/[0-9]//g'`" -a -n "`echo $2|sed 's/[0-9]//g'`"  ] && \
echo "two args must be number" && exit 1

[ -n "`echo $1|sed 's/[0-9]//g'`" ] && echo "first args must be number" && exit 1

#普通变量
[ -n "`echo $num|sed 's/[0-9]//g'`" ] && {
    echo "参数必须为数字" 
    exit 1
}


方法2:变量字串替换加正则表达式
#不为0则是数字
[ -z "`echo "${num//[0-9]/}"`" ] && echo 1 || echo 0

方法3: 变量字串替换加正则表达式
#删除非数字之后，看是否等于本身
[ -n "$num" -a "$num" = "${num//[^0-9]/}" ] && echo "it is num"


(4) 判断mysql是否启动，未启动则自动启动mysql
思路1:如果mysql端口和进程同时存在，即认为mysql服务正常!
[root@mysql-A shell]# cat if-judge-db0.sh 
#!/bin/bash
MYSQL_STARTUP="/data/3306/mysql"
db_process_count=`ps -ef|grep mysql|grep -v grep|wc -l`
db_port_count=`netstat -lnt|grep 3306|wc -l`

if [ ${db_process_count} -eq 2 ] && [ ${db_port_count} -eq 1 ]
  then
  echo "mysql is running! "
else
  ${MYSQL_STARTUP} start >/tmp/mysql.log
  sleep 10;
  if [ ${db_process_count} -ne 2 ] || [ ${db_port_count} -ne 1 ]
      then 
          killall mysqld >/dev/null 2>&1
          sleep 5
          killall mysqld >/dev/null 2>&1
          sleep 5
          [ ${db_port_count} -eq 0 ] && ${MYSQL_STARTUP} start >>/tmp/mysql.log 
          [ $? -eq 0 ] && echo "mysql is started"
   fi
   mail -s "mysql restarted" qxl_work@163.com < /tmp/mysql.log
fi
 
思路2:模拟web服务器，通过mysql账户连接mysql，根据返回状态或返回内容确认mysql服务是否正常!(推荐)
另外：通过web服务的url访问数据库来判断也可以。
手动检查：
[root@mysql-A shell]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "select version();"
+------------+
| version()  |
+------------+
| 5.1.65-log |
+------------+


脚本：
[root@mysql-A shell]# cat if-judge-db1.sh 
#!/bin/bash
MYSQL_STARTUP="/data/3306/mysql"

mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "select version();" >/dev/null 2>&1
if [ $? -eq 0 ]
  then
  echo "mysql is running! "
else
  ${MYSQL_STARTUP} start >/tmp/mysql.log
  sleep 10;
  mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "select version();" >/dev/null 2>&1
  if [ $? -eq 0 ]
      then 
          killall mysqld >/dev/null 2>&1
          sleep 5
          killall mysqld >/dev/null 2>&1
          sleep 5
          ${MYSQL_STARTUP} start >>/tmp/mysql.log 
          [ $? -eq 0 ] && echo "mysql is started"
   fi
   mail -s "mysql restarted" qxl_work@163.com < /tmp/mysql.log
fi


思路3:更专业的生产脚本解决方案
#!/bin/bash 
# this script is created by oldboy. 
# e_mail:xxx@qq.com 
# function: xxxx
# version:1.1  
################################################
MYUSER=root
MYPASS="oldboy"
MYSOCK=/data/3306/mysql.sock
MySQL_STARTUP="/data/3306/mysql"
LOG_PATH=/tmp
LOG_FILE=${LOG_PATH}/mysqllogs_`date +%F`.log
MYSQL_PATH=/usr/local/mysql/bin
MYSQL_CMD="$MYSQL_PATH/mysql -u$MYUSER -p$MYPASS -S $MYSOCK"
$MYSQL_CMD -e "select version();" >/dev/null 2>&1
if [ $? -eq 0 ] 
then
    echo "MySQL is running! " 
    exit 0
else
    $MySQL_STARTUP start >$LOG_FILE
    sleep 5;
    $MYSQL_CMD -e "select version();" >/dev/null 2>&1
    if [ $? -ne 0 ]
      then 
        for num in `seq 5`
        do
           killall mysqld  >/dev/null 2>&1 
       [ $? -ne 0 ] && break;
           sleep 1
        done
        $MySQL_STARTUP start >>$LOG_FILE 
    fi
    $MYSQL_CMD -e "select version();" >/dev/null 2>&1 && Status="restarted" || Status="unknown"
    mail -s "MySQL status is $Status" xxx@qq.com < $LOG_FILE
fi
exit $RETVAL

思考：完成异地模拟web服务器通过账号连接完成mysql服务监控的脚本。

```

(5) 监控apache服务

```

apachemon-1.sh
#!/bin/bash 
. /etc/init.d/functions
LOG_FILE=/tmp/httpd.log
apachectl="/application/apache/bin/apachectl"
HTTPPORTNUM=`netstat -lnt|grep 80|grep -v grep|wc -l`
HTTPPRONUM=`ps -ef|grep http|grep -v grep|wc -l`
wget --quiet --spider http://10.0.0.179:8000 && RETVAL=$?
[ ! -f $LOG_FILE ] && touch $LOG_FILE 
if [ "$RETVAL" != "0" -o "$HTTPPORTNUM" -lt "1"  -o  "$HTTPPRONUM" \< "1" ] ;then
#echo $RETVAL $HTTPPORTNUM $HTTPPRONUM
#exit
   action "httpd is not running" /bin/false
   echo -e "httpd is not running\n" >$LOG_FILE
   echo "Preparing start apache..."
        for num in `seq 10`
         do   
            killall httpd  >/dev/null 2>&1 
            [ $? -ne 0 ] && {
              echo "httpd is killed" >$LOG_FILE
              break;
         }
        sleep 2
     done
     $apachectl start >/dev/null 2>&1 && Status="started" || Status="unknown" 
     [ "$Status" = "started" ] && action "httpd is started" /bin/true||\
      action "httpd is started" /bin/false
      mail -s "`uname -n`'s httpd status is $Status" xxx@qq.com <$LOG_FILE
      exit
else
    action "httpd is running" /bin/true
    exit 0
fi
提示：以上对端口，进程，url同时检测的方法，在生产环境使用的不多，比较专业的做法是监控url更准确，端口和进程都是辅助手段。

```

一个常用简单版本：

```
apachemon-2.sh
#!/bin/bash 
. /etc/init.d/functions
LOG_FILE=/tmp/httpd.log
apachectl="/application/apache/bin/apachectl"
wget --quiet --spider http://10.0.0.179:8000 && RETVAL=$?
[ ! -f $LOG_FILE ] && touch $LOG_FILE 
if [ "$RETVAL" != "0" ] 
  then
     echo -e "Httpd is not running\n" >$LOG_FILE
        for num in `seq 10`
         do   
            killall httpd  >/dev/null 2>&1 
            [ $? -ne 0 ] && {
              echo "Httpd is killed" >>$LOG_FILE
              break;
         }
        sleep 2
     done
     $apachectl restart >/dev/null 2>&1 && Status="restarted" || Status="unknown" 
     [ "$Status" = "restarted" ] && action "Httpd is restarted" /bin/true||\
      action "Httpd is restarted" /bin/false
      mail -s "`uname -n`'s httpd status is $Status" xxx@qq.com <$LOG_FILE
      exit
else
    action "httpd is running" /bin/true
    exit 0
fi

```

监控端通过端口来监控
```
check_httpd_port.sh
#!/bin/bash 
ip_add="$1" 
port="$2"
print_usage(){
       echo -e "$0 ip port"
       exit 1
}
        
#judge para num
if [ $# -ne 2 ]
    then
        print_usage
fi
PORT_COUNT=`nmap $ip_add  -p $port|grep open|wc -l`
#echo -e "\n" |telnet $ip_add $port||grep Connected
#echo -e "\n"|telnet 10.0.0.179 8000|grep Connected
[[ $PORT_COUNT -ge 1 ]] && echo "$ip_add $port is ok." || echo "$ip_add $port is unknown."
```
## 4.2.    case结构条件
### 4.2.1.  case条件语法
```
case "字符串变量" in
    值1) 指令…
;;
    值2) 指令…
;;
    *) 指令…
esac
```


案例1：简单实例
```
[root@mysql-A case]# cat case1.sh 
#!/bin/bash
read -p "Please input a number:" num
case "$num" in 
1)
        echo "input 1"
;;
2)
        echo "input 2"
;;
[3-9])
        echo "input is $num"
;;
*)
        echo "default , input is $num"
        exit;
;;
esac
[root@mysql-A case]# sh case1.sh 
Please input a number:1
input 1
[root@mysql-A case]# sh case1.sh 
Please input a number:23
default , input is 23
[root@mysql-A case]# sh case1.sh sda
Please input a number:sd
default , input is sd
```
案例2：判断用户输入了哪种水果?
```
[root@mysql-A case]# cat case2.sh 
#!/bin/bash
read -p "Please input the fruit name:" fruit
case "$fruit" in
apple|APPLE)
    echo  "the fruit name is alpple"
;;
banana|BANANA)
    echo  "the fruit name is banana"
;;
pear|PEAR)
    echo  "the fruit name is pear"
;;
*)
    echo "default ,fruit name is $fruit "
    exit;
;;
esac

[root@mysql-A case]# sh case2.sh 
Please input the fruit name:d
default ,fruit name is d 
[root@mysql-A case]# sh case2.sh  
Please input the fruit name:apple
the fruit name is alpple
[root@mysql-A case]# sh case2.sh apple
Please input the fruit name:APPLE
the fruit name is alpple
```
案例3：apache启动脚本
```
httpdctl-case-3.sh
#!/bin/bash
#author:xxx
# Source function library.
. /etc/rc.d/init.d/functions

httpd="/application/apache/bin/httpd"
case "$1" in
  start)
        $httpd -k $1 >/dev/null 2>&1
        [ $? -eq 0 ] && action "启动 httpd:" /bin/true ||\
        action "启动 httpd:" /bin/false
        ;;
  stop)
        $httpd -k $1 >/dev/null 2>&1
        if [ $? -eq 0 ] 
        then
          action "停止 httpd:" /bin/true
        else
          action "停止 httpd:" /bin/false
        fi
        ;;
   restart)
        $httpd -k $1 >/dev/null 2>&1
        [ $? -eq 0 ] && action "重起 httpd:" /bin/true||\
        action "重起 httpd:" /bin/false
        ;;
   *)
        echo "Format error!"
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
```

优化后脚本：
```
httpdctl-case4-1.sh
#!/bin/bash
#author:xxx
# Source function library.
[ -f /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions
RETVAL=0
httpd="/application/apache/bin/httpd"
start() {
        $httpd -k start >/dev/null 2>&1
        RETVAL=$?
        [ $RETVAL -eq 0 ] && action "启动 httpd:" /bin/true ||\
        action "启动 httpd:" /bin/false
        return $RETVAL
}

stop() {
        $httpd -k stop >/dev/null 2>&1
        [ $? -eq 0 ] && action "停止 httpd:" /bin/true ||\
        action "停止 httpd:" /bin/false
        return $RETVAL
}
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
       
       sh $0 stop
       sh $0 start
        ;;
   *)
        echo "Format error!"
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
exit $RETVAL
```
案例4：学习系统apache httpd脚本
```
#!/bin/bash
#
# httpd        Startup script for the Apache HTTP Server
#
# chkconfig: - 85 15
# description: Apache is a World Wide Web server.  It is used to serve \
#          HTML files and CGI.
# processname: httpd
# config: /etc/httpd/conf/httpd.conf
# config: /etc/sysconfig/httpd
# pidfile: /var/run/httpd.pid

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/httpd ]; then
        . /etc/sysconfig/httpd
fi

# Start httpd in the C locale by default.
HTTPD_LANG=${HTTPD_LANG-"C"}

# This will prevent initlog from swallowing up a pass-phrase prompt if
# mod_ssl needs a pass-phrase from the user.
INITLOG_ARGS=""

# Set HTTPD=/usr/sbin/httpd.worker in /etc/sysconfig/httpd to use a server
# with the thread-based "worker" MPM; BE WARNED that some modules may not
# work correctly with a thread-based MPM; notably PHP will refuse to start.

# Path to the apachectl script, server binary, and short-form for messages.
apachectl=/usr/sbin/apachectl
httpd=${HTTPD-/usr/sbin/httpd}
prog=httpd
pidfile=${PIDFILE-/var/run/httpd.pid}
lockfile=${LOCKFILE-/var/lock/subsys/httpd}
RETVAL=0

# check for 1.3 configuration
check13 () {
    CONFFILE=/etc/httpd/conf/httpd.conf
    GONE="(ServerType|BindAddress|Port|AddModule|ClearModuleList|"
    GONE="${GONE}AgentLog|RefererLog|RefererIgnore|FancyIndexing|"
    GONE="${GONE}AccessConfig|ResourceConfig)"
    if LANG=C grep -Eiq "^[[:space:]]*($GONE)" $CONFFILE; then
        echo
        echo 1>&2 " Apache 1.3 configuration directives found"
        echo 1>&2 " please read /usr/share/doc/httpd-2.2.3/migration.html"
        failure "Apache 1.3 config directives test"
        echo
        exit 1
    fi
}

# The semantics of these two functions differ from the way apachectl does
# things -- attempting to start while running is a failure, and shutdown
# when not running is also a failure.  So we just do it the way init scripts
# are expected to behave here.
start() {
        echo -n $"Starting $prog: "
        check13 || exit 1
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $httpd $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
}

# When stopping httpd a delay of >10 second is required before SIGKILLing the
# httpd parent; this gives enough time for the httpd parent to SIGKILL any
# errant children.
stop() {
    echo -n $"Stopping $prog: "
    killproc -p ${pidfile} -d 10 $httpd
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}
reload() {
    echo -n $"Reloading $prog: "
    if ! LANG=$HTTPD_LANG $httpd $OPTIONS -t >&/dev/null; then
        RETVAL=$?
        echo $"not reloading due to configuration syntax error"
        failure $"not reloading $httpd due to configuration syntax error"
    else
        killproc -p ${pidfile} $httpd -HUP
        RETVAL=$?
    fi
    echo
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
        status -p ${pidfile} $httpd
    RETVAL=$?
    ;;
  restart)
    stop
    start
    ;;
  condrestart)
    if [ -f ${pidfile} ] ; then
        stop
        start
    fi
    ;;
  reload)
        reload
    ;;
  graceful|help|configtest|fullstatus)
    $apachectl $@
    RETVAL=$?
    ;;
  *)
    echo $"Usage: $prog {start|stop|restart|condrestart|reload|status|fullstatus|graceful|help|configtest}"
    exit 1
esac

exit $RETVAL
```
案例5：学习系统portmap脚本

```
#! /bin/sh
#
# portmap       Start/Stop RPC portmapper
#
# chkconfig: 345 13 87
# description: The portmapper manages RPC connections, which are used by \
#              protocols such as NFS and NIS. The portmap server must be \
#              running on machines which act as servers for protocols which \
#              make use of the RPC mechanism.
# processname: portmap


# This is an interactive program, we need the current locale
[ -f /etc/profile.d/lang.sh ] && . /etc/profile.d/lang.sh
# We can't Japanese on normal console at boot time, so force LANG=C.
if [ "$LANG" = "ja" -o "$LANG" = "ja_JP.eucJP" ]; then
    if [ "$TERM" = "linux" ] ; then
        LANG=C
    fi
fi

# Source function library.
. /etc/init.d/functions

# Get config.
if [ -f /etc/sysconfig/network ]; then
    . /etc/sysconfig/network
else
    echo $"Networking not configured - exiting"
    exit 1
fi

prog="portmap"

# Check that networking is up.
if [ "$NETWORKING" = "no" ]; then
    exit 0
fi

[ -f /sbin/portmap ] || exit 0

[ -f /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

RETVAL=0

start() {
        echo -n $"Starting $prog: "
        daemon portmap $PMAP_ARGS
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch /var/lock/subsys/portmap
    return $RETVAL
}


stop() {
        echo -n $"Stopping $prog: "
        killproc portmap
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/portmap
    return $RETVAL
}

restart() {
    pmap_dump > /var/run/portmap.state
    stop
    start
    pmap_set < /var/run/portmap.state
    rm -f /var/run/portmap.state
}

# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status portmap
    ;;
  restart|reload)
    restart
    ;;
  condrestart)
    [ -f /var/lock/subsys/portmap ] && restart || :
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart|reload|condrestart}"
    exit 1
esac

exit $?
```

```
备注：要掌握的系统标杆脚本
这里留个作业：请大家阅读并对下面脚本进行详细注释：
/etc/init.d/functions  
/etc/init.d/nfs  
/etc/init.d/portmap  
/etc/rc.d/rc.sysinit
/etc/init.d/httpd
提示：此类脚本网上有人注释过的，可以参考他们的去理解。
```
## 4.3.    while循环与util循环
### 4.3.1.  语法
```
while 条件
    do 
    指令…
done


util 条件
    do 
    指令…
done
#util应用场合不多见，了解即可
```
### 4.3.2.  范例
范例1:每隔2秒记录一次系统负载情况
```
方法1：
[root@mysql-A while]# cat while1.sh 
#!/bin/bash
while true
do
        uptime 
        sleep 2
done
[root@mysql-A while]# sh while1.sh 
 12:21:02 up  4:35,  1 user,  load average: 0.00, 0.02, 0.00
 12:21:04 up  4:35,  1 user,  load average: 0.00, 0.02, 0.00
 12:21:06 up  4:35,  1 user,  load average: 0.00, 0.02, 0.00

方法2：
[root@mysql-A while]# cat while1-1.sh 
#!/bin/bash
while [ 1 ]
do
        uptime >>./uptime.log 
        usleep 1000000
done
[root@mysql-A while]# sh while1-1.sh &
[2] 9195
[root@mysql-A while]# tail -f uptime.log 
 13:13:41 up  5:28,  1 user,  load average: 0.00, 0.00, 0.00
 13:13:41 up  5:28,  1 user,  load average: 0.00, 0.00, 0.00
 13:13:41 up  5:28,  1 user,  load average: 0.00, 0.00, 0.00
```

```
脚本后台执行知识拓展：
功能  用途
sh while1-1.sh &    把脚本放到后台执行
ctrl+c  停止执行当前脚本或任务
ctrl+z  暂停执行当前脚本或任务
bg  把当前脚本或任务放到后台执行
fg  当前脚本或任务拿到前台执行，如果有多个任务，可以fg加任务编号调用,如fg 1
jobs    查看执行的脚本或任务
```

资料：
Linux 技巧：让进程在后台可靠运行的几种方法
http://www.ibm.com/developerworks/cn/linux/l-cn-nohup/

范例2:计算从1加到100之和
```
[root@mysql-A while]# cat sum.sh 
#!/bn/bash
i=1
sum=0
while ((i<=100))
do 
        ((sum=sum+i))
        ((i=i+1))
done
echo "sum=$sum"
[root@mysql-A while]# sh sum.sh 
sum=5050
```
### 4.3.3.  相关高级生产实战范例拓展
范例3:生产环境判断url是否正常的简单脚本
```
方法1:根据http code status判断
#!/bin/sh
while true
do
 status=`curl -I -s --connect-timeout 10 $1|head -1|cut -d " " -f 2`
 if [ "$status" = "200"  ] ;then
        echo "this url is good" 
 else
        echo " this url is bad"
 fi
 sleep 2
done


方法2:多条件组合判断
#!/bin/sh
while true
do
status=`curl -I -s --connect-timeout 10 $1|head -1| awk '{print $2}'`
ok=`curl -I -s --connect-timeout 10 $1|head -1|cut -d " " -f 3`
if [ "$status" = "200"  ] && [ "$ok"="OK" ];then
        echo "this url is good" 
else
        echo " this url is bad"
fi
  sleep 3
done

方法3:更专业的生产检查脚本(shell数组方法)
#!/bin/bash
# this script is created by xxx.
# function:case example
# version:1.1
. /etc/init.d/functions

url_list=(
http://xxxx.org
)

function wait()
{
echo -n '3秒后,执行该操作.';
for ((i=0;i<3;i++))
do
  echo -n ".";sleep 1
done
echo
}

function check_url()
{
wait
echo 'check url...'
for ((i=0; i<`echo ${#url_list[*]}`; i++))
do
judge=($(curl -I -s ${url_list[$i]}|head -1|tr "\r" "\n"))
if [[ "${judge[1]}" == '200' && "${judge[2]}"=='OK' ]]
   then
   action "${url_list[$i]}" /bin/true
else
   action "${url_list[$i]}" /bin/false
fi
done
}

check_url

范例4:实战分析apache日志例子
问题1：计算apache一天的日志access－2012－12－08.log中所有行的日志各元素的访问字节数的总和。
while-6.sh
exec <$1
sum=0
while read line
do
  num=`echo $line|awk '{print $10}'`
  [ -n "$num" -a "$num" = "${num//[^0-9]/}" ] || continue
  ((sum=sum+$num))
done
  echo "${1}:${sum} bytes =`echo $((${sum}/1024))`KB"

[root@stu412 logs]# sh while-6.sh access_log 
access_log:2314225 bytes =2259KB

范例5:分析图片服务日志，把日志排(每个图片访问次数*图片大小的总和)行，取top10,也就是计算每个url的总访问的大小。
[root@stu412 logs]# awk '{array_num[$7]++;array_size[$7]+=$10}END{for(x in array_num){print array_size[x],array_num[x],x}}' access_2010-12-8.log  | sort -rn -k1 | head -10
57254 1 /static/js/jquery-jquery-1.3.2.min.js
46232 1 /?=
44286 1 //back/upload/course/2010-10-25-23-48-59-048-18.jpg
33897 3 /static/images/photos/2.jpg
11809 1 /back/upload/teacher/2010-08-30-13-57-43-06210.jpg
10850 1 /back/upload/teacher/2010-08-06-11-39-59-0469.jpg
6417 1 /static/js/addToCart.js
4460 1 /static/js/web_js.js
3583 2 /static/flex/vedioLoading.swf
2686 1 /static/js/default.js
[root@stu412 logs]#

范例6:把大文件按行分割成小文件。
split-file.sh
#!/bin/sh
#mother file
FILE_PATH=$1
#linenum of each file
FILE_NUM=$2
i=1
sub=1
#母文件总行数
totalline=`wc -l ${FILE_PATH} | awk '{print $1}'`
#单个文件行数
((inc=totalline/FILE_NUM))

cat ${FILE_PATH} | while read line
do

    if ((i<=inc))
    then
        ((i++))
    else
        ((sub++))
         i=2
    fi

    echo ${line} >>${FILE_PATH}.${sub}
done
```
## 4.4.    for循环
### 4.4.1.  语法
(1) for循环结构
```
for  变量名 in 变量取值列表
do 
    指令…
done

提示：" in 变量取值列表"可省略，省略时相当于in "$@",使用for i相当于for i in "$@"
```
(2) c语言型for循环结构
```
for  ((exp1;exp2;exp3))
do 
    指令…
done
```
### 4.4.2.  范例

范例1:打印变量列表所有元素, 打印5,4,3,2,1
```
方法1：直接列出元素
[root@mysql-A for]# cat for-1.sh 
#!/bin/bash
for num in 5 4 3 2 1 
do 
        echo $num
done
[root@mysql-A for]# sh for-1.sh 
5
4
3
2
1
```
方法2：大括号方法
```
[root@mysql-A for]# cat for-2.sh 
#!/bin/bash
for num in {5..1} 
do 
        echo $num
done
[root@mysql-A for]# sh for-2.sh 
5
4
3
2
1
[root@mysql-A for]# echo {10..2}
10 9 8 7 6 5 4 3 2
[root@mysql-A for]# echo {a..f}
a b c d e f
方法3：seq用法
[root@mysql-A for]# cat for-2-1.sh
#!/bin/bash
for num in `seq 5 -1 1`
do 
        echo $num
done

范例2:获取当前目录中的的有文件的文件名作为变量输出
[root@mysql-A for]# cat for-3.sh 
#!/bin/bash
for filename in `ls`
do 
        echo $filename
done
```
范例3: 批量修改文件名

```
方法1:
#!/bin/sh
for file in `ls ./*.jpg`  
do
 mv $file `echo $file|sed 's/_finished//g'` 
done

方法2:
#!/bin/sh
for file in `ls ./*.jpg` 
 do 
 /bin/mv $file `echo "${file%_finished*}.jpg"` 
done

方法3:
ls |awk -F 'finished' '{print "mv "$0" "$1$2" "}'|/bin/bash


方法4:
rename "finished" ""  *
```
范例4: 打印9x9乘法表
```
#!/bin/bash  
for a in `seq 1 9`
do
        for b in `seq 1 9`
        do
                if [ $a -ge $b ]
                then
                        echo -en "$a x $b = $(expr $a \* $b)  "
                          
                fi
        done
echo " "
done

#!/bin/bash  
for a in `seq 9`
do
        for b in `seq 9`
        do
                [ $a -ge $b ] && echo -en "$a x $b = $(expr $a \* $b)  "
        done
echo " "
done
```
范例5: 清理开机启动的服务

范例6: 生产环境批量检查web服务是否正常并且发送邮件或手机报警
```
check_web_service.sh
#!/bin/bash
# this script is created by oldboy.
# version:1.1 
################################################
#set -x
RETVAL=0
SCRIPTS_PATH="/server/scripts"
MAIL_GROUP="xxx@qq.com xxx@qq.com"
## web detection function
LOG_FILE="/tmp/web_check.log"
function Get_Url_Status(){
FAILCOUNT=0
for (( i=1 ; $i <= 3 ; i++ )) 
 do 
    wget -T 20 --tries=2 --spider http://${HOST_NAME} >/dev/null 2>&1
    if [ $? -ne 0 ]
        then
         let FAILCOUNT+=1;
    fi
done

#if 3 times then send mail.
if [ $FAILCOUNT -eq 3 ]
     then 
       RETVAL=1
       NOW_TIME=`date +"%m-%d %H:%M:%S"`
       SUBJECT_CONTENT="http://${HOST_NAME} service is error,${NOW_TIME}."
       for MAIL_USER in $MAIL_GROUP
         do 
            echo "send to :$MAIL_USER ,Title:$SUBJECT_CONTENT" >$LOG_FILE
            mail -s "$SUBJECT_CONTENT " $MAIL_USER <$LOG_FILE
        done
else
      RETVAL=0
fi
return $RETVAL
}
#func end.
[ ! -d "$SCRIPTS_PATH" ] && {
  mkdir -p $SCRIPTS_PATH
EOF
}

[ ! -f "$SCRIPTS_PATH/domain.list" ] && {
  cat >$SCRIPTS_PATH/domain.list<<EOF
www.etiantian.org
blog.etiantian.org
EOF
}
#service check 
for  HOST_NAME in `cat $SCRIPTS_PATH/domain.list`
   do
       echo -n "checking $HOST_NAME: "
       #Get_Url_Status
       Get_Url_Status && echo ok||echo no
done
```
范例7: 批量添加100个用户并设置指定密码(密码不能相同)
```
#!/bin/sh
#author:xxx
userchars="test"
passfile="/tmp/user.log"
for num in `seq 3`
 do
   useradd $userchars$num
   passwd="`echo "date $RANDOM"|md5sum|cut -c3-11`"
   echo "$passwd"|passwd --stdin $userchars$num
   echo  -e "user:$userchars$num\tpasswd:$passwd">>$passfile
   #sleep 1
done
echo ------this is xxx contents----------------
cat $passfile
```
## 4.5.    break,continue,exit
```
命令  说明
break n n 表示跳出循环的层数，如果省略n表示跳出整个循环。
continue n  n 表示退到第n层继续循环，如果省略n表示跳出本次循环，忽略本次循环的剩余代码，进入循环的下一次循环。
exit n  退出当前shell程序，并返回n。n也可以省略。
```
# 5.  shell函数
## 5.1.    函数语法
```
函数名() {
    指令…
    return n
}

function 函数名() {
    指令…
}
```
## 5.2.    函数执行
```
调用函数：
(1) 直接执行函数名即可。注意，不需要带小括号。
函数名

(2) 带参数的函数执行方法：
函数名 参数1 参数2
说明：
   函数体中位置参数($1,$2,…,$#,$*,$?,$@)都可以是函数的参数；
   父脚本的参数则临时被函数参数所掩盖或隐藏。
   $0比较特殊，他仍然是父脚本的名称。
   当函数完成时，原来的命令行参数会恢复。
   在shell函数里面，return命令的功能与工作方式与exit相同，用于跳出函数。
   在shell函数体里使用exit会终止整个shell脚本。
   return语句会返回一个退出值给调用的程序。
```
## 5.3.    范例(略)

# 6.  shell脚本调试
## 6.1.    常见错误范例
```
(1) if条件句缺少if结尾关键字
(2) 循环体结构缺少关键字
(3) 成对的符号[],(),{},"",''等不匹配导致错误
(4) 中括号[]两端没空格导致错误
```
## 6.2.    shell脚本调试技巧
```
(1) 使用dos2unix处理脚本
(2) 使用echo命令进行调试
(3) 使用bash命令进行调试 
sh [-nvx] script.sh
参数：
-n 不会执行该脚本，仅查询脚本语法是否有问题，并给出错误提示
-v 在执行程序时，先将脚本的内容输出到屏幕上，如果有错误，也会给出错误提示。
-x 将使用的脚本内容显示到屏幕上，这是对调试很有用的参数。
特别说明：参数-x是一个不可多得的参数。如果执行脚本有问题，一般利用-x参数，就可以知道问题出在哪一行了。
(4) 使用set命令调试部分脚本内容
set命令可辅助脚本测试
set -n 读命令但并不执行
set -v 显示读取的所有行
set -x 显示所有命令及其参数
提示:
   同bash的功能
   开启调试功能set -x 命令，而关闭调试功能set +x

(5) 扩展：使用Bash专用调试器 bashdb
http://bashdb.sourceforge.net/

```