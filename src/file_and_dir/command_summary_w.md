# 命令总结-查看系统用户登录信息命令-(w、who、users、last)

w、who和users工具，是查询已登录当前主机的用户；另外finger -s 也同样能查询；侧重点不一样；

这几个命令有很多相似的地方。在生产场景中，这几个命令会经常用到，但使用的方法一般就是仅仅执行命令本身而已（极少带参数），在实际的工作中，可以根据需求，选择习惯使用的命令或综合使用。

# w - Show who is logged on and what they are doing.
```
# 显示已经登录的用户，并且都做了什么的信息,查看的信息与/var/run/utmp有关。
[root@stu412 ~]# w
07:06:35 up  3:48,  4 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     tty1     -                  Tue07   23:27m  0.00s  0.00s -bash
quxl     pts/0    192.168.84.1     21:51    9:14m  0.00s  0.00s -bash
root     pts/1    192.168.84.1     23:00    0.00s  0.00s  0.00s w
root     pts/2    192.168.84.1     Tue07    8:14m  0.01s  0.01s –bash
# 第一行显示目前的时间、启动 (up) 多久，几个用户在系统上平均负载等；
# 第二行只是各个项目的说明，
# 第三行以后，每行代表一个使用者。
```
# who - show who is logged on
```
#显示哪些用户在登录，终端及登录时间，来源主机。
[root@stu412 ~]# who
root     tty1         2012-07-03 07:38
quxl     pts/0        2012-07-03 21:51 (192.168.84.1)
root     pts/1        2012-07-04 07:09 (192.168.84.1)
root     pts/2        2012-07-03 07:39 (192.168.84.1)

# users - print the user names of users currently logged in to the current host
# 仅显示哪些用户在登录
[root@stu412 ~]# users
quxl root root root
```
# last, lastb - show listing of last logged in users
```
#显示已登录的用户列表及登录时间等,与/var/log/wtmp及/var/log/btmp两个文件有关
[root@stu412 ~]# last
root     pts/1        192.168.84.1     Wed Jul  4 07:09   still logged in   
root     pts/1        192.168.84.1     Tue Jul  3 23:00 - 07:09  (08:08)    
quxl     pts/0        192.168.84.1     Tue Jul  3 21:51   still logged in   
quxl     pts/0        192.168.84.1     Tue Jul  3 21:46 - 21:50  (00:03)    
quxl     pts/0        192.168.84.1     Tue Jul  3 21:46 - 21:46  (00:00)    
root     pts/0        192.168.84.1     Tue Jul  3 21:45 - 21:45  (00:00)    
root     pts/2        192.168.84.1     Tue Jul  3 07:39   still logged in   
root     tty1                          Tue Jul  3 07:38   still logged in   
root     pts/3        192.168.84.1     Tue Jul  3 06:58 - 06:59  (00:00
...(省略)...   
root     pts/0        192.168.84.1     Mon Jun  4 04:11 - 04:11  (00:00)    
root     pts/0        192.168.84.1     Mon Jun  4 03:39 - 04:11  (00:31)    
root     tty1                          Mon Jun  4 03:38 - crash (5+12:12)   
reboot   system boot  2.6.18-238.el5   Mon Jun  4 03:38         (5+20:44)

wtmp begins Mon Jun  4 03:38:13 2012
``` 

