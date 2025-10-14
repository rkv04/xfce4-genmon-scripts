#!/bin/bash

cpu_load=$(mpstat 1 1 | grep "Average" | awk '{printf "%d%%", 100 - $12}')
gpu_load=$(cat /sys/class/drm/card0/device/gpu_busy_percent)

mem_available=$(cat /proc/meminfo | grep MemAvailable | awk '{printf ("%0.1f", $2/1024000)}')
mem_total=$(cat /proc/meminfo | grep MemTotal | awk '{printf ("%0.1f", $2/1024000)}')

gpu_temp=$(sensors | grep -A 0 "edge" | awk '{print $2}' | sed 's/+//')

cpu_formatted=$(printf "%-8s" "CPU: ${cpu_load}")
gpu_formatted=$(printf "%-8s" "GPU: ${gpu_load}%")
mem_formatted=$(printf "%-11s" "${mem_available}/${mem_total}GB")
temp_formatted=$(printf "%-6s" "${gpu_temp}")

echo "${cpu_formatted} ${gpu_formatted} ${mem_formatted} ${temp_formatted} "
