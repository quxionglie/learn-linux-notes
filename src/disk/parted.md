# parted分区命令实战讲解


# 1.	parted简述
parted是一个磁盘分区管理工具，它比fdisk更加灵活，功能也更丰富，同时还支持GUID分区(GUID Partition Table),这在IA64平台上管理磁盘时非常有用，它同时支持交互式和非交互模式，它除了能够进行分区的添加、删除等常见操作外，还可以移动分区，制作文件系统，调整文件系统大小，复制文件系统。

# 2.	业务需求
现有一个服务器做了RAID的硬盘，要求分三个区，
硬盘总分区大小：6.2T
/data0 	4.8T
/data1 	1T
4G (无需格式化，作DRBD)

# 3.	parted实战配置
具体操作方法如下：
```
1.	parted非交互式分区
      parted 	/dev/sdb 	mklabel 	gpt
      parted 	/dev/sdb 	mkpart 	primary 	0 			4800000		#单位M
      parted 	/dev/sdb 	mkpart 	primary 	4800001 	5800001
      parted 	/dev/sdb 	mkpart 	primary 	5800002	5804098
      parted 	/dev/sdb 	p

2.	格式区
      mkfs.ext3 /dev/sdb1
      mkfs.ext3 /dev/sdb2

3.	挂载
      mount /dev/sdb1 /data0
      mount /dev/sdb2 /data1
      df –h
```
# 4.	模拟大于2T硬盘parted分区演示
parted分区的特点是：即时生效!
```
parted /dev/sdc mklabel gpt
parted /dev/sdc mkpart primary 0  200  
parted /dev/sdc p

parted /dev/sdc mkpart primary 201 400
parted /dev/sdc mkpart primary 401 900
parted /dev/sdc p
```

```
[root@stu412 ~]# parted /dev/sdc mklabel gpt
Information: Don't forget to update /etc/fstab, if necessary.

[root@stu412 ~]# parted /dev/sdc p

Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdc: 1074MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start  End  Size  File system  Name  Flags

Information: Don't forget to update /etc/fstab, if necessary.  
[root@stu412 ~]# parted /dev/sdc mkpart primary 0 200
Information: Don't forget to update /etc/fstab, if necessary.

[root@stu412 ~]# parted /dev/sdc p

Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdc: 1074MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End    Size   File system  Name     Flags
1      17.4kB  200MB  200MB               primary

Information: Don't forget to update /etc/fstab, if necessary.   
[root@stu412 ~]# parted /dev/sdc mkpart primary 201 400
Information: Don't forget to update /etc/fstab, if necessary.

[root@stu412 ~]# parted /dev/sdc mkpart primary 401 900
Information: Don't forget to update /etc/fstab, if necessary.

[root@stu412 ~]# parted /dev/sdc p

Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdc: 1074MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

Number  Start   End    Size   File system  Name     Flags
1      17.4kB  200MB  200MB               primary       
2      200MB   400MB  200MB               primary       
3      400MB   900MB  500MB               primary

Information: Don't forget to update /etc/fstab, if necessary.    
[root@stu412 ~]# ls -l /dev/sdc*		#看一下设备信息
brw-r----- 1 root disk 8, 32 Jul 28 19:43 /dev/sdc
brw-r----- 1 root disk 8, 33 Jul 28 19:43 /dev/sdc1
brw-r----- 1 root disk 8, 34 Jul 28 19:43 /dev/sdc2
brw-r----- 1 root disk 8, 35 Jul 28 19:43 /dev/sdc3
```

#格式化分区
```
[root@stu412 ~]# mkfs.ext3 -b 4096 /dev/sdc1
[root@stu412 ~]# mkfs.ext3 -b 4096 /dev/sdc2
[root@stu412 ~]# mkfs.ext3 -b 4096 /dev/sdc3

[root@stu412 ~]# tune2fs -c 1 /dev/sdc1
[root@stu412 ~]# tune2fs -c 1 /dev/sdc2
[root@stu412 ~]# tune2fs -c 1 /dev/sdc3
```
#挂载
```
[root@stu412 ~]# mount /dev/sdc1 /mnt
[root@stu412 ~]# df -h
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2              19G  2.4G   16G  13% /
/dev/sda1             122M   12M  104M  10% /boot
tmpfs                 506M     0  506M   0% /dev/shm
/dev/sdb1             190M  5.6M  175M   4% /data/disk
/dev/sdc1             185M   17M  160M  10% /mnt
```
# 5.	parted交互式分区实践(TODO)
# 6.	parted生产场景如何使用?
(1)	一般只有当硬盘(或raid)大于2T后考虑使用parted分区，否则，我们习惯于fdisk分区

(2)	使用parted的时候，一般都是操作系统已经装好了。

(3)	大于2T的磁盘在安装系统阶段可以使用RAID中的虚拟磁盘技术分区，如分出200M,安装系统，剩余的分区在安装系统后使用parted来进行分区。
