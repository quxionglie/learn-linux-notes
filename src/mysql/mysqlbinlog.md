# mysqlbinlog


# 1.	mysqlbinlog使用说明
## 1.1.	概述
服务器生成日志文件是二进制格式。要想检查这些文本格式的文件，应使用工具mysqlbinlog。

调用方式：
```
shell> mysqlbinlog [options] log-files...
```
例如，要想显示二进制日志binlog.000003的内容，使用下面的命令：
```
shell> mysqlbinlog binlog.0000003
```
输出包括在binlog.000003中包含的所有语句，以及其它信息例如每个语句花费的时间、客户发出的线程ID、发出线程时的时间戳等等。

通常情况，可以使用mysqlbinlog直接读取二进制日志文件并将它们用于本地MySQL服务器。也可以使用--read-from-remote-server选项从远程服务器读取二进制日志。

当读取远程二进制日志时，可以通过连接参数选项来指示如何连接服务器，但它们经常被忽略掉，除非你还指定了--read-from-remote-server选项。这些选项是--host、--password、--port、--protocol、--socket和--user。

还可以使用mysqlbinlog来读取在复制过程中从服务器所写的中继日志文件。中继日志格式与二进制日志文件相同。
## 1.2.	基于时间点的增量恢复
### 1.2.1.	指定开始时间和结束时间
```
mysqlbinlog mysql-bin.000002 --start-datetime="2012-09-01 00:00:00"  --stop-datetime="2012-09-02 14:00:00" -r time.sql
#显示2012-09-01 00:00:00 至 2012-09-02 14:00:00时间段的binlog,并输出到time.sql
```
### 1.2.2.	指定开始时间到文件结束
```
mysqlbinlog mysql-bin.000002 --start-datetime="2012-09-01 00:00:00"  -d oldboy -r time.sql
#只有开始时间,就是从2012-09-01 00:00:00 到日志结尾，oldboy数据库binlog输出
```
### 1.2.3.	从文件开头到指定时间结束
```
mysqlbinlog mysql-bin.000002  --stop-datetime="2012-09-02 14:00:00" -d oldboy
#没有结束时间，就是从日志开头到2012-09-02 14:00:00时刻截止，oldboy数据库binlog输出
```
## 1.3.	基于位置点的增量恢复
### 1.3.1.	指定开始位置和结束位置
```
mysqlbinlog  mysql-bin.000002  --start-position=106 --stop-position=534  -r pos.sql
#输出初始位置106，结束位置534的所有binlog日志到pos.sql
```
### 1.3.2.	指定开始位置到文件结束
```
mysqlbinlog  mysql-bin.000002 --stop-position=534  -r pos.sql
```
### 1.3.3.	从文件开头到指定位置结束
```
mysqlbinlog  mysql-bin.000002  --start-position=106   -r pos.sql
```
### 1.3.4.	指定开始位置和结束位置案例
```
# at 4  #起始点
#120902 19:49:03 server id 1  end_log_pos 106   Start: binlog v 4, server v 5.1.65-log created 120902 19:49:03
BINLOG '
r0dDUA8BAAAAZgAAAGoAAAAAAAQANS4xLjY1LWxvZwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAEzgNAAgAEgAEBAQEEgAAUwAEGggAAAAICAgC
'/*!*/;
# at 106 #结束点
```

# 2.	mysqlbinlog --help
```
#mysqlbinlog --help
mysqlbinlog Ver 3.3 for pc-linux-gnu at i686
Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Dumps a MySQL binary log in a format usable for viewing or for piping to
the mysql command line client.

Usage: mysqlbinlog [options] log-files
-?, --help          Display this help and exit.
--base64-output[=name]
Determine when the output statements should be
base64-encoded BINLOG statements: 'never' disables it and
works only for binlogs without row-based events;
'decode-rows' decodes row events into commented SQL
statements if the --verbose option is also given; 'auto'
prints base64 only when necessary (i.e., for row-based
events and format description events); 'always' prints
base64 whenever possible. 'always' is for debugging only
and should not be used in a production system. If this
argument is not given, the default is 'auto'; if it is
given with no argument, 'always' is used.
--character-sets-dir=name
Directory for character set files.
-d, --database=name List entries for just this database (local log only).
#只列出该数据库的条目(只用本地日志)。

--debug-check       Check memory and open file usage at exit .
--debug-info        Print some debug info at exit.
-D, --disable-log-bin
Disable binary log. This is useful, if you enabled
--to-last-log and are sending the output to the same
MySQL server. This way you could avoid an endless loop.
You would also like to use it when restoring after a
crash to avoid duplication of the statements you already
have. NOTE: you will need a SUPER privilege to use this
option.
#禁用二进制日志。如果使用--to-last-logs选项将输出发送给同一台MySQL服务器，可以避免无限循环。该选项在崩溃恢复时也很有用，可以避免复制已经记录的语句。注释：该选项要求有SUPER权限。

-F, --force-if-open Force if binlog was not closed properly.
-f, --force-read    Force reading unknown binlog events.
#使用该选项，如果mysqlbinlog读它不能识别的二进制日志事件，它会打印警告，忽略该事件并继续。没有该选项，如果mysqlbinlog读到此类事件则停止。

-H, --hexdump       Augment output with hexadecimal and ASCII event dump.
#在注释中显示日志的十六进制转储。该输出可以帮助复制过程中的调试。
-h, --host=name     Get the binlog from server.
#获取给定主机上的MySQL服务器的二进制日志。

-l, --local-load=name
Prepare local temporary files for LOAD DATA INFILE in the specified directory.
#为指定目录中的LOAD DATA INFILE预处理本地临时文件。
-o, --offset=#      Skip the first N entries. #跳过前N个条目。
-p, --password[=name]
Password to connect to remote server.
-P, --port=#        Port number to use for connection or 0 for default to, in
order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/services, built-in default (3306).
--position=#        Deprecated. Use --start-position instead.
#不赞成使用，应使用--start-position。

--protocol=name     The protocol to use for connection (tcp, socket, pipe,
memory).
#使用的连接协议。
-R, --read-from-remote-server
Read binary logs from a MySQL server.
#从MySQL服务器读二进制日志。如果未给出该选项，任何连接参数选项将被忽略。这些选项是--host、--password、--port、--protocol、--socket和--user。

-r, --result-file=name
Direct output to a given file.# 将输出指向给定的文件。

--server-id=#       Extract only binlog entries created by the server having
the given id.
--set-charset=name  Add 'SET NAMES character_set' to the output.
-s, --short-form    Just show regular queries: no extra info and no row-based
events. This is for testing only, and should not be used
in production systems. If you want to suppress
base64-output, consider using --base64-output=never
instead.

-S, --socket=name   The socket file to use for connection.
#用于连接的套接字文件。

--start-datetime=name
Start reading the binlog at first event having a datetime
equal or posterior to the argument; the argument must be
a date and time in the local time zone, in any format
accepted by the MySQL server for DATETIME and TIMESTAMP
types, for example: 2004-12-25 11:25:56 (you should
probably use quotes for your shell to set it properly).
#从二进制日志中第1个日期时间等于或晚于datetime参量的事件开始读取。datetime值相对于运行mysqlbinlog的机器上的本地时区。该值格式应符合DATETIME或TIMESTAMP数据类型。

-j, --start-position=#
Start reading the binlog at position N. Applies to the first binlog passed on the command line.

--stop-datetime=name
Stop reading the binlog at first event having a datetime
equal or posterior to the argument; the argument must be
a date and time in the local time zone, in any format
accepted by the MySQL server for DATETIME and TIMESTAMP
types, for example: 2004-12-25 11:25:56 (you should
probably use quotes for your shell to set it properly).
--stop-position=#   Stop reading the binlog at position N. Applies to the
last binlog passed on the command line.
-t, --to-last-log   Requires -R. Will not stop at the end of the requested
binlog but rather continue printing until the end of the
last binlog of the MySQL server. If you send the output
to the same MySQL server, that may lead to an endless
loop.
#在MySQL服务器中请求的二进制日志的结尾处不停止，而是继续打印直到最后一个二进制日志的结尾。如果将输出发送给同一台MySQL服务器，会导致无限循环。该选项要求--read-from-remote-server。
-u, --user=name     Connect to the remote server as username.
-v, --verbose       Reconstruct SQL statements out of row events. -v -v adds
comments on column data types.
-V, --version       Print version and exit.
--open_files_limit=#
Used to reserve file descriptors for use by this program.
#指定要保留的打开的文件描述符的数量。

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- -----------------------------
base64-output                     (No default value)
character-sets-dir                (No default value)
database                          (No default value)
debug-check                       FALSE
debug-info                        FALSE
disable-log-bin                   FALSE
force-if-open                     TRUE
force-read                        FALSE
hexdump                           FALSE
host                              (No default value)
local-load                        (No default value)
offset                            0
port                              3306
position                          4
read-from-remote-server           FALSE
server-id                         0
set-charset                       (No default value)
short-form                        FALSE
socket                            /usr/local/mysql/tmp/mysql.sock
start-datetime                    (No default value)
start-position                    4
stop-datetime                     (No default value)
stop-position                     18446744073709551615
to-last-log                       FALSE
user                              (No default value)
open_files_limit                  64
```
# 3.	二进制日志
二进制日志以一种更有效的格式，并且是事务安全的方式包含更新日志中可用的所有信息。

二进制日志包含了所有更新了数据或者已经潜在更新了数据（例如，没有匹配任何行的一个DELETE）的所有语句。语句以“事件”的形式保存，它描述数据更改。

注释：二进制日志已经代替了老的更新日志，更新日志在MySQL 5.1中不再使用。

二进制日志还包含关于每个更新数据库的语句的执行时间信息。它不包含没有修改任何数据的语句。

二进制日志的主要目的是在恢复使能够最大可能地更新数据库，因为二进制日志包含备份后进行的所有更新。

二进制日志还用于在主复制服务器上记录所有将发送给从服务器的语句。

运行服务器时若启用二进制日志则性能大约慢1%。但是，二进制日志的好处，即用于恢复并允许设置复制超过了这个小小的性能损失。

当用--log-bin[=file_name]选项启动时，mysqld写入包含所有更新数据的SQL命令的日志文件。如果未给出file_name值， 默认名为-bin后面所跟的主机名。如果给出了文件名，但没有包含路径，则文件被写入数据目录。建议指定一个文件名。

如果你在日志名中提供了扩展名(例如，--log-bin=file_name.extension)，则扩展名被悄悄除掉并忽略。

mysqld在每个二进制日志名后面添加一个数字扩展名。每次你启动服务器或刷新日志时该数字则增加。如果当前的日志大小达到max_binlog_size，还会自动创建新的二进制日志。如果你正使用大的事务，二进制日志还会超过max_binlog_size：事务全写入一个二进制日志中，绝对不要写入不同的二进制日志中。

为了能够知道还使用了哪个不同的二进制日志文件，mysqld还创建一个二进制日志索引文件，包含所有使用的二进制日志文件的文件名。默认情况下与二进制日志文件的文件名相同，扩展名为'.index'。你可以用--log-bin-index[=file_name]选项更改二进制日志索引文件的文件名。当mysqld在运行时，不应手动编辑该文件；如果这样做将会使mysqld变得混乱。

