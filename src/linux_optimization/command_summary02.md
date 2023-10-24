# 命令总结(find、wc、tar、cut、grep、egrep、date、which、echo、shutdown、reboot、useradd、passwd)

# 2.	wc
## 2.1.	说明
wc命令的功能为统计指定文件中的字节数、字数、行数, 并将统计结果显示输出。
wc [-lwm]
选项与参数：
-l  ：仅列出行；
-w  ：仅列出多少字(英文单词)；
-m  ：多少字符；
## 2.2.	范例
范例一：查询行数、单词数、字符数
```
[root@www ~]# cat /etc/man.config | wc
141     722    4617
# 输出的三个数字中，分别代表：行数、单词数、字符数
```

范例二：打印最长行的行数
```
[root@n1 test]# wc file2 -L
11 file2
```