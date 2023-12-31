# MySQL单实例的安装配置指南

2012年写的笔记，部分内容可能已经过时，仅供参考。

# 1.	mysql数据库的安装
## 1.1.	建立mysql账号
```
[root@stu412 ~]# groupadd mysql
[root@stu412 ~]# useradd -s /sbin/nologin -g mysql -M mysql

#检查用户
[root@stu412 ~]# tail -1 /etc/passwd
mysql:x:501:501::/home/mysql:/sbin/nologin

#建立mysql软件目录
[root@stu412 ~]# mkdir -p /home/oldboy/tools/
```
## 1.2.	编译安装mysql
### 1.2.3.	下载
```
[root@stu412 tools]# wget http://cdn.mysql.com/Downloads/MySQL-5.1/mysql-5.1.65.tar.gz
[root@stu412 tools]# cd /home/oldboy/tools/
[root@stu412 tools]# md5sum mysql-5.1.65.tar.gz
376967de2ec738eaec27f7dcf58c3c66  mysql-5.1.65.tar.gz
```
### 1.2.4.	安装
(1)	解压
```
[root@stu412 tools]# tar zxf mysql-5.1.65.tar.gz
[root@stu412 tools]# cd mysql-5.1.65
[root@stu412 mysql-5.1.65]#
```

(2)	配置(编译参数)
```
./configure \
--prefix=/usr/local/mysql \
--with-unix-socket-path=/usr/local/mysql/tmp/mysql.sock \
--localstatedir=/usr/local/mysql/data \
--enable-assembler \
--enable-thread-safe-client \
--with-mysqld-user=mysql \
--with-big-tables \
--without-debug \
--with-pthread \
--enable-assembler \
--with-extra-charsets=complex \
--with-readline \
--with-ssl \
--with-embedded-server \
--enable-local-infile \
--with-plugins=partition,innobase \
--with-plugin-PLUGIN \
--with-mysqld-ldflags=-all-static \
--with-client-ldflags=-all-static
```
可用./configure -–help查看各参数用途。具体注解说明请看附录1。

(3)	静态编译生成mysqld的执行文件
```
[root@stu412 mysql-5.1.65]# make
可执行make –j 4　加快mysql的编译，-j表示希望使用cpu的核数,使用不当可能会安装更慢。
```
(4)	安装mysql
```
[root@stu412 mysql-5.1.65]# make install
```
make 和 make install 中注意安装过程中是否报错(error)。
## 1.3.	获取mysql配置文件
```
[root@stu412 mysql-5.1.65]# ls -l support-files/*.cnf
-rw-r--r-- 1 root root  4714 Aug 12 12:51 support-files/my-huge.cnf
-rw-r--r-- 1 root root 19763 Aug 12 12:51 support-files/my-innodb-heavy-4G.cnf
-rw-r--r-- 1 root root  4688 Aug 12 12:51 support-files/my-large.cnf
-rw-r--r-- 1 root root  4699 Aug 12 12:51 support-files/my-medium.cnf
-rw-r--r-- 1 root root  2467 Aug 12 12:51 support-files/my-small.cnf
[root@stu412 mysql-5.1.65]# /bin/cp support-files/my-small.cnf /etc/my.cnf
#/bin/cp 拷贝不会出现替换提示，即使有重命名也会直接覆盖
```
### 1.3.1.	*.cnf配置文件对比
(1)	my-small.cnf：
```
# Example MySQL config file for small systems.
#
# This is for a system with little memory (<= 64M) where MySQL is only used
# from time to time and it's important that the mysqld daemon
# doesn't use much resources.
# 时常用于内存少于64M的系统,原因在于mysqld后台进程不需要太多的资源.
```
(2)	my-medium.cnf：
```
# Example MySQL config file for medium systems.
#
# This is for a system with little memory (32M - 64M) where MySQL plays
# an important part, or systems up to 128M where MySQL is used together with
# other programs (such as a web server)
#用于(32M - 64M)内存的系统中，并在其中扮演重要的角色。当系统升到128M内存时常与其它程序一起使用（如web服务器）
```
(3)	my-large.cnf：
```
# Example MySQL config file for large systems.
#
# This is for a large system with memory = 512M where the system runs mainly
# MySQL.
#用于512M内存的大系统，系统主要运行mysql。
```
(4)	my-huge.cnf：
```
# Example MySQL config file for very large systems.
#
# This is for a large system with memory of 1G-2G where the system runs mainly
# MySQL.
#用于1G-2G内存的大系统，系统主要运行mysql。
```
(5)	my-innodb-heavy-4G.cnf：
```
#BEGIN CONFIG INFO
#DESCR: 4GB RAM, InnoDB only, ACID, few connections, heavy queries
#TYPE: SYSTEM
#END CONFIG INFO

#
# This is a MySQL example config file for systems with 4GB of memory
# running mostly MySQL using InnoDB only tables and performing complex
# queries with few connections.
# 这是一个针对 4G 内存系统（主要运行只有 InnoDB 表的 MySQL 并使用几个连接数执行复杂的查询）的 MySQL 配置文件例子。
```
## 1.4.	创建mysql数据库文件
```
[root@stu412 mysql-5.1.65]# mkdir -p /usr/local/mysql/data
[root@stu412 mysql-5.1.65]# chown -R mysql.mysql /usr/local/mysql/
[root@stu412 mysql-5.1.65]# /usr/local/mysql/bin/mysql_install_db --user=mysql
Installing MySQL system tables...
120812 13:14:57 [Warning] '--skip-locking' is deprecated and will be removed in a future release. Please use '--skip-external-locking' instead.
# '--skip-locking'已经在未来的发行版本中废弃，请使用'--skip-external-locking'代替
OK
Filling help tables...
120812 13:14:57 [Warning] '--skip-locking' is deprecated and will be removed in a future release. Please use '--skip-external-locking' instead.
OK

To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system
# 你必须拷贝support-files/mysql.server在系统正确的地方，以便在系统启动时开启mysqld

PLEASE REMEMBER TO SET A PASSWORD FOR THE MySQL root USER !
To do so, start the server, then issue the following commands:
# 请记得为MySQL的root用户设置密码
# 做完上面后，启动服务时，你可以使用下面的命令。
/usr/local/mysql/bin/mysqladmin -u root password 'new-password'
/usr/local/mysql/bin/mysqladmin -u root -h stu412 password 'new-password'

Alternatively you can run:
# 另一种选择，你可以运行：
/usr/local/mysql/bin/mysql_secure_installation

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.
#这个会给你移除测试数据库和默认创建匿名用户的选项，强烈推荐用于生产服务器。
See the manual for more instructions.

You can start the MySQL daemon with:
#你可以以下面的方式以守护进程启动MySQL
cd /usr/local/mysql ; /usr/local/mysql/bin/mysqld_safe &

You can test the MySQL daemon with mysql-test-run.pl
#　你可以使用mysql-test-run.pl测试MySQL守护进程
cd /usr/local/mysql/mysql-test ; perl mysql-test-run.pl

Please report any problems with the /usr/local/mysql/bin/mysqlbug script!
#　请使用/usr/local/mysql/bin/mysqlbug脚本报告任何问题
```
## 1.5.	启动mysql
启动方法1：mysql.server
```
#拷贝mysql启动脚本到mysql的命令路径
[root@stu412 mysql-5.1.65]# cp support-files/mysql.server /usr/local/mysql/bin/
[root@stu412 mysql-5.1.65]# chmod 700 /usr/local/mysql/bin/mysql.server

#启动mysql
[root@stu412 mysql-5.1.65]# /usr/local/mysql/bin/mysql.server start
Starting MySQL.[  OK  ]
[root@stu412 mysql-5.1.65]#
[root@stu412 mysql-5.1.65]# netstat -lnt | grep 3306
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN  
[root@stu412 mysql-5.1.65]# /usr/local/mysql/bin/mysql.server stop
Shutting down MySQL....[  OK  ]
[root@stu412 mysql-5.1.65]# netstat -lnt | grep 3306
[root@stu412 mysql-5.1.65]#
#要想使用方法2启动mysql,需执行/usr/local/mysql/bin/mysql.server stop或killall mysqld(生产环境尽量不要使用killall)结束mysql进程

[root@stu412 mysql-5.1.65]# cp ./support-files/mysql.server /etc/init.d/mysqld
[root@server mysql-5.1.65]# /etc/init.d/mysqld start
```

启动方法2：mysqld_safe
```
[root@stu412 mysql-5.1.65]# /usr/local/mysql/bin/mysqld_safe --user=mysql &
[1] 19291
[root@stu412 mysql-5.1.65]# 120812 13:23:03 mysqld_safe Logging to '/usr/local/mysql/data/stu412.err'.
120812 13:23:03 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/data
#这里再敲回车进入命令行状态


检查mysql是否启动
#查看端口
[root@stu412 mysql-5.1.65]# netstat -lnt | grep 3306
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN

#查看进程
[root@stu412 mysql-5.1.65]# ps -ef | grep mysql
root      3732  3152  0 13:30 pts/0    00:00:00 grep mysql
root     19291  3152  0 13:23 pts/0    00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --user=mysql
mysql    19391 19291  0 13:23 pts/0    00:00:00 /usr/local/mysql/libexec/mysqld --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql --log-error=/usr/local/mysql/data/stu412.err --pid-file=/usr/local/mysql/data/stu412.pid --socket=/usr/local/mysql/tmp/mysql.sock --port=3306
#查看错误日志
#如果发现3306端口没起来，请tail -100 /usr/local/mysql/data/机器名.err检查日志。
[root@stu412 mysql-5.1.65]# tail -10 /usr/local/mysql/data/stu412.err
120812 13:22:07 mysqld_safe mysqld from pid file /usr/local/mysql/data/stu412.pid ended
120812 13:23:03 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/data
120812 13:23:03 [Warning] '--skip-locking' is deprecated and will be removed in a future release. Please use '--skip-external-locking' instead.
120812 13:23:03  InnoDB: Initializing buffer pool, size = 8.0M
120812 13:23:03  InnoDB: Completed initialization of buffer pool
120812 13:23:03  InnoDB: Started; log sequence number 0 44233
120812 13:23:03 [Note] Event Scheduler: Loaded 0 events
120812 13:23:03 [Note] /usr/local/mysql/libexec/mysqld: ready for connections.
Version: '5.1.65'  socket: '/usr/local/mysql/tmp/mysql.sock'  port: 3306  Source distribution
```
## 1.6.	配置mysql的全局路径
方法1：
```
#echo 'export PATH=$PATH:/usr/local/mysql/bin' >>/etc/profile
#source /etc/profile
```
方法2：把/usr/local/mysql/bin下面的命令拷贝到/usr/local/sbin下
```
#/bin/cp /usr/local/mysql/bin/* /usr/local/sbin/


[root@stu412 mysql-5.1.65]# mysql		#找不到命令
-bash: mysql: command not found


[root@stu412 mysql-5.1.65]# echo 'export PATH=$PATH:/usr/local/mysql/bin' >>/etc/profile
#echo后要使用单引号,双引号不行,原因如下：
[root@stu412 mysql-5.1.65]#  echo 'export PATH=$PATH:/usr/local/mysql/bin'
export PATH=$PATH:/usr/local/mysql/bin
[root@stu412 mysql-5.1.65]#  echo "export PATH=$PATH:/usr/local/mysql/bin"
export PATH=/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/mysql/bin:/usr/local/mysql/bin


[root@stu412 mysql-5.1.65]# source /etc/profile	#使用内容生效
[root@stu412 mysql-5.1.65]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.1.65 Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> quit
Bye
[root@stu412 mysql-5.1.65]#
[root@stu412 mysql-5.1.65]# echo $PATH
/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/mysql/bin
```
## 1.7.	配置/etc/init.d/mysqld start方式启动数据库
```
[root@stu412 mysql-5.1.65]# cp support-files/mysql.server /etc/init.d/mysqld
[root@stu412 mysql-5.1.65]# chmod 700 /etc/init.d/mysqld
[root@stu412 mysql-5.1.65]# /etc/init.d/mysqld restart


#设置mysql开机启动
[root@stu412 mysql-5.1.65]# chkconfig --add mysqld
[root@stu412 mysql-5.1.65]# chkconfig mysqld on
[root@stu412 mysql-5.1.65]# chkconfig --list mysqld
mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off

```
## 1.8.	测试mysql
```
[root@stu412 mysql-5.1.65]# mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.1.65 Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| test               |
+--------------------+
3 rows in set (0.03 sec)

mysql> select user();
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+
1 row in set (0.03 sec)

mysql> quit
Bye
```
## 1.9.	mysql安全配置
### 1.9.1.	为root增加密码
```
#更改mysql中root的密码为123456
[root@stu412 mysql-5.1.65]# mysqladmin -u root password '123456'

[root@stu412 mysql-5.1.65]# mysql #现在不能直接进去了
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
[root@stu412 mysql-5.1.65]# mysql -u root -p
Enter password:	#这里输入密码
```
### 1.9.2.	查看并清理多余用户
```
[root@stu412 mysql-5.1.65]# mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.1.65 Source distribution

Copyright (c) 2000, 2011, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select user, host from mysql.user;
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
|      | localhost |
| root | localhost |
|      | stu412    |
| root | stu412    |
+------+-----------+
5 rows in set (0.03 sec)

mysql> drop user ""@localhost;\
Query OK, 0 rows affected (0.07 sec)

mysql> drop user ""@stu412;
Query OK, 0 rows affected (0.00 sec)

mysql> drop user root@stu412;
Query OK, 0 rows affected (0.00 sec)

mysql> select user, host from mysql.user;
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
| root | localhost |
+------+-----------+
2 rows in set (0.00 sec)

mysql>
```


# 附录1：./configure -–help解读
```
本文configure 参数：
./configure \
--prefix=/usr/local/mysql \
--with-unix-socket-path=/usr/local/mysql/tmp/mysql.sock \
--localstatedir=/usr/local/mysql/data \
--enable-assembler \
--enable-thread-safe-client \
--with-mysqld-user=mysql \
--with-big-tables \
--without-debug \
--with-pthread \
--enable-assembler \
--with-extra-charsets=complex \
--with-readline \
--with-ssl \
--with-embedded-server \
--enable-local-infile \
--with-plugins=partition,innobase \
--with-plugin-PLUGIN \
--with-mysqld-ldflags=-all-static \
--with-client-ldflags=-all-static


[root@server mysql-5.1.65]# ./configure --help
`configure' configures MySQL Server 5.1.65 to adapt to many kinds of systems.

Usage(用法): ./configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
-h, --help              display this help and exit
--help=short        display options specific to this package
--help=recursive    display the short help of all the included packages
-V, --version           display version information and exit
-q, --quiet, --silent   do not print `checking...' messages
--cache-file=FILE   cache test results in FILE [disabled]
-C, --config-cache      alias for `--cache-file=config.cache'
-n, --no-create         do not create output files
--srcdir=DIR        find the sources in DIR [configure dir or `..']

Installation directories:	#安装目录
--prefix=PREFIX         install architecture-independent files in PREFIX
[/usr/local]
#安装路径,默认[/usr/local]

--exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
[PREFIX]
#执行文件路径，默认是PREFIX

By default, `make install' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=$HOME'.
#默认情况下，`make install'会安装所有文件在"/usr/local/bin","/usr/local/lib"等，你可以"--prefix"指定安装前辍覆盖"/usr/local",例如"--prefix=$HOME "。

For better control, use the options below.
#为了更好的控制，你可以用下面的选项。

Fine tuning of the installation directories:
--bindir=DIR            user executables [EPREFIX/bin]
--sbindir=DIR           system admin executables [EPREFIX/sbin]
--libexecdir=DIR        program executables [EPREFIX/libexec]
--sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
--sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
--localstatedir=DIR     modifiable single-machine data [PREFIX/var]
#可修改的单机数据(数据库文件存放路径),默认[PREFIX/var]

--libdir=DIR            object code libraries [EPREFIX/lib]
--includedir=DIR        C header files [PREFIX/include]
--oldincludedir=DIR     C header files for non-gcc [/usr/include]
--datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
--datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
--infodir=DIR           info documentation [DATAROOTDIR/info]
--localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
--mandir=DIR            man documentation [DATAROOTDIR/man]
--docdir=DIR            documentation root [DATAROOTDIR/doc/mysql]
--htmldir=DIR           html documentation [DOCDIR]
--dvidir=DIR            dvi documentation [DOCDIR]
--pdfdir=DIR            pdf documentation [DOCDIR]
--psdir=DIR             ps documentation [DOCDIR]

Program names:
--program-prefix=PREFIX            prepend PREFIX to installed program names
--program-suffix=SUFFIX            append SUFFIX to installed program names
--program-transform-name=PROGRAM   run sed PROGRAM on installed program names

System types:
--build=BUILD     configure for building on BUILD [guessed]
--host=HOST       cross-compile to build programs to run on HOST [BUILD]
--target=TARGET   configure for building compilers for TARGET [HOST]

Optional Features:
--disable-option-checking  ignore unrecognized --enable/--with options
--disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
--enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
--enable-shared[=PKGS]  build shared libraries [default=yes]
--enable-static[=PKGS]  build static libraries [default=yes]
--enable-fast-install[=PKGS]
optimize for fast installation [default=yes]
--disable-dependency-tracking  speeds up one-time build
--enable-dependency-tracking   do not reject slow dependency extractors
--disable-libtool-lock  avoid locking (might break parallel builds)
--enable-mysql-maintainer-mode
Enable a MySQL maintainer-specific development
environment
--disable-community-features
Disable additional features provided by the user
community.
--disable-thread-safe-client
Compile the client without threads.
--enable-assembler      Use assembler versions of some string
functions if available.
#如果可以，某些字符串函数使用汇编版本
--enable-profiling      Build a version with query profiling code (req.
community-features)
--enable-local-infile   Enable LOAD DATA LOCAL INFILE (default: disabled)
#启用LOAD DATA LOCAL INFILE,(默认是关闭的)
--disable-grant-options Disables the use of --init-file, --skip-grant-tables and --bootstrap options
--disable-largefile     Omit support for large files
--enable-debug-sync     Build a version with Debug Sync Facility

Optional Packages:
--with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
--without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
--with-pic              try to use only PIC/non-PIC objects [default=use
both]
--with-gnu-ld           assume the C compiler uses GNU ld [default=no]
--with-charset=CHARSET
Default character set, use one of:
binary
armscii8 ascii big5 cp1250 cp1251 cp1256 cp1257
cp850 cp852 cp866 cp932 dec8 eucjpms euckr gb2312 gbk geostd8
greek hebrew hp8 keybcs2 koi8r koi8u
latin1 latin2 latin5 latin7 macce macroman
sjis swe7 tis620 ucs2 ujis utf8
--with-collation=COLLATION
Default collation
--with-extra-charsets=CHARSET,CHARSET,...
Use charsets in addition to default (none, complex,
all, or a list selected from the above sets)
--without-uca           Skip building of the national Unicode collations.

--with-debug[=full]     Enable various amounts of debugging support (full
adds a slow memory checker).
--with-system-type      Set the system type, like "sun-solaris10"
--with-machine-type     Set the machine type, like "powerpc"
--with-darwin-mwcc      Use Metrowerks CodeWarrior wrappers on OS X/Darwin
--with-other-libc=DIR   Link against libc and other standard libraries
installed in the specified non-standard location
overriding default. Originally added to be able to
link against glibc 2.2 without making the user
upgrade the standard libc installation.
--with-server-suffix    Append value to the version string.
--with-pthread          Force use of pthread library.#强制使用pthread库

--with-named-thread-libs=ARG
Use specified thread libraries instead of
those automatically found by configure.
--with-named-curses-libs=ARG
Use specified curses libraries instead of
those automatically found by configure.
--with-unix-socket-path=SOCKET
Where to put the unix-domain socket.  SOCKET must be
an absolute file name.
--with-tcp-port=port-number
Which port to use for MySQL services (default 3306)
--with-mysqld-user=username
What user the mysqld daemon shall be run as.
# mysqld守护进程以何用户身份运行
--with-zlib-dir=no|bundled|DIR
Provide MySQL with a custom location of compression
library. Given DIR, zlib binary is assumed to be in
$DIR/lib and header files in $DIR/include.
--with-libwrap=DIR      Compile in libwrap (tcp_wrappers) support
--with-valgrind         Valgrind instrumentation [default=no]
--with-error-inject     Enable error injection in MySQL Server
--with-fast-mutexes     Compile with fast mutexes (default is disabled)
--with-atomic-ops=rwlocks|smp|up
Implement atomic operations using pthread rwlocks or
atomic CPU instructions for multi-processor
(default) or uniprocessor configuration
--with-mysqld-ldflags   Extra linking arguments for mysqld   	#额外链接参数
--with-client-ldflags   Extra linking arguments for clients  	#额外链接参数
--with-mysqld-libs   Extra libraries to link with for mysqld
--with-lib-ccflags      Extra CC options for libraries
--with-low-memory       Try to use less memory to compile to avoid
memory limitations.
--with-comment          Comment about compilation environment.
--with-big-tables       Support tables with more than 4 G rows even on 32
bit platforms
#支持超过4G行的表，甚至在32位系统上也可以。
--with-max-indexes=N    Sets the maximum number of indexes per table,
default 64
--with-ssl=DIR    Include SSL support #包含ssl支持
--with-plugins=PLUGIN[[[,PLUGIN..]]] #包含在mysqld的插件
Plugins to include in mysqld. (default is: none)
Must be a configuration name or a comma separated
list of plugins.
Available configurations are: none max max-no-ndb
all.
Available plugins are: partition daemon_example
ftexample archive blackhole csv example federated
heap innobase innodb_plugin myisam myisammrg
ndbcluster.
--without-plugin-PLUGIN Disable the named plugin from being built.
Otherwise, for plugins which are not selected for
inclusion in mysqld will be built dynamically (if
supported)
--with-plugin-PLUGIN    Forces the named plugin to be linked into mysqld
statically.
--with-ndb-sci=DIR      Provide MySQL with a custom location of sci library.
Given DIR, sci library is assumed to be in $DIR/lib
and header files in $DIR/include.

--with-ndb-test       Include the NDB Cluster ndbapi test programs

--with-ndb-docs       Include the NDB Cluster ndbapi and mgmapi documentation

--with-ndb-port       Port for NDB Cluster management server

--with-ndb-port-base  Base port for NDB Cluster transporters

--without-ndb-debug   Disable special ndb debug features
--with-ndb-ccflags=CFLAGS
Extra CFLAGS for ndb compile

--without-ndb-binlog       Disable ndb binlog
--without-server        Only build the client.
--with-embedded-server  Build the embedded server (libmysqld).#生成内嵌服务器
--without-query-cache   Do not build query cache.
--without-geometry      Do not build geometry-related parts.
--with-embedded-privilege-control
Build parts to check user's privileges.
Only affects embedded library.
--with-mysqlmanager     Build the mysqlmanager binary: yes/no (default:
build if server is built.)
--without-docs          Skip building of the documentation.
--without-man          Skip building of the man pages.
--without-readline      Use system readline instead of bundled copy.
--without-libedit       Use system libedit instead of bundled copy.

Some influential environment variables:
CC          C compiler command
CFLAGS      C compiler flags
LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
nonstandard directory <lib dir>
LIBS        libraries to pass to the linker, e.g. -l<library>
CPPFLAGS    C/C++/Objective C preprocessor flags, e.g. -I<include dir> if
you have headers in a nonstandard directory <include dir>
CPP         C preprocessor
CXX         C++ compiler command
CXXFLAGS    C++ compiler flags
CXXCPP      C++ preprocessor
CCAS        assembler compiler command (defaults to CC)
CCASFLAGS   assembler compiler flags (defaults to CFLAGS)

Use these variables to override the choices made by `configure' or to help
it to find libraries and programs with nonstandard names/locations.

Description of plugins:
#插件描述
=== Partition Support === #分区支持
Plugin Name:      partition
Description:      MySQL Partitioning Support
Supports build:   static
Configurations:   max, max-no-ndb

=== Daemon Example Plugin ===
Plugin Name:      daemon_example
Description:      This is an example plugin daemon.
Supports build:   dynamic

=== Simple Parser ===
Plugin Name:      ftexample
Description:      Simple full-text parser plugin
Supports build:   dynamic

=== Archive Storage Engine ===
Plugin Name:      archive
Description:      Archive Storage Engine
Supports build:   static and dynamic
Configurations:   max, max-no-ndb

=== Blackhole Storage Engine === #黑洞存储引擎
Plugin Name:      blackhole
Description:      Basic Write-only Read-never tables #只写不能读的表
Supports build:   static and dynamic
Configurations:   max, max-no-ndb

=== CSV Storage Engine ===		#CSV存储引擎
Plugin Name:      csv
Description:      Stores tables in text CSV format	#使用CSV文本格式存储表
Supports build:   static
Status:           mandatory

=== Example Storage Engine ===
Plugin Name:      example
Description:      Example for Storage Engines for developers
Supports build:   dynamic
Configurations:   max, max-no-ndb

=== Federated Storage Engine ===
Plugin Name:      federated
Description:      Connects to tables on remote MySQL servers
Supports build:   static and dynamic
Configurations:   max, max-no-ndb

=== Memory Storage Engine === #内存存储引擎
Plugin Name:      heap
Description:      Volatile memory based tables
Supports build:   static
Status:           mandatory

=== InnoDB Storage Engine ===	# InnoDB存储引擎
Plugin Name:      innobase
Description:      Transactional Tables using InnoDB
Supports build:   static and dynamic
Configurations:   max, max-no-ndb

=== InnoDB Storage Engine ===
Plugin Name:      innodb_plugin
Description:      Transactional Tables using InnoDB
Supports build:   dynamic
Configurations:   max, max-no-ndb

=== MyISAM Storage Engine ===
Plugin Name:      myisam
Description:      Traditional non-transactional MySQL tables
Supports build:   static
Status:           mandatory

=== MyISAM MERGE Engine ===
Plugin Name:      myisammrg
Description:      Merge multiple MySQL tables into one
Supports build:   static
Status:           mandatory

=== Cluster Storage Engine === #集群存储引擎
Plugin Name:      ndbcluster
Description:      High Availability Clustered tables
Supports build:   static
Configurations:   max
附录2：my-innodb-heavy-4G.cnf解读
[root@server support-files]# cat my-innodb-heavy-4G.cnf
#BEGIN CONFIG INFO
#DESCR: 4GB RAM, InnoDB only, ACID, few connections, heavy queries
#描述：4GB 内存、只有 InnoDB、ACID、很少连接数、繁重的查询
#TYPE: SYSTEM
#END CONFIG INFO

#
# This is a MySQL example config file for systems with 4GB of memory
# running mostly MySQL using InnoDB only tables and performing complex
# queries with few connections.
# 这是一个针对 4G 内存系统（主要运行只有 InnoDB 表的 MySQL 并使用几个连接数执行复杂的查询）的 MySQL 配置文件例子。

# MySQL programs look for option files in a set of
# locations which depend on the deployment platform.
# You can copy this option file to one of those
# locations. For information about these locations, see:
# http://dev.mysql.com/doc/mysql/en/option-files.html
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.
#
# More detailed information about the individual options can also be
# found in the manual.
#

#
# The following options will be read by MySQL client applications.
# Note that only client applications shipped by MySQL are guaranteed
# to read this section. If you want your own MySQL client program to
# honor these values, you need to specify it as an option during the
# MySQL client library initialization.
# 下面的选项将被 MySQL 客户端应用程序所读取。
# 注意，只有 MySQL 标准的客户端应用程序是被保证能读取到该章节的。
# 如果你希望你自己的 MySQL 客户端程序能够承兑这些值，你需要在 MySQL 客户端库初始化中作为一个选项来指定它。

[client]
#password       = [your_password]
port            = 3306
socket          = /usr/local/mysql/tmp/mysql.sock

# *** Application-specific options follow here ***
# *** 应用程序特定的选项在下面 ***
#
# The MySQL server
#
[mysqld]

# generic configuration options
# 通用配置选项
port            = 3306
socket          = /usr/local/mysql/tmp/mysql.sock

# back_log is the number of connections the operating system can keep in
# the listen queue, before the MySQL connection manager thread has
# processed them. If you have a very high connection rate and experience
# "connection refused" errors, you might need to increase this value.
# Check your OS documentation for the maximum value of this parameter.
# Attempting to set back_log higher than your operating system limit
# will have no effect.
# back_log 是指保持在操作系统监听队列中的连接数量，即在 MySQL 连接管理器线程处理它们之前的连接数量。
# 如果你有一个非常高的连接率并见到过“拒绝连接”的错误，你可能需要提高该值。
# 检查你的操作系统文档中该参数的最大值。
# 试图将 back_log 设置得高于你操作系统的限制将不会起到任何作用。
back_log = 50

# Don't listen on a TCP/IP port at all. This can be a security
# enhancement, if all processes that need to connect to mysqld run
# on the same host.  All interaction with mysqld must be made via Unix
# sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
# 根本不用监听一个 TCP/IP 端口。
# 如果运行在相同主机上的所有进程都需要连接到 mysqld，这可能是一个安全增强。
# 所有与 mysqld 的互动都必须通过 Unix sockets（套接字）或命名管道进行。
# 注意，在 Windows 上使用该选项但却不启用命名管道（通过“enable-named-pipe”选项）将使得 mysqld 变得无用。
#skip-networking

# The maximum amount of concurrent sessions the MySQL server will
# allow. One of these connections will be reserved for a user with
# SUPER privileges to allow the administrator to login even if the
# connection limit has been reached.
# MySQL 允许的并发会话的最大数量。
# 其中的一个连接将被保留给拥有 SUPER 特权的用户，即使已经到达了连接限制，仍可以允许管理者登录。
max_connections = 100

# Maximum amount of errors allowed per host. If this limit is reached,
# the host will be blocked from connecting to the MySQL server until
# "FLUSH HOSTS" has been run or the server was restarted. Invalid
# passwords and other errors during the connect phase result in
# increasing this value. See the "Aborted_connects" status variable for
# global counter.
# 每个主机允许的最大错误数量。
# 如果已到达该限制，主机将阻止对 MySQL 服务器的连接，直到运行“FLUSH HOSTS”或者服务器被重启。
# 在连接阶段的无效密码和其它错误将导致该值被提高。
# 请看全局计数器的“Aborted_connects”状态变量。
max_connect_errors = 10

# The number of open tables for all threads. Increasing this value
# increases the number of file descriptors that mysqld requires.
# Therefore you have to make sure to set the amount of open files
# allowed to at least 4096 in the variable "open-files-limit" in
# section [mysqld_safe]
# 所有线程打开表的数量。
# 提高该值将提高 mysqld 需要的文件描述符的数量。
# 因此，你必须确定要设置的打开文件数量，在“mysqld 安全”章节的“open-file-limit”变量中，允许到至少为 4096。
table_open_cache = 2048

# Enable external file level locking. Enabled file locking will have a
# negative impact on performance, so only use it in case you have
# multiple database instances running on the same files (note some
# restrictions still apply!) or if you use other software relying on
# locking MyISAM tables on file level.
# 启用外部文件级锁定。
# 启用文件锁定将有一个性能上的负面影响，因此，只有在如果你有多个数据库实例运行在相同的文件上（注意，有些限制仍旧被应用）或者如果你使用其它软件依靠在文件级上锁定 MyISAM 表时，才使用。
#external-locking

# The maximum size of a query packet the server can handle as well as
# maximum query size server can process (Important when working with
# large BLOBs).  enlarged dynamically, for each connection.
# 服务器可以处理的一个查询包的最大容量，以及服务器可以处理的最大查询大小（当工作在大型 BLOB 字段时很重要）。
# 动态扩大，对于每一个连接。
max_allowed_packet = 16M

# The size of the cache to hold the SQL statements for the binary log
# during a transaction. If you often use big, multi-statement
# transactions you can increase this value to get more performance. All
# statements from transactions are buffered in the binary log cache and
# are being written to the binary log at once after the COMMIT.  If the
# transaction is larger than this value, temporary file on disk is used
# instead.  This buffer is allocated per connection on first update
# statement in transaction
# 在一个事务中能够为二进制日志 SQL 语句保持的缓存大小。
# 如果你经常使用大的、多语句的事务，你可以提高该值以获得更好的性能。
# 来自事务的所有语句被缓冲到二进制日志缓存，并在 COMMIT 之后立即被写入到二进制日志中。
# 如果事务大于该值，磁盘上的临时文件将被替代使用。
# 该缓冲在事务中第一个更新语句中，被分配给每个连接。
binlog_cache_size = 1M

# Maximum allowed size for a single HEAP (in memory) table. This option
# is a protection against the accidential creation of a very large HEAP
# table which could otherwise use up all memory resources.
# 一个单一的 HEAP（在内存中）表的最大允许大小。
# 该选项对偶然创建的一个非常大的 HEAP 表起保护作用，否则它将会使用完所有的内存资源。
max_heap_table_size = 64M

# Size of the buffer used for doing full table scans.
# Allocated per thread, if a full scan is needed.
# 使用全表扫描时的缓存大小
# 如果全表扫描是需要的，将分配给每个线程。
read_buffer_size = 2M

# When reading rows in sorted order after a sort, the rows are read
# through this buffer to avoid disk seeks. You can improve ORDER BY
# performance a lot, if set this to a high value.
# Allocated per thread, when needed.
# 当在一个有序的排序中读取行时，可以通过该缓冲区来读取行，以避免对磁盘的查找。
# 如果将该值设置为一个很高的值，你可以大幅度提高 ORDER BY 的性能。
# 当需要时，分配给每个线程。
read_rnd_buffer_size = 16M

# Sort buffer is used to perform sorts for some ORDER BY and GROUP BY
# queries. If sorted data does not fit into the sort buffer, a disk
# based merge sort is used instead - See the "Sort_merge_passes"
# status variable. Allocated per thread if sort is needed.
# 排序缓冲被用来执行一些 ORDER BY 和 GROUP BY 查询的排序。
# 如果已排序的数据没有进入到排序缓冲，一个基于磁盘的合并排序将被替代使用
# - 请看“Sort_merge_passes”状态变量。
# 如果排序是需要的，将分配给每个线程。
sort_buffer_size = 8M

# This buffer is used for the optimization of full JOINs (JOINs without
# indexes). Such JOINs are very bad for performance in most cases
# anyway, but setting this variable to a large value reduces the
# performance impact. See the "Select_full_join" status variable for a
# count of full JOINs. Allocated per thread if full join is found
# 该缓冲被用来优化 FULL JOIN（没有索引的 JOIN）。
# 无论如何，该 JOIN 在大多数情况下对性能是非常坏的，但是设置该变量为一个大值将减少对性能的影响。
# 请看针对一定数量的 FULL JOIN 的“Select_full_join”状态变量。
# 如果 FULL JOIN 被发现，将分配给每个线程。
join_buffer_size = 8M

# How many threads we should keep in a cache for reuse. When a client
# disconnects, the client's threads are put in the cache if there aren't
# more than thread_cache_size threads from before.  This greatly reduces
# the amount of thread creations needed if you have a lot of new
# connections. (Normally this doesn't give a notable performance
# improvement if you have a good thread implementation.)
# 我们保持在一个缓存中的可重用的线程有多少。
# 当一个客户端断开连接时，如果在这之前的线程没有超过 thread_cache_size，客户端的线程将放在缓存中。
# 如果你有很多新的连接，这将大幅减少创建所需线程的数量。
# （如果你有一个很好的线程实现，这通常不会带来一个显著的性能提升。）
thread_cache_size = 8

# This permits the application to give the threads system a hint for the
# desired number of threads that should be run at the same time.  This
# value only makes sense on systems that support the thread_concurrency()
# function call (Sun Solaris, for example).
# You should try [number of CPUs]*(2..4) for thread_concurrency
# 这允许应用程序给予线程系统一个针对运行在相同时间的线程所需数量的提示。
# 该值只在支持 thread_concurrency() 函数调用的系统上有意义（例如 Sun Solaris）。
# 你应该对 thread_concurrency 尝试 CPU 数量的 2/4/6/... 倍。
thread_concurrency = 8

# Query cache is used to cache SELECT results and later return them
# without actual executing the same query once again. Having the query
# cache enabled may result in significant speed improvements, if your
# have a lot of identical queries and rarely changing tables. See the
# "Qcache_lowmem_prunes" status variable to check if the current value
# is high enough for your load.
# Note: In case your tables change very often or if your queries are
# textually different every time, the query cache may result in a
# slowdown instead of a performance improvement.
# 查询缓存被用来缓存 SELECT 结果并在稍后返回它们，不会再次实际执行相同的查询。
# 如果你有很多相同的查询并且很少改变表的话，查询缓存的启用将导致显著的速度改善。
# 请看“Qcache_lowmem_prunes”状态变量，以检查当前值对于你的加载是否足够高。
# 注意：如果你的表经常改变，或者如果你的查询每次是不同的原文，那么查询缓存将导致变慢，替代性能的改善。
query_cache_size = 64M

# Only cache result sets that are smaller than this limit. This is to
# protect the query cache of a very large result set overwriting all
# other query results.
# 只有缓存结果集是小于该限制的。
# 这可以保护一个非常大结果集的查询缓存覆盖所有其它查询结果。
query_cache_limit = 2M

# Minimum word length to be indexed by the full text search index.
# You might wish to decrease it if you need to search for shorter words.
# Note that you need to rebuild your FULLTEXT index, after you have
# modified this value.
# 编制到全文检索索引的最小单词长度。
# 如果你需要检索更短的单词，你可能希望减小它。
# 注意，在你修改了该值以后，你需要重建你的 FULLINDEX 索引。
ft_min_word_len = 4

# If your system supports the memlock() function call, you might want to
# enable this option while running MySQL to keep it locked in memory and
# to avoid potential swapping out in case of high memory pressure. Good
# for performance.
# 如果你的系统支持 memlock() 函数调用，
# 你可能想要启用该选项（运行 MySQL 以保持它锁定到内存，
# 并在出现高内存压力时避免潜在的交换输出）。
# 这对性能是很有益的。
#memlock

# Table type which is used by default when creating new tables, if not
# specified differently during the CREATE TABLE statement.
# 如果在 CREATE TABLE 语句中没有指定不同的表类型，这就是创建一个新表时所使用的默认表类型。
default-storage-engine = MYISAM

# Thread stack size to use. This amount of memory is always reserved at
# connection time. MySQL itself usually needs no more than 64K of
# memory, while if you use your own stack hungry UDF functions or your
# OS requires more stack for some operations, you might need to set this
# to a higher value.
# 使用的线程堆栈大小。
# 该内存量总是在连接时间被保留的。
# MySQL 自己通常需要不超过 64K 的内存，然而如果你使用的是你自己的堆栈 UDF 函数或者你的系统针对某些操作需要更多堆栈，你可能需要设置该值为一个更高的值。
thread_stack = 192K

# Set the default transaction isolation level. Levels available are:
# READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE
# 设置默认的事务隔离等级。
# 可用的级别有：READ-UNCOMMITTED、READ-COMMITTED、REPEATABLE-READ、SERIALIZABLE。
transaction_isolation = REPEATABLE-READ

# Maximum size for internal (in-memory) temporary tables. If a table
# grows larger than this value, it is automatically converted to disk
# based table This limitation is for a single table. There can be many
# of them.
# 内部（内存中的）临时表的最大容量。
# 如果一个表的增长超过该值，它将自动地转换到基于磁盘的表。
# 该限制是针对一个单一的表，但可以有很多这样的表。
tmp_table_size = 64M

# Enable binary logging. This is required for acting as a MASTER in a
# replication configuration. You also need the binary log if you need
# the ability to do point in time recovery from your latest backup.
# 启用二进制日志。
# 这在一个复制配置中，对于充当 MASTER 的是必要的。
# 如果你需要有能力及时从你最后的备份点中进行恢复，你也需要二进制日志。
log-bin=mysql-bin

# binary logging format - mixed recommended
#二进制日志格式 - 推荐值：mixed。
binlog_format=mixed

# If you're using replication with chained slaves (A->B->C), you need to
# enable this option on server B. It enables logging of updates done by
# the slave thread into the slave's binary log.
# 如果你正在使用链锁从服务器（A-〉B-〉C）进行复制，你需要在服务器 B 上启用该选项。
# 它允许通过从服务器线程将日志记录到从服务器的二进制日志中来实现日志的更新。
#log_slave_updates

# Enable the full query log. Every query (even ones with incorrect
# syntax) that the server receives will be logged. This is useful for
# debugging, it is usually disabled in production use.
# 启用完整的查询日志。服务器接收到的每一个查询（甚至是错误的语法）都将被记录。
# 这对于调试是很有用的，它通常在产品(环境)使用时被禁用。
#log

# Print warnings to the error log file.  If you have any problem with
# MySQL you should enable logging of warnings and examine the error log
# for possible explanations.
# 打印警告到错误日志文件。
# 如果你有任何 MySQL 的问题，你应该启用警告日志并检查错误日志中可能的解释。
#log_warnings

# Log slow queries. Slow queries are queries which take more than the
# amount of time defined in "long_query_time" or which do not use
# indexes well, if log_short_format is not enabled. It is normally good idea
# to have this turned on if you frequently add new queries to the
# system.
# 记录慢查询。
# 慢查询是指消耗时间超过“long_query_time”中定义的总时间的查询，或者如果 log_short_format 没有启用，不使用索引的查询。
# 如果你频繁地添加新查询到系统中，打开这个通常是一个比较好的主意。
slow_query_log

# All queries taking more than this amount of time (in seconds) will be
# trated as slow. Do not use "1" as a value here, as this will result in
# even very fast queries being logged from time to time (as MySQL
# currently measures time with second accuracy only).
# 所有消耗时间超过该总时间的查询都将被视为是缓慢的。
# 不要在这里使用“1”值，因为这会导致甚至非常快的查询都会被不时地被记录（MySQL 当前的度量时间只精确到秒）。
long_query_time = 2


# ***  Replication related settings
# *** 与复制有关的设置

# Unique server identification number between 1 and 2^32-1. This value
# is required for both master and slave hosts. It defaults to 1 if
# "master-host" is not set, but will MySQL will not function as a master
# if it is omitted.
# 1 到 2^32-1 之间的唯一服务器标识号。
# 该值对于主服务器和从服务器都是必须的。
# 如果“master-host”没有设置则默认为 1，但若是忽略，MySQL 将不会作为一个主服务器的功能。
server-id = 1

# Replication Slave (comment out master section to use this)
# 复制从服务器（注释掉主服务器章节以便使用这个）。
# To configure this host as a replication slave, you can choose between
# two methods :
# 要配置该主机为一个复制从服务器，你可以选择以下两种方法：

# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
# 1）使用 CHANGE MASTER TO 命令（在我们的手册中有完整的描述） - 其语法是：
#
# CHANGE MASTER TO MASTER_HOST = 〈host〉, MASTER_PORT = 〈port〉, MASTER_USER = 〈user〉, MASTER_PASSWORD = 〈password〉;
#
# 使用带引号的字符串替换 〈host〉、〈user〉、〈password〉，并且 〈port〉 是主服务器的端口号（默认为 3306）。
#
# 例子：
#
# CHANGE MASTER TO MASTER_HOST = '125.564.12.1', MASTER_PORT = 3306, MASTER_USER = 'joe', MASTER_PASSWORD = 'secret'; # OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    changes in this file to the variable values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
# 2）设置下面的变量。然而，如果你选择了该方法，请在第一时间内启动复制（就算不成功，
# 例如，如果你在 MASTER_PASSWORD 中未键入密码，并且从服务器连接失败），
# 从服务器将创建一个 master.info 文件，稍后在该文件中对下面变量值的任何改变都将被忽略，
# 并被 master.info 文件中的连接所覆盖，
# 除非你关闭从服务器、删除 master.info 并重新启动从服务器。
# 基于这种因素，你可能想要离开下面未接触的行（已注释的）并替代使用 CHANGE MASTER TO（请看上面）。

# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
# 需要 2 到 2^32-1 之间的唯一 id（与主服务器不同）。
# 如果“master-host”已被设置，默认设置为 2。
# 但若是忽略，将不会作为一个从服务器的功能。
#server-id = 2
#
# The replication master for this slave – required
# 针对该从服务器的复制主服务器 - 必须的。
#master-host = <hostname>
#
# The username the slave will use for authentication when connecting
# to the master – required
# 用户名，当连接到主服务器时，从服务器将用此来进行认证 - 必须的。
#master-user = <username>
#
# The password the slave will authenticate with when connecting to
# the master – required
# 密码，当连接到主服务器时，从服务器将用此来进行认证 - 必须的。
#master-password = <password>
#
# The port the master is listening on.
# optional - defaults to 3306
# 端口，主服务器正在监听的。
# 可选的 - 默认为 3306。
#master-port = <port>

# Make the slave read-only. Only users with the SUPER privilege and the
# replication slave thread will be able to modify data on it. You can
# use this to ensure that no applications will accidently modify data on
# the slave instead of the master
# 让从服务器只读。
# 只有拥有 SUPER 特权的用户和复制从服务器线程能够修改它的数据。
# 你可以使用这个来确保不会有应用程序在无意中替代主服务器修改从服务器上的数据。
#read_only


#*** MyISAM Specific options
#*** MyISAM 特有的选项

# Size of the Key Buffer, used to cache index blocks for MyISAM tables.
# Do not set it larger than 30% of your available memory, as some memory
# is also required by the OS to cache rows. Even if you're not using
# MyISAM tables, you should still set it to 8-64M as it will also be
# used for internal temporary disk tables.
# 键缓冲区的大小，用来为 MyISAM 表缓存索引块。
# 不要将它设置为超过你可用内存的 30% 以上，因为操作系统也需要一些内存来缓存行。
# 即使你不使用 MyISAM 表，你仍应该将它设置为 8-64M，因为它也被用于内部的临时磁盘表。
key_buffer_size = 32M

# MyISAM uses special tree-like cache to make bulk inserts (that is,
# INSERT ... SELECT, INSERT ... VALUES (...), (...), ..., and LOAD DATA
# INFILE) faster. This variable limits the size of the cache tree in
# bytes per thread. Setting it to 0 will disable this optimisation.  Do
# not set it larger than "key_buffer_size" for optimal performance.
# This buffer is allocated when a bulk insert is detected.
# MyISAM 使用特殊的类似于树的缓存来让大批量插入（亦即 INSERT ... SELECT、INSERT ... VALUES(...) 和 LOAD DATA INFILE）操作变得更快。
# 该变量限制每个线程的缓存树的字节大小。
# 将它设置为 0 将禁用该优化。
# 为了优化性能，不要将它设置得比“key_buffer_size”大。
# 当检测到大量的插入时，该缓冲区被分配。
bulk_insert_buffer_size = 64M

# This buffer is allocated when MySQL needs to rebuild the index in
# REPAIR, OPTIMIZE, ALTER table statements as well as in LOAD DATA INFILE
# into an empty table. It is allocated per thread so be careful with
# large settings.
# 当 MySQL 需要通过 REPAIR、OPTIMIZE、ALTER 表语句重建索引，
# 以及 LOAD DATA INFILE 到一个空表时，该缓冲区被分配。
# 它是给每个线程分配的，因此小心比较大的设置。
myisam_sort_buffer_size = 128M

# The maximum size of the temporary file MySQL is allowed to use while
# recreating the index (during REPAIR, ALTER TABLE or LOAD DATA INFILE.
# If the file-size would be bigger than this, the index will be created
# through the key cache (which is slower).
# 当重建索引（在 REPAIR、ALTER TABLE 或 LOAD DATA INFILE 期间）时，
# MySQL 允许使用的临时文件的最大大小。
# 如果“file-size”比这个值大，索引将通过键缓存（更慢一些）创建。
myisam_max_sort_file_size = 10G

# If a table has more than one index, MyISAM can use more than one
# thread to repair them by sorting in parallel. This makes sense if you
# have multiple CPUs and plenty of memory.
# 如果一个表有超过一个的索引，MyISAM 能够在排序时并行地使用超过一个的线程来修复它们。
# 如果你有多个 CPU 和足够的内存，这是很有意义的。
myisam_repair_threads = 1

# Automatically check and repair not properly closed MyISAM tables.
# 自动地检查和修复没有正确关闭的 MyISAM 表。
myisam_recover

# *** INNODB Specific options ***
# *** INNODB 特定的选项 ***

# Use this option if you have a MySQL server with InnoDB support enabled
# but you do not plan to use it. This will save memory and disk space
# and speed up some things.
# 如果你有一个支持 InnoDB 启用的 MySQL 服务器，而你却并不计划使用它，请使用该选项。
# 这可以保存一些内存和磁盘空间，并提高速度。
#skip-innodb

# Additional memory pool that is used by InnoDB to store metadata
# information.  If InnoDB requires more memory for this purpose it will
# start to allocate it from the OS.  As this is fast enough on most
# recent operating systems, you normally do not need to change this
# value. SHOW INNODB STATUS will display the current amount used.
# 附加的内存池，InnoDB 用来存储元数据信息。
# 如果 InnoDB 因该目的而需要更多的内存，它将开始从操作系统来分配它。
# 由于这在大多数最近的操作系统上是足够快的，你通常不需要改变这个值。
# SHOW INNODB STATUS 将显示当前使用总量。
innodb_additional_mem_pool_size = 16M

# InnoDB, unlike MyISAM, uses a buffer pool to cache both indexes and
# row data. The bigger you set this the less disk I/O is needed to
# access data in tables. On a dedicated database server you may set this
# parameter up to 80% of the machine physical memory size. Do not set it
# too large, though, because competition of the physical memory may
# cause paging in the operating system.  Note that on 32bit systems you
# might be limited to 2-3.5G of user level memory per process, so do not
# set it too high.
# InnoDB，不像 MyISAM，使用一个缓冲池来缓存索引和行数据。
# 你将该值设得越大，在表中访问需要的数据时，磁盘 I/O 就越少。
# 在一个专用的数据库服务器上，你可以设置该参数到机器物理内存大小的 80%。
# 不要把它设置得太大，因为物理内存的竞争可能导致操作系统中的分页。
# 注意，在 32 位的系统上，你可能在每个处理器的用户级内存上被限制在 2-3.5G，
# 因此不要把它设置得太高。
innodb_buffer_pool_size = 2G

# InnoDB stores data in one or more data files forming the tablespace.
# If you have a single logical drive for your data, a single
# autoextending file would be good enough. In other cases, a single file
# per device is often a good choice. You can configure InnoDB to use raw
# disk partitions as well - please refer to the manual for more info
# about this.
# InnoDB 存储数据到一个或多个数据文件，形成表空间。
# 如果对于你对你的数据有一个单一的物理设备，那么一个单一的自动扩展文件就已经足够了。
# 在其它情况下，每设备一个单一文件是一个非常好的选择。
# 你也可以配置 InnoDB 来使用原始的磁盘分区 - 请参考手册以获取更多有关这个的信息。
innodb_data_file_path = ibdata1:10M:autoextend

# Set this option if you would like the InnoDB tablespace files to be
# stored in another location. By default this is the MySQL datadir.
# 如果你希望 InnoDB 表空间文件存储到其它的地方，设置该选项。
# 默认的是 MySQL 数据目录。
#innodb_data_home_dir = <directory>

# Number of IO threads to use for async IO operations. This value is
# hardcoded to 4 on Unix, but on Windows disk I/O may benefit from a
# larger number.
# 异步 IO 操作所使用的 IO 线程数。
# 该值在 Unix 系统上被硬编码为 4，但在 Windows 上，磁盘 I/O 可能受益于一个更大的数字。
innodb_file_io_threads = 4

# If you run into InnoDB tablespace corruption, setting this to a nonzero
# value will likely help you to dump your tables. Start from value 1 and
# increase it until you're able to dump the table successfully.
# 如果你遇到 InnoDB 表空间腐烂，设置该值为一个非零值，将很容易地帮助你导出你的表。
# 以值 1 开始并提高它，直到你能够成功地导出表。
#innodb_force_recovery=1

# Number of threads allowed inside the InnoDB kernel. The optimal value
# depends highly on the application, hardware as well as the OS
# scheduler properties. A too high value may lead to thread thrashing.
# InnoDB 内核里面允许的线程数量。
# 最佳的值高度取决于应用程序、硬件以及操作系统的调度属性。
# 一个太高的值可能导致线程颠簸。
innodb_thread_concurrency = 16

# If set to 1, InnoDB will flush (fsync) the transaction logs to the
# disk at each commit, which offers full ACID behavior. If you are
# willing to compromise this safety, and you are running small
# transactions, you may set this to 0 or 2 to reduce disk I/O to the
# logs. Value 0 means that the log is only written to the log file and
# the log file flushed to disk approximately once per second. Value 2
# means the log is written to the log file at each commit, but the log
# file is only flushed to disk approximately once per second.
# 如果设置为 1，InnoDB 在每次提交（提供完整的 ACID 行为）时刷新事务日志到磁盘。
# 如果你想安全地进行折中，并且你正在运行小事务，你可以为 0 或 2 来减少日志的磁盘 I/O。
# 值 0 表示日志只被写入到日志文件，并且日志文件大约每秒一次刷新到磁盘。
# 值 2 表示日志在每次提交时被写入到日志文件，但是日志文件只是大约每秒一次被刷新到磁盘。
innodb_flush_log_at_trx_commit = 1

# Speed up InnoDB shutdown. This will disable InnoDB to do a full purge
# and insert buffer merge on shutdown. It may increase shutdown time a
# lot, but InnoDB will have to do it on the next startup instead.
# 加速 InnoDB 的关闭。
# 这在关闭时将禁用 InnoDB 做一个完整的清除和插入缓冲合并。
# 它可能会提高不少关闭的时间，但替代的是 InnoDB 将在下一次启动时来完成它。
#innodb_fast_shutdown

# The size of the buffer InnoDB uses for buffering log data. As soon as
# it is full, InnoDB will have to flush it to disk. As it is flushed
# once per second anyway, it does not make sense to have it very large
# (even with long transactions).
# InnoDB 缓冲日志数据所使用的缓冲区大小。
# 一旦它满了，InnoDB 将刷新它到磁盘。
# 因为不管怎么它都是每秒刷新一次，所以没有必要让它变得很大（甚至是很长的事务）。
innodb_log_buffer_size = 8M

# Size of each log file in a log group. You should set the combined size
# of log files to about 25%-100% of your buffer pool size to avoid
# unneeded buffer pool flush activity on log file overwrite. However,
# note that a larger logfile size will increase the time needed for the
# recovery process.
# 一个日志组中每个日志文件的大小。
# 你可以设置日志文件的联合大小为你的缓冲池大小的 25%-100%，
# 以避免对日志文件不必要的缓冲池动态刷新重写。
# 然而，注意，一个更大的日志文件大小将增加恢复处理所需的时间。
innodb_log_file_size = 256M

# Total number of files in the log group. A value of 2-3 is usually good
# enough.
# 日志组中文件的总数。
# 通常值为 2-3 就已足够了。
innodb_log_files_in_group = 3

# Location of the InnoDB log files. Default is the MySQL datadir. You
# may wish to point it to a dedicated hard drive or a RAID1 volume for
# improved performance
# InnoDB 日志文件的位置。
# 默认为 MySQL 的数据目录。
# 你可能希望指定它到一个专用的硬盘或一个 RAID1 卷标来改善性能。
#innodb_log_group_home_dir

# Maximum allowed percentage of dirty pages in the InnoDB buffer pool.
# If it is reached, InnoDB will start flushing them out agressively to
# not run out of clean pages at all. This is a soft limit, not
# guaranteed to be held.
# InnoDB 缓冲池中允许的脏页面的最大百分比。
# 如果它到达了，InnoDB 将开始积极地清理它们，以避免消耗完所有的干净页面。
# 这是一个软限制，不保证能够一直保持。
innodb_max_dirty_pages_pct = 90

# The flush method InnoDB will use for Log. The tablespace always uses
# doublewrite flush logic. The default value is "fdatasync", another
# option is "O_DSYNC".
# InnoDB 对日志使用的刷新方法。
# 表空间总是使用双写刷新逻辑。
# 默认值为“fdatasync”，其它选项是“O_DSYNC”。
#innodb_flush_method=O_DSYNC

# How long an InnoDB transaction should wait for a lock to be granted
# before being rolled back. InnoDB automatically detects transaction
# deadlocks in its own lock table and rolls back the transaction. If you
# use the LOCK TABLES command, or other transaction-safe storage engines
# than InnoDB in the same transaction, then a deadlock may arise which
# InnoDB cannot notice. In cases like this the timeout is useful to
# resolve the situation.
# 一个 InnoDB 事务应等待的在回滚之前被授权锁定的时长。
# InnoDB 在它自己的锁定表中自动地检测事务死锁，并回滚事务。
# 如果你在相同的事务中使用 LOCK TABLES 命令，或者其它比 InnoDB 更加事务安全的存储引擎，
# 那么稍后会出现 InnoDB 不能提示的死锁。
# 如果像这样，超时对于解决问题是很有用的。
innodb_lock_wait_timeout = 120


[mysqldump]
# Do not buffer the whole result set in memory before writing it to
# file. Required for dumping very large tables
# 在写入到文件之前，不要缓冲整个结果集。
# 导出非常大的表时是必须的。
quick

max_allowed_packet = 16M

[mysql]
no-auto-rehash

# Only allow UPDATEs and DELETEs that use keys.
# 只允许 UPDATE 和 DELETE 使用键。
#safe-updates

[myisamchk]
key_buffer_size = 512M
sort_buffer_size = 512M
read_buffer = 8M
write_buffer = 8M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
# Increase the amount of open files allowed per process. Warning: Make
# sure you have set the global system limit high enough! The high value
# is required for a large number of opened tables
# 增加每次处理所允许打开的文件数量。
# 警告：确保你已经设置全局系统限制足够高！
# 对于一个大数量的打开表，高值是必须的。
open-files-limit = 8192
```
# 附录2：MySQL自动安装脚本
```
auto-install-mysql.sh

#!/bin/sh
# auto install mysql, just for test
# write by quxl at 2012-08

MYSQL_PASSWORD="123456"
DOWNLOAD_MYSQL_DIR=~/tools

#------ add mysql user --------
echo "add mysql user <start>..."
groupadd mysql
useradd -s /sbin/nologin -g mysql -M mysql
echo "add mysql user <end>..."
echo

#------ download mysql --------
echo "download mysql <start>..."
mkdir -p $DOWNLOAD_MYSQL_DIR
cd $DOWNLOAD_MYSQL_DIR
# wget http://cdn.mysql.com/Downloads/MySQL-5.1/mysql-5.1.65.tar.gz
# or upload mysql-5.1.65.tar.gz to the centos os.
echo "download mysql <end>..."
echo

#------ install mysql --------
echo " install mysql <start>..."
cd $DOWNLOAD_MYSQL_DIR
tar zxf mysql-5.1.65.tar.gz
cd mysql-5.1.65

./configure \
--prefix=/usr/local/mysql \
--with-unix-socket-path=/usr/local/mysql/tmp/mysql.sock \
--localstatedir=/usr/local/mysql/data \
--enable-assembler \
--enable-thread-safe-client \
--with-mysqld-user=mysql \
--with-big-tables \
--without-debug \
--with-pthread \
--enable-assembler \
--with-extra-charsets=complex \
--with-readline \
--with-ssl \
--with-embedded-server \
--enable-local-infile \
--with-plugins=partition,innobase \
--with-plugin-PLUGIN \
--with-mysqld-ldflags=-all-static \
--with-client-ldflags=-all-static

make && make install


/bin/cp $DOWNLOAD_MYSQL_DIR/mysql-5.1.65/support-files/my-small.cnf /etc/my.cnf
echo " install mysql <end>..."
echo

#------ create  mysql date file --------
echo " create  mysql date file <start>..."
mkdir -p /usr/local/mysql/data
chown -R mysql.mysql /usr/local/mysql/
/usr/local/mysql/bin/mysql_install_db --user=mysql
echo " create  mysql date file <end>..."
echo

#------ run  mysql  --------
echo " run  mysql <start>..."
echo " copy  mysql.server to /etc/init.d/mysqld "
chkconfig --add mysqld
chkconfig mysqld on
echo " set  mysql as server suc... "

cp $DOWNLOAD_MYSQL_DIR/mysql-5.1.65/support-files/mysql.server /etc/init.d/mysqld
/usr/local/mysql/bin/mysqld_safe --user=mysql &
echo " run  mysql <end>..."
echo

#------ set  mysql path --------
echo " set  mysql path <start>..."
echo 'export PATH=$PATH:/usr/local/mysql/bin' >>/etc/profile
source /etc/profile
echo $PATH
export $PATH
echo " set  mysql path <end>..."
echo

#------ set  mysql passwd --------
echo " set  mysql passwd <start>..."
mysqladmin -u root password '$MYSQL_PASSWORD'
echo " set  mysql passwd <end>..."
echo  
```
