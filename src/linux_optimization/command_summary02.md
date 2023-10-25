# 命令总结(find、wc、tar、cut、grep、egrep、date、which、echo、shutdown、reboot)

# 2.	wc
## 2.1.	说明
```
wc命令的功能为统计指定文件中的字节数、字数、行数, 并将统计结果显示输出。
wc [-lwm]
选项与参数：
-l  ：仅列出行；
-w  ：仅列出多少字(英文单词)；
-m  ：多少字符；
```

## 2.2.	范例
范例一：查询行数、单词数、字符数
```
[root@www ~]# cat /etc/man.config | wc
141     722    4617
# 输出的三个数字中，分别代表：行数、单词数、字符数
```

范例二：打印最长行的长度
```
[root@iZwz91k1z8823a10r46djgZ ~]# cat file 
1234
abcde
2345
ss_123456
aa
[root@iZwz91k1z8823a10r46djgZ ~]# wc -L file 
9 file
```

# 3.	tar
## 3.1.	说明
```
tar可将多个文件和文件夹保存为单个文件，同时还保留所有文件属性，如所有者、权限。
tar [-cxtzjvfpPN] 文件与目录 ....
参数：
-c  ：建立一个压缩文件 (create 的意思)；
-x  ：解开一个压缩文件
-t  ：查看 tarfile 里面的文件！
特别注意， c/x/t 仅能存在一个,不能同时存在！因为不可能同时压缩与解压缩。
-z  ：是否同时具有 gzip 的属性？即是否需要用 gzip 压缩？
-j  ：是否同时具有 bzip2 的属性？即是否需要用 bzip2 压缩？
-v  ：压缩的过程中显示文件！这个常用，但不建议用在后台执行的过程中！
-f  ：使用文件名，请留意，在 f 之后要立即接文件名！不要再加参数！
例如使用"tar -zcvfP tfile sfile"就是错误的写法，要写成"tar -zcvPf tfile sfile"才对！

-C 目录    ：这个选项用在解压缩时，若要在特定目录解压缩，可以使用这个参数。

-p  ：使用原文件的原来属性（属性不会依据使用者而变）
-P  ：可以使用绝对路径来压缩！
-N  ：比后面接的日期(yyyy/mm/dd)还要新的才会被打包进新建的文件中！
--exclude FILE：在压缩的过程中，不要将 FILE 打包！

简单使用：
压　缩：tar -jcv -f filename.tar.bz2 要被压缩的文件或目录名称
查　询：tar -jtv -f filename.tar.bz2
解压缩：tar -jxv -f filename.tar.bz2 -C 欲解压缩的目录
```

## 3.2.	范例
范例一：简单打包与显示归档文件信息
```
$ tar –cf output.tar [SOURCES]
如
$ tar -cf output.tar file1 file2 file3
```
文件名必须紧跟在-f之后，并且应该是参数组的最后一项。
tar的参数有限，如果有很多文件要归档的话，使用追加(append)选项更安全些。

列出归档文件内容：
```
[root@n1 ~]# tar -tf output.tar
file1
file2
file3
```
获知更多选项:使用-v或-vv选项
```
[root@n1 ~]# tar -tvvf output.tar
-rw-r--r-- root/root         0 2023-10-25 13:51 file1
-rw-r--r-- root/root         0 2023-10-25 13:51 file2
-rw-r--r-- root/root         0 2023-10-25 13:51 file3
```

范例二：向归档文件中添加文件

追加选项：-r

```
[root@n1 ~]# tar -rvf output.tar new_file 
tar: new_file: Cannot stat: No such file or directory
tar: Exiting with failure status due to previous errors
# 文件不存在
[root@n1 ~]# touch new_file
[root@n1 ~]# tar -rvf output.tar new_file
new_file
[root@n1 ~]# tar -tf output.tar
file1
file2
file3
new_file
```

范例三：[重要]归档文件中提取文件或文件夹
```
[root@n1 test]# tar -xf output.tar -C output2
-x表示提取
-C表示提取到哪个目录
[root@n1 outpu2]# mkdir dir2
[root@n1 outpu2]# tar -xf output.tar -C dir2
[root@n1 outpu2]# ll dir2
total 0
drwxr-xr-x 2 root root 6 Oct 25 14:00 dir1
-rw-r--r-- 1 root root 0 Oct 25 13:51 file1
-rw-r--r-- 1 root root 0 Oct 25 13:51 file2
-rw-r--r-- 1 root root 0 Oct 25 13:51 file3
-rw-r--r-- 1 root root 0 Oct 25 13:53 new_file
```
提取特定文件
```
[root@n1 outpu2]# ls
output.tar
[root@n1 outpu2]# tar -xvf output.tar file1
file1
[root@n1 outpu2]# ls
file1  output.tar
```
只提取file文件

范例四：tar中使用stdin或stdout
```
[root@n1 test3]# mkdir ~/destination
[root@n1 test3]# touch file file1 file2
[root@n1 test3]# tar -cf - file file1 file2 | tar -xvf - -C ~/destination
file
file1
file2
[root@n1 test3]# ls ~/destination/
file  file1  file2
```
file1 file2 file3进行归档并提取到~/destination中。类似cp命令。

范例五：拼装两个归档文档
```
[root@n1 test3]# tar -tf file1.tar
file
[root@n1 test3]# tar -tf file2.tar
file1
file2
file3
[root@n1 test3]# tar -Af file1.tar file2.tar
[root@n1 test3]# tar -tf file1.tar
file
file1
file2
file3
[root@n1 test3]# tar -tf file2.tar
file1
file2
file3
将file2.tar的内容合并到file1.tar
```
范例六：通过检查时间戳来更新文件中的内容
添加选项可以将任意文件加入到归档文件中，如果同名文件存在，则归档文件中会包含两个同名文件。
-u选项表明：只有比归档文件更新(newer)时才进行添加。
```
$ tar -uvvf archive.tar filea
```
filea 与归档文件有相同的时间戳，则不执行任何操作。

范例七：从归档文件中删除文档
```
[root@n1 test3]# tar -tvvf file1.tar
-rw-r--r-- root/root         0 2023-10-25 14:03 file
-rw-r--r-- root/root         0 2023-10-25 14:05 file1
-rw-r--r-- root/root         0 2023-10-25 14:05 file2
-rw-r--r-- root/root         0 2023-10-25 14:05 file3
[root@n1 test3]# tar -f file1.tar --delete file
[root@n1 test3]# tar -tvvf file1.tar
-rw-r--r-- root/root         0 2023-10-25 14:05 file1
-rw-r--r-- root/root         0 2023-10-25 14:05 file2
-rw-r--r-- root/root         0 2023-10-25 14:05 file3
```
范例八：[重要]压缩tar归档文件

-j：bunzip格式 file.tar.bz2

-z：gzip格式	 file.tar.gz

--lzma：：lzma格式 file.tar.lzma
```
[root@n1 tmp]# tar -cpf etc.tar /etc      
tar: Removing leading `/' from member names
[root@n1 tmp]# tar -cjpf etc.tar.bz2 /etc
tar: Removing leading `/' from member names
[root@n1 tmp]# tar -czpf etc.tar.gz /etc
tar: Removing leading `/' from member names
[root@n1 tmp]# ll
-rw-r--r-- 1 root root 53688320 Apr 19 07:42 etc.tar
-rw-r--r-- 1 root root  3407465 Apr 19 07:43 etc.tar.bz2
-rw-r--r-- 1 root root  5160047 Apr 19 07:43 etc.tar.gz
```
[重要]
-p参数是为了保存文件的权限与属性。

如无特殊需要请不要用-P选项来保留绝对路径(包含根路径)。

范例九：[重要]从归档文件中排除部分文件
--exclude [PATTERN]排除匹配通配符样式的文件。
排除所有的.txt文件。
```
#打包目录所有文件，但不包括.txt文件
[root@n1 ~]# touch filel  test.txt
[root@n1 ~]# tar -cf output.tar * --exclude "*.txt"
[root@n1 ~]# tar -tvvf output.tar
-rw------- root/root      1268 2023-07-26 14:38 anaconda-ks.cfg
-rw-r--r-- root/root         0 2023-10-25 16:00 filel
```
通配符样式用双引号来引用。

范例十：[重要]排除版本控制目录(阿烈：暂未试出有此选项—exclude-vcs)
—exclude-vcs选项排除svn,git,cvs等版本控制中的代码目录
```
[root@iZwz91k1z8823a10r46djgZ job_git]# ls -la
total 12
drwxr-xr-x   3 root root 4096 Oct 25 16:13 .
dr-xr-x---. 15 root root 4096 Oct 25 16:12 ..
-rw-r--r--   1 root root    0 Oct 25 16:13 aa
drwxr-xr-x   7 root root 4096 Oct 25 16:13 .git
[root@iZwz91k1z8823a10r46djgZ job_git]# cd ..
[root@iZwz91k1z8823a10r46djgZ ~]# tar --exclude-vcs -czvvf source_code.tar.gz job_git
drwxr-xr-x root/root         0 2023-10-25 16:13 job_git/
-rw-r--r-- root/root         0 2023-10-25 16:13 job_git/aa
[root@iZwz91k1z8823a10r46djgZ ~]# tar -tf source_code.tar.gz
job_git/
job_git/aa

```
范例十一：[重要]增量备份
```
tar zcvf c.tar.gz -N $(date -d yesterday +%F) ./a
tar zcvf a.tar.gz -N 2009/09/26 ./a

[root@n1 gittest]# tar zcvf c.tar.gz -N $(date -d yesterday +%F) ./a
tar: Option --after-date: Treating date `2023-10-24' as 2023-10-24 00:00:00
./a/
./a/cc.file
```
# 4.	cut
## 4.1.	说明
```
cut主要是用来分割文件中的字符串，并且根据要求进行显示。
cut -d'分隔字符' -f fields #用于有特定分隔字符
cut -c 字符区间            #用于排列整齐的信息
选项与参数：
-d  ：后面接分隔字符。与 -f 一起使用；
-f  ：依据 -d 的分隔字符将一段信息分割成为数段，用 -f 取出第几段的意思；
-c  ：以字符 (characters) 的单位取出固定字符区间；
```
## 4.2.	范例
范例一：提取指定列。
```
[root@n1 tmp]# cat student_data.txt
No      Name    Mark    Percent
1       Sarath  45      90
2       Alex    49      98
3       Anu     45      90
[root@n1 tmp]# cat -A student_data.txt
No^IName^IMark^IPercent$
1^ISarath^I45^I90$
2^IAlex^I49^I98$
3^IAnu^I45^I90$
[root@n1 tmp]# cut -f1 student_data.txt
No
1
2
3
制表符是字段或列的默认定界符。
提取多个字段(逗号分割的列表)：
[root@n1 tmp]# cut -f2,4 student_data.txt
Name    Percent
Sarath  90
Alex    98
Anu     90
```

范例二：--complement 进行补集运算

第三列之外所有列
```
[root@n1 tmp]# cut -f3 --complement student_data.txt
No      Name    Percent
1       Sarath  90
2       Alex    98
3       Anu     90
```

范例三：指定定界符-d
```
[root@n1 tmp]# cat delimited_data.txt
;Name;Mark;Percent
1;Sarath;45;90
2;Alex;49;98
3;Anu;45;90
[root@n1 tmp]# cut -f2 -d";" delimited_data.txt
Name
Sarath
Alex
Anu
```
范例四：指定字符或字节范围
```
-b 表示字节
-c表示字符
-f表示定义字段

每种参数格式表示范围如下：  
N    从第1 个开始数的第N 个字节、字符或域  
N-   从第N 个开始到所在行结束的所有字符、字节或域  
N-M  从第N 个开始到第M 个之间(包括第M 个)的所有字符、字节或域  
-M   从第1 个开始到第M 个之间(包括第M 个)的所有字符、字节或域

打印第1到第5个字符
[root@n1 tmp]# cat range_fields.txt
abcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxyz
abcdefghijklmnopqrstuvwxy
[root@n1 tmp]# cut -c1-5 range_fields.txt
abcde
abcde
abcde
abcde

打印前2个字符
[root@n1 tmp]# cut range_fields.txt -c-2
ab
ab
ab
ab


当用-b或-c提取多个字段时，必须使用--output-delimiter，否则会区分不了字段。
$ cut range_fields.txt -c1-3,6-9 --output-delimiter "," # linux shell脚本攻略
abc,fghi
abc,fghi
abc,fghi
abc,fghi


[root@n1 tmp]# cut range_fields.txt -c1-3,6-9 --output-delimiter ","
abcfghi
abcfghi
abcfghi
abcfghi
=>阿烈：但我在centos5.6试过，--output-delimiter不起作用啊,奇怪了

按照指定的_进行分割，返回结果使用_分割。
[root@n1 tmp]# echo "this_is_min" | cut -f1,3 -d"_"
this_min

对于没有DELIM的行会完全返回，如果不希望返回可以使用-s；
默认返回的各个域仍按照-d指定的DELIM分割显示，如果希望结果中使用指定的分隔符，可以使用--output-delimiter=STRING指定。
[root@n1 tmp]# echo "this_is_min" | cut -f1,3 -d"_" --output-delimiter=","
this,min
```

# 5.	grep/egrep
## 5.1.	grep/egrep说明
```
grep [-acinv] [--color=auto] '搜寻字符串' filename
参数说明：
-a ：将二进制文件中以文本文件的方式搜索数据
-c ：计算找到 '搜索字符串' 的次数
-i ：忽略大小写的不同，所以大小写视为相同
-n ：输出行号
-v ：反向选择，即显示出没有 '搜索字符串' 内容的那一行！
--color=auto 可将正确的那个'搜索字符串'的数据标上颜色
```
egrep 是使用正则表达式的grep命令

grep -v '^$' regular_express.txt | grep -v '^#'

等同于

egrep -v '^$|^#' regular_express.txt

grep 支持的是基础型的正则表达式，而 egrep 支持扩展正则表达式。事实上， egrep 是 grep -E 的别名。

## 5.4.	范例
范例一：将 last 当中，有出现 root 的那一行就取出来；
```
[root@www ~]# last | grep 'root'
```
范例二：与范例一相反，只要没有 root 的就取出！
```
[root@n1 tmp]# last | grep -v 'root'
```
范例三：在 last 的输出信息中，只要有 root 就取出，并且仅取第一列
```
[root@n1 tmp]# last | grep 'root' |cut -d ' ' -f1
root
root
root
root
root
root
root
root
# 在取出 root 之后，利用上个命令 cut 的处理，就能够仅取得第一列！
```
范例四：取出 /etc/man.config 内含 MANPATH 的那几行
```
[root@n1 tmp]# grep --color=auto 'MANPATH' /etc/man.config
# 神奇的是，如果加上 --color=auto 的选项，找到的关键词部分会用特殊颜色显示！
```
范例五：统计匹配行的数量 -C
```
[root@n1 tmp]# echo -e "1 2 3 4\nhello\n5 6" | egrep -c "[0-9]"
2
-C只统计统计匹配行的数量，而不是匹配的次数。
```
范例六：统计匹配的次数
```
[root@n1 tmp]# echo -e "1 2 3 4\nhello\n5 6" | egrep -o "[0-9]" | wc -l
6
```
范例七：打印匹配行的行数
```
[root@n1 tmp]# cat sample1.txt
gnu is not unix
linux is fun
bash is art
[root@n1 tmp]# cat sample2.txt
planetlinux
[root@n1 tmp]# grep linux -n sample1.txt
2:linux is fun
[root@n1 tmp]# grep linux -n sample1.txt sample2.txt
sample1.txt:2:linux is fun
sample2.txt:1:planetlinux
```

范例八：匹配多个样式 –e或-f
```
$ grep -e "pattern1" -e "pattern"

[root@n1 tmp]# echo this is a line of text | grep -e "this" -e "line" -o
this
line

或在样式中逐行写下需要匹配的样式，然后用选项-f执行grep。
[root@n1 tmp]# cat pat_file
hello
cool
[root@n1 tmp]# echo hello this is cool | grep -f pat_file
hello this is cool
```
范例九：grep搜索中包括或排除文件
```
grep "main()" . -r --include *.{c,cpp}
some{string1,string2,string3} 会扩展成 somestring1 somestring2 somestring3.

排除所有README文件
[root@n1 tmp]# grep "main()" . -r  --exclude "README"
排除目录：--exclude-dir
从文件中读取需排除的文件列表，使用—exclude FILE

范例十：使用0值字节的grep与xargs
[root@n1 test]# echo "test" > file1
[root@n1 test]# echo "cool" > file2
[root@n1 test]# echo "test" > file3
[root@n1 test]# cat file*
test
cool
test
[root@n1 test]# grep "test" file* -lZ
file1file3[root@n1 test]# grep "test" file* -lZ | xargs -0 rm
[root@n1 test]# ls
file2
```

# 6.	date
## 6.1.	说明
```
date命令的功能是显示和设置系统日期和时间
语法：
date [-d <字符串>][-u][+FORMAT]
或
date [-s <字符串>][-u][MMDDhhmmCCYYss]
或 date [--help][--version]

补充说明：
第一种语法可用来显示系统日期或时间，以%为开头的参数为格式参数，可指定日期或时间的显示格式。
第二种语法可用来设置系统日期与时间。只有管理员才有设置日期与时间的权限。若不加任何参数，data会显示目前的日期与时间。

参　　数：
　%H 　小时(以00-23来表示)。 
　%I 　小时(以01-12来表示)。 
　%K 　小时(以0-23来表示)。 
　%l 　小时(以0-12来表示)。 
　%M 　分钟(以00-59来表示)。 
　%P 　AM或PM。 
　%r 　时间(含时分秒，小时以12小时AM/PM来表示)。 
　%s 　总秒数。起算时间为1970-01-01 00:00:00 UTC。 
　%S 　秒(以本地的惯用法来表示)。 
　%T 　时间(含时分秒，小时以24小时制来表示)。 
　%X 　时间(以本地的惯用法来表示)。 
　%Z 　市区。 
　%a 　星期的缩写。 如：Sat
　%A 　星期的完整名称。如：Saturday 
　%b 　月份英文名的缩写。如：Nov 
　%B 　月份的完整英文名称。如：November 
　%c 　日期与时间。只输入date指令也会显示同样的结果。 
　%d 　日期(以01-31来表示)。 
　%D 　日期(含年月日)。 
　%j 　该年中的第几天。 
　%m 　月份(以01-12来表示)。 
　%U 　该年中的周数。 
　%w 　该周的天数，0代表周日，1代表周一，异词类推。 
　%x 　日期(以本地的惯用法来表示)。 
　%y 　年份(以00-99来表示)。 
　%Y 　年份(以四位数来表示)。 
　
%n 　在显示时，插入新的一行。 
　%t 　在显示时，插入tab。 
　MM 　月份(必要)。 
　DD 　日期(必要)。 
　hh 　小时(必要)。 
　mm 　分钟(必要)。 
　CC 　年份的前两位数(选择性)。 
　YY 　年份的后两位数(选择性)。 
　ss 　秒(选择性)。

-d<字符串> 　显示字符串所指的日期与时间。字符串前后必须加上双引号。 
　-s<字符串> 　根据字符串来设置日期与时间。字符串前后必须加上双引号。 
　-u 　显示GMT。 
　--help 　在线帮助。 
　--version 　显示版本信息。
```
当你以 root 身分更改了系统时间之后，请记得以 clock -w 来将系统时间写入 CMOS 中，这样下次重新开机时系统时间才会持续抱持最新的正确值。
## 6.2.	范例
范例一：显示时间
```
[root@n1 tmp]# date
Wed Oct 25 16:19:43 CST 2023
[root@n1 tmp]# date '+%T%n%D' #显示时间后跳行，再显示目前日期
16:19:52
10/25/23
[root@n1 tmp]# date '+%B %d'  #显示月份与日数
October 25
[root@n1 tmp]# date '+This date now is =>%x £¬time is now =>%X'
This date now is =>10/25/2023 £¬time is now =>04:20:09 PM
```
范例二：设定时间

```
date -s "格式化的日期或时间"
date -s //设置当前时间，只有root权限才能设置，其他只能查看。
date -s 20080523 //设置成20080523，这样会把具体时间设置成空00:00:00
date -s 01:01:01 //设置具体时间，不会对日期做更改
date -s "01:01:01 2008-05-23" //这样可以设置全部时间
date -s "01:01:01 20080523" //这样可以设置全部时间
date -s "2008-05-23 01:01:01" //这样可以设置全部时间
date -s "20080523 01:01:01" //这样可以设置全部时间
```

范例三：日期加减
```
date +%Y%m%d         //显示前天年月日
date +%Y%m%d --date="+1 day"  //显示前一天的日期
date +%Y%m%d --date="-1 day"  //显示后一天的日期
date +%Y%m%d --date="-1 month"  //显示上一月的日期
date +%Y%m%d --date="+1 month"  //显示下一月的日期
date +%Y%m%d --date="-1 year"  //显示前一年的日期
date +%Y%m%d --date="+1 year"  //显示下一年的日期

[root@n1 test]# date +%Y%m%d
20120622
[root@n1 test]# date +%Y%m%d --date="+1 day"
20120623
[root@n1 test]# date +%Y%m%d --date="-1 day"
20120621
[root@n1 test]# date +%Y%m%d --date="-1 month"
20120522
[root@n1 test]# date +%Y%m%d --date="+1 month"
20120722
[root@n1 test]# date +%Y%m%d --date="-1 year"
20110622
[root@n1 test]# date +%Y%m%d --date="+1 year"
20130622

[root@n1 test]# date -d next-day +%Y%m%d
20120623
[root@n1 test]# date -d last-day +%Y%m%d
20120621
[root@n1 test]# date -d yesterday +%Y%m%d
20120621
[root@n1 test]# date -d tomorrow +%Y%m%d
20120623
[root@n1 test]# date -d last-month +%Y%m
201205
[root@n1 test]# date -d next-month +%Y%m
201207
[root@n1 test]# date -d next-year +%Y
2013

[root@n1 test]# date +%Y%m%d
20120622
[root@n1 test]# date -d "2 days ago" +%Y%m%d         
20120620
[root@n1 test]# date -d "4 days ago" +%Y%m%d
20120618
[root@n1 test]# date -d "-1 days ago" +%Y%m%d
20120623
[root@n1 test]# date -d "-2 days ago" +%Y%m%d
20120624
[root@n1 test]# date -d "1 week ago" +%Y%m%d      
20120615
[root@n1 test]# date -d "1 year ago" +%Y%m%d
20110622
```

# 7.	which
which指令会在环境变量$PATH设置的目录里查找符合条件的文件。
```
# which [-a] command
选项或参数：
-a ：列出所有PATH 目录中可以找到的命令，而不止第一个被找到的命令
```

范例一：分别用root与一般帐号搜寻 ifconfig 这个命令的完整文件名
```
[root@n1 tmp]# which ifconfig
/usr/sbin/ifconfig       

```
范例二：用 which 去找出 which 的文件名？
```
[root@n1 tmp]# which which
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
	/usr/bin/alias
	/usr/bin/which
```
范例三：请找出 cd 这个命令的完整文件名
```
[root@n1 tmp]# which cd
/usr/bin/cd
```
# 8.	echo
## 8.1.	说明
echo命令的功能是在显示器上显示一段文字，一般起到一个提示的作用。
```
功能说明：显示文字。
语 　 法：echo [-ne][字符串]或 echo [--help][--version]
补充说明：echo会将输入的字符串送往标准输出。输出的字符串间以空白字符隔开, 并在最后加上换行号。
参　　 数：-n 不要在最后自动换行
-e 若字符串中出现以下字符，则特别加以处理，而不会将它当成一般
文字输出：
\a 发出警告声；
\b 删除前一个字符；
\c 最后不加上换行符号；
\f 换行但光标仍旧停留在原来的位置；
\n 换行且光标移至行首；
\r 光标移至行首，但不换行；
\t 插入tab；
\v 与\f相同；
\\ 插入\字符；
\nnn 插入nnn（八进制）所代表的ASCII字符；
–help 显示帮助
–version 显示版本信息
```
## 8.2.	范例
范例一：echo显示字符串
```
[root@n1 ~]# echo hello world
hello world
[root@n1 ~]# echo hello\ world
hello world
[root@n1 ~]# echo hello\\ world
hello\ world
[root@n1 ~]# echo 'hello\\ world'
hello\\ world
[root@n1 ~]# echo "hello\\ world"
hello\ world
[root@n1 ~]# echo `hello\\ world`
-bash: hello world: command not found
```
范例二：echo的转义显示: 加上-e参数
```
[root@n1 ~]# echo -e 'hello\nworld'
hello
world
```
# 9.	关机命令shutdown
shutdown可以达成如下的工作：
- (1)	可以自由选择关机模式：是要关机、重新启动或进入单人操作模式均可；
- (2)	可以配置关机时间: 可以配置成现在立刻关机, 也可以配置某一个特定的时间才关机。
- (3)	可以自定义关机信息：在关机之前，可以将自己配置的信息传送给在线 user 。
- (4)	可以仅发出警告信息：有时有可能你要进行一些测试，而不想让其它的使用者干扰， 或者是明白的告诉使用者某段时间要注意一下！这个时候可以使用 shutdown 来吓一吓使用者，但却不是真的要关机啦！
- (5)	可以选择是否要 fsck 检查文件系统 。
## 9.1.	shutdown语法
```
# /sbin/shutdown [-t 秒] [-arkhncfF] 时间 [警告信息]
选项与参数：
-t sec ： -t 后面加秒数，即"过几秒后关机"的意思
-k     ： 不要真的关机，只是发送警告信息出去！
-r     ： 在将系统的服务停掉之后就重新启动(常用)
-h     ： 将系统的服务停掉后，立即关机。 (常用)
-n     ： 不经过 init 程序，直接以 shutdown 的功能来关机
-f     ： 关机并启动之后，强制略过 fsck 的磁盘检查
-F     ： 系统重新启动之后，强制进行 fsck 的磁盘检查
-c     ： 取消已经在进行的 shutdown 命令内容。
时间   ： 这是一定要加入的参数！指定系统关机的时间！时间的范例底下会说明。
```     
范例：
```
[root@www ~]# /sbin/shutdown -h 10 'I will shutdown after 10 mins'
# 告诉大家，这部机器会在十分钟后关机！并且会显示在目前登录者的屏幕前方！
```
此外，需要注意的是，时间参数请务必加入命令中，否则shutdown会自动跳到 run-level 1 (就是单人维护的登陆情况)，

## 9.2.	范例
```
[root@www ~]# shutdown -h now
立刻关机，其中 now 相当于时间为 0 的状态

[root@www ~]# shutdown -h 20:25
系统在今天的 20:25 分会关机，若在21:25才下达此命令，则隔天才关机

[root@www ~]# shutdown -h +10
系统再过十分钟后自动关机

[root@www ~]# shutdown -r now
系统立刻重新启动

[root@www ~]# shutdown -r +30 'The system will reboot'  
再过三十分钟系统会重新启动，并显示后面的信息给所有在在线的使用者

[root@www ~]# shutdown -k now 'This system will reboot'  
仅发出警告信件的参数！系统并不会关机啦！
```

# 10.	重新开机reboot
```
功能说明：重新开机。
语法：dreboot [-dfinw]
补充说明：执行reboot指令可让系统停止运作，并重新开机。
参数：
-d 　重新开机时不把数据写入记录文件/var/tmp/wtmp。本参数具有"-n"参数的效果。
-f 　强制重新开机，不调用shutdown指令的功能。
-i 　在重开机之前，先关闭所有网络界面。
-n 　重开机之前不检查是否有未结束的程序。
-w 　仅做测试，并不真的将系统重新开机，只会把重开机的数据写入/var/log目录下的wtmp记录文件。
```
范例：
```
#reboot    		=>重开机。
#reboot –w	 	=>做个重开机的模拟（只有记录并不会真的重开机）。
```
虽然目前的 shutdown/reboot/halt 等等命令均已经在关机前进行了 sync 这个工具的调用， 不过，多做几次总是比较放心点。
```
[root@www ~]# sync; sync; sync; reboot 
```