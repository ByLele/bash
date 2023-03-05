#########################################################################
# File Name:    bash01.sh
# Author:       程序员Carl
# mail:         programmercarl@163.com
# Created Time: 2023年03月05日 星期日 04时00分40秒
#########################################################################
#!/bin/bash
#NICARR=$(ifconfig -a| awk '[a-z]' {print $1}) #获取所有网卡名称

IPADDR=$(ifconfig -a| awk '/inet/ {print $2}')

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

source /etc/profile #重新加载系统环境变量和配置文件


[ $(id -u) -gt 0 ] && echo "root exec run!" #&& exit 1 # id -u　用户uid root==0  gt比较

#Version=$(awk '{print $(NF-1)}' /etc/redhat-release)

#PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`# 获取当前脚步所在的目录路径　$0 当前脚步名称和路径
PROGPATH=/home/colin/bash
echo $PROGPATH
[ -f $PROGPATH ] && PROGPATH="."]　#-f　条件判断　检查PROGPATH 文件是否存在

#LOGPATH="$PROGPATH/log"
#[ -e $LOGPATH ] || mkdir $LOGPATH]# -f -e 测试选项

RESULTFILE="$LOGPATH/HostDailyCheck-`date +%F`.txt"

#定义报表的全局变量
report_DateTime="" #日期 ok
report_Hostname="" #主机名 ok
report_OSRelease="" #发行版本 ok
report_Kernel="" #内核 ok
report_Language="" #语言/编码 ok
report_LastReboot="" #最近启动时间 ok
report_Uptime="" #运行时间（天） ok
report_CPUs="" #CPU数量 ok
report_CPUType="" #CPU类型 ok
report_Arch="" #CPU架构 ok
report_CpuUsedPercent="" #CPU使用率% ok
report_MemTotal="" #内存总容量(MB) ok
report_MemFree="" #内存剩余(MB) ok
report_MemUsedPercent="" #内存使用率% ok
report_DiskTotal="" #硬盘总容量(GB) ok
report_DiskFree="" #硬盘剩余(GB) ok
report_DiskUsedPercent="" #硬盘使用率% ok
report_InodeTotal="" #Inode总量 ok
report_InodeFree="" #Inode剩余 ok
report_InodeUsedPercent="" #Inode使用率 ok
report_IP="" #IP地址 ok
report_MAC="" #MAC地址 ok
report_Gateway="" #默认网关 ok
report_DNS="" #DNS ok
report_Listen="" #监听 ok
report_Selinux="" #Selinux ok
report_DefunctProsess="" #僵尸进程数量 ok
report_RuningService="" #运行中服务数 ok
report_Syslog="" #日志服务 ok





function GetSystemStatus(){
echo "++++++++++++++++++++++系统检查+++++++++++++++++++++++++++++"
if [ -e /etc/sysconfig/i18n ];then
    default_LANG="$(grep "LANG=" /etc/sysconfig/i18n | grep -v "^#" | awk -F '"' '{print $2}')"
else
    default_LANG=$LANG
fi
export LANG="en_US.UTF-8"
#Release=$(cat /etc/redhat-release 2>/dev/null)
Release=$(lsb_release -a 2>/dev/null)
Kernel=$(uname -r)
OS=$(uname -o)
Hostname=$(uname -n)
SELinux="11"
#SELinux=$(/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}')
LastReboot=$(who -b | awk '{print $3,$4}')
uptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
echo " 系统：$OS"
echo " 发行版本：$Release"
echo " 内核：$Kernel"
echo " 主机名：$Hostname"
echo " SELinux：$SELinux"
echo "语言/编码：$default_LANG"
echo " 当前时间：$(date +'%F %T')"
echo " 最后启动：$LastReboot"
echo " 运行时间：$uptime"
#报表信息
report_DateTime=$(date +"%F %T") #日期
report_Hostname="$Hostname" #主机名
report_OSRelease="$Release" #发行版本
report_Kernel="$Kernel" #内核
report_Language="$default_LANG" #语言/编码
report_LastReboot="$LastReboot" #最近启动时间
report_Uptime="$uptime" #运行时间（天）
report_Selinux="$SELinux"
export LANG="$default_LANG"

}

function GetGPUStatus(){

echo ""
echo ""
echo "############################ CPU检查 #############################"
Physical_CPUs=$(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)
Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
CPU_Kernels=$(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')
CPU_Type=$(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)
CPU_Arch=$(uname -m)
echo "物理CPU个数:$Physical_CPUs"
echo "逻辑CPU个数:$Virt_CPUs"
echo "每CPU核心数:$CPU_Kernels"
echo " CPU型号:$CPU_Type"
echo " CPU架构:$CPU_Arch"
#报表信息
report_CPUs=$Virt_CPUs #CPU数量
report_CPUType=$CPU_Type #CPU类型
report_Arch=$CPU_Arch #CPU架构
}


function check(){
GetSystemStatus
GetGPUStatus
}

echo $RESULTFILE
echo >> RESULTFILE
