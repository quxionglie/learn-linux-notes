# 命令总结-磁盘空间的命令(mount umount)

# 1.	mount
## 1.1.	说明
```
名字:
mount - mount a file system		#挂载文件系统

语法：mount [-参数] [设备名称] [挂载点]

其中常用的参数有：
-a 安装在/etc/fstab文件中类出的所有文件系统。
-f 伪装mount，作出检查设备和目录的样子，但并不真正挂载文件系统。
-n 不把安装记录在/etc/mtab 文件中。
-r 讲文件系统安装为只读。
-v 详细显示安装信息。
-w 将文件系统安装为可写，为命令默认情况。
-t <文件系统类型> 指定设备的文件系统类型，常见的有：
ext2 是linux目前常用的文件系统
msdos MS-DOS的fat，就是fat16
vfat windows98常用的fat32
nfs 网络文件系统
iso9660 CD-ROM光盘标准文件系统
ntfs windows NT/2000/XP的文件系统
auto 自动检测文件系统
-o <选项> 指定挂载文件系统时的选项，有些也可写到在 /etc/fstab 中。常用的有：
defaults 使用所有选项的默认值（auto、nouser、rw、suid）
auto/noauto 允许/不允许以 –a选项进行安装
dev/nodev 对/不对文件系统上的特殊设备进行解释
exec/noexec 允许/不允许执行二进制代码
suid/nosuid 确认/不确认suid和sgid位
user/nouser 允许/不允许一般用户挂载
codepage=XXX 代码页
iocharset=XXX 字符集
ro 以只读方式挂载
rw 以读写方式挂载
remount 重新安装已经安装了的文件系统
loop 挂载“回旋设备”以及“ISO镜像文件”

The standard form of the mount command, is #标准mount命令使用格式
mount -t type device dir
```
## 1.2.	实例
```
#挂载Ext2/Ext3文件系统
# mkdir /mnt/hdc6
# mount /dev/hdc6 /mnt/hdc6

#挂载 CD 或 DVD 光盘
# mkdir /media/cdrom
# mount -t iso9660 /dev/cdrom /media/cdrom
# mount /dev/cdrom /media/cdrom

#挂载u盘
#如果计算机没有其它SCSI设备和usb外设的情况下，插入的U盘的设备路径是 /dev/sda1：
# mkdir /mnt/u
# mount /dev/sda1 /mnt/u
```
# 2.	umount
umount - unmount file systems 卸除文件系统。
```
语　　法：       
umount [-hV]
umount -a [-dflnrv] [-t vfstype] [-O options]
umount [-dflnrv] dir | device [...]
umount <挂载点|设备>

参　　数：
Options for the umount command:

-V     Print version and exit.	#显示版本信息

-h     Print help message and exit.

-v     Verbose mode.				#显示详细的信息

-n     Unmount without writing in /etc/mtab.

-r     In case unmounting fails, try to remount read-only.
#若无法成功卸除，则尝试以只读的方式重新挂入文件系统。

-d     In  case  the  unmounted device was a loop device, also free this loop device.

-i     Don't call the /sbin/umount.<filesystem> helper even if it exists.  By default /sbin/umount.<filesystem> helper is called if one exists.

-a     All  of  the  file systems described in /etc/mtab are unmounted. (With umount version 2.7 and later: the proc filesystem is not unmounted.)
#卸除/etc/mtab中记录的所有文件系统。

-t vfstype	#-t<文件系统类型>   仅卸除选项中所指定的文件系统。
Indicate that the actions should only be taken on file systems of  the specified  type.  More than one type may be specified in a comma separated list.  The list of file system types can be prefixed with no  to specify the file system types on which no action should be taken.


-O options
Indicate  that  the  actions should only be taken on file systems with the specified options in /etc/fstab.  More than one option type may be specified in a comma separated list.  Each option can be prefixed with no to specify options for which no action should be taken.

-f     Force unmount (in case of an unreachable NFS system).  (Requires  kernel 2.1.116 or later.)	#强制卸载

-l     Lazy unmount. Detach the filesystem from the filesystem hierarchy now, and cleanup all references to the filesystem as soon as it is not busy anymore.  (Requires kernel 2.4.11 or later.)
#延迟卸载。 选项 –l 并不是马上umount，而是在该目录空闲后再umount。

# umount -v /dev/sda1          通过设备名卸载
# umount -v /mnt/mymount/      通过挂载点卸载
```

