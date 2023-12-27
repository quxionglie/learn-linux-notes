# MySQL主从复制实践讲解

2012年写的笔记，部分内容可能已经过时，仅供参考。

# 1	复制准备
## 1.1.	定义服务器角色

主库(mysql master)： 	192.168.65.133 	port：3306

从库(mysql slave)： 	    192.168.65.133 	port：3307

## 1.2.	数据库环境准备
具备单机单数据库多实例的环境

或两台服务器，每个机器一个数据库的环境。
## 1.3.	数据库讲法的约定
主库(master)，从库(slave)

# 2.	主库上执行操作
## 2.1.	设置server-id值并开启binlog参数
复制的关键就是binlog日志。

执行vi /data/3306/my.cnf,修改下面两个参数：
```
[mysqld]
log-bin = /data/3306/mysql-bin
server-id = 1

提示：
(1)	上面参数要放在[mysqld]模块下，否则会出错。
(2)	server-id值取服务器ip地址的最后8位，目的是避免不同机器或实例ID重复(不适合多实例)。
(3)	先在文件中查找相关参数按要求修改，不存在时再修改参数，切记，参数不能重复。
(4)	修改my.cnf后需要重起数据库命令：/data/3306/mysql restart,注意要确认真正重起了。
```
检查配置后的结果：
```
[root@stu412 ~]# grep -E "server-id|log-bin" /data/3306/my.cnf
log-bin = /data/3306/mysql-bin #log-bin后面可以不带=号内容，mysql会使用默认日志
server-id = 1
```
## 2.2.	建立同步的账号rep
登录mysql 3306实例数据库
```
[root@stu412 ~]# mysql -uroot -p'123456' -S /data/3306/mysql.sock
mysql> grant replication slave on *.* to 'rep'@'192.168.65.%' identified by '123456';
Query OK, 0 rows affected (0.02 sec)

# replication slave为mysql同步的必须权限，此处不要授权all
# *.* 表示所有库所有表，你可以指定具体的库和表进行复制。
# 'rep'@'192.168.65.%' 中rep表同步账号，'192.168.65.%'为授权主机，
# %表示允许整个192.168.65.0网段以rep用户访问。
# '123456'表示密码，实际环境要设置复杂一点。

检查rep账号
mysql> select user,host from mysql.user;
+------+--------------+
| user | host         |
+------+--------------+
| root | 127.0.0.1    |
| rep  | 192.168.65.% |
| root | localhost    |
+------+--------------+
3 rows in set (0.00 sec)
#或使用 show grants for 'rep'@'192.168.65.%';
```
## 2.3.	对数据库锁表只读(当前窗口不要关闭)

生产环境时，操作主从复制，是需要锁表停机时间的。锁表会影响业务。
```
mysql> flush tables with read lock;
Query OK, 0 rows affected (0.00 sec)

# 这个锁表命令的时间，在不同的引擎的情况下，会受下面参数的控制，
# 锁表时，如果超过设置时间不操作会自动解锁。
interactive_timeout		28800
wait_timeout				28800

mysql> show variables like '%timeout%';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| connect_timeout            | 10    |
| delayed_insert_timeout     | 300   |
| innodb_lock_wait_timeout   | 120   |
| innodb_rollback_on_timeout | OFF   |
| interactive_timeout        | 28800 |
| net_read_timeout           | 30    |
| net_write_timeout          | 60    |
| slave_net_timeout          | 3600  |
| table_lock_wait_timeout    | 50    |
| wait_timeout               | 28800 |
+----------------------------+-------+
10 rows in set (0.00 sec)
```
## 2.4.	查看主库状态
```
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000004 |      258 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)
```
## 2.5.	导出数据库数据

单开新窗口，导出数据库数据，如果数据量很大(100G+),并且允许停机，可以停库直接打包数据文件迁移。
```
[root@stu412 ~]# mkdir -p /server/backup
[root@stu412 ~]# mysqldump -uroot -p'123456' -S /data/3306/mysql.sock -A -B | gzip >/server/backup/mysql_bak.$(date +%F).sql.gz
[root@stu412 ~]# ls -lh /server/backup/
total 140K
-rw-r--r-- 1 root root 136K Sep  1 16:02 mysql_bak.2012-09-01.sql.gz

导库后，解锁主库，恢复可写
mysql> unlock tables;
Query OK, 0 rows affected (0.00 sec)
```
## 2.6.	把主库备份的MYSQL数据迁移到从库
此时用到的命令可能有scp,rsync等。
本文讲解的是单数据库多实例的主从配置，因此，数据在一台机器上。

# 3.	从库上执行操作
## 3.1.	设置server-id值并关闭binlog参数
数据库的server-id一般在LAN内是唯一的，这里的server-id要和主库及其它从库不同，并注释掉从库的binlog参数配置。

vi /data/3307/my.cnf 编辑my.cnf配置文件:
```
[mysqld]
#log-bin = /data/3306/mysql-bin
server-id = 2
```
检查结果：
```
[root@stu412 ~]# grep -E "server-id|log-bin" /data/3307/my.cnf
#log-bin = /data/3307/mysql-bin
server-id = 3
```
重起从库：
```
/data/3307/mysql restart
```
## 3.2.	还原主库导出的数据到从库
```
[root@stu412 ~]# cd /server/backup/
[root@stu412 backup]# ll
total 140
-rw-r--r-- 1 root root 138278 Sep  1 16:02 mysql_bak.2012-09-01.sql.gz
[root@stu412 backup]# gzip -d mysql_bak.2012-09-01.sql.gz
[root@stu412 backup]# ls -l
total 500
-rw-r--r-- 1 root root 507318 Sep  1 16:02 mysql_bak.2012-09-01.sql
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3307/mysql.sock <mysql_bak.2012-09-01.sql
```
## 3.3.	登录从库配置同步参数
```
mysql -uroot -p'123456' -S /data/3307/mysql.sock
CHANGE MASTER TO
MASTER_HOST='192.168.65.133',
MASTER_PORT=3306,
MASTER_USER='rep',
MASTER_PASSWORD='123456',		
MASTER_LOG_FILE='mysql-bin.000004', 		#注意不能多空格
MASTER_LOG_POS=258;							#注意不能多空格


不登录数据库，在命令行快速执行CHANGE MASTER的语句(适合在脚本中批量建slave库)
mysql -uroot -p'123456' -S /data/3307/mysql.sock<< EOF
CHANGE MASTER TO
MASTER_HOST='192.168.65.133',
MASTER_PORT=3306,
MASTER_USER='rep',
MASTER_PASSWORD='123456',
MASTER_LOG_FILE='mysql-bin.000004',
MASTER_LOG_POS=258;
EOF
```
## 3.4.	启动从库同步开关
```
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3307/mysql.sock -e "start slave;"
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3307/mysql.sock -e "show  slave status\G;"

注:停止从库的命令: stop slave;
*************************** 1. row ***************************
Slave_IO_State: Waiting for master to send event
Master_Host: 192.168.65.133	#当前mysql master服务主机
Master_User: rep
Master_Port: 3306
Connect_Retry: 60
Master_Log_File: mysql-bin.000004
Read_Master_Log_Pos: 258
Relay_Log_File: relay-bin.000002
Relay_Log_Pos: 251
Relay_Master_Log_File: mysql-bin.000004
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Replicate_Do_DB:
Replicate_Ignore_DB: mysql
Replicate_Do_Table:
Replicate_Ignore_Table:
Replicate_Wild_Do_Table:
Replicate_Wild_Ignore_Table:
Last_Errno: 0
Last_Error:
Skip_Counter: 0
Exec_Master_Log_Pos: 258
Relay_Log_Space: 400
Until_Condition: None
Until_Log_File:
Until_Log_Pos: 0
Master_SSL_Allowed: No
Master_SSL_CA_File:
Master_SSL_CA_Path:
Master_SSL_Cert:
Master_SSL_Cipher:
Master_SSL_Key:
Seconds_Behind_Master: 0	#和主库同步延迟的秒数，这个参数很重要
Master_SSL_Verify_Server_Cert: No
Last_IO_Errno: 0
Last_IO_Error:
Last_SQL_Errno: 0
Last_SQL_Error:

[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3307/mysql.sock -e "show  slave status\G;" | egrep 'Slave_IO_Running|Slave_SQL_Running'
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
```

判断复制是否成功，就要看IO和SQL两个线程是否显示为Yes状态
```
Slave_IO_Running: Yes  	#负责从库去主库读取BINLOG日志，并写入从库的中继日志中。
Slave_SQL_Running: Yes 	#负责读取并执行中继日志中的BINLOG，转换sql语句后应用到数据库汇总。
```
show  slave status的参数说明请看mysql手册。


## 3.5.	测试复制结果
```
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "create database ett;"  
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "show databases like 'ett';"  
+----------------+
| Database (ett) |
+----------------+
| ett            |
+----------------+
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "drop database ett;"  
[root@stu412 backup]# mysql -uroot -p'123456' -S /data/3306/mysql.sock -e "show databases like 'ett';"  
[root@stu412 backup]#
```
# 4.	生产环境主从库同步注意事项
## 4.1.	第一次做从库如何做?

服务器只有主库，且跑了线上应用了，此时可能需要申请停机维护时间。=>凌晨停机配置主从复制。

# 4.2.	无须熬夜在工作时间轻松配置从库
也可以不申请，在定时任务备份时，每天的夜里服务器压力小时候定时备份时做一些措施。如：

(1)	锁表备份全备一份。

(2)	锁表前后取得show master status值记录日志里。

这样就可以在白天从容的实现主从同步了。

实现脚本：
```

[root@stu412 server]# cat mysql_backup.sh
#!/bin/bash
MYUSER=root
MYPASS="123456"
MYSOCK=/data/3306/mysql.sock

MAIN_PATH=/server/backup
DATA_PATH=/server/backup
LOG_FILE=${DATA_PATH}/mysqllogs_`date +%F`.log
DATA_FILE=${DATA_PATH}/mysql_backup_`date +%F`.sql.gz

MYSQL_PATH=/usr/local/mysql/bin
MYSQL_CMD="$MYSQL_PATH/mysql -u$MYUSER -p$MYPASS -S $MYSOCK"
MYSQL_DUMP="$MYSQL_PATH/mysqldump -u$MYUSER -p$MYPASS -S $MYSOCK -A -B --flush-logs --single-transaction -e"

$MYSQL_CMD -e "flush tables with read lock;"
echo "---------show master status result---------" >> $LOG_FILE
$MYSQL_CMD -e "show master status;" >> $LOG_FILE
${MYSQL_DUMP} | gzip > $DATA_FILE
$MYSQL_CMD -e "unlock tables;"
mail -s "mysql slave log" qxl_work@163.com < $LOG_FILE
```

```

[root@stu412 server]# sh mysql_backup.sh
[root@stu412 backup]# cat mysqllogs_2012-09-01.log
---------show master status result---------
File    Position        Binlog_Do_DB    Binlog_Ignore_DB
mysql-bin.000004        418
```

## 4.3.	不停主库一键批量创建从库脚本
mysql_slave.sh
```

#!/bin/sh
################################################
#this scripts is created by oldboy
#oldboy QQ:31333741
#site:http://www.etiantian.org
#blog:http://oldboy.blog.51cto.com
#oldboy trainning QQ group: 208160987 226199307  44246017
################################################

MYUSER=root
MYPASS="oldboy"
MYSOCK=/data/3306/mysql.sock

MAIN_PATH=/server/backup
DATA_PATH=/server/backup
LOG_FILE=${DATA_PATH}/mysqllogs_`date +%F`.log
DATA_FILE=${DATA_PATH}/mysql_backup_`date +%F`.sql.gz

MYSQL_PATH=/usr/local/mysql/bin
MYSQL_CMD="$MYSQL_PATH/mysql -u$MYUSER -p$MYPASS -S $MYSOCK"

#recover
cd ${DATA_PATH}
gzip -d mysql_backup_`date +%F`.sql.gz
$MYSQL_CMD < mysql_backup_`date +%F`.sql

#config slave
cat |$MYSQL_CMD<< EOF
CHANGE MASTER TO  
MASTER_HOST='10.0.0.179',
MASTER_PORT=3306,
MASTER_USER='rep',
MASTER_PASSWORD='oldboy123',
MASTER_LOG_FILE='mysql-bin.000008',
MASTER_LOG_POS=342;
EOF

$MYSQL_CMD -e "show slave status\G"|egrep "IO_Running|SQL_Running" >$>LOG_FILE
mail -s "mysql slave result" 31333741@qq.com < $LOG_FILE
```

# 5.	相关mysql技术技巧概览
## 5.1.	配置忽略权限库同步参数
```
binlog-ignore-db=information_schema
binlog-ignore-db=mysql
```
      
## 5.2.	主从复制故障解决
```
show  slave  status报错:Error  xxx  don't  exist
且show  slave  status\G;
Slave_IO_Running: Yes
Slave_SQL_Running : No
Seconds_Behind_Master: NULL
```
解决方法:
```
stop  slave;
set  global  sql_slave_skip_counter=1; #忽略执行N个更新
start  slave;
```
## 5.3.	让MySQL slave记录binlog方法

在从库的my.cnf中加入如下参数
```
log-slave=updates
log-bin=mysql3307-bin
expize_logs_days = 7
```
应用场景：级联复制或从库做数据备份

## 5.4.	严格设置从库只读
read-only的妙用;

## 5.5.	生产环境如何确保从库只读
```
1)mysql从服务器中加入read-only参数或者在从服务器启动时加该参数;
2)忽略mysql库及information_schema库同步;
3)授权从库用户时仅授权select权限.
```
生产环境访问主库授权：
```
grant select,insert,update,delete on blog.* to 'blog'@'10.0.0.%' identified by '123456';
```
生产环境访问从库授权：
```
grant select on blog.* to 'blog'@'10.0.0.%' identified by '123456';
```

## 5.6.	生产环境读写分离的账户设置建议
主库(提供写)：blog 	passwd 	ip:192.168.65.133 	port:3306

从库(提供读)：blog 	passwd 	ip:192.168.65.134 	port:3306

除了IP之外，账号、密码、端口等看起来都是一样的。尽量为开发人员提供方便。

