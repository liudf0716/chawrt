#!/bin/sh

# 定义 ANSI 颜色代码
RESET='\033[0m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'

# 获取 CPU 核心数用于负载计算
cores=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)
[ -z "$cores" ] || [ "$cores" -eq 0 ] && cores=1  # 默认单核

# 获取负载并添加分级颜色
load_raw=$(awk '{print $1}' /proc/loadavg)
load_percent=$(awk -v l="$load_raw" -v c="$cores" 'BEGIN {printf "%.0f", (l/c)*100}')

# 根据负载百分比设置颜色
if [ "$load_percent" -lt 60 ]; then
    load="${GREEN}${load_percent}%%${RESET}"
else
    load="${RED}${load_percent}%%${RESET}"
fi

# 获取 uptime
uptime=$(uptime | awk -F'up|,' '{gsub(/^[ ]+/, "", $2); print $2}')

# 获取内存信息 - 修复格式问题
mem_info=$(free | awk '/Mem:/ {
    used_mb = $3 / 1024;
    total_mb = $2 / 1024;
    printf "%.0f%%%% of %.0fM", (used_mb * 100) / total_mb, total_mb
}')

# 获取 IP 地址
ipaddr=$(ip -4 addr show br-lan 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
[ -z "$ipaddr" ] && ipaddr=$(ip -4 addr show eth0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
[ -z "$ipaddr" ] && ipaddr="N/A"

# 获取 CPU 温度并添加分级颜色
temp="N/A"
for path in /sys/class/thermal/thermal_zone*/temp \
            /sys/class/hwmon/hwmon*/temp1_input; do
    if [ -f "$path" ]; then
        read raw_temp < "$path" 2>/dev/null
        if [ -n "$raw_temp" ] && [ "$raw_temp" -eq "$raw_temp" ] 2>/dev/null; then
            temp_value=$(( (raw_temp + 500) / 1000 ))
            
            # 根据温度设置颜色
            if [ "$temp_value" -lt 60 ]; then
                temp="${GREEN}${temp_value}°C${RESET}"
            else
                temp="${RED}${temp_value}°C${RESET}"
            fi
            break
        fi
    fi
done

# 获取根分区使用情况 - 修复格式问题
root_usage=$(df -h / | awk 'NR==2 {printf "%s of %s", $5, $2}')
root_usage=$(echo $root_usage | sed 's/%/%%/')

# 输出 MOTD 信息（带颜色）
echo
printf "System load:   ${load}		Up time:	${BLUE}${uptime}${RESET}\n"
printf "Memory usage:  ${GREEN}${mem_info}${RESET}	IP:		${BLUE}${ipaddr}${RESET}\n"
printf "CPU temp:      ${temp}		Usage of /:	${BLUE}${root_usage}${RESET}\n"
echo