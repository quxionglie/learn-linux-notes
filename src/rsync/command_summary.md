# 深入网络操作命令(mail mutt nslookup dig traceroute df du fsck dd)


#  1.	mail
## 1.1.	直接编辑文字邮件与发送邮件
```
[root@stu412 ~]# mail qxl_work@163.com
Subject: test		#邮件标题
body				#邮件内容
aasds
.					#这一行只有一个小圆点，代表输入结束
Cc: xleequ@163.com	#抄送给谁
```

## 1.2.	利用"纯文本文件"发送邮件
```
[root@stu412 ~]# cat file.py
def function():
var = 5
next = 6
third = 7
[root@stu412 ~]# mail -s 'title' qxl_work@163.com <~/file.py
```
## 1.3.	以附件方式发送邮件
```
[root@stu412 ~]# rpm -qa sharitils
[root@stu412 ~]# yum install -y sharutils
[root@stu412 ~]# uuencode /etc/hosts  myhosts | mail -s 'test file' qxl_work@163.com
```
# 2.	mutt
```
mutt - The Mutt Mail User Agent
mutt是一个文字模式的邮件管理程序，提供了全屏幕的操作界面。
#mutt [-a 附件] [-i body文件] [-b 秘密副本] [-c 一般副本] \
>  [-s 邮件标题 ] email地址
选项与参数：
-a 附件
-i body文件：Specify a file to include into the body of a message.
邮件的body部分，先编写成为文件而已；

-b 地址：指定密件副本的收信人地址。
原收件者不知道这封信还会寄给后面的那个秘密副本收件者；
-c 地址 :抄送给谁
-s 邮件标题
```
## 1.4.	在线编辑邮件，然后发出去
```
[root@stu412 mail]# mutt -s "test send 2012" qxl_work@163.com
y:Send  q:Abort  t:To  c:CC  s:Subj  a:Attach file  d:Descrip  ?:Help
#y:发送  q:中止  t:To  c:CC  s:Subj  a:Attach file  d:Descrip  ?:Help
From: root <root@stu412.localdomain>
To: qxl_work@163.com
Cc:
Bcc:
Subject: test send 2012
Reply-To:
Fcc:
PGP: Clear


-- Attachments
- I     1 /tmp/mutt-stu412-11803-0    [text/plain, 7bit, us-ascii, 0.1K]
  -- Mutt: Compose  [Approx. msg size: 0.1K   Atts: 1]---------------------
```

## 1.5.	添加附件发送邮件
```
[root@stu412 ~]# mutt -s 'file' -a /etc/hosts -- qxl_work@163.com
y:Send  q:Abort  t:To  c:CC  s:Subj  a:Attach file  d:Descrip  ?:Help
From: root <root@stu412.localdomain>
To: qxl_work@163.com
Cc:
Bcc:
Subject: file
Reply-To:
Fcc:
PGP: Clear


-- Attachments
- I     1 /tmp/mutt-stu412-11894-0    [text/plain, 7bit, us-ascii, 0.1K]
  A     2 /etc/hosts                  [text/plain, 7bit, us-ascii, 0.2K]
  -- Mutt: Compose  [Approx. msg size: 0.2K   Atts: 2]---------------------



echo "内容" | mutt -s "邮件标题" -a "/etc/hosts" "aleco.qu@gmail.com"

注意：
(1)	"-a filename"这个选项必须是在命令的最后面，如果上述改成： mutt -a /etc/hosts  -s "file" ...  就不行！会失败的！
(2)	在文件名与 email 地址之间需要加上两个连续减号" -- "才行！
```
## 3.	nslookup
```
nslookup - query Internet name servers interactively
查询ip与主机名的对应关系
语法：nslookup [-option] [hostname|IP]

#找出google的ip
[root@stu412 ~]# nslookup www.google.com
Server:         192.168.84.2
Address:        192.168.84.2#53

Non-authoritative answer:
www.google.com  canonical name = www.l.google.com.
Name:   www.l.google.com
Address: 74.125.71.99
...省略...

#找出74.125.71.99的对应的主机名
[root@stu412 ~]# nslookup 74.125.71.99
Server:         192.168.84.2
Address:        192.168.84.2#53

Non-authoritative answer:
99.71.125.74.in-addr.arpa       name = hx-in-f99.1e100.net.

Authoritative answers can be found from:
```
# 4.	dig
```
dig - DNS lookup utility
dig命令是一个用于询问 DNS 域名服务器的灵活的工具。
它执行 DNS 搜索，显示从受请求的域名服务器返回的答复。
```

```
#默认参数查询
[root@stu412 ~]# dig linux.vbird.org

; <<>> DiG 9.3.6-P1-RedHat-9.3.6-16.P1.el5 <<>> linux.vbird.org
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12962
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;linux.vbird.org.               IN      A

;; ANSWER SECTION:
linux.vbird.org.        5       IN      A       140.116.44.180

;; Query time: 17 msec
;; SERVER: 192.168.84.2#53(192.168.84.2)
;; WHEN: Mon Jul 30 22:16:01 2012
;; MSG SIZE  rcvd: 49


#获取SOA相关信息
[root@stu412 ~]# dig -t soa linux.vbird.org

; <<>> DiG 9.3.6-P1-RedHat-9.3.6-16.P1.el5 <<>> -t soa linux.vbird.org
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8895
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;linux.vbird.org.               IN      SOA

;; AUTHORITY SECTION:
vbird.org.              5       IN      SOA     dns.vbird.org. root.dns.vbird.org. 2007091402 28800 7200 720000 86400

;; Query time: 17 msec
;; SERVER: 192.168.84.2#53(192.168.84.2)
;; WHEN: Mon Jul 30 22:29:05 2012
;; MSG SIZE  rcvd: 78

#获取快速回答
[root@stu412 ~]# dig www.google.com +short
www.l.google.com.
74.125.71.105
74.125.71.99
74.125.71.106
74.125.71.147
74.125.71.103
74.125.71.104


#查询反解信息
[root@stu412 ~]# dig -x 183.60.136.70

; <<>> DiG 9.3.6-P1-RedHat-9.3.6-16.P1.el5 <<>> -x 183.60.136.70
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 57399
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0

;; QUESTION SECTION:
;70.136.60.183.in-addr.arpa.    IN      PTR

;; AUTHORITY SECTION:
60.183.in-addr.arpa.    5       IN      SOA     dns.guangzhou.gd.cn. root.dns.guangzhou.gd.cn. 2012040601 86400 86400 3628800 172800

;; Query time: 17 msec
;; SERVER: 192.168.84.2#53(192.168.84.2)
;; WHEN: Mon Jul 30 22:33:28 2012
;; MSG SIZE  rcvd: 104
```
# 5.	traceroute
```
traceroute - print the route packets trace to network host
查询两节点间通信状况的好坏
# traceroute [选项与参数] IP
选项与参数：
-n ：可以不必进行主机的名称解析，单纯用 IP ，速度较快！
-U ：使用 UDP 的 port 33434 来进行检测，这是默认的检测协议；
-I ：使用 ICMP 的方式来进行检测；
-T ：使用 TCP 来进行检测，一般使用 port 80 测试
-w ：若对方主机在几秒钟内没有回应就表示不通...默认是 5 秒
-p 端口号：若不想使用 UDP 与 TCP 的默认端口号来检测，可在此改变端口号。
-i 设备：用在比较复杂的环境，如果你的网络接口很多很复杂时，才会用到这个参数；
举例来说，你有两条 ADSL 可以连接到外面，那你的主机会有两个 ppp，
你可以使用 -i 来选择是 ppp0 还是 ppp1 啦！
-g 路由：与 -i 的参数相仿，只是 -g 后面接的是 gateway 的 IP 就是了。
```

```
[root@linuxdb ~]# traceroute -n www.google.com.hk
traceroute to www.google.com.hk (173.194.72.199), 30 hops max, 40 byte packets
1  58.61.154.1  1.108 ms  1.364 ms  1.563 ms
2  58.60.8.173  0.352 ms  0.663 ms  0.659 ms
3  58.60.8.217  1.521 ms 58.60.8.221  1.249 ms 58.60.8.217  1.504 ms
4  58.60.8.193  0.933 ms 58.60.8.125  3.891 ms  3.886 ms
5  202.97.33.150  4.128 ms 202.97.64.10  17.299 ms 202.97.33.150  4.106 ms
6  202.97.61.222  4.084 ms  3.838 ms  3.970 ms
7  202.97.61.102  7.784 ms  7.779 ms 202.97.61.222  4.125 ms
8  202.97.61.102  7.978 ms  7.956 ms  7.921 ms
9  202.97.62.214  7.905 ms 209.85.241.58  8.470 ms *
10  209.85.241.58  9.050 ms 209.85.241.216  40.705 ms *
11  209.85.250.120  61.139 ms * 209.85.250.103  61.438 ms
12  173.194.72.199  99.236 ms  68.507 ms  98.146 ms
```
# 6.	df,du
df：列出文件系统的整体磁盘使用量
      
du：评估文件系统的磁盘使用量（常用于评估目录所占容量）

## 6.1.	df
df - report file system disk space usage
```
功能：检查文件系统的磁盘空间占用情况。可以利用该命令来获取硬盘被占用了多少空间，目前还剩下多少空间等信息。  
语法：df [-ahikHTm] [目录或文件名]
说明：df命令可显示所有文件系统对i节点和磁盘块的使用情况。  
该命令各个选项的含义如下：  
-a, --all 显示所有文件系统的磁盘使用情况，包括0块（block）的文件系统，如/proc文件系统。  
-k,like --block-size=1K 以k字节为单位显示。  
-m,like --block-size=1M 以M字节为单位显示。  
-h, --human-readable
print sizes in human readable format (e.g., 1K 234M 2G)
以可读的方式显示文件的大小，如1K,234M,2G
-i,--inodes显示i节点信息，而不是磁盘块。  
-t,--type=TYPE显示各指定类型的文件系统的磁盘空间使用情况。  
-x,--exclude-type=TYPE列出不是某一指定类型文件系统的磁盘空间使用情况（与t选项相反）。  
-T,--print-type显示文件系统类型。  
```

```
[root@stu412 ~]# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda2             19669908   2057904  16596696  12% /
/dev/sda1               124427     11599    106404  10% /boot
tmpfs                   517352         0    517352   0% /dev/shm
[root@stu412 ~]# df –h	#以可读的方式显示
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2              19G  2.0G   16G  12% /
/dev/sda1             122M   12M  104M  10% /boot
tmpfs                 506M     0  506M   0% /dev/shm

[root@stu412 ~]# df –i	#显示inode节点使用情况
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
/dev/sda2            5079040   58761 5020279    2% /
/dev/sda1              32128      35   32093    1% /boot
tmpfs                 129338       1  129337    1% /dev/shm
[root@stu412 ~]# df –aT		#显示所有文件系统及类型
Filesystem    Type   1K-blocks      Used Available Use% Mounted on
/dev/sda2     ext3    19669908   2057908  16596692  12% /
proc          proc           0         0         0   -  /proc
sysfs        sysfs           0         0         0   -  /sys
devpts      devpts           0         0         0   -  /dev/pts
/dev/sda1     ext3      124427     11599    106404  10% /boot
tmpfs        tmpfs      517352         0    517352   0% /dev/shm
none   binfmt_misc           0         0         0   -  /proc/sys/fs/binfmt_misc
sunrpc  rpc_pipefs           0         0         0   -  /var/lib/nfs/rpc_pipefs
nfsd          nfsd           0         0         0   -  /proc/fs/nfsd
[root@stu412 ~]# df -h /etc/
#df会自动分析该目录或文件所在的分区，并将该分区的容量显示出来
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2              19G  2.0G   16G  12% /
```
## 6.2.	du
```
du - estimate file space usage
# du [-ahskm] 文件或目录名称
选项与参数：
-a  ：列出所有的文件与目录容量，因为默认仅统计目录底下的文件量而已。
-h  ：以人们较易读的容量格式 (G/M) 显示；
-s  ：列出总量而已，而不列出每个各别的目录占用容量；
-S  ：不包括子目录下的总计，与 -s 有点差别。
-k  ：以 KBytes 列出容量显示；
-m  ：以 MBytes 列出容量显示；
```
范例1：列出目前目录下的所有文件容量
```
[root@stu412 ~]# du
4       ./Mail
8       ./test
12      ./mail
4       ./destination
108040  .
#实际显示时，仅会显示目录容量(不含文件)
#输出的数值数据以 1K 为单位。
```
范例2：将文件容量也列出来
```
[root@stu412 ~]# du -a
4       ./Mail
0       ./file2
8       ./install.log.syslog
...省略...
28      ./.bash_history
108040  .
```
范例3：检查根目录底下每个目录所占用的容量(常用)
```
[root@stu412 ~]# du -sm /*
8       /bin
6       /boot
377     /data
1       /dev
63      /etc
1       /home
89      /lib
1       /lost+found
1       /media
0       /misc
1       /mnt
0       /net
1       /oldboy
1       /opt
0       /proc
106     /root
34      /sbin
1       /selinux
1       /srv
0       /sys
1       /tmp
1       /user1
1       /user2
1181    /usr
128     /var
#利用通配符 * 来代表每个目录，
```
# 7.	fsck

fsck - check and repair a Linux file system	   #检查和修复linux文件系统
```
# fsck [-t 文件系统] [-ACay] 设备名称
选项与参数：
-t  fslist：Specifies the type(s) of file system to be checked.
指定文件系统。
不过由于现今的 Linux 太聪明了，他会自动的通过 superblock 去分辨文件系统，
因此通常可以不需要这个选项的！
-A  ：Walk through the /etc/fstab file and try to check all file systems in one run.
依据 /etc/fstab 的内容，将需要的设备扫瞄一次。/etc/fstab 于下一小节说明，
通常启动过程中就会运行此一命令了。
-a  ：utomatically repair the file system without any questions。
自动修复检查到的有问题的扇区！
-y  ：与 -a 类似，但是某些 filesystem 仅支持 -y 这个参数！
-C  ：可以在检验的过程当中，使用一个直方图来显示目前的进度！

EXT2/EXT3 的额外选项功能：(e2fsck 这支命令所提供)
-f  ：强制检查！一般来说，如果 fsck 没有发现任何 unclean 的标志，不会主动进入
细化检查的，如果您想要强制 fsck 进入细部检查，就得加上 -f 标志！
-D  ：针对文件系统下的目录进行优化配置。
```

```
[root@stu412 ~]# fsck -C -f -t ext3 /dev/sda1         
fsck 1.39 (29-May-2006)
e2fsck 1.39 (29-May-2006)
/dev/sda1 is mounted.

WARNING!!!  Running e2fsck on a mounted filesystem may cause
SEVERE filesystem damage.

Do you really want to continue (y/n)? yes

/boot: recovering journal
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure                                           
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/boot: 35/32128 files (8.6% non-contiguous), 15660/128488 blocks    
注意：通常只有身为 root 且你的文件系统有问题的时候才使用这个命令，否则在正常状况下使用此一命令， 可能会造成对系统的危害！通常使用这个命令的场合都是在系统出现极大的问题，导致你在 Linux 启动的时候得进入单人单机模式下进行维护的行为时，才必须使用此一命令！
由于 fsck 在扫瞄硬盘的时候，可能会造成部分文件系统的损坏，所以运行 fsck 时， 被检查的 分区 务必不可挂载到系统上！即是需要在卸载的状态！
```
# 8.	dd
dd - convert and copy a file

dd：用指定大小的块拷贝一个文件，并在拷贝的同时进行指定的转换。
```
语法：
dd [OPERAND]...
dd OPTION

#生成1M大小的文件
[root@stu412 ~]# dd if=/dev/zero of=junk.data bs=1M count=1
1+0 records in
1+0 records out
#if代表输入文件(input file)，of代表输出文件(output file),
#bs代表以字节为单位的块大小(block size)，count代表要被复制的块数
#/dev/zero是一个字符设备，它会不断的返回0值字节(\0),
#如果不指定输入参数（if），默认情况下dd会从stdin中读取输入。与之类似，如果不指定输出参数(of),
#则dd会将stdout作为默认输出。

1048576 bytes (1.0 MB) copied, 0.000692656 seconds, 1.5 GB/s
[root@stu412 ~]# ls -lh junk.data
-rw-r--r-- 1 root root 1.0M Jul 31 20:27 junk.data
```

