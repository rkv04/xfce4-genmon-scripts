#!/bin/bash

export LC_ALL=C

cpu_load=$(mpstat 1 1 | grep "Average" | awk '{printf "%d%%", 100 - $12}')

mem_used=$(free -m | awk 'NR==2{printf "%.1f", $3/1024}')
mem_total=$(free -m | awk 'NR==2{printf "%.1f", $2/1024}')

disk_free=$(df -m / | awk 'NR==2{printf "%.1f", $4/1024}')
disk_total=$(df -m / | awk 'NR==2{printf "%.1f", $2/1024}')

gpu_temp=$(sensors | grep -A 0 "edge" | awk '{printf "%d", $2}' | sed 's/+//')

cpu_formatted=$(printf "%-10s" "CPU: ${cpu_load}")
mem_formatted=$(printf "%-11s" "${mem_used}/${mem_total}GB")
disk_formatted=$(printf "%-14s" "${disk_free}/${disk_total}GB")
temp_formatted=$(printf "%-4s" "${gpu_temp}°C")

echo "${cpu_formatted} ${mem_formatted} ${disk_formatted} ${temp_formatted}"
