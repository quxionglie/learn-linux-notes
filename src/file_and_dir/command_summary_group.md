# 命令总结-用户管理命令-用户组(groupadd、groupdel)

# 1.	groupadd
## 1.1.	说明
```
groupadd - create a new group #创建新的用户组
# groupadd [-g gid] [-r] [-f] 组名
选项与参数：
-g GID ：The numerical value of the group’s ID. This value must be unique, unless the -o option is used. The value must be non-negative. The default is to use the smallest ID value greater than 500 and greater than every other group. Values between 0 and 499 are typically reserved for system accounts.
#后面是gid的值。除非使用-o选项，否则值必须唯一。不能使用负值。默认使用最小id值要大于500并且大于其它用户组。0至499值通常赋予系统账户。

-r  ：创建系统群组！与 /etc/login.defs 内的 GID_MIN 有关。
-f  ：强制覆盖一个已经存在的用户组账户。
-o  ：This option permits to add group with non-unique GID. 组id不必唯一。


与groupadd命令相关的文件有：
/etc/group 	用户组相关文件
/etc/gshadow 	用户组加密相关文件
```
## 1.2.	实例
范例一：新建一个用户组，名称为 group1
```
[root@stu412 ~]# groupadd group1
[root@stu412 ~]# grep group1 /etc/group /etc/gshadow
/etc/group:group1:x:912:
/etc/gshadow:group1:!::
# 用户组的 GID会由 500 以上最大 GID+1 来决定！
```
# 2.	groupdel
## 2.1.	说明
```
groupdel - delete a group  #删除用户组
实际就是修改/etc/group和/etc/gshadow文件。

DESCRIPTION
The groupdel command modifies the system account files, deleting all entries that refer to group. The named group must exist. #groupdel命令会修改系统账户文件，删除关联到此群组的所有实体。群组必须是存在的。
You must manually check all file systems to insure that no files remain with the named group as the file group ID.你必须检查所有文件系统以确保文件的群组是此群组的文件没有遗留下来。

CAVEATS(警告)
You may not remove the primary group of any existing user. You must remove the user before you remove the group.在删除用户组前必须先删除用户。
```
## 2.2.	实例
范例一：将group1 删除！
```
[root@stu412 ~]# groupdel group1
```
范例二：删除vbird1群组
```
[root@stu412 ~]# groupdel vbird1
groupdel: cannot remove user's primary group.

#为什么 group1 可以删除，但vbird1不能删除呢？原因很简单，"有某个账号(/etc/passwd)的初始化群组使用该群组！"
[root@stu412 ~]# grep vbird1 /etc/passwd
vbird1:x:508:508::/home/vbird1:/bin/bash
[root@stu412 ~]# id vbird1
uid=508(vbird1) gid=508(vbird1) groups=508(vbird1)
```

所以，当然无法删除。否则 vbird1 这个用户登陆系统后， 就会找不到 GID ，那可是会造成很大的困扰的！那么如果硬要删除 vbird1,你"必须要确认/etc/passwd内的账号没有任何人使用该群组作为初始化群组"才行！

所以，你可以：修改 vbird1 的 GID ，或者是：删除 vbird1 这个使用者。

groupdel比较简单，工作中使用的频率也非常少，大家会以上的简单应用就可以。
