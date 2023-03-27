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



function GetCpuUsage(){
#echo ""
#echo ""
#echo "############################ CPU使用情况 #############################"
mpstat -P ALL 1 1 | grep -v '平均时间' >> $LOGPATH/ALLcpu.log
echo "" >> $LOGPATH/ALLcpu.log

whole_cpu_Usage=$(mpstat -P ALL 1 1 | grep -E '平均时间|Average' | column -t)
cpu_ave=$(echo "$whole_cpu_Usage" | grep all | awk '{print 100 - $NF}')
collect_title='sys_cpu'
collect_info="$cpu_ave"


#mpstat -P ALL $1 $2 > $LOGPATH/ALLcpu.log
#sleep 1

#whole_cpu_Usage=$(cat $LOGPATH/ALLcpu.log | grep -E '平均时间|Average' | column -t)
#all_cpu_idle=$(echo "$whole_cpu_Usage" | grep all | awk '{print $NF}')
#report_CpuUsedPercent="$(echo | awk "{print 100-$all_cpu_idle}")""%"
#echo "" >> $LOGPATH/ALLcpu.log
#echo "CPU使用率：""$report_CpuUsedPercent" >> $LOGPATH/ALLcpu.log
}


function getMemStatus(){
#echo ""
#echo ""
#echo "############################ 内存检查 ############################"
#if [[ $centosVersion < 7 ]];then
#free -mo
#else
#free -h
#fi
free -h -s 1 -c 1 >> $LOGPATH/ALLmem.log 
sar -r 1 1 >> $LOGPATH/ALLmem-use.log 
whole_mem_Usage=$(sar -r 1 1  | grep -E '平均时间|Average' | column -t | awk '{print $5}')
echo "" >> $LOGPATH/ALLmem-use.log
echo "内存使用率：""$whole_mem_Usage""%" >> $LOGPATH/ALLmem-use.log

collect_title=$collect_title",sys_mem"
collect_info=$collect_info","$whole_mem_Usage


#报表信息
MemTotal=$(grep MemTotal /proc/meminfo| awk '{print $2}') #KB
MemFree=$(grep MemFree /proc/meminfo| awk '{print $2}') #KB
let MemUsed=MemTotal-MemFree
MemPercent=$(awk "BEGIN {if($MemTotal==0){printf 100}else{printf \"%.2f\",$MemUsed*100/$MemTotal}}")
report_MemTotal="$((MemTotal/1024))""MB" #内存总容量(MB)
report_MemFree="$((MemFree/1024))""MB" #内存剩余(MB)
report_MemUsedPercent="$(awk "BEGIN {if($MemTotal==0){printf 100}else{printf \"%.2f\",$MemUsed*100/$MemTotal}}")""%" #内存使用率
}


function getDiskStatus(){
echo ""
echo ""
echo "############################ 磁盘检查 ############################"
df -hiP | sed 's/Mounted on/Mounted/'> /tmp/inode
df -hTP | sed 's/Mounted on/Mounted/'> /tmp/disk 
join /tmp/disk /tmp/inode | awk '{print $1,$2,"|",$3,$4,$5,$6,"|",$8,$9,$10,$11,"|",$12}'| column -t
#报表信息
diskdata=$(df -TP | sed '1d' | awk '$2!="tmpfs"{print}') #KB
disktotal=$(echo "$diskdata" | awk '{total+=$3}END{print total}') #KB
diskused=$(echo "$diskdata" | awk '{total+=$4}END{print total}') #KB
diskfree=$((disktotal-diskused)) #KB
diskusedpercent=$(echo $disktotal $diskused | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}') 
inodedata=$(df -iTP | sed '1d' | awk '$2!="tmpfs"{print}')
inodetotal=$(echo "$inodedata" | awk '{total+=$3}END{print total}')
inodeused=$(echo "$inodedata" | awk '{total+=$4}END{print total}')
inodefree=$((inodetotal-inodeused))
inodeusedpercent=$(echo $inodetotal $inodeused | awk '{if($1==0){printf 100}else{printf "%.2f",$2*100/$1}}')
report_DiskTotal=$((disktotal/1024/1024))"GB" #硬盘总容量(GB)
report_DiskFree=$((diskfree/1024/1024))"GB" #硬盘剩余(GB)
report_DiskUsedPercent="$diskusedpercent""%" #硬盘使用率%
report_InodeTotal=$((inodetotal/1000))"K" #Inode总量
report_InodeFree=$((inodefree/1000))"K" #Inode剩余
report_InodeUsedPercent="$inodeusedpercent""%" #Inode使用率%
echo ""
echo "磁盘使用率：""$report_DiskUsedPercent"
echo "inode使用率：""$report_InodeUsedPercent"

collect_title=$collect_title",dick_per,inode_per"
collect_info=$collect_info","$diskusedpercent","$inodeusedpercent
}


function getServiceStatus(){
echo ""
echo ""
echo "############################ 服务检查 ############################"
echo ""
if [[ $centosVersion > 7 ]];then
conf=$(systemctl list-unit-files --type=service --state=enabled --no-pager | grep "enabled")
process=$(systemctl list-units --type=service --state=running --no-pager | grep ".service")
#报表信息
report_SelfInitiatedService="$(echo "$conf" | wc -l)" #自启动服务数量
report_RuningService="$(echo "$process" | wc -l)" #运行中服务数量
else
conf=$(/sbin/chkconfig | grep -E ":on|:启用")
process=$(/sbin/service --status-all 2>/dev/null | grep -E "is running|正在运行")
#报表信息
report_SelfInitiatedService="$(echo "$conf" | wc -l)" #自启动服务数量
report_RuningService="$(echo "$process" | wc -l)" #运行中服务数量
fi
echo "服务配置"
echo "--------"
echo "$conf" | column -t
echo ""
echo "正在运行的服务"
echo "--------------"
echo "$process"
}

function getListenStatus(){
echo ""
echo ""
echo "############################ 监听检查 ############################"
whole_tcp_connect=$(netstat -n | awk '/^tcp/{++S[$NF]} END { for (key in S) print key,S[key]}')
echo "$whole_tcp_connect"
echo "------------------------------------------------------------------"
TCPListen=$(ss -ntul | column -t)
echo "$TCPListen"
#报表信息
report_Listen="$(echo "$TCPListen"| sed '1d' | awk '/tcp/ {print $5}' | awk -F: '{print $NF}' | sort | uniq | wc -l)"
}



function getHowLongAgo(){
# 计算一个时间戳离现在有多久了
datetime="$*"
[ -z "$datetime" ] && echo "错误的参数：getHowLongAgo() $*"
Timestamp=$(date +%s -d "$datetime") #转化为时间戳
Now_Timestamp=$(date +%s)
Difference_Timestamp=$(($Now_Timestamp-$Timestamp))
days=0;hours=0;minutes=0;
sec_in_day=$((60*60*24));
sec_in_hour=$((60*60));
sec_in_minute=60
while (( $(($Difference_Timestamp-$sec_in_day)) > 1 ))
do
let Difference_Timestamp=Difference_Timestamp-sec_in_day
let days++
done
while (( $(($Difference_Timestamp-$sec_in_hour)) > 1 ))
do
let Difference_Timestamp=Difference_Timestamp-sec_in_hour
let hours++
done
echo "$days 天 $hours 小时前"
}


function getDumpStatus(){
echo ""
echo ""
echo "############################ 软件终端dump检查 ############################"
if [ $(ls -al /hislog/crash/coredump/ | grep -v "总用量" | wc -l) -ge 3 ];then
	echo ""
	echo "coredump文件"
	echo "-------------"
	ls -al /hislog/crash/coredump/ | grep -v "总用量" | awk '{print $6,$7,$8,$9}'
	echo ""
else
	echo "设备未产生coredump文件"
fi

if [ $(ls -al /hislog/crash/kdump/ | grep -v "总用量" | wc -l) -ge 3 ];then
        echo ""
        echo "kdump文件"
        echo "-------------"
        ls -al /hislog/crash/kdump/ | grep -v "总用量" | awk '{print $6,$7,$8,$9}'
	echo ""
else
        echo "设备未产生kdump文件"
fi
}


function getProcessStatus(){
echo ""
echo ""
echo "############################ 进程检查 ############################"
if [ $(ps -ef | grep defunct | grep -v grep | wc -l) -ge 1 ];then
echo ""
echo "僵尸进程";
echo "--------"
ps -ef | head -n1
ps -ef | grep defunct | grep -v grep
else
echo "无僵尸进程"
fi

echo ""
echo "CPU占用TOP15"
echo "------------"
echo -e "PID %CPU %usr %system %guest %wait COMMAND
$(pidstat -u -p ALL $1 $2 | grep -E '平均时间|Average' | awk '{print $3, $8, $4, $5, $6, $7, $10}' | sort -k2rn | head -n 15)"| column -t

echo ""
echo "内存占用TOP15"
echo "-------------"
echo -e "PID %MEM VSZ RSS COMMAND
$(pidstat -r -p ALL $1 $2 | grep -E '平均时间|Average' | awk '{print $3, $8, $6, $7, $9}' | sort -k2rn | head -n 15)"| column -t
#报表信息
report_DefunctProsess="$(ps -ef | grep defunct | grep -v grep|wc -l)"
}

#zta-c关键进程
SYSTEM_SERVICE_LIST="sdp-etcd sdp-etcd-cluster sdp-spad sdp-sys-init sdp-dap sdp-promoted sdp-passport sdp_proxy sdp-console sdp-node-agent sdp-controller sdp-config-builder sdp-nginx sdp-proxy sdp-clusterd sdp-hids"
SDP_SYSTEM_SERVICE_LIST="$SYSTEM_SERVICE_LIST sdp-forward zta-controller"


# 需要测试 pid 变化的进程
collect_process=$SDP_SYSTEM_SERVICE_LIST
#collect_porfession_process
getpid(){
        for process in ${collect_porfession_process[@]};
        do
                pidof $process
        done

}
spiltpid(){
        getpid > /tmp/process_1.log
        cat /tmp/process_1.log | tr " " "|" > /tmp/process_2.log
        rm /tmp/process_1.log

}

pidstatis(){
	for process in ${collect_process[@]};
	do
		ps -eo pid,lstart,etime,comm | grep -E $process | grep -v 'grep' | awk '{if($7<"01:00") {print $NF}}'
	done
}



function getChangePid(){
echo ""
echo ""
echo "######################## 统计1分钟内pid变化的程序 #########################"
pidstatis > /tmp/pid_stat.log

if [ "`cat /tmp/pid_stat.log | wc -l`" -eq 0 ];then
	echo "统计的进程 PID 未出现变化"
else
	echo "存在pid变化的有如下进程："
	cat /tmp/pid_stat.log | uniq
fi
rm /tmp/pid_stat.log
}


function getSyslogStatus(){
echo ""
echo ""
echo "############################ syslog检查 ##########################"
echo "服务状态：$(getState rsyslog)"
echo ""
echo "/etc/rsyslog.conf"
echo "-----------------"
cat /etc/rsyslog.conf 2>/dev/null | grep -v "^#" | grep -v "^\\$" | sed '/^$/d' | column -t
#报表信息
report_Syslog="$(getState rsyslog)"
}




function getState(){
if [[ $centosVersion < 7 ]];then
if [ -e "/etc/init.d/$1" ];then
if [ `/etc/init.d/$1 status 2>/dev/null | grep -E "is running|正在运行" | wc -l` -ge 1 ];then
r="active"
else
r="inactive"
fi
else
r="unknown"
fi
else
#CentOS 7+
r="$(systemctl is-active $1 2>&1)"
fi
echo "$r"
}

function getHealth(){
  echo""
  echo""
  echo "############################ health检查 ##########################"
  atrust_tool health
  sleep 5
}

#获取每个进程的CPU、内存占用、句柄数量、线程数量
function get_process_info(){
  lsof -n|awk '{print $2}'|sort|uniq -c > process_handle.txt
  check_list=$SDP_SYSTEM_SERVICE_LIST
  for temp_process in $check_list; do
      for process_id in $(pidof $temp_process); do
        cpu=$(ps -aux |grep $temp_process |grep $process_id |awk '{print $3}')
        mem=`ps -aux |grep $temp_process |grep $process_id |awk '{print $4}'`
        handle_num=$(cat process_handle.txt | awk '{if( $2 == "'"$process_id"'") print $1}')
        thread_num=` ls /proc/${process_id}/task |wc -l`
        process_info_cpu=$temp_process"_"$process_id"_cpu"
        process_info_mem=$temp_process"_"$process_id"_mem"
        process_info_handle=$temp_process"_"$process_id"_handle"
        process_info_thread=$temp_process"_"$process_id"_thread"
        collect_title=$collect_title","$process_info_cpu","$process_info_mem","$process_info_handle","$process_info_thread
        collect_info=$collect_info","$cpu","$mem","$handle_num","$thread_num
        ##echo "$temp_process $process_id:-->$cpu,$mem,$handle_num,$thread_num"
    done
    done
}



function check(){
GetSystemStatus
GetGPUStatus
}

echo $RESULTFILE
echo >> RESULTFILE

function check(){
GetSystemStatus
GetGPUStatus
}

echo $RESULTFILE
echo >> RESULTFILE
