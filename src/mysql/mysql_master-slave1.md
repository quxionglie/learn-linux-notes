# MySQL主从复制原理详解

2012年写的笔记，部分内容可能已经过时，仅供参考。

# 1	MySQL主从复制
## 1.1.	MySQL主从复制介绍
MySQL支持单向、链式级联、异步复制。在复制过程中，一个服务器充当主服务器(Master)，而一个或多个其它的服务器充当从服务器(Slave)。

如果设置了链式复制，那么，从服务器(Slave)服务器本身除了充当从服务器外，也会同时充当其下面从服务器的主服务器，链式级联复制类型A-->B-->C-->D的复制形式。

当配置好主从复制后，所有对数据库内容的更新必须在主服务器上进行，以避免用户对主服务器上数据库内容的更新与对从服务器上数据库内容更新之间发生冲突。生产环境中一般会忽略授权表的同步，然后对从服务器的用户授权select读权限或在my.cnf配置文件中加read-only参数来确保从库只读，当然二者同时操作效果更佳。

MySQL主从复制有利于数据库的健壮性、访问速度和系统维护管理。

## 1.2.	生产场景MySQL主从复制常用基本架构
TODO 画图

## 1.3.	MySQL主从复制原理介绍
MySQL的主从复制是一个异步复制过程，数据从Master数据库复制Slave数据库。在Master与Slave之间实现整个主从复制的过程中有三个线程参与完成。其中两个线程(SQL线程和IO线程)在Slave端，另外一个线程(IO线程)在Master端。

要实现MySQL主从复制，首先必须打开Master端的Binlog(MySQL-bin.xxxx)功能，否则无法实现主从复制。因为整个复制过程实际上就是从Master端获取Binlog日志，然后再在Slave自身以相同顺序执行binlog日志中所记录的各种操作。打开MySQL的Binlog可以通过在MySQL的配置文件my.cnf中的mysqld模块增加"log-bin"参数项。

## 1.4.	MySQL主从复制过程描述
(1)	Slave服务器上执行start slave，开启主从复制开关。

(2)	此时，Slave服务器的IO线程会通过在Master上授权的复制用户请求连接Master服务器，并请求从指定Binlog日志文件的指定位置(日志文件和位置就是在配置主从复制服务器执行change master命令时指定的)的Binlog日志内容。

(3)	Master服务器接收到来自Slave服务器的IO线程的请求后，Master服务器上负责复制的IO线程根据Slave线程请求的信息指定Binlog日志文件指定位置之后的Binlog日志信息，然后返回给Slave端的IO线程。返回的信息中除了日志内容外，还有本次返回的日志后在Master服务器端的新的Binlog文件名称以及在Binlog中的指定位置。

(4)	当Slave服务器的IO线程获取到来自Master服务器上IO线程发送日志内容及日志文件及位置点后，将Binlog日志依次写入到Slave端自身的Relay Log(即中继日志)文件(MySQL-relay-bin.xxxx)的最末端，并将新的Binlog文件名和位置记录到master-info文件中，以便下一次读取Master端新的binlog日志时能够告诉Master服务器需要从新Binlog日志的哪个文件哪个位置开始请求新的Binlog日志内容。

(5)	Slave服务器端的SQL线程会实时检测本地Relay Log中新增的日志内容，然后及时把Log 文件中内容的内容解析成在Master端曾经执行的SQL语句的内容，并在自身Slave服务器上按语句的顺序执行应用这些SQL语句。

(6)	经过上面的过程，就可以确保在Master端和Slave端执行了同样的SQL语句。当复制状态正常的情况下，Master和Slave端的数据完全一样的。
