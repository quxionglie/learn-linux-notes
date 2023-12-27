# MySQL灾难恢复实战多案例精华讲解

2012年写的笔记，部分内容可能已经过时，仅供参考。

# 1.	MySQL增量恢复必备条件
## 1.1.	开启MySQL log-bin日志功能
```
[root@stu412 ~]# grep log-bin /data/3306/my.cnf
log-bin = /data/3306/mysql-bin
```
## 1.2.	存在MySQL数据库全备
### 1.2.1.	生产环境mysqldump备份命令
```
mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -F -B $DBNAME --default-character-set=gbk --single-transaction -e | gzip > $DATA_FILE
```

### 1.2.2.	生产环境mysqldump备份脚本
mysqlbak.sh脚本
```
#!/bin/sh
################################################
#this scripts is created by oldboy
################################################
#parameter defined
BAKDATE=`date +%F`
MYUSER=root
MYPASS="oldboy"
MYSOCK=/data/3306/mysql.sock
DBNAME="oldboy"
MAIN_PATH=/server/backup
DATA_PATH=/server/backup
LOG_FILE=${DATA_PATH}/mysql_logs_${BAKDATE}.log
DATA_FILE=${DATA_PATH}/mysql_backup_${BAKDATE}.sql.gz

#command defined
MYSQL_PATH=/usr/local/mysql/bin
#MYSQL_DUMP="$MYSQL_PATH/mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -A  -B -F --single-transaction -e"
MYSQL_DUMP="$MYSQL_PATH/mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -F -B $DBNAME --default-character-set=gbk --single-transaction -e"
#backup command
${MYSQL_DUMP} | gzip > $DATA_FILE
#check backup result
du -sh $DATA_FILE >$LOG_FILE
mail -s "${BAKDATE} mysql bak log" xxx@qq.com < $LOG_FILE
```
# 2.	MySQL增量恢复案例图解

# 3.	恢复数据库场景
## 3.1.	多实例数据库主库为例
启动数据库
```
/data/3306/mysql start
```

```
查看端口
[root@stu412 ~]# netstat -lnt | grep 3306
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN

登录方式
mysql -uroot -p'123456' -S /data/3306/mysql.sock
```
## 3.2.	建库建表及数据语句
### 3.2.1.	建立GBK格式oldboy库语句
```
create database oldboy DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
```
### 3.2.2.	建立GBK格式student表语句
```
use oldboy;
set names gbk;
create table student(
Sno int(10) NOT NULL COMMENT '学号',
Sname varchar(16) NOT NULL COMMENT '姓名',
Ssex char(2) NOT NULL COMMENT '性别',
Sage tinyint(2)  NOT NULL default '0' COMMENT '学生年龄',
Sdept varchar(16)  default NULL  COMMENT '学生所在系别',
PRIMARY KEY  (Sno)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=gbk;
```
### 3.2.3.	向student表插入数据语句
```
set names gbk;
INSERT INTO student values(0001,'陆亚','男',24,'计算机网络');
INSERT INTO student values(0002,'elain ','男',26,'computer application');
INSERT INTO student values(0003,'xiaozhang','男',28,'物流管理');
INSERT INTO student values(0004,'jeacen','男',20,'computer application');
INSERT INTO student values(0005,'张阳','男',29,'计算机科学与技术');
```

## 3.3.	模拟误删数据语句
```
drop database oldboy;
#这里权模拟未执行
```
# 4.	执行语句并检查环境
## 4.1.	执行建库建表及插入数据语句
```
[root@stu412 ~]# mysql -uroot -p'123456' -S /data/3306/mysql.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.1.65-log Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database oldboy DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
Query OK, 1 row affected (0.00 sec)

mysql> set names gbk;
Query OK, 0 rows affected (0.00 sec)
mysql> show databases like 'oldboy';
+-------------------+
| Database (oldboy) |
+-------------------+
| oldboy            |
+-------------------+
1 row in set (0.00 sec)

mysql> use oldboy;
Database changed

mysql> set names gbk;
Query OK, 0 rows affected (0.00 sec)

mysql> create table student(
-> Sno int(10) NOT NULL COMMENT '学号',
-> Sname varchar(16) NOT NULL COMMENT '姓名',
-> Ssex char(2) NOT NULL COMMENT '性别',
-> Sage tinyint(2)  NOT NULL default '0' COMMENT '学生年龄',
-> Sdept varchar(16)  default NULL  COMMENT '学生所在系别',
-> PRIMARY KEY  (Sno)
-> ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=gbk;
Query OK, 0 rows affected (0.04 sec)

mysql> INSERT INTO student values(0001,'陆亚','男',24,'计算机网络');
ERROR 1598 (HY000): Binary logging not possible. Message: Transaction level 'READ-COMMITTED' in InnoDB is not safe for binlog mode 'STATEMENT'

mysql> set session binlog_format=mixed;
Query OK, 0 rows affected (0.00 sec)
#其后，我在my.cnf中加入binlog_format=mixed,并重启了mysql

mysql> INSERT INTO student values(0001,'陆亚','男',24,'计算机网络');
Query OK, 1 row affected (0.02 sec)
```


## 4.2.	检查数据库及数据
```
mysql> show create database oldboy\G
*************************** 1. row ***************************
Database: oldboy
Create Database: CREATE DATABASE `oldboy` /*!40100 DEFAULT CHARACTER SET gbk */
1 row in set (0.00 sec)
mysql> show create table student\G
*************************** 1. row ***************************
Table: student
Create Table: CREATE TABLE `student` (
`Sno` int(10) NOT NULL COMMENT '学号',
`Sname` varchar(16) NOT NULL COMMENT '姓名',
`Ssex` char(2) NOT NULL COMMENT '性别',
`Sage` tinyint(2) NOT NULL DEFAULT '0' COMMENT '学生年龄',
`Sdept` varchar(16) DEFAULT NULL COMMENT '学生所在系别',
PRIMARY KEY (`Sno`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk
1 row in set (0.00 sec)
mysql> desc student;
+-------+-------------+------+-----+---------+-------+
| Field | Type        | Null | Key | Default | Extra |
+-------+-------------+------+-----+---------+-------+
| Sno   | int(10)     | NO   | PRI | NULL    |       |
| Sname | varchar(16) | NO   |     | NULL    |       |
| Ssex  | char(2)     | NO   |     | NULL    |       |
| Sage  | tinyint(2)  | NO   |     | 0       |       |
| Sdept | varchar(16) | YES  |     | NULL    |       |
+-------+-------------+------+-----+---------+-------+
5 rows in set (0.00 sec)
mysql> select * from student;
+-----+-----------+------+------+------------------+
| Sno | Sname     | Ssex | Sage | Sdept            |
+-----+-----------+------+------+------------------+
|   1 | 陆亚      | 男   |   24 | 计算机网络       |
|   2 | elain     | 男   |   26 | computer applica |
|   3 | xiaozhang | 男   |   28 | 物流管理         |
|   4 | jeacen    | 男   |   20 | computer applica |
|   5 | 张阳      | 男   |   29 | 计算机科学与技术 |
+-----+-----------+------+------+------------------+
5 rows in set (0.00 sec)
```

# 5.	凌晨0点备份数据库
## 5.1.	定时任务数据库备份脚本
```
[root@stu412 scripts]# cat /server/scripts/mysqlbak.sh
#!/bin/sh
################################################
#this scripts is created by oldboy
################################################
#parameter defined
BAKDATE=`date +%F`
MYUSER=root
MYPASS="123456"
MYSOCK=/data/3306/mysql.sock
DBNAME="oldboy"
MAIN_PATH=/server/backup
DATA_PATH=/server/backup
LOG_FILE=${DATA_PATH}/mysql_logs_${BAKDATE}.log
DATA_FILE=${DATA_PATH}/mysql_backup_${BAKDATE}.sql.gz

#command defined
MYSQL_PATH=/usr/local/mysql/bin
#MYSQL_DUMP="$MYSQL_PATH/mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -A  -B -F --single-transaction -e"
MYSQL_DUMP="$MYSQL_PATH/mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -F -B $DBNAME --default-character-set=gbk --single-transaction -e"
#backup command
${MYSQL_DUMP} | gzip > $DATA_FILE
#check backup result
du -sh $DATA_FILE >$LOG_FILE
mail -s "${BAKDATE} mysql bak log" xxx@163.com < $LOG_FILE
```
## 5.2.	半夜0点手工执行脚本备份数据库
```
[root@stu412 ~]# mkdir -p /server/backup
[root@stu412 ~]# dos2unix /server/scripts/mysqlbak.sh
dos2unix: converting file /server/scripts/mysqlbak.sh to UNIX format ...

[root@stu412 ~]# sh /server/scripts/mysqlbak.sh
[root@stu412 ~]# ls -l /server/backup/
total 8
-rw-r--r-- 1 root root 1005 Sep  2 17:23 mysql_backup_2012-09-02.sql.gz
-rw-r--r-- 1 root root   51 Sep  2 17:23 mysql_logs_2012-09-02.log
[root@stu412 ~]# cat /server/backup/mysql_logs_2012-09-02.log
4.0K    /server/backup/mysql_backup_2012-09-02.sql.gz

#实际工作中是通过定时调度来备份的
#backup mysql by quxl on 2012-09-02
0 0 * * * /bin/sh /server/scripts/mysqlbak.sh>/dev/null 2>&1
```

## 5.3.	备份后查看binlog日志情况
```
[root@stu412 ~]# ls -lrt /data/3306
total 36
-rwx------ 1 mysql mysql 1053 Sep  2 18:38 mysql
-rw-r--r-- 1 mysql mysql 1907 Sep  2 19:38 my.cnf
-rw-rw---- 1 mysql mysql    6 Sep  2 19:39 mysqld.pid
-rw-rw---- 1 mysql root  3518 Sep  2 19:39 mysql_oldboy3306.err
srwxrwxrwx 1 mysql mysql    0 Sep  2 19:39 mysql.sock
drwxr-xr-x 5 mysql mysql 4096 Sep  2 19:47 data
-rw-rw---- 1 mysql mysql  740 Sep  2 19:49 slow.log
-rw-rw---- 1 mysql mysql   56 Sep  2 19:49 mysql-bin.index
-rw-rw---- 1 mysql mysql  106 Sep  2 19:49 mysql-bin.000002
-rw-rw---- 1 mysql mysql 1748 Sep  2 19:49 mysql-bin.000001
#备份的同时binlog文件生成了新的文件名。增量恢复就是从mysql-bin.000002开始的
```
# 6.	备份后模拟用户继续更新数据
## 6.1.	模拟网站用户更新数据
0点备份后，用户还会随时更新数据。下面以手工模拟向oldboy库的student表插入数据。
注：可以定一个脚本存储过程，模拟实时更新，然后恢复效果会更好。
```
[root@stu412 ~]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "set names gbk;select * from oldboy.student;"
+-----+-----------+------+------+------------------+
| Sno | Sname     | Ssex | Sage | Sdept            |
+-----+-----------+------+------+------------------+
|   1 | 陆亚      | 男   |   24 | 计算机网络       |
|   2 | elain     | 男   |   26 | computer applica |
|   3 | xiaozhang | 男   |   28 | 物流管理         |
|   4 | jeacen    | 男   |   20 | computer applica |
|   5 | 张阳      | 男   |   29 | 计算机科学与技术 |
+-----+-----------+------+------+------------------+
[root@stu412 ~]# mysql -uroot -p'123456' -S /data/3306/mysql.sock
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 15
Server version: 5.1.65-log Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql> use oldboy;
Database changed
mysql> set names gbk;
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO student values(0006,'wangzhao','男',21,'导弹专业');
Query OK, 1 row affected (0.02 sec)

mysql> INSERT INTO student values(0007,'xumubin','男',29,'中文专业');
Query OK, 1 row affected (0.10 sec)
```

## 6.2.	查看备份后再次更新后的数据库内容
```
mysql> select * from student;
+-----+-----------+------+------+------------------+
| Sno | Sname     | Ssex | Sage | Sdept            |
+-----+-----------+------+------+------------------+
|   1 | 陆亚      | 男   |   24 | 计算机网络       |
|   2 | elain     | 男   |   26 | computer applica |
|   3 | xiaozhang | 男   |   28 | 物流管理         |
|   4 | jeacen    | 男   |   20 | computer applica |
|   5 | 张阳      | 男   |   29 | 计算机科学与技术 |
|   6 | wangzhao  | 男   |   21 | 导弹专业         |
|   7 | xumubin   | 男   |   29 | 中文专业         |
+-----+-----------+------+------+------------------+
7 rows in set (0.00 sec)
```
# 7.	模拟用户破坏数据库
## 7.1.	删除oldboy数据库
脑残老大删除数据库。
```
mysql> drop database oldboy;
Query OK, 1 row affected (0.04 sec)
```
## 7.2.	检查破坏结果
```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| db3306             |
| mysql              |
| test               |
+--------------------+
4 rows in set (0.00 sec)
```
## 7.3.	发现故障并排除原因
# 8.	增量恢复全过程(重点)
## 8.1.	检查全备及binlog日志
### 8.1.1.	检查凌晨全备
```
[root@stu412 ~]# ll /server/backup/
total 8
-rw-r--r-- 1 root root 1005 Sep  2 17:23 mysql_backup_2012-09-02.sql.gz
-rw-r--r-- 1 root root   51 Sep  2 17:23 mysql_logs_2012-09-02.log
```
### 8.1.2.	检查全备后的所有binlog
```
[root@stu412 ~]# ls -lrt /data/3306/mysql-bin.*
-rw-rw---- 1 mysql mysql   56 Sep  2 19:49 /data/3306/mysql-bin.index
-rw-rw---- 1 mysql mysql 1748 Sep  2 19:49 /data/3306/mysql-bin.000001
-rw-rw---- 1 mysql mysql  612 Sep  2 19:53 /data/3306/mysql-bin.000002
```      
### 8.1.3.	立即刷新并备份出binlog
```
[root@stu412 ~]# mysqladmin -uroot -p'123456' -S /data/3306/mysql.sock flush-logs
[root@stu412 ~]# ls -lrt /data/3306/mysql-bin.*
-rw-rw---- 1 mysql mysql 1748 Sep  2 19:49 /data/3306/mysql-bin.000001
-rw-rw---- 1 mysql mysql   84 Sep  2 19:54 /data/3306/mysql-bin.index
-rw-rw---- 1 mysql mysql  106 Sep  2 19:54 /data/3306/mysql-bin.000003
-rw-rw---- 1 mysql mysql  655 Sep  2 19:54 /data/3306/mysql-bin.000002
[root@stu412 ~]# cp /data/3306/mysql-bin.000002 /server/backup/
```
提示：根据时间点及前一个binlog可以知道发现问题前的binlog日志为mysql-bin.000002,如果网站写入里大，文件可能不止一个。
## 8.2.	恢复binlog生成sql语句
```
[root@stu412 ~]# cd /server/backup/
[root@stu412 backup]# ls -l
total 12
-rw-r----- 1 root root  655 Sep  2 19:55 mysql-bin.000002
-rw-r--r-- 1 root root 1004 Sep  2 19:49 mysql_backup_2012-09-02.sql.gz
-rw-r--r-- 1 root root   51 Sep  2 19:49 mysql_logs_2012-09-02.log
[root@stu412 backup]# mysqlbinlog mysql-bin.000002 >bin.sql
[root@stu412 backup]# egrep -v "^#|^$|\*" bin.sql
BINLOG '
r0dDUA8BAAAAZgAAAGoAAAAAAAQANS4xLjY1LWxvZwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAEzgNAAgAEgAEBAQEEgAAUwAEGggAAAAICAgC
BEGIN
BINLOG '
K0hDUBMBAAAAOgAAAOoAAAAAABAAAAAAAAEABm9sZGJveQAHc3R1ZGVudAAFAw/+AQ8GIAD+BCAA
EA==
K0hDUBcBAAAAOAAAACIBAAAAABAAAAAAAAEABf/gBgAAAAh3YW5nemhhbwLE0BUItby1r9eo0rU=
BEGIN
BINLOG '
M0hDUBMBAAAAOgAAAL0BAAAAABAAAAAAAAEABm9sZGJveQAHc3R1ZGVudAAFAw/+AQ8GIAD+BCAA
EA==
M0hDUBcBAAAANwAAAPQBAAAAABAAAAAAAAEABf/gBwAAAAd4dW11YmluAsTQHQjW0M7E16jStQ==
drop database oldboy
DELIMITER ;
```
提示：如果有多个库，此时
```
mysqlbinlog mysql-bin.000002 -d oldboy >bin.sql
```
当然对于库也要分库备，否则恢复还是麻烦。

注：可查看sql语句的用法：
```
[root@stu412 backup]# mysqlbinlog -v  mysql-bin.000002
/*!40019 SET @@session.max_insert_delayed_threads=0*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#120902 19:49:03 server id 1  end_log_pos 106   Start: binlog v 4, server v 5.1.65-log created 120902 19:49:03
BINLOG '
r0dDUA8BAAAAZgAAAGoAAAAAAAQANS4xLjY1LWxvZwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAEzgNAAgAEgAEBAQEEgAAUwAEGggAAAAICAgC
'/*!*/;
# at 106
#120902 19:51:07 server id 1  end_log_pos 176   Query   thread_id=6     exec_time=0     error_code=0
SET TIMESTAMP=1346586667/*!*/;
SET @@session.pseudo_thread_id=6/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=1, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=0/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C gbk *//*!*/;
SET @@session.character_set_client=28,@@session.collation_connection=28,@@session.collation_server=8/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
BEGIN
/*!*/;
# at 176
# at 234
#120902 19:51:07 server id 1  end_log_pos 234   Table_map: `oldboy`.`student` mapped to number 16
#120902 19:51:07 server id 1  end_log_pos 290   Write_rows: table id 16 flags: STMT_END_F

BINLOG '
K0hDUBMBAAAAOgAAAOoAAAAAABAAAAAAAAEABm9sZGJveQAHc3R1ZGVudAAFAw/+AQ8GIAD+BCAA
EA==
K0hDUBcBAAAAOAAAACIBAAAAABAAAAAAAAEABf/gBgAAAAh3YW5nemhhbwLE0BUItby1r9eo0rU=
'/*!*/;
### INSERT INTO oldboy.student
### SET
###   @1=6
###   @2='wangzhao'
###   @3='男'
###   @4=21
###   @5='导弹专业'
# at 290
#120902 19:51:07 server id 1  end_log_pos 317   Xid = 67
COMMIT/*!*/;
# at 317
#120902 19:51:15 server id 1  end_log_pos 387   Query   thread_id=6     exec_time=0     error_code=0
SET TIMESTAMP=1346586675/*!*/;
BEGIN
/*!*/;
# at 387
# at 445
#120902 19:51:15 server id 1  end_log_pos 445   Table_map: `oldboy`.`student` mapped to number 16
#120902 19:51:15 server id 1  end_log_pos 500   Write_rows: table id 16 flags: STMT_END_F

BINLOG '
M0hDUBMBAAAAOgAAAL0BAAAAABAAAAAAAAEABm9sZGJveQAHc3R1ZGVudAAFAw/+AQ8GIAD+BCAA
EA==
M0hDUBcBAAAANwAAAPQBAAAAABAAAAAAAAEABf/gBwAAAAd4dW11YmluAsTQHQjW0M7E16jStQ==
'/*!*/;
### INSERT INTO oldboy.student
### SET
###   @1=7
###   @2='xumubin'
###   @3='男'
###   @4=29
###   @5='中文专业'
# at 500
#120902 19:51:15 server id 1  end_log_pos 527   Xid = 68
COMMIT/*!*/;
# at 527
#120902 19:53:36 server id 1  end_log_pos 612   Query   thread_id=8     exec_time=0     error_code=0
SET TIMESTAMP=1346586816/*!*/;
/*!\C latin1 *//*!*/;
SET @@session.character_set_client=8,@@session.collation_connection=8,@@session.collation_server=8/*!*/;
drop database oldboy
/*!*/;
# at 612
#120902 19:54:49 server id 1  end_log_pos 655   Rotate to mysql-bin.000003  pos: 4
DELIMITER ;
# End of log file
ROLLBACK /* added by mysqlbinlog */;
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
```
## 8.3.	恢复凌晨全备
开始恢复，先恢复凌晨全备，然后恢复整备到出问题时的所有增量数据。

解压全备文件
```
[root@stu412 backup]# ls -l mysql_backup_2012-09-02.sql.gz
-rw-r--r-- 1 root root 1004 Sep  2 19:49 mysql_backup_2012-09-02.sql.gz
[root@stu412 backup]# gzip -d mysql_backup_2012-09-02.sql.gz
[root@stu412 backup]# ls -l mysql_backup_2012-09-02.sql
-rw-r--r-- 1 root root 2389 Sep  2 19:49 mysql_backup_2012-09-02.sql

[root@stu412 backup]# egrep -v "^#|^$|\*" mysql_backup_2012-09-02.sql
-- MySQL dump 10.13  Distrib 5.1.65, for pc-linux-gnu (i686)
--
-- Host: localhost    Database: oldboy
-- ------------------------------------------------------
-- Server version       5.1.65-log
--
-- Current Database: `oldboy`
--
USE `oldboy`;
--
-- Table structure for table `student`
--
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
`Sno` int(10) NOT NULL COMMENT '瀛﹀彿',
`Sname` varchar(16) NOT NULL COMMENT '濮撳悕',
`Ssex` char(2) NOT NULL COMMENT '鎬у埆',
`Sage` tinyint(2) NOT NULL DEFAULT '0' COMMENT '瀛︾敓骞撮緞',
`Sdept` varchar(16) DEFAULT NULL COMMENT '瀛︾敓鎵€鍦ㄧ郴鍒?,
PRIMARY KEY (`Sno`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk;
--
-- Dumping data for table `student`
--
LOCK TABLES `student` WRITE;
INSERT INTO `student` VALUES (1,'陆亚','男',24,'计算机网络'),(2,'elain ','男',26,'computer applica'),(3,'xiaozhang','男',28,'物流管理'),(4,'jeacen','男',20,'computer applica'),(5,'张阳','男',29,'计算机科学与技术');
UNLOCK TABLES;
-- Dump completed on 2012-09-02 19:49:03


[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "show databases;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| test               |
+--------------------+
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock < mysql_backup_2012-09-02.sql
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "show databases;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| oldboy             |
| test               |
+--------------------+
[root@stu412 backup]#
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "set names gbk;select * from oldboy.student;"
+-----+-----------+------+------+------------------+
| Sno | Sname     | Ssex | Sage | Sdept            |
+-----+-----------+------+------+------------------+
|   1 | 陆亚      | 男   |   24 | 计算机网络       |
|   2 | elain     | 男   |   26 | computer applica |
|   3 | xiaozhang | 男   |   28 | 物流管理         |
|   4 | jeacen    | 男   |   20 | computer applica |
|   5 | 张阳      | 男   |   29 | 计算机科学与技术 |
+-----+-----------+------+------+------------------+
凌晨备份的数据已经找回来了。
```
## 8.4.	恢复增量数据
```
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock < bin.sql
```   
#不清理脑残的drop databases语句，这句是不能恢复的。                  
## 8.5.	查看恢复后的数据
## 8.6.	手工清理脑残删除语句
```
[root@stu412 backup]# cat bin.sql
/*!40019 SET @@session.max_insert_delayed_threads=0*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#120902 19:49:03 server id 1  end_log_pos 106   Start: binlog v 4, server v 5.1.65-log created 120902 19:49:03
BINLOG '
r0dDUA8BAAAAZgAAAGoAAAAAAAQANS4xLjY1LWxvZwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAEzgNAAgAEgAEBAQEEgAAUwAEGggAAAAICAgC
'/*!*/;
# at 106
#120902 19:51:07 server id 1  end_log_pos 176   Query   thread_id=6     exec_time=0     error_code=0
SET TIMESTAMP=1346586667/*!*/;
SET @@session.pseudo_thread_id=6/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=1, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=0/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C gbk *//*!*/;
SET @@session.character_set_client=28,@@session.collation_connection=28,@@session.collation_server=8/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
BEGIN
/*!*/;
# at 176
# at 234
#120902 19:51:07 server id 1  end_log_pos 234   Table_map: `oldboy`.`student` mapped to number 16
#120902 19:51:07 server id 1  end_log_pos 290   Write_rows: table id 16 flags: STMT_END_F

BINLOG '
K0hDUBMBAAAAOgAAAOoAAAAAABAAAAAAAAEABm9sZGJveQAHc3R1ZGVudAAFAw/+AQ8GIAD+BCAA
EA==
K0hDUBcBAAAAOAAAACIBAAAAABAAAAAAAAEABf/gBgAAAAh3YW5nemhhbwLE0BUItby1r9eo0rU=
'/*!*/;
# at 290
#120902 19:51:07 server id 1  end_log_pos 317   Xid = 67
COMMIT/*!*/;
# at 317
#120902 19:51:15 server id 1  end_log_pos 387   Query   thread_id=6     exec_time=0     error_code=0
SET TIMESTAMP=1346586675/*!*/;
BEGIN
/*!*/;
# at 387
# at 445
#120902 19:51:15 server id 1  end_log_pos 445   Table_map: `oldboy`.`student` mapped to number 16
#120902 19:51:15 server id 1  end_log_pos 500   Write_rows: table id 16 flags: STMT_END_F

BINLOG '
M0hDUBMBAAAAOgAAAL0BAAAAABAAAAAAAAEABm9sZGJveQAHc3R1ZGVudAAFAw/+AQ8GIAD+BCAA
EA==
M0hDUBcBAAAANwAAAPQBAAAAABAAAAAAAAEABf/gBwAAAAd4dW11YmluAsTQHQjW0M7E16jStQ==
'/*!*/;
# at 500
#120902 19:51:15 server id 1  end_log_pos 527   Xid = 68
COMMIT/*!*/;
# at 527
#120902 19:53:36 server id 1  end_log_pos 612   Query   thread_id=8     exec_time=0     error_code=0
SET TIMESTAMP=1346586816/*!*/;
/*!\C latin1 *//*!*/;
SET @@session.character_set_client=8,@@session.collation_connection=8,@@session.collation_server=8/*!*/;
#drop database oldboy		#注释掉此行
/*!*/;
# at 612
#120902 19:54:49 server id 1  end_log_pos 655   Rotate to mysql-bin.000003  pos: 4
DELIMITER ;
# End of log file
ROLLBACK /* added by mysqlbinlog */;
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
```
## 8.7.	重复执行8.3,8.4步骤
```
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock < bin.sql
```
## 8.8.	再次查看恢复后结果
```
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "set names gbk;select * from oldboy.student;"
+-----+-----------+------+------+------------------+
| Sno | Sname     | Ssex | Sage | Sdept            |
+-----+-----------+------+------+------------------+
|   1 | 陆亚      | 男   |   24 | 计算机网络       |
|   2 | elain     | 男   |   26 | computer applica |
|   3 | xiaozhang | 男   |   28 | 物流管理         |
|   4 | jeacen    | 男   |   20 | computer applica |
|   5 | 张阳      | 男   |   29 | 计算机科学与技术 |
|   6 | wangzhao  | 男   |   21 | 导弹专业         |
|   7 | xumubin   | 男   |   29 | 中文专业         |
+-----+-----------+------+------+------------------+
```
# 9.	mysqlbinlog的增量恢复方式
## 9.1.	基于时间点的增量恢复
### 9.1.1.	指定开始时间和结束时间
```
mysqlbinlog mysql-bin.000002 --start-datetime="2012-09-01 00:00:00"  --stop-datetime="2012-09-02 14:00:00" -r time.sql
#显示2012-09-01 00:00:00 至 2012-09-02 14:00:00时间段的binlog,并输出到time.sql
```
### 9.1.2.	指定开始时间到文件结束
```
mysqlbinlog mysql-bin.000002 --start-datetime="2012-09-01 00:00:00"  -d oldboy -r time.sql
#只有开始时间,就是从2012-09-01 00:00:00 到日志结尾，oldboy数据库binlog输出
```
### 9.1.3.	从文件开头到指定时间结束
```
mysqlbinlog mysql-bin.000002  --stop-datetime="2012-09-02 14:00:00" -d oldboy
#没有结束时间，就是从日志开头到2012-09-02 14:00:00时刻截止，oldboy数据库binlog输出
```
## 9.2.	基于位置点的增量恢复
### 9.2.1.	指定开始位置和结束位置
```
mysqlbinlog  mysql-bin.000002  --start-position=106 --stop-position=534  -r pos.sql
#输出初始位置106，结束位置534的所有binlog日志到pos.sql
```
9.2.2.	指定开始位置到文件结束
```
mysqlbinlog  mysql-bin.000002 --stop-position=534  -r pos.sql
```
9.2.3.	从文件开头到指定位置结束
```
mysqlbinlog  mysql-bin.000002  --start-position=106   -r pos.sql
```
9.2.4.	指定开始位置和结束位置案例
```
# at 4  #起始点
#120902 19:49:03 server id 1  end_log_pos 106   Start: binlog v 4, server v 5.1.65-log created 120902 19:49:03
BINLOG '
r0dDUA8BAAAAZgAAAGoAAAAAAAQANS4xLjY1LWxvZwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAEzgNAAgAEgAEBAQEEgAAUwAEGggAAAAICAgC
'/*!*/;
# at 106 #结束点
```
# 10.	MySQL重要命令
## 10.1.	mysql命令(略)
## 10.2.	mysqldump命令(略)
## 10.3.	mysqlbinlog命令(略)
# 11.	更多MySQL数据库灾难恢复案例
# 12.	附录
## 12.1.	MySQL binlog 日志的三种模式
```
Row Level：
日志中会记录成每一行数据被修改的形式，然后在slave端再对相同的数据进行修改。
优点：在row level模式下，bin-log中可以不记录执行的sql语句的上下文相关的信息，仅仅只需要记录那一条记录被修改了，修改成什么样了。所以row level的日志内容会非常清楚的记录下每一行数据修改的细节，非常容易理解。而且不会出现某些特定情况下的存储过程，或function，以及 trigger的调用和触发无法被正确复制的问题。
缺点：row level下，所有的执行的语句当记录到日志中的时候，都将以每行记录的修改来记录，这样可能会产生大量的日志内容，比如有这样一条update语句：update product set owner_member_id = ‘b’ where owner_member_id = ‘a’，执行之后，日志中记录的不是这条update语句所对应额事件(MySQL以事件的形式来记录bin-log日志)，而是这条语句所更新的每一条记录的变化情况，这样就记录成很多条记录被更新的很多个事件。自然，bin-log日志的量就会很大。尤其是当执行alter table之类的语句的时候，产生的日志量是惊人的。因为MySQL对于alter table之类的表结构变更语句的处理方式是整个表的每一条记录都需要变动，实际上就是重建了整个表。那么该表的每一条记录都会被记录到日志中。
——————————————————————————————————–
Statement Level:
每一条会修改数据的sql都会记录到 master的bin-log中。slave在复制的时候sql进程会解析成和原来master端执行过的相同的sql来再次执行。
优点：statement level下的优点首先就是解决了row level下的缺点，不需要记录每一行数据的变化，减少bin-log日志量，节约IO，提高性能。因为他只需要记录在Master上所执行的语句的细节，以及执行语句时候的上下文的信息。
缺点：由于他是记录的执行语句，所以，为了让这些语句在slave端也能正确执行，那么他还必须记录每条语句在执行的时候的一些相关信息，也就是上下文信息，以保证所有语句在slave端杯执行的时候能够得到和在master端执行时候相同的结果。另外就是，由于MySQL现在发展比较快，很多的新功能不断的加入，使MySQL得复制遇到了不小的挑战，自然复制的时候涉及到越复杂的内容，bug也就越容易出现。在statement level下，目前已经发现的就有不少情况会造成MySQL的复制出现问题，主要是修改数据的时候使用了某些特定的函数或者功能的时候会出现，比如：sleep()函数在有些版本中就不能真确复制，在存储过程中使用了last_insert_id()函数，可能会使slave和master上得到不一致的id等等。由于row level是基于每一行来记录的变化，所以不会出现类似的问题。
——————————————————————————————————–

Mixed，
实际上就是前两种模式的结合。在Mixed模式下，MySQL会根据执行的每一条具体的sql语句来区分对待记录的日志形式，也就是在Statement和Row之间选择一种。新版本中的Statment level还是和以前一样，仅仅记录执行的语句。而新版本的MySQL中队row level模式也被做了优化，并不是所有的修改都会以row level来记录，像遇到表结构变更的时候就会以statement模式来记录，如果sql语句确实就是update或者delete等修改数据的语句，那么还是会记录所有行的变更。
——————————————————————————————————–
```
在配置文件中参数如下：
```
log-bin=mysql-bin
#binlog_format=”STATEMENT”
#binlog_format=”ROW”
binlog_format=”MIXED”
运行时在线修改：
mysql> SET SESSION binlog_format = ‘STATEMENT’;
mysql> SET SESSION binlog_format = ‘ROW’;
mysql> SET SESSION binlog_format = ‘MIXED’;
mysql> SET GLOBAL binlog_format = ‘STATEMENT’;
mysql> SET GLOBAL binlog_format = ‘ROW’;
mysql> SET GLOBAL binlog_format = ‘MIXED’;
```