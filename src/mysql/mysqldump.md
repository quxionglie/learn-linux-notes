# mysqldump


# 1.	mysqldump概述
mysqldump 是 mysql 的第三方工具。主要负责 mysql 数据库的导入导出工作。

常用导出语句：

(1)	导出结构不导出数据
```
mysqldump -uroot -p -d dbname  > xxx.sql
```
(2)	导出数据不导出结构
```
mysqldump -uroot -p -t dbname  > xxx.sql
```
(3)	导出数据和表结构
```
mysqldump -uroot -p dbname  > xxx.sql
```
(4)	4.导出特定表的结构
```
mysqldump -uroot -p -B dbname --table 表名 > xxx.sql
```

InnoDB和MyISAM引擎备份对比：

(1)	InnoDB引擎备份

InnoDB引擎为行锁，因此，备份时可以不对数据库加锁的操作，可以加选项--single-transaction进行备份：
```
mysqldump -A -F -B --single-transaction |gzip >/data/backup/$(date +%F).tar.gz
```
(2)	MyISAM引擎备份

由于MyISAM引擎为表级锁，因此，在备份时需要防止在备份期间数据写入而导致不一致，所以，在备份时使用--lock-all-tables加上读锁
```
mysqldump -A -F -B --lock-all-tables |gzip >/data/backup/$(date +%F).tar.gz
```
# 2.	mysqldump语法与参数说明
```
mysqldump [OPTIONS] database [tables]
mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
mysqldump [OPTIONS] --all-databases [OPTIONS]
```
```
mysqldump支持下列(参数OPTIONS)：
帮助
(1)	连接路径：
-u, --user=name
与服务器连接时，MySQL使用的用户名。缺省值是你的当前登录名。

-p, --password[=name]
与服务器连接时，MySQL使用的口令。缺省值是你的当前用户口令。

-h, --host=name
与服务器连接时，MySQL连接的数据库服务器IP。缺省主机是localhost。

-P, --port=#
与服务器连接时，MySQL数据库服务器使用的TCP/IP端口号。用于连接localhost以外的DB服务器时使用
(2)	数据筛选：
-A, --all-databases
选择所有的数据库

-B, --databases
指定操作数据库

--tables
指定操作表

-t, --no-create-info
只导出数据，而不添加CREATE TABLE语句。

-d, --no-data
不导出任何数据，只导出数据库表结构。

-w, --where=name
指定欲导出数据条件
(3)	字符集控制：
--default-character-set=name
指定导出数据时采用何种字符集，如果数据表不是采用默认的latin1字符集的话，那么导出时必须指定该选项，否则再次导入数据后将产生乱码问题。

--set-charset
在输出文件中添加“SET NAMES default_character_set”使用默认字符集，--skip-set-charset取消默认

(4)	输出控制：
--opt
这只是一个快捷选项，等同于同时添加--add-drop-table, --add-locks, --create-options, --quick,--extended-insert,--lock-tables,--set-charset,--disable-keys选项。本选项能让mysqldump很快的导出数据，并且导出的数据能很快导回。该选项默认开启，但可以用--skip-opt禁用。注意，如果运行mysqldump没有指定--quick或--opt选项，则会将整个结果集放在内存中。如果导出大数据库的话可能会出现问题。

-q, --quick
该选项在导出大表时很有用，它强制mysqldump从服务器查询取得记录直接输出而不是取得所有记录后将它们缓存到内存中。

-T, --tab=name
对于每个给定的表，创建一个table_name.sql文件，它包含SQL CREATE命令，和一个table_name.txt文件，它包含数据。注意：这只有在mysqldump运行在mysqld守护进程运行的同一台机器上的时候才工作。.txt文件的格式根据–fields-xxx和 –lines–xxx选项来定。

-c, --complete-insert
导出的数据采用包含字段名的完整INSERT方式，也就是把所有的值都写在一行。这么做能提高插入效率，但是可能会受到max_allowed_packet参数的影响而导致插入失败。因此，需要谨慎使用该参数。

(5)	其它常用参数：
-x, --lock-all-tables
在开始导出之前，提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭--single-transaction和--lock-tables选项。

-l, --lock-tables
它和--lock-all-tables类似，不过是锁定当前导出的数据表，而不是一下子锁定全部库下的表。本选项只适用于MyISAM表，如果是Innodb表可以用--single-transaction选项。

--single-transaction
该选项在导出数据之前提交一个BEGIN SQL语句，BEGIN不会阻塞任何应用程序且能保证导出时数据库的一致性状态。它只适用于事务表，例如InnoDB和BDB。本选项和--lock-tables选项是互斥的，因为LOCK TABLES会使任何挂起的事务隐含提交。要想导出大表的话，应结合使用--quick选项。

--add-drop-database
在创建数据库之前添加：DROP DATABASE语句

--add-drop-table
在每个create语句之前增加一个drop table

--add-locks
在每个表导出之前增加LOCK TABLES并且之后UNLOCK TABLE。(为了使得更快地插入到MySQL)。

-F --flush-logs
备份前刷新日志，通常结合锁定表参数使用

--compatible = name
它告诉mysqldump，导出的数据将和哪种数据库或哪个旧版本的MySQL服务器相兼容。值可以为ansi、mysql323、mysql40、postgresql、oracle、mssql、db2、maxdb、no_key_options、no_tables_options、no_field_options等，要使用几个值，用逗号将它们隔开。当然了，它并不保证能完全兼容，而是尽量兼容。
```
3.	mysqldump --help
```
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
#导出全部数据库。

-Y, --all-tablespaces
Dump all the tablespaces.
#导出全部表空间。
#mysqldump  -uroot -p --all-databases --all-tablespaces

-y, --no-tablespaces
Do not dump any tablespace information.#不导出任何表空间信息。
--add-drop-database Add a DROP DATABASE before each create.
#每个数据库创建之前添加drop数据库语句。

--add-drop-table    Add a DROP TABLE before each create.
#每个数据表创建之前添加drop数据表语句。(默认为打开状态，使用--skip-add-drop-table取消选项)
--add-locks         Add locks around INSERT statements.
#在每个表导出之前增加LOCK TABLES并且之后UNLOCK  TABLE。(默认为打开状态，使用--skip-add-locks取消选项)
#mysqldump  -uroot -p --all-databases  (默认添加LOCK语句)
#mysqldump  -uroot -p --all-databases –skip-add-locks   (取消LOCK语句)

--allow-keywords    Allow creation of column names that are keywords.
#允许创建是关键词的列名字。

--character-sets-dir=name
Directory for character set files.# 字符集文件的目录
-i, --comments      Write additional information.
#附加注释信息。默认为打开，可以用--skip-comments取消
#mysqldump  -uroot -p --all-databases  (默认记录注释)
#mysqldump  -uroot -p --all-databases --skip-comments   (取消注释)

--compatible=name   Change the dump to be compatible with a given mode. By
default tables are dumped in a format optimized for
MySQL. Legal modes are: ansi, mysql323, mysql40,
postgresql, oracle, mssql, db2, maxdb, no_key_options,
no_table_options, no_field_options. One can use several
modes separated by commas. Note: Requires MySQL server
version 4.1.0 or higher. This option is ignored with
earlier server versions.
#导出的数据将和其它数据库或旧版本的MySQL 相兼容。值可以为ansi、mysql323、mysql40、postgresql、oracle、mssql、db2、maxdb、no_key_options、no_tables_options、no_field_options等，
要使用几个值，用逗号将它们隔开。它并不保证能完全兼容，而是尽量兼容。
--compact           Give less verbose output (useful for debugging). Disables
structure comments and header/footer constructs.  Enables
options --skip-add-drop-table --skip-add-locks
--skip-comments --skip-disable-keys --skip-set-charset.
#导出更少的输出信息(用于调试)。去掉注释和头尾等结构。可以使用选项：--skip-add-drop-table  --skip-add-locks --skip-comments --skip-disable-keys --skip-set-charset

-c, --complete-insert
Use complete insert statements.
#使用完整的insert语句(包含列名称)。这么做能提高插入效率，但是可能会受到max_allowed_packet参数的影响而导致插入失败。
-C, --compress      Use compression in server/client protocol.
#在客户端和服务器之间启用压缩传递所有信息

-a, --create-options
Include all MySQL specific create options.
#在CREATE TABLE语句中包括所有MySQL特性选项。(默认为打开状态)


-B, --databases     Dump several databases. Note the difference in usage; in
this case no tables are given. All name arguments are
regarded as database names. 'USE db_name;' will be
included in the output.
#导出几个数据库。参数后面所有名字参量都被看作数据库名。

-#, --debug[=#]     This is a non-debug version. Catch this and exit.
--debug-check       Check memory and open file usage at exit.
#检查内存和打开文件使用说明并退出。
--debug-info        Print some debug info at exit.# 输出调试信息并退出
--default-character-set=name
Set the default character set. #设置默认字符集
--delayed-insert    Insert rows with INSERT DELAYED.
# 采用延时插入方式（INSERT DELAYED）导出数据

--delete-master-logs
Delete logs on master after backup. This automatically
enables --master-data.
#master备份后删除日志. 这个参数将自动激活--master-data。

-K, --disable-keys  '/*!40000 ALTER TABLE tb_name DISABLE KEYS */; and
'/*!40000 ALTER TABLE tb_name ENABLE KEYS */; will be put
in the output.
#对于每个表，用/*!40000 ALTER TABLE tbl_name DISABLE KEYS */;和/*!40000 ALTER TABLE tbl_name ENABLE KEYS */;语句引用INSERT语句。这样可以更快地导入dump出来的文件，因为它是在插入所有行后创建索引的。该选项只适合MyISAM表，默认为打开状态。

-E, --events        Dump events.# 导出事件。
-e, --extended-insert
Use multiple-row INSERT syntax that include several
VALUES lists.
#使用具有多个VALUES列的INSERT语法。这样使导出文件更小，并加速导入时的速度。默认为打开状态，使用--skip-extended-insert取消选项。
--fields-terminated-by=name
Fields in the output file are terminated by the given  string.
#导出文件中忽略给定字段。与--tab选项一起使用，不能用于--databases和--all-databases选项
--fields-enclosed-by=name
Fields in the output file are enclosed by the given character.
#输出文件中的各个字段用给定字符包裹。

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
#开始导出之前刷新日志。
#请注意：假如一次导出多个数据库(使用选项--databases或者--all-databases)，将会逐个数据库刷新日志。除使用--lock-all-tables或者--master-data外。在这种情况下，日志将会被刷新一次，相应的所以表同时被锁定。因此，如果打算同时导出和刷新日志应该使用--lock-all-tables 或者--master-data 和--flush-logs。
--flush-privileges  Emit a FLUSH PRIVILEGES statement after dumping the mysql
database.  This option should be used any time the dump
contains the mysql database and any other database that
depends on the data in the mysql database for proper
restore.
#在导出mysql数据库之后，发出一条FLUSH  PRIVILEGES 语句。为了正确恢复，该选项应该用于导出mysql数据库和依赖mysql数据库数据的任何时候。
-f, --force         Continue even if we get an SQL error.
#在导出过程中忽略出现的SQL错误。
-?, --help          Display this help message and exit.
--hex-blob          Dump binary strings (BINARY, VARBINARY, BLOB) in
hexadecimal format.
#使用十六进制格式导出二进制字符串字段。如果有二进制数据就必须使用该选项。影响到的字段类型有BINARY、VARBINARY、BLOB。
-h, --host=name     Connect to host.
--ignore-table=name Do not dump the specified table. To specify more than one
table to ignore, use the directive multiple times, once
for each table.  Each table must be specified with both
database and table names, e.g.,
--ignore-table=database.table.
#不导出指定表。指定忽略多个表时，需要重复多次，每次一个表。每个表必须同时指定数据库和表名。例如：--ignore-table=database.table1 --ignore-table=database.table2 ……
--insert-ignore     Insert rows with INSERT IGNORE.
--lines-terminated-by=name
Lines in the output file are terminated by the given string.
#输出文件的每行用给定字符串划分。

-x, --lock-all-tables
Locks all tables across all databases. This is achieved
by taking a global read lock for the duration of the
whole dump. Automatically turns --single-transaction and
--lock-tables off.
#提交请求锁定所有数据库中的所有表，以保证数据的一致性。这是一个全局读锁，并且自动关闭--single-transaction 和--lock-tables 选项。
-l, --lock-tables   Lock all tables for read.
--log-error=name    Append warnings and errors to given file.
#附加警告和错误信息到给定文件

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
#该选项将binlog的位置和文件名追加到输出文件中。如果为1，将会输出CHANGE MASTER 命令；如果为2，输出的CHANGE  MASTER命令前添加注释信息。该选项将打开--lock-all-tables 选项，除非--single-transaction也被指定（在这种情况下，全局读锁在开始导出时获得很短的时间；其他内容参考下面的--single-transaction选项）。该选项自动关闭--lock-tables选项。
mysqldump  -uroot -p --host=localhost --all-databases --master-data=1;
mysqldump  -uroot -p --host=localhost --all-databases --master-data=2;

--max_allowed_packet=#
The maximum packet length to send to or receive from server.
#服务器发送和接受的最大包长度。
--net_buffer_length=#
The buffer size for TCP/IP and socket communication.
# TCP/IP和socket连接的缓存大小。

--no-autocommit     Wrap tables with autocommit/commit statements.
#使用autocommit/commit 语句包裹表。
-n, --no-create-db  Suppress the CREATE DATABASE ... IF EXISTS statement that
normally is output for each dumped database if
--all-databases or --databases is given.
#只导出数据，而不添加CREATE DATABASE 语句。
-t, --no-create-info
Don't write table creation info.
#只导出数据，而不添加CREATE TABLE 语句。

-d, --no-data       No row information.
#不导出任何数据，只导出数据库表结构。

-N, --no-set-names  Suppress the SET NAMES statement
--opt               Same as --add-drop-table, --add-locks, --create-options,
--quick, --extended-insert, --lock-tables, --set-charset,
and --disable-keys. Enabled by default, disable with
--skip-opt.
#等同于--add-drop-table,  --add-locks, --create-options, --quick, --extended-insert, --lock-tables,  --set-charset, --disable-keys 该选项默认开启,  可以用--skip-opt禁用.

--order-by-primary  Sorts each table's rows by primary key, or first unique
key, if such a key exists.  Useful when dumping a MyISAM
table to be loaded into an InnoDB table, but will make
the dump itself take considerably longer.
#如果存在主键，或者第一个唯一键，对每个表的记录进行排序。在导出MyISAM表到InnoDB表时有效，但会使得导出工作花费很长时间。

-p, --password[=name]
Password to use when connecting to server. If password is
not given it's solicited on the tty.
-P, --port=#        Port number to use for connection.
--protocol=name     The protocol to use for connection (tcp, socket, pipe, memory).
#使用的连接协议，包括：tcp, socket, pipe, memory.
-q, --quick         Don't buffer query, dump directly to stdout.
#不缓冲查询，直接导出到标准输出。默认为打开状态，使用--skip-quick取消该选项。
-Q, --quote-names   Quote table and column names with backticks (`).
#使用（`）引起表和列名。默认为打开状态，使用--skip-quote-names取消该选项。
--replace           Use REPLACE INTO instead of INSERT INTO.
#使用REPLACE INTO 取代INSERT INTO.
-r, --result-file=name
Direct output to a given file. This option should be used
in MSDOS, because it prevents new line '\n' from being
converted to '\r\n' (carriage return + line feed).
#直接输出到指定文件中。该选项应该用在使用回车换行对（\\r\\n）换行的系统上（例如：DOS，Windows）。该选项确保只有一行被使用。
-R, --routines      Dump stored routines (functions and procedures).
#导出存储过程以及自定义函数。

--set-charset       Add 'SET NAMES default_character_set' to the output.
Enabled by default; suppress with --skip-set-charset.
#添加'SET NAMES  default_character_set'到输出文件。默认为打开状态，使用--skip-set-charset关闭选项。

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
#将导出时间添加到输出文件中。默认为打开状态，使用--skip-dump-date关闭选项。

--skip-opt          Disable --opt. Disables --add-drop-table, --add-locks,
--create-options, --quick, --extended-insert,
--lock-tables, --set-charset, and --disable-keys.
-S, --socket=name   The socket file to use for connection.
#指定连接mysql的socket文件位置，
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
#为每个表在给定路径创建tab分割的文本文件。注意：仅仅用于mysqldump和mysqld服务器运行在相同机器上。
--tables            Overrides option --databases (-B).
#覆盖--databases (-B)参数，指定需要导出的表名。
--triggers          Dump triggers for each dumped table.
#导出触发器。该选项默认启用，用--skip-triggers禁用它。
--tz-utc            SET TIME_ZONE='+00:00' at top of dump to allow dumping of
TIMESTAMP data when a server has data in different time
zones or data is being moved between servers with
different time zones.
#在导出顶部设置时区TIME_ZONE='+00:00' ，以保证在不同时区导出的TIMESTAMP 数据或者数据被移动其他时区时的正确性。
-u, --user=name     User for login if not current user.
-v, --verbose       Print info about the various stages.
-V, --version       Output version information and exit.
-w, --where=name    Dump only selected records. Quotes are mandatory.
#只转储给定的WHERE条件选择的记录。请注意如果条件包含命令解释符专用空格或字符，一定要将条件引用起来。
#mysqldump  -uroot -p --host=localhost --all-databases --where=” user=’root’”

-X, --xml           Dump a database as well formed XML.
#导出XML格式.
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