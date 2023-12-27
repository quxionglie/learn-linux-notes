# MySQL常用基础命令操作实战讲解

2012年写的笔记，部分内容可能已经过时，仅供参考。


# 1.  mysql服务操作
## 1.1.    启动与关闭mysql
单实例：

方法1:
```
#启动
[root@server ~]# /etc/init.d/mysqld start
Starting MySQL.[  OK  ]
[root@server ~]# netstat -lnt | grep 3306
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN      
[root@server ~]# /etc/init.d/mysqld status
MySQL running (817)[  OK  ]

#停止
[root@server ~]# /etc/init.d/mysqld stop
Shutting down MySQL......[  OK  ]

#/etc/init.d/mysqld由mysql解压安装目录拷贝过来的
[root@server mysql-5.1.65]# cp ./support-files/mysql.server /etc/init.d/mysqld
```

方法2:
```
#启动
[root@server ~]# /usr/local/mysql/bin/mysqld_safe --user=mysql &
[1] 1489
[root@server ~]# 120818 11:21:19 mysqld_safe Logging to '/usr/local/mysql/data/server.err'.
120818 11:21:19 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/data

#停止
[root@server ~]# killall mysqld
[root@server ~]# killall mysqld
[root@server ~]# killall mysqld
mysqld: no process killed #表示完成了关闭操作,生产环境下不常用

[root@server ~]# killall -9 mysqld
mysqld: no process killed #表示完成了关闭操作,生产环境下不常用
```

多实例：
```
/data/3306/mysql start
/data/3307/mysql start
/data/3306/mysql stop
/data/3307/mysql stop
```
## 1.2.    登录mysql方法

单实例：
```
(1) mysql                   #刚装完系统无密码情况登录方式
(2) mysql -uroot            #刚装完系统无密码情况登录方式
(3) mysql -uroot -p     #标准命令行登录方式
(4) mysql -uroot -p'123456' #非脚本里，一般不会这么用，密码明文的会泄露密码
```

多实例：
```
mysql -uroot -p -S /data/3306/mysql.sock
```
## 1.3.    登录mysql后
```
[root@server ~]# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.1.65 Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```
## 1.4.    mysql的帮助
```
mysql> help

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.

For server side help, type 'help contents'

#查看help命令
mysql> help show;
Name: 'SHOW'
Description:
SHOW has many forms that provide information about databases, tables,
columns, or status information about the server. This section describes
those following:

SHOW AUTHORS
SHOW {BINARY | MASTER} LOGS
SHOW BINLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count]
SHOW CHARACTER SET [like_or_where]
SHOW COLLATION [like_or_where]
SHOW [FULL] COLUMNS FROM tbl_name [FROM db_name] [like_or_where]
SHOW CONTRIBUTORS
SHOW CREATE DATABASE db_name
SHOW CREATE EVENT event_name
SHOW CREATE FUNCTION func_name
SHOW CREATE PROCEDURE proc_name
SHOW CREATE TABLE tbl_name
SHOW CREATE TRIGGER trigger_name
SHOW CREATE VIEW view_name
SHOW DATABASES [like_or_where]
SHOW ENGINE engine_name {STATUS | MUTEX}
SHOW [STORAGE] ENGINES
SHOW ERRORS [LIMIT [offset,] row_count]
SHOW EVENTS
SHOW FUNCTION CODE func_name
SHOW FUNCTION STATUS [like_or_where]
SHOW GRANTS FOR user
SHOW INDEX FROM tbl_name [FROM db_name]
SHOW INNODB STATUS
SHOW MASTER STATUS
SHOW OPEN TABLES [FROM db_name] [like_or_where]
SHOW PLUGINS
SHOW PROCEDURE CODE proc_name
SHOW PROCEDURE STATUS [like_or_where]
SHOW PRIVILEGES
SHOW [FULL] PROCESSLIST
SHOW PROFILE [types] [FOR QUERY n] [OFFSET n] [LIMIT n]
SHOW PROFILES
SHOW SCHEDULER STATUS
SHOW SLAVE HOSTS
SHOW SLAVE STATUS
SHOW [GLOBAL | SESSION] STATUS [like_or_where]
SHOW TABLE STATUS [FROM db_name] [like_or_where]
SHOW [FULL] TABLES [FROM db_name] [like_or_where]
SHOW TRIGGERS [FROM db_name] [like_or_where]
SHOW [GLOBAL | SESSION] VARIABLES [like_or_where]
SHOW WARNINGS [LIMIT [offset,] row_count]

like_or_where:
    LIKE 'pattern'
  | WHERE expr

If the syntax for a given SHOW statement includes a LIKE 'pattern'
part, 'pattern' is a string that can contain the SQL "%" and "_"
wildcard characters. The pattern is useful for restricting statement
output to matching values.

Several SHOW statements also accept a WHERE clause that provides more
flexibility in specifying which rows to display. See
http://dev.mysql.com/doc/refman/5.1/en/extended-show.html.

URL: http://dev.mysql.com/doc/refman/5.1/en/show.html

#查看grant命令
mysql> help grant;
Name: 'GRANT'
Description:
Syntax:
GRANT
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    TO user_specification [, user_specification] ...
    [REQUIRE {NONE | ssl_option [[AND] ssl_option] ...}]
    [WITH with_option ...]

object_type:
    TABLE
  | FUNCTION
  | PROCEDURE

priv_level:
    *
  | *.*
  | db_name.*
  | db_name.tbl_name
  | tbl_name
  | db_name.routine_name

user_specification:
    user [IDENTIFIED BY [PASSWORD] 'password']

ssl_option:
    SSL
  | X509
  | CIPHER 'cipher'
  | ISSUER 'issuer'
  | SUBJECT 'subject'

with_option:
    GRANT OPTION
  | MAX_QUERIES_PER_HOUR count
  | MAX_UPDATES_PER_HOUR count
  | MAX_CONNECTIONS_PER_HOUR count
  | MAX_USER_CONNECTIONS count

The GRANT statement grants privileges to MySQL user accounts. GRANT
also serves to specify other account characteristics such as use of
secure connections and limits on access to server resources. To use
GRANT, you must have the GRANT OPTION privilege, and you must have the
privileges that you are granting.

Normally, a database administrator first uses CREATE USER to create an
account, then GRANT to define its privileges and characteristics. For
example:

CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'mypass';
GRANT ALL ON db1.* TO 'jeffrey'@'localhost';
GRANT SELECT ON db2.invoice TO 'jeffrey'@'localhost';
GRANT USAGE ON *.* TO 'jeffrey'@'localhost' WITH MAX_QUERIES_PER_HOUR 90;

However, if an account named in a GRANT statement does not already
exist, GRANT may create it under the conditions described later in the
discussion of the NO_AUTO_CREATE_USER SQL mode.

The REVOKE statement is related to GRANT and enables administrators to
remove account privileges. See [HELP REVOKE].

When successfully executed from the mysql program, GRANT responds with
Query OK, 0 rows affected. To determine what privileges result from the
operation, use SHOW GRANTS. See [HELP SHOW GRANTS].

URL: http://dev.mysql.com/doc/refman/5.1/en/grant.html

mysql> help revoke;
Name: 'REVOKE'
Description:
Syntax:
REVOKE
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    FROM user [, user] ...

REVOKE ALL PRIVILEGES, GRANT OPTION
    FROM user [, user] ...

The REVOKE statement enables system administrators to revoke privileges
from MySQL accounts. Each account name uses the format described in
http://dev.mysql.com/doc/refman/5.1/en/account-names.html. For example:

REVOKE INSERT ON *.* FROM 'jeffrey'@'localhost';

If you specify only the user name part of the account name, a host name
part of '%' is used.

For details on the levels at which privileges exist, the permissible
priv_type and priv_level values, and the syntax for specifying users
and passwords, see [HELP GRANT]

To use the first REVOKE syntax, you must have the GRANT OPTION
privilege, and you must have the privileges that you are revoking.

To revoke all privileges, use the second syntax, which drops all
global, database, table, column, and routine privileges for the named
user or users:

REVOKE ALL PRIVILEGES, GRANT OPTION FROM user [, user] ...

To use this REVOKE syntax, you must have the global CREATE USER
privilege or the UPDATE privilege for the mysql database.

URL: http://dev.mysql.com/doc/refman/5.1/en/revoke.html
```
## 1.5.    退出mysql 
```
mysql> quit     #或exit
Bye
[root@server ~]#
```
## 1.6.    修改mysql root用户密码
```
安装完myql后,默认的管理员root密码为空，很不安全。
mysqladmin -u root  password '123456'       #密码为空时，这样修改

修改密码方法1:
[root@server ~]# mysqladmin -u root -p'123456' password '123456'

修改密码方法2:
mysql> update mysql.user set password=PASSWORD("123456") where user='root';
Query OK, 1 row affected (0.05 sec)
Rows matched: 2  Changed: 1  Warnings: 0

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)
```
## 1.7.    找回mysql root用户密码
单实例：
```
killall mysqld
mysqld_safe --skip-grant-tables &
mysql -u root -p
```

多实例：
```
killall mysqld
mysqld_safe --defaults-file=/data/3306/my.cnf --skip-grant-tables &
mysql -u root -p -S /data/3306/mysql.sock
```
修改密码
```
mysql> update mysql.user set password=PASSWORD("123456") where user='root';
Query OK, 1 row affected (0.05 sec)
Rows matched: 2  Changed: 1  Warnings: 0

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)
```
重起登录测试：
```
killall mysqld
单实例：/etc/init.d/mysqld restart
多实例：/data/3306/mysql restart
```

操作演示：
```
[root@server ~]# killall mysqld
[root@server ~]# killall mysqld
mysqld: no process killed
[root@server ~]# mysqld_safe --skip-grant-tables &
[1] 2215
[root@server ~]# 120818 12:01:33 mysqld_safe Logging to '/usr/local/mysql/data/server.err'.
120818 12:01:34 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/data

[root@server ~]# mysql -u root -p
Enter password:         #直接按回车
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.1.65 Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> update mysql.user set password=PASSWORD("123456") where user='root';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 2  Changed: 0  Warnings: 0

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

mysql> quit;
Bye


[root@server ~]# mysqladmin -u root  password '123456'
mysqladmin: 
You cannot use 'password' command as mysqld runs
 with grant tables disabled (was started with --skip-grant-tables).
Use: "mysqladmin flush-privileges password '*'" instead
[root@server ~]# mysqladmin -u root flush-privileges password '123456'
mysqladmin: unable to change password; error: 'Can't find any matching row in the user table'
[root@server ~]# mysqladmin flush-privileges password '123456'
mysqladmin: connect to server at 'localhost' failed
error: 'Access denied for user 'root'@'localhost' (using password: NO)'
```
# 2.  数据库操作
## 2.1.    创建数据库
```
语法：CREATE DATABASE db_name;
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
    [create_specification] ...

create_specification:
    [DEFAULT] CHARACTER SET [=] charset_name
  | [DEFAULT] COLLATE [=] collation_name
```
(1) 各种编码的数据库
```
默认编码：
CREATE DATABASE test_db;

utf-8：
CREATE DATABASE test_db_utf8 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

gbk：
CREATE DATABASE test_db_gbk DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
```
(2) 创建默认编码的数据库
```
mysql> create database test_db;
Query OK, 1 row affected (0.00 sec)

mysql> show create database test_db;
+----------+--------------------------------------------------------------------+
| Database | Create Database                                                    |
+----------+--------------------------------------------------------------------+
| test_db  | CREATE DATABASE `test_db` /*!40100 DEFAULT CHARACTER SET latin1 */ |
+----------+--------------------------------------------------------------------+
1 row in set (0.00 sec)
```
(3) 创建utf-8编码的数据库
```
mysql> CREATE DATABASE test_db_utf8 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
Query OK, 1 row affected (0.00 sec)

mysql> show create database test_db_utf8;
+--------------+-----------------------------------------------------------------------+
| Database     | Create Database                                                       |
+--------------+-----------------------------------------------------------------------+
| test_db_utf8 | CREATE DATABASE `test_db_utf8` /*!40100 DEFAULT CHARACTER SET utf8 */ |
+--------------+-----------------------------------------------------------------------+
1 row in set (0.00 sec)
```
(4) 创建gbk编码的数据库
```
mysql> CREATE DATABASE test_db_gbk DEFAULT CHARACTER SET gbk COLLATE gbk_chinese_ci;
Query OK, 1 row affected (0.00 sec)

mysql> show create database test_db_gbk;
+-------------+---------------------------------------------------------------------+
| Database    | Create Database                                                     |
+-------------+---------------------------------------------------------------------+
| test_db_gbk | CREATE DATABASE `test_db_gbk` /*!40100 DEFAULT CHARACTER SET gbk */ |
+-------------+---------------------------------------------------------------------+
1 row in set (0.00 sec)
```

(5) 查看mysql支持的编码列表
```
mysql> SHOW CHARACTER SET;
+----------+-----------------------------+---------------------+--------+
| Charset  | Description                 | Default collation   | Maxlen |
+----------+-----------------------------+---------------------+--------+
| big5     | Big5 Traditional Chinese    | big5_chinese_ci     |      2 |
| dec8     | DEC West European           | dec8_swedish_ci     |      1 |
| cp850    | DOS West European           | cp850_general_ci    |      1 |
| hp8      | HP West European            | hp8_english_ci      |      1 |
| koi8r    | KOI8-R Relcom Russian       | koi8r_general_ci    |      1 |
| latin1   | cp1252 West European        | latin1_swedish_ci   |      1 |
| latin2   | ISO 8859-2 Central European | latin2_general_ci   |      1 |
| swe7     | 7bit Swedish                | swe7_swedish_ci     |      1 |
| ascii    | US ASCII                    | ascii_general_ci    |      1 |
| ujis     | EUC-JP Japanese             | ujis_japanese_ci    |      3 |
| sjis     | Shift-JIS Japanese          | sjis_japanese_ci    |      2 |
| hebrew   | ISO 8859-8 Hebrew           | hebrew_general_ci   |      1 |
| tis620   | TIS620 Thai                 | tis620_thai_ci      |      1 |
| euckr    | EUC-KR Korean               | euckr_korean_ci     |      2 |
| koi8u    | KOI8-U Ukrainian            | koi8u_general_ci    |      1 |
| gb2312   | GB2312 Simplified Chinese   | gb2312_chinese_ci   |      2 |
| greek    | ISO 8859-7 Greek            | greek_general_ci    |      1 |
| cp1250   | Windows Central European    | cp1250_general_ci   |      1 |
| gbk      | GBK Simplified Chinese      | gbk_chinese_ci      |      2 |
| latin5   | ISO 8859-9 Turkish          | latin5_turkish_ci   |      1 |
| armscii8 | ARMSCII-8 Armenian          | armscii8_general_ci |      1 |
| utf8     | UTF-8 Unicode               | utf8_general_ci     |      3 |
| ucs2     | UCS-2 Unicode               | ucs2_general_ci     |      2 |
| cp866    | DOS Russian                 | cp866_general_ci    |      1 |
| keybcs2  | DOS Kamenicky Czech-Slovak  | keybcs2_general_ci  |      1 |
| macce    | Mac Central European        | macce_general_ci    |      1 |
| macroman | Mac West European           | macroman_general_ci |      1 |
| cp852    | DOS Central European        | cp852_general_ci    |      1 |
| latin7   | ISO 8859-13 Baltic          | latin7_general_ci   |      1 |
| cp1251   | Windows Cyrillic            | cp1251_general_ci   |      1 |
| cp1256   | Windows Arabic              | cp1256_general_ci   |      1 |
| cp1257   | Windows Baltic              | cp1257_general_ci   |      1 |
| binary   | Binary pseudo charset       | binary              |      1 |
| geostd8  | GEOSTD8 Georgian            | geostd8_general_ci  |      1 |
| cp932    | SJIS for Windows Japanese   | cp932_japanese_ci   |      2 |
| eucjpms  | UJIS for Windows Japanese   | eucjpms_japanese_ci |      3 |
+----------+-----------------------------+---------------------+--------+
36 rows in set (0.00 sec)
```
## 2.2.    删除数据库
```
语法：DROP {DATABASE | SCHEMA} [IF EXISTS] db_name

mysql> show databases like 'test_db_gbk';
+------------------------+
| Database (test_db_gbk) |
+------------------------+
| test_db_gbk            |
+------------------------+
1 row in set (0.00 sec)

mysql> drop database test_db_gbk;
Query OK, 0 rows affected (0.00 sec)

mysql> show databases like 'test_db_gbk';
Empty set (0.01 sec)
```
## 2.3.    指定当前数据库
```
语法：USE db_name
mysql> use test_db_utf8;
Database changed
mysql> show tables;
Empty set (0.00 sec)
```
## 2.4.    查看当前数据库
```
mysql> select database();
+--------------+
| database()   |
+--------------+
| test_db_utf8 |
+--------------+
1 row in set (0.00 sec)

mysql> select version();
+-----------+
| version() |
+-----------+
| 5.1.65    |
+-----------+
1 row in set (0.04 sec)
mysql> select user();
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.00 sec)
```
## 2.5.    查看当前数据库的表
```
mysql> show tables;
Empty set (0.00 sec)
```
## 2.6.    删除数据库的多余帐号
```
语法：drop user "user"@"主机域"
mysql> select user,host from mysql.user;
+-----------+-----------+
| user      | host      |
+-----------+-----------+
| root      | 127.0.0.1 |
| oldboy    | localhost |
| root      | localhost |
| wordpress | localhost |
+-----------+-----------+
4 rows in set (0.01 sec)
mysql> drop  user 'oldboy'@'localhost';
Query OK, 0 rows affected (0.01 sec)
mysql> select user,host from mysql.user;
+-----------+-----------+
| user      | host      |
+-----------+-----------+
| root      | 127.0.0.1 |
| root      | localhost |
| wordpress | localhost |
+-----------+-----------+
3 rows in set (0.00 sec)
```
## 2.7.    创建用户并赋予权限
```
示例：grant create,select,insert,update,delete on wordpress.* to 'wordpress'@localhost identified by '123456';
mysql> help grant
Name: 'GRANT'
Description:
Syntax:
GRANT
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    TO user_specification [, user_specification] ...
    [REQUIRE {NONE | ssl_option [[AND] ssl_option] ...}]
    [WITH with_option ...]

object_type:
    TABLE
  | FUNCTION
  | PROCEDURE

priv_level:
    *
  | *.*
  | db_name.*
  | db_name.tbl_name
  | tbl_name
  | db_name.routine_name

user_specification:
    user [IDENTIFIED BY [PASSWORD] 'password']

ssl_option:
    SSL
  | X509
  | CIPHER 'cipher'
  | ISSUER 'issuer'
  | SUBJECT 'subject'

with_option:
    GRANT OPTION
  | MAX_QUERIES_PER_HOUR count
  | MAX_UPDATES_PER_HOUR count
  | MAX_CONNECTIONS_PER_HOUR count
  | MAX_USER_CONNECTIONS count
```
(1) 赋予用户权限


(2) 查看用户有哪些权限
```
mysql> show grants for wordpress@localhost;
+------------------------------------------------------------------------------------------------------------------+
| Grants for wordpress@localhost                                                                                   |
+------------------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'wordpress'@'localhost' IDENTIFIED BY PASSWORD '*6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9' |
| GRANT SELECT, INSERT, UPDATE, DELETE, CREATE ON `wordpress`.* TO 'wordpress'@'localhost'                         |
+------------------------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
```

(3) 取消用户权限
```
mysql> help revoke
Name: 'REVOKE'
Description:
Syntax:
REVOKE
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    FROM user [, user] ...

REVOKE ALL PRIVILEGES, GRANT OPTION
    FROM user [, user] ...

REVOKE INSERT ON *.* FROM 'jeffrey'@'localhost';
```
(4) 查看ALL PRIVILEGES权限


上一节课的grant内容

## 2.8.    查看mysql用户
```
mysql> select user,host from mysql.user;
+-----------+-----------+
| user      | host      |
+-----------+-----------+
| root      | 127.0.0.1 |
| root      | localhost |
| wordpress | localhost |
+-----------+-----------+
3 rows in set (0.00 sec)
```
# 3.  表操作
## 3.1.    准备(建立数据库)
```
mysql> CREATE DATABASE test_db_utf8 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
Query OK, 1 row affected (0.01 sec)

mysql> show databases like "test_db_utf8";
+-------------------------+
| Database (test_db_utf8) |
+-------------------------+
| test_db_utf8            |
+-------------------------+
1 row in set (0.00 sec)

mysql> show create database test_db_utf8;
+--------------+-----------------------------------------------------------------------+
| Database     | Create Database                                                       |
+--------------+-----------------------------------------------------------------------+
| test_db_utf8 | CREATE DATABASE `test_db_utf8` /*!40100 DEFAULT CHARACTER SET utf8 */ |
+--------------+-----------------------------------------------------------------------+
1 row in set (0.00 sec)
```
## 3.2.    建表
```
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  login_id varchar(32) NOT NULL DEFAULT '' COMMENT '登录id',
  user_id varchar(32) NOT NULL DEFAULT '' COMMENT '用户名',
  password varchar(32) NOT NULL DEFAULT '' COMMENT '密码',
  login_time datetime DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (login_id),
  UNIQUE KEY un_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

mysql> use test_db_utf8;
Database changed

mysql> CREATE TABLE t_user (
    ->   login_id varchar(32) NOT NULL DEFAULT '' COMMENT '登录id',
    ->   user_id varchar(32) NOT NULL DEFAULT '' COMMENT '用户名',
    ->   password varchar(32) NOT NULL DEFAULT '' COMMENT '密码',
    ->   login_time datetime DEFAULT NULL COMMENT '最后登录时间',
    ->   PRIMARY KEY (login_id),
    ->   UNIQUE KEY un_user_id (user_id)
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';
Query OK, 0 rows affected (0.04 sec)
```
## 3.3.    查看建表sql
### 3.3.1.  查看表结构命令：desc 表名 或 show columns from 表名
```
如：
desc t_user;
show columns from t_user;

mysql> desc t_user;
+------------+-------------+------+-----+---------+-------+
| Field      | Type        | Null | Key | Default | Extra |
+------------+-------------+------+-----+---------+-------+
| login_id   | varchar(32) | NO   | PRI |         |       |
| user_id    | varchar(32) | NO   | UNI |         |       |
| password   | varchar(32) | NO   |     |         |       |
| login_time | datetime    | YES  |     | NULL    |       |
+------------+-------------+------+-----+---------+-------+
4 rows in set (0.03 sec)

mysql> show columns from t_user;
+------------+-------------+------+-----+---------+-------+
| Field      | Type        | Null | Key | Default | Extra |
+------------+-------------+------+-----+---------+-------+
| login_id   | varchar(32) | NO   | PRI |         |       |
| user_id    | varchar(32) | NO   | UNI |         |       |
| password   | varchar(32) | NO   |     |         |       |
| login_time | datetime    | YES  |     | NULL    |       |
+------------+-------------+------+-----+---------+-------+
4 rows in set (0.01 sec)
```
### 3.3.2.  查看建表sql
```
mysql> show create table t_user;
…省略…
| t_user | CREATE TABLE `t_user` (
  `login_id` varchar(32) NOT NULL DEFAULT '' COMMENT '登录id',
  `user_id` varchar(32) NOT NULL DEFAULT '' COMMENT '用户名',
  `password` varchar(32) NOT NULL DEFAULT '' COMMENT '密码',
  `login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`login_id`),
  UNIQUE KEY `un_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表' |
…省略…
```
### 3.3.3.  插入数据
```
mysql> insert into t_user(login_id, user_id,password) values ('123', 'sky', '123456');
Query OK, 1 row affected (0.03 sec)

mysql> select * from t_user;
+----------+---------+----------+------------+
| login_id | user_id | password | login_time |
+----------+---------+----------+------------+
| 123      | sky     | 123456   | NULL       |
+----------+---------+----------+------------+
1 row in set (0.04 sec)

备份命令：
mysql> system mysqldump -uroot -p'123456' test_db_utf8>/tmp/test_db.sql;
mysql> system ls -l /tmp/test_db.sql
-rw-r--r-- 1 root root 2202 Aug 18 16:55 /tmp/test_db.sql 
#system为跳出mysql执行系统命令，执行完毕返回myql
```
## 3.4.    查询数据
略
## 3.5.    修改数据
略
## 3.6.    删除数据
```
delete from 表名 where 表达式;

删除全部记录：
delete from 表名;
truncate table 表名;

略
```
## 3.7.    更改表结构：alter命令
```
#重命名表
mysql> ALTER TABLE table_name RENAME table_name_new;

#删除列
mysql> ALTER TABLE table_name DROP column_name;

#增加列
mysql> ALTER TABLE table_name ADD column_name varchar(20);
mysql> ALTER TABLE table_name ADD column_name tinyint NOT NULL DEFAULT '1';

#改变列的名称及类型
mysql> ALTER TABLE table_name CHANGE column_name column_name_new new_type;
mysql> ALTER TABLE table_name CHANGE column_name column_name_new tinyint NOT NULL DEFAULT '1';
```
## 3.8.    更改表名
```
ALTER TABLE table_name RENAME table_name_new;
RENAME TABLE tbl_name TO new_tbl_name;
```
## 3.9.    删除表
```
drop table 表名
```
# 4.  mysql数据备份
## 4.1.    解决填充中文数据乱码问题
```
mysql> insert into t_user(login_id, user_id,password) values ('124', '中文', '123456');
Query OK, 1 row affected (0.00 sec)

mysql> select * from t_user;
+----------+---------+----------+------------+
| login_id | user_id | password | login_time |
+----------+---------+----------+------------+
| 123      | sky     | 123456   | NULL       |
| 124      | 中文  | 123456   | NULL       |
+----------+---------+----------+------------+
2 rows in set (0.01 sec)


mysql> set names gbk;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into t_user(login_id, user_id,password) values ('125', '中文', '123456');
Query OK, 1 row affected, 1 warning (0.03 sec)

mysql> select * from t_user;
+----------+---------+----------+------------+
| login_id | user_id | password | login_time |
+----------+---------+----------+------------+
| 123      | sky     | 123456   | NULL       |
| 124      | ????¨C? | 123456   | NULL       |
| 125      | 丿??   | 123456   | NULL       |
+----------+---------+----------+------------+
3 rows in set (0.01 sec)

mysql> set names utf-8;
ERROR 1115 (42000): Unknown character set: 'utf'
mysql> set names utf8;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into t_user(login_id, user_id,password) values ('126', '您', '123456');
Query OK, 1 row affected (0.00 sec)

mysql> select * from t_user;
+----------+----------------+----------+------------+
| login_id | user_id        | password | login_time |
+----------+----------------+----------+------------+
| 123      | sky            | 123456   | NULL       |
| 124      | ??-?–? | 123456   | NULL       |
| 125      | 涓?枃        | 123456   | NULL       |
| 126      | 您            | 123456   | NULL       |
+----------+----------------+----------+------------+
4 rows in set (0.00 sec)
```
## 4.2.    mysql字符集介绍

GBK

UTF-8

## 4.3.    set names做了什么?
```
mysql> show variables like 'character_set%';
+--------------------------+----------------------------------------+
| Variable_name            | Value                                  |
+--------------------------+----------------------------------------+
| character_set_client     | latin1                                 |
| character_set_connection | latin1                                 |
| character_set_database   | utf8                                   |
| character_set_filesystem | binary                                 |
| character_set_results    | latin1                                 |
| character_set_server     | latin1                                 |
| character_set_system     | utf8                                   |
| character_sets_dir       | /usr/local/mysql/share/mysql/charsets/ |
+--------------------------+----------------------------------------+
8 rows in set (0.00 sec)


mysql> set names utf8;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'character_set%';
+--------------------------+----------------------------------------+
| Variable_name            | Value                                  |
+--------------------------+----------------------------------------+
| character_set_client     | utf8                                   |
| character_set_connection | utf8                                   |
| character_set_database   | utf8                                   |
| character_set_filesystem | binary                                 |
| character_set_results    | utf8                                   |
| character_set_server     | latin1                                 |
| character_set_system     | utf8                                   |
| character_sets_dir       | /usr/local/mysql/share/mysql/charsets/ |
+--------------------------+----------------------------------------+
8 rows in set (0.00 sec)

mysql> set names gbk;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'character_set%';
+--------------------------+----------------------------------------+
| Variable_name            | Value                                  |
+--------------------------+----------------------------------------+
| character_set_client     | gbk                                    |
| character_set_connection | gbk                                    |
| character_set_database   | utf8                                   |
| character_set_filesystem | binary                                 |
| character_set_results    | gbk                                    |
| character_set_server     | latin1                                 |
| character_set_system     | utf8                                   |
| character_sets_dir       | /usr/local/mysql/share/mysql/charsets/ |
+--------------------------+----------------------------------------+
8 rows in set (0.00 sec)
```

```
下面针对的是gbk的数据库：
提示：set names gbk把上面3个参数改成了gbk,即
| character_set_client     | gbk                                    |
| character_set_connection | gbk                                    |
| character_set_results    | gbk                                    |
通常上面三个参数和数据库character_set_database的字符集相同，才能确保写入数据库可以正确输出。
同时修改上面三个参数（每次连接DB后都需要执行）: set names gbk

更简单的方法：
[mysqld]
default-character-set=gbk
这个mysql启动后，默认是GBK字符连接，不需要set names命令了。
或登录命令加上参数
mysql -uroot -p'123456' default-character-set=gbk
mysql -uroot -p'123456' -S /data/3306/mysql.sock default-character-set=gbk


同时也要注意自己的操作系统字符集：
[root@server tmp]# echo $LANG
en_US.UTF-8
[root@server tmp]# cat /etc/sysconfig/i18n
LANG="en_US.UTF-8"
SYSFONT="latarcyrheb-sun16
``` 

## 4.4.    备份单个数据库
```
mysqldump -u 用户 -p'密码' default-character-set=latin1 数据库名>备份文件名(数据库默认编码是latin1)
普通备份：
mysqldump -uroot -p'123456' test_db_utf8>/data/backup/db/test_db_utf8.sql

压缩备份：
mysqldump -uroot -p'123456' test_db_utf8 | gzip >/data/backup/db/test_db_utf8.sql.gz

设置字符集备份：
mysqldump -uroot -p'123456' test_db_utf8 --default-character-set=utf8 | gzip >/data/backup/db/test_db_utf8.sql.gz

生产环境常用压缩备份
[root@server ~]# mkdir -p /data/backup/db/
[root@server ~]# cd /data/backup/db/
[root@server db]# mysqldump -uroot -p'123456' test_db_utf8>/data/backup/db/test_db_utf8.sql
[root@server db]# mysqldump -uroot -p'123456' test_db_utf8 | gzip >/data/backup/db/test_db_utf8.sql.gz
[root@server db]# ll
total 8
-rw-r--r-- 1 root root 2332 Aug 18 18:13 test_db_utf8.sql
-rw-r--r-- 1 root root  919 Aug 18 18:13 test_db_utf8.sql.gz
```
## 4.5.    备份多个数据库
```
mysqldump -uroot -p'123456' -B test_db_utf8 test_db2_utf8 --default-character-set=utf8  >/data/backup/db/test_db_muli.sql.gz
-B参数是关键。
-B, --databases    Dump several databases. Note the difference in usage; in
                      this case no tables are given. All name arguments are
                      regarded as database names. 'USE db_name;' will be
                      included in the output.

[root@server db]# mysql -uroot -p'123456' -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| oldboy             |
| test               |
| test_db_utf8       |
| wordpress          |
+--------------------+
```
## 4.6.    备份单个表
```
mysqldump -u 用户 -p'密码'   数据库名 表名>备份文件名 
mysqldump -uroot -p'123456' test_db_utf8 t_user>t_user.sql
```
## 4.7.    备份多个表
mysqldump -u 用户 -p'密码'  数据库名 表名 表名>备份文件名 
## 4.8.    备份数据库结构(不包含数据)
```
mysqldump -u 用户 -d -p'密码'  数据库名 表名>备份文件名 
-d 只备份表结构
-d, --no-data       No row information.

mysqldump -uroot -d -p'123456' test_db_utf8 t_user>t_user_desc.sql
```
# 5.  恢复数据库
## 5.1.    source命令恢复
```
msql>use 数据库
msql>source test_db_utf8.sql
test_db_utf8.sql为脚本文件

mysql> use test_db_utf8
Database changed
mysql> show tables;
+------------------------+
| Tables_in_test_db_utf8 |
+------------------------+
| t_user                 |
+------------------------+
1 row in set (0.00 sec)
mysql> drop table t_user;
Query OK, 0 rows affected (0.01 sec)

mysql> source /data/backup/db/test_db_utf8.sql
…省略…
Query OK, 5 rows affected (0.00 sec)
Records: 5  Duplicates: 0  Warnings: 0
Query OK, 0 rows affected (0.00 sec)
…省略…
mysql> show tables;
+------------------------+
| Tables_in_test_db_utf8 |
+------------------------+
| t_user                 |
+------------------------+
1 row in set (0.01 sec)
```
## 5.2.    mysql命令恢复(标准)
```
mysql -u root -p'123456' test_db_utf8<test_db_utf8.sql

[root@server db]# mysql -u root -p'123456' test_db_utf8<test_db_utf8.sql
```
# 6.  mysql带-e参数实现非交互式对话
## 6.1.    基本使用
```
[root@server db]# mysql -u root -p'123456' -e "select * from test_db_utf8.t_user"
+----------+---------+----------+------------+
| login_id | user_id | password | login_time |
+----------+---------+----------+------------+
| 123      | sky     | 123456   | NULL       |
| 124      | 中文  | 123456   | NULL       |
| 125      | ???     | 123456   | NULL       |
| 126      | ?       | 123456   | NULL       |
| 128      | ??      | 123456   | NULL       |
+----------+---------+----------+------------+
[root@server db]# mysql -u root -p'123456' -e "select * from test_db_utf8.t_user"
[root@server db]# mysql -u root -p'123456' -e "truncate table test_db_utf8.t_user"
[root@server db]# mysql -u root -p'123456' -e "select * from test_db_utf8.t_user"
[root@server db]# mysql -u root -p'123456' test_db_utf8<test_db_utf8.sql
```
## 6.2.    查看mysql状态
```
[root@server db]# mysql -u root -p'123456' -e "show processlist;"
+----+------+-----------+------+---------+------+-------+------------------+
| Id | User | Host      | db   | Command | Time | State | Info             |
+----+------+-----------+------+---------+------+-------+------------------+
| 32 | root | localhost | NULL | Query   |    0 | NULL  | show processlist |
+----+------+-----------+------+---------+------+-------+------------------+

[root@server ~]# mysql -u root -p'123456' -e "show variables;" | head -5
Variable_name   Value
auto_increment_increment        1
auto_increment_offset   1
autocommit      ON
automatic_sp_privileges ON
[root@server ~]#
[root@server ~]# mysql -u root -p'123456' -e "show global status;" | head -5
Variable_name   Value
Aborted_clients 0
Aborted_connects        1
Binlog_cache_disk_use   0
Binlog_cache_use        0
[root@server ~]#

 
附录1：mysqldump --help 解读
[root@server db]# mysqldump --help
mysqldump  Ver 10.13 Distrib 5.1.65, for pc-linux-gnu (i686)
Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Dumping structure and contents of MySQL databases and tables.
Usage: mysqldump [OPTIONS] database [tables]
OR     mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
OR     mysqldump [OPTIONS] --all-databases [OPTIONS]

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf 
The following groups are read: mysqldump client
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.
  --all               Deprecated. Use --create-options instead.
  -A, --all-databases Dump all the databases. This will be same as --databases
                      with all databases selected.
  -Y, --all-tablespaces 
                      Dump all the tablespaces.
  -y, --no-tablespaces 
                      Do not dump any tablespace information.
  --add-drop-database Add a DROP DATABASE before each create.
  --add-drop-table    Add a DROP TABLE before each create.
  --add-locks         Add locks around INSERT statements.
  --allow-keywords    Allow creation of column names that are keywords.
  --character-sets-dir=name 
                      Directory for character set files.
  -i, --comments      Write additional information.
  --compatible=name   Change the dump to be compatible with a given mode. By
                      default tables are dumped in a format optimized for
                      MySQL. Legal modes are: ansi, mysql323, mysql40,
                      postgresql, oracle, mssql, db2, maxdb, no_key_options,
                      no_table_options, no_field_options. One can use several
                      modes separated by commas. Note: Requires MySQL server
                      version 4.1.0 or higher. This option is ignored with
                      earlier server versions.
  --compact           Give less verbose output (useful for debugging). Disables
                      structure comments and header/footer constructs.  Enables
                      options --skip-add-drop-table --skip-add-locks
                      --skip-comments --skip-disable-keys --skip-set-charset.
  -c, --complete-insert 
                      Use complete insert statements.
  -C, --compress      Use compression in server/client protocol.
  -a, --create-options 
                      Include all MySQL specific create options.
  -B, --databases     Dump several databases. Note the difference in usage; in
                      this case no tables are given. All name arguments are
                      regarded as database names. 'USE db_name;' will be
                      included in the output.
  -#, --debug[=#]     This is a non-debug version. Catch this and exit.
  --debug-check       Check memory and open file usage at exit.
  --debug-info        Print some debug info at exit.
  --default-character-set=name 
                      Set the default character set.
  --delayed-insert    Insert rows with INSERT DELAYED.
  --delete-master-logs 
                      Delete logs on master after backup. This automatically
                      enables --master-data.
  -K, --disable-keys  '/*!40000 ALTER TABLE tb_name DISABLE KEYS */; and
                      '/*!40000 ALTER TABLE tb_name ENABLE KEYS */; will be put
                      in the output.
  -E, --events        Dump events.
  -e, --extended-insert 
                      Use multiple-row INSERT syntax that include several
                      VALUES lists.
  --fields-terminated-by=name 
                      Fields in the output file are terminated by the given
                      string.
  --fields-enclosed-by=name 
                      Fields in the output file are enclosed by the given
                      character.
  --fields-optionally-enclosed-by=name 
                      Fields in the output file are optionally enclosed by the
                      given character.
  --fields-escaped-by=name 
                      Fields in the output file are escaped by the given
                      character.
  --first-slave       Deprecated, renamed to --lock-all-tables.
  -F, --flush-logs    Flush logs file in server before starting dump. Note that
                      if you dump many databases at once (using the option
                      --databases= or --all-databases), the logs will be
                      flushed for each database dumped. The exception is when
                      using --lock-all-tables or --master-data: in this case
                      the logs will be flushed only once, corresponding to the
                      moment all tables are locked. So if you want your dump
                      and the log flush to happen at the same exact moment you
                      should use --lock-all-tables or --master-data with
                      --flush-logs.
  --flush-privileges  Emit a FLUSH PRIVILEGES statement after dumping the mysql
                      database.  This option should be used any time the dump
                      contains the mysql database and any other database that
                      depends on the data in the mysql database for proper
                      restore. 
  -f, --force         Continue even if we get an SQL error.
  -?, --help          Display this help message and exit.
  --hex-blob          Dump binary strings (BINARY, VARBINARY, BLOB) in
                      hexadecimal format.
  -h, --host=name     Connect to host.
  --ignore-table=name Do not dump the specified table. To specify more than one
                      table to ignore, use the directive multiple times, once
                      for each table.  Each table must be specified with both
                      database and table names, e.g.,
                      --ignore-table=database.table.
  --insert-ignore     Insert rows with INSERT IGNORE.
  --lines-terminated-by=name 
                      Lines in the output file are terminated by the given
                      string.
  -x, --lock-all-tables 
                      Locks all tables across all databases. This is achieved
                      by taking a global read lock for the duration of the
                      whole dump. Automatically turns --single-transaction and
                      --lock-tables off.
  -l, --lock-tables   Lock all tables for read.
  --log-error=name    Append warnings and errors to given file.
  --master-data[=#]   This causes the binary log position and filename to be
                      appended to the output. If equal to 1, will print it as a
                      CHANGE MASTER command; if equal to 2, that command will
                      be prefixed with a comment symbol. This option will turn
                      --lock-all-tables on, unless --single-transaction is
                      specified too (in which case a global read lock is only
                      taken a short time at the beginning of the dump; don't
                      forget to read about --single-transaction below). In all
                      cases, any action on logs will happen at the exact moment
                      of the dump. Option automatically turns --lock-tables
                      off.
  --max_allowed_packet=# 
                      The maximum packet length to send to or receive from
                      server.
  --net_buffer_length=# 
                      The buffer size for TCP/IP and socket communication.
  --no-autocommit     Wrap tables with autocommit/commit statements.
  -n, --no-create-db  Suppress the CREATE DATABASE ... IF EXISTS statement that
                      normally is output for each dumped database if
                      --all-databases or --databases is given.
  -t, --no-create-info 
                      Don't write table creation info.
  -d, --no-data       No row information.
  -N, --no-set-names  Suppress the SET NAMES statement
  --opt               Same as --add-drop-table, --add-locks, --create-options,
                      --quick, --extended-insert, --lock-tables, --set-charset,
                      and --disable-keys. Enabled by default, disable with
                      --skip-opt.
  --order-by-primary  Sorts each table's rows by primary key, or first unique
                      key, if such a key exists.  Useful when dumping a MyISAM
                      table to be loaded into an InnoDB table, but will make
                      the dump itself take considerably longer.
  -p, --password[=name] 
                      Password to use when connecting to server. If password is
                      not given it's solicited on the tty.
  -P, --port=#        Port number to use for connection.
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -q, --quick         Don't buffer query, dump directly to stdout.
  -Q, --quote-names   Quote table and column names with backticks (`).
  --replace           Use REPLACE INTO instead of INSERT INTO.
  -r, --result-file=name 
                      Direct output to a given file. This option should be used
                      in MSDOS, because it prevents new line '\n' from being
                      converted to '\r\n' (carriage return + line feed).
  -R, --routines      Dump stored routines (functions and procedures).
  --set-charset       Add 'SET NAMES default_character_set' to the output.
                      Enabled by default; suppress with --skip-set-charset.
  -O, --set-variable=name 
                      Change the value of a variable. Please note that this
                      option is deprecated; you can set variables directly with
                      --variable-name=value.
  --single-transaction 
                      Creates a consistent snapshot by dumping all tables in a
                      single transaction. Works ONLY for tables stored in
                      storage engines which support multiversioning (currently
                      only InnoDB does); the dump is NOT guaranteed to be
                      consistent for other storage engines. While a
                      --single-transaction dump is in process, to ensure a
                      valid dump file (correct table contents and binary log
                      position), no other connection should use the following
                      statements: ALTER TABLE, DROP TABLE, RENAME TABLE,
                      TRUNCATE TABLE, as consistent snapshot is not isolated
                      from them. Option automatically turns off --lock-tables.
  --dump-date         Put a dump date to the end of the output.
  --skip-opt          Disable --opt. Disables --add-drop-table, --add-locks,
                      --create-options, --quick, --extended-insert,
                      --lock-tables, --set-charset, and --disable-keys.
  -S, --socket=name   The socket file to use for connection.
  --ssl               Enable SSL for connection (automatically enabled with
                      other flags).Disable with --skip-ssl.
  --ssl-ca=name       CA file in PEM format (check OpenSSL docs, implies
                      --ssl).
  --ssl-capath=name   CA directory (check OpenSSL docs, implies --ssl).
  --ssl-cert=name     X509 cert in PEM format (implies --ssl).
  --ssl-cipher=name   SSL cipher to use (implies --ssl).
  --ssl-key=name      X509 key in PEM format (implies --ssl).
  --ssl-verify-server-cert 
                      Verify server's "Common Name" in its cert against
                      hostname used when connecting. This option is disabled by
                      default.
  -T, --tab=name      Create tab-separated textfile for each table to given
                      path. (Create .sql and .txt files.) NOTE: This only works
                      if mysqldump is run on the same machine as the mysqld
                      server.
  --tables            Overrides option --databases (-B).
  --triggers          Dump triggers for each dumped table.
  --tz-utc            SET TIME_ZONE='+00:00' at top of dump to allow dumping of
                      TIMESTAMP data when a server has data in different time
                      zones or data is being moved between servers with
                      different time zones.
  -u, --user=name     User for login if not current user.
  -v, --verbose       Print info about the various stages.
  -V, --version       Output version information and exit.
  -w, --where=name    Dump only selected records. Quotes are mandatory.
  -X, --xml           Dump a database as well formed XML.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- -----------------------------
all                               TRUE
all-databases                     FALSE
all-tablespaces                   FALSE
no-tablespaces                    FALSE
add-drop-database                 FALSE
add-drop-table                    TRUE
add-locks                         TRUE
allow-keywords                    FALSE
character-sets-dir                (No default value)
comments                          TRUE
compatible                        (No default value)
compact                           FALSE
complete-insert                   FALSE
compress                          FALSE
create-options                    TRUE
databases                         FALSE
debug-check                       FALSE
debug-info                        FALSE
default-character-set             utf8
delayed-insert                    FALSE
delete-master-logs                FALSE
disable-keys                      TRUE
events                            FALSE
extended-insert                   TRUE
fields-terminated-by              (No default value)
fields-enclosed-by                (No default value)
fields-optionally-enclosed-by     (No default value)
fields-escaped-by                 (No default value)
first-slave                       FALSE
flush-logs                        FALSE
flush-privileges                  FALSE
force                             FALSE
hex-blob                          FALSE
host                              (No default value)
insert-ignore                     FALSE
lines-terminated-by               (No default value)
lock-all-tables                   FALSE
lock-tables                       TRUE
log-error                         (No default value)
master-data                       0
max_allowed_packet                16777216
net_buffer_length                 1046528
no-autocommit                     FALSE
no-create-db                      FALSE
no-create-info                    FALSE
no-data                           FALSE
order-by-primary                  FALSE
port                              3306
quick                             TRUE
quote-names                       TRUE
replace                           FALSE
routines                          FALSE
set-charset                       TRUE
single-transaction                FALSE
dump-date                         TRUE
socket                            /usr/local/mysql/tmp/mysql.sock
ssl                               FALSE
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-verify-server-cert            FALSE
tab                               (No default value)
triggers                          TRUE
tz-utc                            TRUE
user                              (No default value)
verbose                           FALSE
where                             (No default value)
[root@server db]#
```
 