#!/bin/bash

y="y"
yes="yes"
disk_name=`df -h|grep sd|grep -vE '/$'|awk '{print $1}'`
#disk_name=`df -h|grep sd|awk '{print $1}'`
disk_cmd="/home/sandbox/tos/data/disk_cmd"
disk_cmd_status="/home/sandbox/tos/data/disk_cmd_status"
reboot="sudo reboot"

#结果展示不再重定向不可见,如果有串口可以看见打印信息.
disk_check()
{
    if [ -n "$disk_name" ];then
        read -p "Must reboot the device, check disk become effective. 
Do you want to reboot now?[Y/N]:" sure
        if [ ${sure,,} = ${y,,} -o $sure = ${yes,,} ];then
            echo "Disk $disk_name will check."
            echo -n "e2fsck -p $disk_name; echo \$? > $disk_cmd_status" > $disk_cmd
            echo "system reboot."
            $reboot
        fi
    else
        echo "System disk not support check"
    fi
}

disk_format()
{
    if [ -n "$disk_name" ];then
        read -p "Note: Do format disk will make data missed, Are you continue?[Y/N]:" sure
        if [ ${sure,,} = ${y,,} -o $sure = ${yes,,} ];then
            read -p "Format disk default run fast path, Are you continue?[Y/N]" fast
            if [ ${fast,,} = ${y,,} -o $fast = ${yes,,} ];then
                echo "Fast path to run mkfs.ext4"
                echo -n "mkfs.ext4 -F ${disk_name}; echo \$? > $disk_cmd_status" > $disk_cmd
                echo "system reboot."
                $reboot
            else
                read -p "Check the device for bad blocks before format disk(a lot time), Are you continue?[Y/N]" slow
                if [ ${slow,,} = ${y,,} -o $sure = ${yes,,} ];then
                    echo "Slow path to run mkfs.ext4"
                    echo -n "mkfs.ext4 -Fc ${disk_name}; echo \$? > $disk_cmd_status" > $disk_cmd
                    echo "system reboot."
                    $reboot
                fi
            fi
        fi
    else
        echo "System disk not support format"
    fi
}

disk_status()
{
    printf "%-14s %-16s %6s %5s %6s %4s\n" "Filesystem" "Type" "Size" "Used" "Avail" "Use%"
    printf "%-14s %-16s %6s %5s %6s %4s\n" `df -hT|grep sd|awk '{print $1,$2,$3,$4,$5,$6}'`
}

if [ $# -eq 1 ];then
    case $1 in
        status)
            disk_status
            ;;
        check)
            disk_check
            ;;
        format)
            disk_format
            ;;
        *)
            echo "Request error."
            exit
    esac
else
    echo "Error format, Please try again."
    exit
fi

#if [ -e $disk_cmd ];then
#    cmd=`cat $disk_cmd`
#    if [ -n $cmd ];then
#        $cmd
#        rm -rf $disk_cmd
#    fi
#fi
