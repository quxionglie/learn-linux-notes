# centos7.9系统安装文档

## 1.安装过程
### 准备软件与系统
CentOS-7-x86_64-DVD-2009.iso

VMware

### 新建虚拟机 
![](/images/install_centos7/1.png)
![](/images/install_centos7/2.png)
![](/images/install_centos7/3.png)
![](/images/install_centos7/4.png)
![](/images/install_centos7/5.png)
![](/images/install_centos7/6.png)
![](/images/install_centos7/7.png)


### 开始安装   
![](/images/install_centos7/WX20231023-160347@2x.png)

### 选择语言为English、键盘布局类型为us
![](/images/install_centos7/WX20231023-160438@2x.png)

### 设置时区 Asia/Shanghai
![](/images/install_centos7/WX20231023-160519@2x.png)  

![](/images/install_centos7/WX20231023-160540@2x.png)

### 确认安装位置, 默认    
![](/images/install_centos7/WX20231023-160624@2x.png)

![](/images/install_centos7/WX20231023-160641@2x.png)

![](/images/install_centos7/WX20231023-161219@2x.png)

### 配置网络参数  
![](/images/install_centos7/WX20231023-160703@2x.png)

设置开机启用
![](/images/install_centos7/WX20231023-160906@2x.png)


![](/images/install_centos7/WX20231023-161015@2x.png)

配置GATEWAY、DNS,这里默认用DHCP

![](/images/install_centos7/WX20231023-161047@2x.png)

### 设置主机名 n1    
![](/images/install_centos7/WX20231023-163510@2x.png)

### 选择安装软件包, 最小化安装
![](/images/install_centos7/WX20231023-161118@2x.png)

### 开始安装程序
![](/images/install_centos7/WX20231023-161650@2x.png)

![](/images/install_centos7/8.png)

### 设置ROOT密码   
![](/images/install_centos7/WX20231023-161650@2x.png)

### 安装完成, Reboot重启  


### 关闭防火墙和 selinux
```
# 临时关闭防火墙
systemctl stop firewalld
# 永久防火墙开机自关闭
systemctl disable firewalld

# 临时关闭SELinux
setenforce 0
# 查看SELinux状态
getenforce
# 开机关闭SELinux
# 编辑/etc/selinux/config文件，如下图，将SELINUX的值设置为disabled。
```