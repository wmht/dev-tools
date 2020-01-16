#! /bin/bash
# 开启kdump调试,可对主机异常宕机收集信息
# 使用Crash工具分析core文件示例
# cd /var/crash/127.0.0.1-2019-07-08-15:52:25
# crash /usr/lib/debug/lib/modules/3.10.0-514.26.2.el7.x86_64/vmlinux vmcore
# 启动kdump
systemctl enable kdump.service
systemctl start kdump.service
systemctl status kdump.service
# 安装crash
yum install -y crash
# 安装debug-info
unamer=`uname -r`
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-"$unamer".rpm
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-"$unamer".rpm
rpm -ivh kernel-debuginfo-common-x86_64-"$unamer".rpm
rpm -ivh kernel-debuginfo-"$unamer".rpm
