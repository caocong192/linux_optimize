#!/bin/bash
#author by cc
#this script is only for CentOS 7.x
#check the OS

platform=`uname -i`
if [ $platform != "x86_64" ];then
echo "this script is only for 64bit Operating System !"
exit 1
fi
echo "the platform is ok"
cat << EOF
your system is CentOS 7 x86_64
EOF

#添加公网DNS地址
cat >> /etc/resolv.conf << EOF
nameserver 114.114.114.114
nameserver 223.5.5.5
EOF

#Yum源更换为国内阿里源
yum install wget telnet -y
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#添加阿里的epel源
#add the epel
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
# rpm -ivh http://dl.Fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm

#yum重新建立缓存
yum clean all
yum makecache

#基础软件安装
yum -y install wget net-tools screen lsof tcpdump nc mtr openssl-devel vim bash-completion lrzsz nmap telnet tree ntpdate bash-completion chrony

#同步时间
yum -y install ntp
sed -i 's/server 0.centos.pool.ntp.org iburst/server ntp1.aliyun.com iburst/' /etc/ntp.conf
sed -i 's/server 1.centos.pool.ntp.org iburst/server ntp2.aliyun.com iburst/' /etc/ntp.conf
sed -i 's/server 2.centos.pool.ntp.org iburst/server ntp3.aliyun.com iburst/' /etc/ntp.conf
systemctl restart ntpd.service

#设置最大打开文件描述符数
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
* soft nofile 655350
* hard nofile 655350
EOF


#禁用selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

#关闭防火墙
systemctl disable firewalld.service
systemctl stop firewalld.service

#set ssh
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
systemctl restart sshd.service


#内核参数优化
cat >> /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 30
net.ipv4.ip_local_port_range = 1024 65000
fs.file-max = 655350
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
vm.swappiness = 10
EOF
/sbin/sysctl -p

#vim定义退格键可删除最后一个字符类型
echo 'alias vi=vim' >> /etc/profile
echo 'stty erase ^H' >> /etc/profile
cat >> /root/.vimrc << EOF
set tabstop=4
set shiftwidth=4
set expandtab
syntax on
"set number
EOF
