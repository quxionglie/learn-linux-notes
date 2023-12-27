# 命令总结-磁盘空间的命令(fsck dd dump fdisk parted)


# 1.	fsck


fsck - check and repair a Linux file system		#检查和修复linux文件系统

语法: fsck [-sACVRP] [-t fstype] [–] [fsck-options] filesys […]
```
描述：当文件系统发生错误时，可用fsck指令尝试加以修复。
The exit code returned by fsck is the sum of the following conditions:
0    - No errors
1    - File system errors corrected
2    - System should be rebooted
4    - File system errors left uncorrected
8    - Operational error
16   - Usage or syntax error
32   - Fsck canceled by user request
128  - Shared library error
The exit code returned when multiple file systems are checked is the bit-wise OR of the  exit  codes  for  each  file system that is checked.

参数：
-a 自动修复文件系统，不询问任何问题。
-A 依照/etc/fstab配置文件的内容，检查文件内所列的全部文件系统。
-N 不执行指令，仅列出实际执行会进行的动作。
-P 当搭配"-A"参数使用时，则会同时检查所有的文件系统。
-r 采用互动模式，在执行修复时询问问题，让用户得以确认并决定处理方式。
-R 当搭配"-A"参数使用时，则会略过/目录的文件系统不予检查。
-s 依序执行检查作业，而非同时执行。
-t<文件系统类型> 指定要检查的文件系统类型。
-T 执行fsck指令时，不显示标题信息。
-V 显示指令执行过程。

-y: 与-a类似，但是某些文件系统仅支持 -y 这个参数，所以也可以用 -y

fdisk -l 查看设备号
运行 fsck -y /dev/sdb1 修复磁盘

[root@stu412 ~]# fdisk -l

Disk /dev/sda: 21.4 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          16      128488+  83  Linux
/dev/sda2              17        2544    20306160   83  Linux
/dev/sda3            2545        2609      522112+  82  Linux swap / Solaris

[root@stu412 ~]# fsck -y /dev/sda2
fsck 1.39 (29-May-2006)
e2fsck 1.39 (29-May-2006)
/dev/sda2 is mounted.

WARNING!!!  Running e2fsck on a mounted filesystem may cause
SEVERE filesystem damage.

Do you really want to continue (y/n)? yes

/: recovering journal
/: clean, 58692/5079040 files, 673095/5076540 blocks

注意 :
此指令可与 /etc/fstab 相互参考操作来加以了解。
运行fsck命令后产生的文件有什么用？

当执行fsck命令时，fsck命令如果发现存在孤立的文件或目录，这些孤立的文件或目录对于系统管理员或用户来说，无法访问到它，因为它与它的上级目录失去了关联，如果用户允许fsck重新把它们找回来的话，fsck命令就会把这些孤立的文件或目录放在文件系统的/lost+found目录下，并用各自的i-node号来命名，以便用户查找自己需要的文件。Lost+found目录通过它的英文含义我们都可以知道，它是一个失物认领处。

因此当某个用户发现自己丢失了某个文件，可以在执行fsck之后到/lost+found目录下去查找，这时通过文件名已无法辨认出文件的作用，只能用file之类的命令来确定文件的类型，如果是数据文件，可以用more或vi命令来查看，如果是二进制文件，可以用dbx命令来调试或者试着执行它(注意它可能是一个具有破坏性的程序)，知道文件或目录的作用之后，可以对其进行改名。

如果用户不允许fsck把这些孤立的文件或目录找回来，那么fsck命令就会破坏这些文件或目录，彻底丢失这些文件或目录，用户或系统管理员永远也无法找回它们。
```
# 2.	dd
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
-rw-r--r-- 1 root root 1.0M Jul 15 20:05 junk.data

dd命令详解
from: http://blog.csdn.net/liumang_D/article/details/3899462

dd应用实例。

1.将本地的/dev/hdb整盘备份到/dev/hdd

dd if=/dev/hdb of=/dev/hdd

2.将/dev/hdb全盘数据备份到指定路径的image文件

dd if=/dev/hdb of=/root/image

3.将备份文件恢复到指定盘

dd if=/root/image of=/dev/hdb

4.备份/dev/hdb全盘数据，并利用gzip工具进行压缩，保存到指定路径

    dd if=/dev/hdb | gzip > /root/image.gz

5.将压缩的备份文件恢复到指定盘

gzip -dc /root/image.gz | dd of=/dev/hdb

6.备份磁盘开始的512个字节大小的MBR信息到指定文件

dd if=/dev/hda of=/root/image count=1 bs=512

count=1指仅拷贝一个块；bs=512指块大小为512个字节。

恢复：dd if=/root/image of=/dev/hda

7.备份软盘

dd if=/dev/fd0 of=disk.img count=1 bs=1440k (即块大小为1.44M)

8.拷贝内存内容到硬盘

dd if=/dev/mem of=/root/mem.bin bs=1024 (指定块大小为1k)

9.拷贝光盘内容到指定文件夹，并保存为cd.iso文件

dd if=/dev/cdrom(hdc) of=/root/cd.iso

10.增加swap分区文件大小

第一步：创建一个大小为256M的文件：

dd if=/dev/zero of=/swapfile bs=1024 count=262144

第二步：把这个文件变成swap文件：

mkswap /swapfile

第三步：启用这个swap文件：

swapon /swapfile

第四步：编辑/etc/fstab文件，使在每次开机时自动加载swap文件：

/swapfile    swap    swap    default   0 0

11.销毁磁盘数据
dd if=/dev/urandom of=/dev/hda1

注意：利用随机的数据填充硬盘，在某些必要的场合可以用来销毁数据。

12.测试硬盘的读写速度
dd if=/dev/zero bs=1024 count=1000000 of=/root/1Gb.file
dd if=/root/1Gb.file bs=64k | dd of=/dev/null

通过以上两个命令输出的命令执行时间，可以计算出硬盘的读、写速度。

13.确定硬盘的最佳块大小：
dd if=/dev/zero bs=1024 count=1000000 of=/root/1Gb.file
dd if=/dev/zero bs=2048 count=500000 of=/root/1Gb.file
dd if=/dev/zero bs=4096 count=250000 of=/root/1Gb.file
dd if=/dev/zero bs=8192 count=125000 of=/root/1Gb.file

通过比较以上命令输出中所显示的命令执行时间，即可确定系统最佳的块大小。

14.修复硬盘：

     dd if=/dev/sda of=/dev/sda 或dd if=/dev/hda of=/dev/hda

当硬盘较长时间(一年以上)放置不使用后，磁盘上会产生magnetic flux point，当磁头读到这些区域时会遇到困难，并可能导致I/O错误。当这种情况影响到硬盘的第一个扇区时，可能导致硬盘报废。上边的命令有可能使这些数据起死回生。并且这个过程是安全、高效的。
```
# 3.	dump

dump - ext2/3 filesystem backup	#备份ext2/3文件系统。
```
语法：
dump  [-level#]  [-ackMnqSuv]  [-A file] [-B records] [-b blocksize] [-d density] [-D file] [-e inode numbers] [-E file] [-f file] [-F script] [-h level] [-I nr errors] [-jcompression level] [-L label] [-Q file] [-s feet] [-T date] [-y] [-zcompression level] files-to-dump

说明：
Dump  examines  files  on an ext2/3 filesystem and determines which files need to be backed up. These files are copied to the given disk, tape or other storage medium for safe keeping (see  the  -f option below for doing remote backups). A dump that is larger than the output medium is broken into multiple volumes. On most media the size  is  determined  by  writing until an end-of-media indication is returned.

补充说明：dump为备份工具程序，可将目录或整个文件系统备份至指定的设备，或备份成一个大文件。
dump [-cnu][-0123456789][-b <区块大小>][-B <区块数目>][-d <密度>][-f <设备名称>][-h <层级>][-s <磁带长度>][-T <日期>][目录或文件系统] 或 dump [-wW]

参数：
　-0123456789 　备份的层级。
　-b<区块大小> 　指定区块的大小，单位为KB。
　-B<区块数目> 　指定备份卷册的区块数目。
　-c 　修改备份磁带预设的密度与容量。
　-d<密度> 　设置磁带的密度。单位为BPI。
　-f<设备名称> 　指定备份设备。
　-h<层级> 　当备份层级等于或大雨指定的层级时，将不备份用户标示为"nodump"的文件。
　-n 　当备份工作需要管理员介入时，向所有"operator"群组中的使用者发出通知。
　-s<磁带长度> 　备份磁带的长度，单位为英尺。
　-T<日期> 　指定开始备份的时间与日期。
　-u 　备份完毕后，在/etc/dumpdates中记录备份的文件系统，层级，日期与时间等。
　-w 　与-W类似，但仅显示需要备份的文件。
　-W 　显示需要备份的文件及其最后一次备份的层级，时间与日期。


可参考：http://hi.baidu.com/ming_eng/item/fbbbb660e01e791c7cdecc4a
Linux dump命令详解
```
# 4.	fdisk
fdisk - Partition table manipulator for Linux #磁盘分区表操作工具

```
语法:
fdisk [-u] [-b sectorsize] [-C cyls] [-H heads] [-S sects] device
fdisk -l [-u] [device ...]
fdisk -s partition ...

fdisk [-b <分区大小>][-uv][外围设备代号]
fdisk [-l][-b <分区大小>][-uv][外围设备代号...]
fdisk [-s < partition分区编号>]

描述：
Hard  disks can be divided into one or more logical disks called partitions.  This division is described in the partition table found in sector 0 of the disk.
#硬盘能划分成的一个或多个逻辑磁盘称为分区。

选项：
-b sectorsize		# -b<分区大小> 指定每个分区的大小。
Specify  the  sector size of the disk. Valid values are 512, 1024, or 2048.  (Recent kernels know the sector size. Use this only on old kernels or to override  the  kernel’s ideas.)

-C cyls
Specify  the number of cylinders of the disk.  I have no idea why anybody would want to do so.

-H heads
Specify the number of heads of the disk. (Not the physical number,  of  course,  but the number used for partition tables.)  Reasonable values are 255 and 16.

-S sects
Specify  the  number of sectors per track of the disk.  (Not the physical number, of course, but the number used for partition tables.)  A reasonable value is 63.

-l     List the partition tables for the specified devices and then exit.   
#列出指定的外围设备的分区表状况。

-u     When listing partition tables, give sizes in sectors instead of cylinders.
#搭配"-l"参数列表，会用分区数目取代柱面数目，来表示每个分区的起始地址。

-s partition
The size of the partition (in blocks) is printed on the standard output.


[root@stu412 ~]# fdisk -l

Disk /dev/sda: 21.4 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
#这个硬盘是80G的，有255个磁面；63个扇区；2610个磁柱；每个 cylinder（磁柱）的容量是 8225280 bytes
Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          16      128488+  83  Linux
/dev/sda2              17        2544    20306160   83  Linux
/dev/sda3            2545        2609      522112+  82  Linux swap / Solaris

[root@stu412 ~]# fdisk /dev/sda2
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel. Changes will remain in memory only,
until you decide to write them. After that, of course, the previous
content won't be recoverable.


The number of cylinders for this disk is set to 2528.
There is nothing wrong with that, but this is larger than 1024,
and could in certain setups cause problems with:
1) software that runs at boot time (e.g., old versions of LILO)
2) booting and partitioning software from other OSs
   (e.g., DOS FDISK, OS/2 FDISK)
   Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

Command (m for help): m
Command action
a   toggle a bootable flag	#设定硬盘启动区
b   edit bsd disklabel
c   toggle the dos compatibility flag
d   delete a partition			#删除一个分区
l   list known partition types	#列出分区类型
m   print this menu				#m 是列出菜单
n   add a new partition			#添加一个新分区
o   create a new empty DOS partition table
p   print the partition table	#列出分区表
q   quit without saving changes	#不保存退出
s   create a new empty Sun disklabel
t   change a partition's system id		#改变分区类型
u   change display/entry units
v   verify the partition table
w   write table to disk and exit			#把分区表写入硬盘并退出
x   extra functionality (experts only)	#扩展应用，专家功能

Command (m for help): p

Disk /dev/sda2: 20.7 GB, 20793507840 bytes
255 heads, 63 sectors/track, 2528 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

     Device Boot      Start         End      Blocks   Id  System

Command (m for help): d
No partition is defined yet!

Command (m for help): n
Command action
e   extended
p   primary partition (1-4)
e
Partition number (1-4): 1
First cylinder (1-2528, default 1): 1
Last cylinder or +size or +sizeM or +sizeK (1-2528, default 2528):
Using default value 2528
```

# 5.	parted
```
GNU Parted - a partition manipulation program
语法：
parted [options] [device [command [options...]...]]
parted [选项]...  [设备 [命令 [参数]...]...]
选项:
-h, --help
displays a help message.

-i, --interactive
prompts for user intervention.	#用户交互时，提示用户

-s, --script
never prompt the user.			#从不提示用户

-v, --version
displays the version.

命令:
check partition
does a simple check on partition.	#对分区进行简单检查

cp [source-device] source dest			#将文件系统复制到另一个分区
copies  the  source  partition’s  filesystem  on source-device (or the current
device if no other device was specified) to the dest partition on the  current
device.

help [command]
prints general help, or help on command if specified.

mkfs partition fs-type
make  a  filesystem  fs-type  on  partition.  fs-type  can  be one of "fat16",
"fat32", "ext2", "linux-swap" or "reiserfs".

mklabel label-type		 #创建新的磁盘标签 (分区表)
Creates a new disklabel (partition table) of label-type.  label-type should be
one of "bsd", "dvh", "gpt", "loop", "mac", "msdos", "pc98" or "sun".

mkpart part-type [fs-type] start end		#创建一个分区
make  a  part-type partition with filesystem fs-type (if specified), beginning
at start and ending at end (in megabytes).  fs-type can  be  one  of  "fat16",
"fat32",  "ext2", "HFS", "linux-swap", "NTFS", "reiserfs" or "ufs".  part-type
should be one of "primary", "logical" or "extended"

mkpartfs part-type fs-type start end		#创建一个带有文件系统的分区
make a part-type partition with filesystem fs-type beginning at start and end-
ing at end (in megabytes)

move partition start end					#移动分区
move  partition to start at start and end at end. Note: move never changes the
minor number

name partition name			 
set the name of partition to name. This option works only on  Mac,  PC98,  and
GPT disklabels. The name can be placed in quotes, if necessary

print  displays the partition table		#打印分区表，或者分区

quit   exits parted

resize partition start end					#改变分区中文件系统的大小
resize the filesystem on partition to start at start and end at end megabytes

rm partition		#删除分区
deletes partition

select device		#选择设备作为当前要编辑的设备
choose  device as the current device to edit. device should usually be a Linux
hard disk device, but it can be a partition, software raid  device  or  a  LVM
logical volume if that is necessary

set partition flag state	#改变分区的标志的状态
change  the  state  of  the  flag  on partition to state. Flags supported are:
"boot"(Mac, MS-DOS, PC98), "root"(Mac), "swap"(Mac),  "hidden"(MS-DOS,  PC98),"raid"(MS-DOS), "lvm"(MS-DOS), "lba"(MS-DOS) and "palo"(MS-DOS).  state should be either "on" or "off"
```



from: http://xukaizijian.blog.163.com/blog/static/170433119201153022620720/
```
操作实例：
(parted)表示在parted中输入的命令，其他为自动打印的信息   
1、首先类似fdisk一样，先选择要分区的硬盘，此处为/dev/hdd：
[root@10.10.90.97 ~]# parted /dev/hdd
GNU Parted 1.8.1
Using /dev/hdd
Welcome to GNU Parted! Type 'help' to view a list of commands.
2、选择了/dev/hdd作为我们操作的磁盘，接下来需要创建一个分区表(在parted中可以使用help命令打印帮助信息)：
(parted) mklabel
Warning: The existing disk label on /dev/hdd will be destroyed and all data on this disk will be lost. Do you want to continue?
Yes/No?(警告用户磁盘上的数据将会被销毁，询问是否继续，我们这里是新的磁盘，输入yes后回车) yes
New disk label type? [msdos]? (默认为msdos形式的分区，我们要正确分区大于2TB的磁盘，应该使用gpt方式的分区表，输入gpt后回车)gpt
3、创建好分区表以后，接下来就可以进行分区操作了，执行mkpart命令，分别输入分区名称，文件系统和分区 的起止位置
(parted) mkpart
Partition name? []? dp1
File system type? [ext2]? ext3
Start? 0
End? 500GB
4、分好区后可以使用print命令打印分区信息，下面是一个print的样例
(parted) print
Model: VBOX HARDDISK (ide)
Disk /dev/hdd: 2199GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Number Start End Size File system Name Flags
1 17.4kB 500GB 500GB dp1
5、如果分区错了，可以使用rm命令删除分区，比如我们要删除上面的分区，然后打印删除后的结果
(parted)rm 1 #rm后面使用分区的号码
(parted) print
Model: VBOX HARDDISK (ide)
Disk /dev/hdd: 2199GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Number Start End Size File system Name Flags
6、按照上面的方法把整个硬盘都分好区，下面是一个分完后的样例
(parted) mkpart
Partition name? []? dp1
File system type? [ext2]? ext3
Start? 0
End? 500GB
(parted) mkpart
Partition name? []? dp2
File system type? [ext2]? ext3
Start? 500GB
End? 2199GB
(parted) print
Model: VBOX HARDDISK (ide)
Disk /dev/hdd: 2199GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Number Start End Size File system Name Flags
1 17.4kB 500GB 500GB dp1
2 500GB 2199GB 1699GB dp2
7、由于parted内建的mkfs还不够完善，所以完成以后我们可以使用quit命令退出parted并使用 系统的mkfs命令对分区进行格式化了，此时如果使用fdisk -l命令打印分区表会出现警告信息，这是正常的
[root@10.10.90.97 ~]# fdisk -l
WARNING: GPT (GUID Partition Table) detected on '/dev/hdd'! The util fdisk doesn't support GPT. Use GNU Parted.
Disk /dev/hdd: 2199.0 GB, 2199022206976 bytes
255 heads, 63 sectors/track, 267349 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Device Boot Start End Blocks Id System
/dev/hdd1 1 267350 2147482623+ ee EFI GPT
[root@10.10.90.97 ~]# mkfs.ext3 /dev/hdd1
[root@10.10.90.97 ~]# mkfs.ext3 /dev/hdd2
[root@10.10.90.97 ~]# mkdir /dp1 /dp2
[root@10.10.90.97 ~]# mount /dev/hdd1 /dp1
[root@10.10.90.97 ~]# mount /dev/hdd2 /dp2
```
