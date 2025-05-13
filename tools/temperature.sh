#!/bin/sh

# 2025-05-01 by Matt Simerson <matt@tnpi.net>

HOSTNAME="$(hostname)"

do_cpu() {
    i=0
    out="cpu,host=$HOSTNAME"

    if [ -e "/sys/class/thermal/thermal_zone0/temp" ]; then
        # Raspberry Pi
        value=$(awk '{print $1/1000}' /sys/class/thermal/thermal_zone0/temp)
        echo "$out temp0=$value"

    elif [ -n "$(sysctl -qn dev.cpu.0.temperature)" ]; then
        while [ $i -lt $(sysctl -n hw.ncpu) ]; do
            value=$(sysctl -n dev.cpu.${i}.temperature 2>/dev/null)

            if [ -n "$value" ]; then
                if [ "$i" = "0" ]; then
                    out="$out temp$i=${value%?}"
                else
                    out="$out,temp$i=${value%?}"
                fi
            fi
            i=$((i + 1))
        done
        echo $out
    else
        # try ACPI
        value=$(sysctl -qn hw.acpi.thermal.tz1.temperature)

        if [ -z "$value" ]; then
            value=$(sysctl -qn hw.acpi.thermal.tz0.temperature)
        fi

        if [ -z "$value" ]; then
            # try Intel PCH (Skylake)
            value=$(sysctl -qn dev.pchtherm.0.temperature)
        fi

        if [ -n "$value" ]; then
            value="${value%?}"
            echo "$out temp0=$value"
        fi
    fi
}

do_gpu() {
    if [ -x "/usr/bin/vcgencmd" ]; then
        temp=$(sudo /usr/bin/vcgencmd measure_temp | sed -e 's/[^0-9\.]//g')
        if [ -n "$temp" ]; then
            echo "gpu,host=$HOSTNAME temp=$temp"
        fi
    fi
}

do_freq() {
    # Pi4 range: 600 - 1500 MHz
    out="cpu,host=$HOSTNAME freq0"

    if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq" ]; then
        # Linux / Pi OS / Ubuntu
        value=$(/usr/bin/awk '{print $1/1000}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
        echo "$out=$value"
    elif [ -n "$(sysctl -qn dev.cpu.0.freq 2>/dev/null)" ]; then
        # FreeBSD
        i=0
        while [ $i -lt "$(sysctl -n hw.ncpu)" ]; do
            freq=$(sysctl -n dev.cpu.$i.freq 2>/dev/null)
            
            if [ -n "$freq" ]; then
                if [ "$i" = "0" ]; then
                    out="$out=$freq"
                else
                    out="$out,freq$i=$freq"
                fi
            fi
            i=$((i + 1))
        done
        echo "$out"
    fi
}

get_disk_temp() {
    if [ -x "/usr/local/sbin/smartctl" ]; then
        sudo /usr/local/sbin/smartctl -A /dev/$1 | grep ^Temperature: | awk '{print $2}'
    fi
}

do_disk() {
    out="disk,host=$HOSTNAME"
    i=0
    found=0
    while [ $i -lt 4 ]; do
        temp=$(get_disk_temp "nvme$i")
        if [ -n "$temp" ]; then
            if [ "$found" = "0" ]; then
                out="$out temp${i}=$temp"
            else
                out="$out,temp${i}=$temp"
            fi
            found=$((found + 1))
        fi
        i=$((i + 1))
    done
    if [ $found -gt 0 ]; then
        echo $out
    fi
}

do_sudo() {
    _sd=/usr/local/etc/sudoers.d
    if [ ! -d "$_sd" ]; then _sd=/etc/sudoers.d; fi
    if [ ! -d "$_sd" ]; then
        echo "No sudoers.d directory found"
        exit 1
    fi

    if [ -x /usr/bin/vcgencmd ]; then
        echo 'telegraf ALL=(ALL) NOPASSWD: /usr/bin/vcgencmd' >> "$_sd/telegraf"
    fi

    if [ -x /usr/local/sbin/smartctl ]; then
        echo 'telegraf ALL=(ALL) NOPASSWD: /usr/local/sbin/smartctl' >> "$_sd/telegraf"
    fi
}

case "$1" in
  cpu)
    do_cpu
    ;;  
  gpu)
    do_gpu
    ;;  
  freq)
    do_freq
    ;;  
  disk)
    do_disk
    ;;
  sudo)
    do_sudo
    ;;
  all)
    do_freq
    do_cpu
    do_gpu
    do_disk
    ;;
  *)
    echo "Usage: $0 {cpu|gpu|freq|disk|all}"
    exit 1
    ;;
esac
