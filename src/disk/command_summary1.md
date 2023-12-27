# 命令总结-信息显示命令(uname hostname dmesg uptime du df)


# 1.	uname

uname - print system information	#打印系统信息
```
语法：
uname [OPTION]...

描述：
Print certain system information.  With no OPTION, same as -s.

       -a, --all
              print  all  information, in the following order, except omit -p and -i
              if unknown:

       -s, --kernel-name
              print the kernel name

       -n, --nodename				#打印网络主机名
              print the network node hostname

       -r, --kernel-release
              print the kernel release

       -v, --kernel-version		#打印内核版本
              print the kernel version

       -m, --machine				#打印机器硬件名
              print the machine hardware name

       -p, --processor
              print the processor type or "unknown"

       -i, --hardware-platform
              print the hardware platform or "unknown"

       -o, --operating-system
              print the operating system

       --help display this help and exit

       --version
              output version information and exit
```

```
[root@stu412 ~]# uname
Linux
[root@stu412 ~]# uname -a
Linux stu412 2.6.18-238.el5 #1 SMP Thu Jan 13 16:24:47 EST 2011 i686 i686 i386 GNU/Linux
[root@stu412 ~]# uname -r
2.6.18-238.el5
[root@stu412 ~]# uname -v
#1 SMP Thu Jan 13 16:24:47 EST 2011
[root@stu412 ~]# uname -m
i686
[root@stu412 ~]# uname -p
i686
[root@stu412 ~]# uname -o
GNU/Linux
```
# 2.	hostname

hostname - show or set the system's host name	#显示或设置系统主机名

```
GET NAME
When called without any arguments, the program displays the current names: hostname,domainname,dnsdomainname


SET NAME
When called with one argument or with the --file option, the commands set the host name, the NIS/YP domain name or the node name.
Note, that only the super-user can change the names. #仅有超级管理员能修改hostname

[root@stu412 ~]# hostname
stu412
[root@stu412 ~]# hostname new-hostname

ctrl＋d注销一下系统，再重登录
Last login: Sat Jul 14 20:46:34 2012 from 192.168.65.1
[root@new-hostname ~]#
```
# 3.	dmesg

dmesg - print or control the kernel ring buffer

语法:dmesg [ -c ] [ -n level ] [ -s bufsize ]

描述：
```
dmesg is used to examine or control the kernel ring buffer.
The  program  helps  users to print out their bootup messages.
# dmesg用来显示内核环缓冲区（kernel-ring buffer）内容，帮助用户打印开机信息

选项：
-c     Clear the ring buffer contents after printing.
#显示信息后，清除ring buffer中的内容。

-sbufsize	  
Use a buffer of size bufsize to query the kernel ring buffer. This is 16392 by default. (The default kernel syslog buffer size was 4096 at first, 8192 since 1.3.54, 16384 since 2.1.113.) If you have set the kernel buffer to be larger than the default then this option can be used to view the entire buffer.

-nlevel	#设置记录信息的层级。
Set the level at which logging of messages is done to the console. For example, -n 1 prevents all messages, expect panic messages, from appearing on the console. All levels of messages are still written to /proc/kmsg, so syslogd(8) can still be used to control exactly where kernel messages appear. When the -n option is used, dmesg will not print or clear the kernel ring buffer.
When both options are used, only the last option on the command line will have an effect.

dmesg用来显示内核环缓冲区（kernel-ring buffer）内容，内核将各种消息存放在这里。在系统引导时，内核将与硬件和模块初始化相关的信息填到这个缓冲区中。内核环缓冲区中的消息对于诊断系统问题 通常非常有用。在运行dmesg时，它显示大量信息。通常通过less或grep使用管道查看dmesg的输出，这样可以更容易找到待查信息。
[root@stu412 ~]# dmesg | less
Linux version 2.6.18-238.el5 (mockbuild@builder10.centos.org) (gcc version 4.1.2 20080704 (Red Hat 4.1.2-48)) #1 SMP Thu Jan 13 16:24:47 EST 2011
BIOS-provided physical RAM map:
BIOS-e820: 0000000000010000 - 000000000009f800 (usable)
BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
BIOS-e820: 00000000000ca000 - 00000000000cc000 (reserved)
BIOS-e820: 00000000000dc000 - 00000000000e4000 (reserved)
BIOS-e820: 00000000000e8000 - 0000000000100000 (reserved)
BIOS-e820: 0000000000100000 - 000000003fef0000 (usable)
BIOS-e820: 000000003fef0000 - 000000003feff000 (ACPI data)
BIOS-e820: 000000003feff000 - 000000003ff00000 (ACPI NVS)
BIOS-e820: 000000003ff00000 - 0000000040000000 (usable)
BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
BIOS-e820: 00000000fffe0000 - 0000000100000000 (reserved)
128MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000f69b0
Memory for crash kernel (0x0 to 0x0) notwithin permissible range
disabling kdump
Using x86 segment limits to approximate NX protection
On node 0 totalpages: 262144
DMA zone: 4096 pages, LIFO batch:0
Normal zone: 225280 pages, LIFO batch:31
HighMem zone: 32768 pages, LIFO batch:7
DMI present.
[root@stu412 ~]# dmesg | grep eth
eth0: registered as PCnet/PCI II 79C970A
eth0: link up
eth0: link up
eth0: link up
eth0: link up
eth0: link up
eth0: link up
```
# 4.	uptime
uptime - Tell how long the system has been running.	#显示系统运行多久
```
描述：uptime  gives  a one line display of the following information.  The current time, how long the system has been running, how many users are currently logged on, and  the  system  load  averages for the past 1, 5, and 15 minutes.
#uptime会在一行显示以下信息，依次为：现在时间、系统已经运行了多长时间、目前有多少登陆用户、系统在过去的1分钟、5分钟和15分钟内的平均负载。

This is the same information contained in the header line displayed by w(1).

什么是系统平均负载呢？ 系统平均负载是指在特定时间间隔内运行队列中的平均进程数。
如果每个CPU内核的当前活动进程数不大于3的话，那么系统的性能是良好的。如果每个CPU内核的任务数大于5，那么这台机器的性能有严重问题。
如果你的linux主机是1个双核CPU的话，当Load Average 为6的时候说明机器已经被充分使用了。
[root@stu412 ~]# uptime
07:40:37 up  7:48,  2 users,  load average: 0.00, 0.00, 0.00
```
# 5.	du

du - estimate file space usage	#估算文件的使用空间

```
语法：
du [OPTION]... [FILE]...
du [OPTION]... --files0-from=F

-a, --all
write counts for all files, not just directories
#显示所有的文件，不仅仅是目录

-B, --block-size=SIZE use SIZE-byte blocks

-b, --bytes
equivalent to ‘--apparent-size --block-size=1’
#显示目录或文件大小时，以byte为单位。

-c, --total
produce a grand total
#除了显示目录或文件的大小外，同时也显示所有目录或文件的总和。

-D, --dereference-args
dereference FILEs that are symbolic links #显示指定符号连接的源文件大小。

-h, --human-readable	#人类可读的方式显示大写
print sizes in human readable format (e.g., 1K 234M 2G)

-m     like --block-size=1M		# 以1MB为单位。

-L, --dereference
dereference all symbolic links

-P, --no-dereference
don’t follow any symbolic links (this is the default)

-S, --separate-dirs
do not include size of subdirectories#显示每个目录的大小时，并不含其子目录的大小。

-s, --summarize	#仅显示总计，即当前目录的大小。
display only a total for each argument

-x, --one-file-system
skip directories on different file systems

-X FILE, --exclude-from=FILE
Exclude files that match any pattern in FILE.

--exclude=PATTERN Exclude files that match PATTERN.	#略过指定的目录或文件

[root@stu412 ~]# du
8       ./test
4       ./destination
108024  .
[root@stu412 ~]# du -h
8.0K    ./test
4.0K    ./destination
106M    .
[root@stu412 ~]# du -sh
106M    .
[root@stu412 ~]# du /etc | sort -nr | head
63516   /etc
40372   /etc/selinux
40340   /etc/selinux/targeted
38092   /etc/selinux/targeted/modules
38060   /etc/selinux/targeted/modules/active
7324    /etc/gconf
5100    /etc/gconf/gconf.xml.defaults
4376    /etc/selinux/targeted/modules/active/modules
3032    /etc/rc.d
2184    /etc/gconf/schemas
```
# 6.	df
语法：df [选项]  
说明：df命令可显示所有文件系统对i节点和磁盘块的使用情况。
```
选项：  
-a include dummy file systems #显示所有文件系统的磁盘使用情况，包括0块（block）的文件系统，如/proc文件系统。  
-k 以k字节为单位显示。  
-h, --human-readable 使用人类可读的格式
-i list inode information instead of block usage #显示i节点信息，而不是磁盘块。  
-t, --type=TYPE 显示各指定类型的文件系统的磁盘空间使用情况。  
-x, --exclude-type=TYPE 列出不是某一指定类型文件系统的磁盘空间使用情况（与t选项相反）。  
-T 显示文件系统类型。

[root@stu412 etc]# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda2             19669908   2055744  16598856  12% /
/dev/sda1               124427     11599    106404  10% /boot
tmpfs                   517352         0    517352   0% /dev/shm
[root@stu412 etc]# df –h	#可读的格式显示
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2              19G  2.0G   16G  12% /
/dev/sda1             122M   12M  104M  10% /boot
tmpfs                 506M     0  506M   0% /dev/shm
[root@stu412 etc]# df –hi	#可读的格式显示i节点信息
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
/dev/sda2               4.9M     58K    4.8M    2% /
/dev/sda1                32K      35     32K    1% /boot
tmpfs                   127K       1    127K    1% /dev/shm
[root@stu412 etc]# df –hiT	#显示文件系统类型
Filesystem    Type    Inodes   IUsed   IFree IUse% Mounted on
/dev/sda2     ext3      4.9M     58K    4.8M    2% /
/dev/sda1     ext3       32K      35     32K    1% /boot
tmpfs        tmpfs      127K       1    127K    1% /dev/shm
```