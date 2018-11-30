#!/bin/sh
R_BOLD="\033[31m\033[1m"
G_BOLD="\033[32m\033[1m"
BOLD="\033[33m\033[1m"
NORM="\033[0m"
INFO="$BOLD Info: $NORM"
ERROR="$BOLD *** Error: $NORM"
INPUT="$BOLD => $NORM"

SWAP_FILE=`nvram get apps_swap_file`
SWAP_SIZE=`nvram get apps_swap_size`
i=1
cd /tmp

swap_info(){
       echo -e "**********************************************************"
       echo -e ""
       echo -e "  ${G_BOLD}虚拟内存:$NORM  总计($G_BOLD$(free |grep -A1 "Swap" |awk   '{print $2}')$NORM)  已用($G_BOLD$(free |grep -A1 "Swap" |awk   '{print $3}')$NORM)  可用($G_BOLD$(free |grep -A1 "Swap" |awk   '{print $4}')$NORM)"
       echo -e ""
       echo -e "**********************************************************"
}


case "$1" in
  start)
echo -e "$INFO 此脚本文件指导创建虚拟内存"
echo -e "$INFO 默认创建的虚拟内存文件存放在 \"swap\" 文件夹并不可改变"
echo -e "$INFO 检查可用的挂载分区......"
for mounted in `/bin/mount |awk '{if($0 ~/mnt/){ print $3}}'` ; do
  echo -e "$G_BOLD [$i] --> $mounted $NORM"
  eval mounts$i=$mounted
  i=`expr $i + 1`
done

if [ $i == "1" ] ; then
  echo -e "$ERROR $R_BOLD 未找到挂载磁盘，执行退出。$NORM"
  exit 1
fi

echo -en "$INPUT $BOLD 请输入磁盘分区序号或键入 0 退出程序 $NORM\n$BOLD[0-`expr $i - 1`]$NORM: "
read partitionNumber
if [ "$partitionNumber" == "0" ] ; then
  echo -e $INFO 执行退出...
  exit 0
fi
if [ "$partitionNumber" = "" ] || [ "`echo $partitionNumber|sed 's/[0-9]//g'`" != "" ] ; then
  echo -e "$ERROR $R_BOLD 无效的参数，执行退出...$NORM"
  exit 1
fi
if [ "$partitionNumber" -gt `expr $i - 1` ] ; then
  echo -e "$ERROR $R_BOLD 分区序号无效，执行退出...$NORM"
  exit 1
fi

eval entPartition=\$mounts$partitionNumber
echo -e "$INFO 已选择$G_BOLD $entPartition $NORM磁盘分区"
APPS_INSTALL_PATH=$entPartition/swap


mem_size=`free |awk '$0 ~/Swap/{print $4}'`
pool_size=`df |awk '{if($0 ~"'$entPartition'") {print $4}}'`
if [ $pool_size -gt $SWAP_SIZE ]; then
        [ -e "$APPS_INSTALL_PATH/$SWAP_FILE" ] && swapoff $APPS_INSTALL_PATH/$SWAP_FILE
        [ -d "$APPS_INSTALL_PATH" ] && rm -rf $APPS_INSTALL_PATH
        echo -e "$INFO 创建虚拟内存文件夹： $APPS_INSTALL_PATH "
        mkdir -p $APPS_INSTALL_PATH
        echo -en "$INFO 默认虚拟内存大小： [$BOLD$SWAP_SIZE$NORM],新文件大小：\c $BOLD"
        read answer
        if [ "$answer" = "" ]
        then
        {
        echo -e "$INFO 虚拟内存大小未改变"
        }
        else
        {
             if [ "$answer" != "" ] && [ "`echo $answer|sed 's/[0-9]//g'`" = "" ] && [ $answer -lt $pool_size ]
             then
             {
                  SWAP_SIZE=$answer
                  echo -en "$INFO 虚拟内存大小已改变： $BOLD[$SWAP_SIZE]$NORM \n"
             }
            else
            {
                  echo -e "$ERROR $R_BOLD 无效的参数！ $NORM"
                  exit 1
            }
            fi
        }
        fi
       swap_count=`expr $SWAP_SIZE / 1000 - 1`
       echo -e "$INFO dd if=/dev/zero of=$APPS_INSTALL_PATH/$SWAP_FILE bs=1M count=$swap_count"
       dd if=/dev/zero of=$APPS_INSTALL_PATH/$SWAP_FILE bs=1M count=$swap_count
       echo -e "$INFO 已创建虚拟内存文件： $APPS_INSTALL_PATH/$SWAP_FILE"
       mkswap $APPS_INSTALL_PATH/$SWAP_FILE
       echo -e "$INFO $G_BOLD 虚拟内存路径：$APPS_INSTALL_PATH/$SWAP_FILE $NORM"
       swapon $APPS_INSTALL_PATH/$SWAP_FILE

           swap_info

       fi
       echo -e "$INFO 是否创建启动项？ y? :\c "
       read yor
       if [ "$yor" = "y" ]
       then
       {
       [ -e "/jffs/scripts/services-start" ] && [ `cat /jffs/scripts/services-start |awk '{if($0 ~/swapon/) {print $0}}'|wc -l` -ge 1 ] &&\
       sed -i 'N;/\n.*swapon/!P;D' /jffs/scripts/services-start && sed -i '/swapon/d' /jffs/scripts/services-start
       [ ! -e "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
       [ `grep "#!/bin/sh" /jffs/scripts/services-start |wc -l` -lt 1 ] && sed -i '1i#!\/bin\/sh' /jffs/scripts/services-start
       sed -i '1asleep 30' /jffs/scripts/services-start
       sed -i '2aswapon '$APPS_INSTALL_PATH'/'$SWAP_FILE'' /jffs/scripts/services-start
           chmod 755 /jffs/scripts/services-start
       echo -e "$INFO $G_BOLD开机启动项已创建！ $NORM"
       }
       else
       {
       echo -e "$INFO $G_BOLD开机启动项未创建成功，执行退出... $NORM"
       exit 1
       }
       fi
       ;;
  stop)
echo -e "$INFO 请选择要卸载虚拟内存的文件路径"
echo -e "$INFO 检查可用的挂载分区......"
for mounted in `/bin/mount |awk '{if($0 ~/mnt/){ print $3}}'` ; do
  echo -e "$G_BOLD [$i] --> $mounted $NORM"
  eval mounts$i=$mounted
  i=`expr $i + 1`
done

if [ $i == "1" ] ; then
  echo -e "$ERROR $R_BOLD 未找到挂载磁盘，执行退出。$NORM"
  exit 1
fi

echo -en "$INPUT $BOLD 请输入磁盘分区序号或键入 0 退出程序 $NORM\n$BOLD[0-`expr $i - 1`]$NORM: "
read partitionNumber
if [ "$partitionNumber" == "0" ] ; then
  echo -e $INFO 执行退出...
  exit 0
fi
if [ "$partitionNumber" = "" ] || [ "`echo $partitionNumber|sed 's/[0-9]//g'`" != "" ] ; then
  echo -e "$ERROR $R_BOLD 无效的参数，执行退出...$NORM"
  exit 1
fi
if [ "$partitionNumber" -gt `expr $i - 1` ] ; then
  echo -e "$ERROR $R_BOLD 分区序号无效，执行退出...$NORM"
  exit 1
fi

eval entPartition=\$mounts$partitionNumber
echo -e "$INFO 已卸载$G_BOLD $entPartition/swap/$SWAP_FILE $NORM虚拟内存文件"
APPS_INSTALL_PATH=$entPartition/swap

       [ -e "/jffs/scripts/services-start" ] && [ `cat /jffs/scripts/services-start |awk '{if($0 ~/swapon/) {print $0}}'|wc -l` -ge 1 ] &&\
       sed -i 'N;/\n.*swapon/!P;D' /jffs/scripts/services-start && sed -i '/swapon/d' /jffs/scripts/services-start
       [ -e "$APPS_INSTALL_PATH/$SWAP_FILE" ] && swapoff $APPS_INSTALL_PATH/$SWAP_FILE
       [ -d "$APPS_INSTALL_PATH" ] && rm -rf $APPS_INSTALL_PATH
           swap_info
       ;;

  info)
       swap_info
       ;;

  *)
  exit 1
  ;;
esac
