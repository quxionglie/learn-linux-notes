# 命令总结-附加命令(nohup watch time ps)

# 1.	nohup
## 1.1.	说明
```
nohup - run a command immune to hangups, with output to a non-tty
用途：不挂断地运行命令。
语法：nohup Command [ Arg ... ] [　& ]
描述：nohup 命令运行由 Command 参数和任何相关的 Arg 参数指定的命令，忽略所有挂断（SIGHUP）信号。在注销后使用 nohup 命令运行后台中的程序。要运行后台中的 nohup 命令，添加 & （ 表示“and”的符号）到命令的尾部。
无论是否将 nohup 命令的输出重定向到终端，输出都将附加到当前目录的 nohup.out 文件中。如果当前目录的 nohup.out 文件不可写，输出重定向到 $HOME/nohup.out 文件中。如果没有文件能创建或打开以用于追加，那么 Command 参数指定的命令不可调用。如果标准错误是一个终端，那么把指定的命令写给标准错误的所有输出作为标准输出重定向到相同的文件描述符。
```
## 1.2.	实例
```
[root@stu412 ~]# cat /root/echo.sh
#!/bin/bash
echo + >> /tmp/echo.log

sleep  1
[root@stu412 ~]# nohup sh /root/echo.sh &
[1] 12058
[root@stu412 ~]# nohup: appending output to `nohup.out'

[root@stu412 ~]# tail -f /tmp/echo.log #为什么只打印了一个+号???
+



[root@stu412 ~]# cat echo.sh 	#修改了一下,使用while true
#!/bin/bash
#echo + >> /tmp/echo.log

while true
do
echo $(date +%H%M%S)>> /tmp/echo.log
sleep 2;
done
sleep  1
[root@stu412 ~]# sh echo.sh #会一直打印，在ctrl+c中断后,停止执行
[root@stu412 ~]# tail -f /tmp/echo.log
125455
125458
125501
125504
…省略…
[root@stu412 ~]# sh echo.sh &		#会一直打印，退出ssh窗口后，停止执行

[1] 12701
[root@stu412 ~]# echo >/tmp/echo.log
[root@stu412 ~]# tail -f /tmp/echo.log

125730
125733
125736
125740
125743
125746
125749
125752
[root@stu412 ~]# nohup sh /root/echo.sh &	#会一直打印，退出ssh窗口后，也还在执行

[1] 12816
nohup: appending output to `nohup.out'
[root@stu412 ~]# tail -f /tmp/echo.log

130106
130109
130112
…省略…
```
# 2.	watch(实时监测命令)
watch  - execute a program periodically, showing out-put fullscreen.watch will run until interrupted.
By  default,  the program  is run every 2 seconds; use -n or –interval to specify a different interval.#执行频率，默认每2秒。可用-n选项修改执行频率
The -d or --differences flag will highlight the  differences  between  successive updates.

watch 是一个非常实用的命令，可以帮你实时监测一个命令的运行结果，省得一遍又一遍的手动运行。该命令最为常用的两个选项是-d和-n，其中-n表示间隔多少秒执行一次"command"，-d表示高亮发生变化的位置。下面列举几个在watch中常用的实时监视命令：

```
[root@stu412 ~]# watch -d -n 1 'who' #每隔一秒执行一次who命令，以监视服务器当前用户登录的状况。
Every 1.0s: who                            Tue Jul 10 20:50:37 2012
root     tty1         2012-07-10 20:49
root     pts/0        2012-07-10 07:41 (192.168.84.1)
root     pts/1        2012-07-10 20:41 (192.168.84.1)
root     pts/2        2012-07-10 20:46 (192.168.84.1)


#watch可以同时运行多个命令，命令间用分号分隔。
#以下命令监控磁盘的使用状况，以及当前目录下文件的变化状况，包括文件的新增、删除和文件修改日期的更新等。
[root@stu412 ~]# watch -d -n 1 'df -h; ls -l'
Every 1.0s: df -h; ls -l                   Tue Jul 10 20:50:29 2012

Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2              19G  2.0G   16G  12% /
/dev/sda1             122M   12M  104M  10% /boot
tmpfs                 506M     0  506M   0% /dev/shm
total 107936
-rw------- 1 root root      964 Jun  4 03:35 anaconda-ks.cfg
drwxr-xr-x 2 root root     4096 Jun 22 08:33 destination
---------- 1 root root        0 Jul 10 20:50 file2
-rwx------ 1 root root       46 Jun 11 04:27 file.py
-rw-r--r-- 1 root root    18135 Jun  4 03:35 install.log
-rw-r--r-- 1 root root     3967 Jun  4 03:35 install.log.syslog
-rwxr--r-- 1 root root 85141056 Jun 10 00:09 jdk-6u26-linux-i586.bi
n
-rw-r--r-- 1 root root       29 Jun 11 04:22 multi_blanks.txt
-rw-r--r-- 1 root root 24503313 Jun  9 23:22 mysql-5.1.62.tar.gz
-rw-r--r-- 1 root root   693025 Apr 12 21:05 nginx-1.0.15.tar.gz
drwxr-xr-x 2 root root     4096 Jun 28 07:32 test
```
# 3.	time
```
time - time a simple command or give resource usage
time命令-记录某个程序运行的时间。
-p选项也是格式，表示使用posix标准的格式，主要的区别是显示的时间都是以s为单位的。
```
```
[root@stu412 ~]# /usr/bin/time -o output.txt ps	#把运行ps的时间记录下来保存到output.txt中去。
PID TTY          TIME CMD
4439 pts/2    00:00:00 bash
11629 pts/2    00:00:00 time
11630 pts/2    00:00:00 ps
[root@stu412 ~]# cat output.txt  #使用了0.01秒钟，占用了18%的CPU时间
0.00user 0.00system 0:00.01elapsed 18%CPU (0avgtext+0avgdata 3184maxresident)k
0inputs+0outputs (2major+225minor)pagefaults 0swaps

[root@stu412 ~]# time  ps   
PID TTY          TIME CMD
4439 pts/2    00:00:00 bash
11696 pts/2    00:00:00 ps

real    0m0.008s
user    0m0.002s
sys     0m0.002s
[root@stu412 ~]# time  -p ps
PID TTY          TIME CMD
4439 pts/2    00:00:00 bash
11697 pts/2    00:00:00 ps
real 0.00
user 0.00
sys 0.00

[root@stu412 ~]# which time
/usr/bin/time
```
# 4.	ps
```
ps - report a snapshot of the current processes. #报告当前进程的快照信息
语法：ps [options]
描述：ps displays information about a selection of the active processes. If you want a repetitive update of the selection and the displayed information, use top(1) instead.

-A 列出所有的行程
-w 显示加宽可以显示较多的资讯
-au 显示较详细的资讯
-aux 显示所有包含其他使用者的行程
```

```
[root@stu412 ~]# ps -A
PID TTY          TIME CMD
1 ?        00:00:00 init
2 ?        00:00:00 migration/0
3 ?        00:00:00 ksoftirqd/0
4 ?        00:00:00 events/0
5 ?        00:00:00 khelper
...省略...
5518 ?        00:00:00 httpd
5519 ?        00:00:00 httpd
5520 ?        00:00:00 httpd
5521 ?        00:00:00 httpd
11749 pts/2    00:00:00 man
11752 pts/2    00:00:00 sh
11753 pts/2    00:00:00 sh
11758 pts/2    00:00:00 less
11789 pts/0    00:00:00 bash
11857 pts/0    00:00:00 ps

[root@stu412 ~]# ps -w
PID TTY          TIME CMD
11789 pts/0    00:00:00 bash
11912 pts/0    00:00:00 ps

[root@stu412 ~]# ps –aux	#常用
Warning: bad syntax, perhaps a bogus '-'? See /usr/share/doc/procps-3.2.7/FAQ
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   2160   636 ?        Ss   19:57   0:00 init [3]                  
root         2  0.0  0.0      0     0 ?        S<   19:57   0:00 [migration/0]
root         3  0.0  0.0      0     0 ?        SN   19:57   0:00 [ksoftirqd/0]
...省略...
apache    5518  0.0  0.5  23556  5536 ?        S    21:03   0:00 /usr/sbin/httpd
apache    5519  0.0  0.5  23556  5536 ?        S    21:03   0:00 /usr/sbin/httpd
apache    5520  0.0  0.5  23556  5536 ?        S    21:03   0:00 /usr/sbin/httpd
...省略...

```