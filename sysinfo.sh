#!/bin/bash

cpu_load=$(mpstat 1 1 | grep "Average" | awk '{printf "%d%%", 100 - $12}')

mem_used=$(free -m | awk 'NR==2{printf "%.1f", $3/1024}')
mem_total=$(free -m | awk 'NR==2{printf "%.1f", $2/1024}')

gpu_temp=$(sensors | grep -A 0 "edge" | awk '{printf "%d", $2}' | sed 's/+//')

cpu_formatted=$(printf "%-8s" "CPU: ${cpu_load}")
mem_formatted=$(printf "%-11s" "${mem_used}/${mem_total}GB")
temp_formatted=$(printf "%-6s" "${gpu_temp}°C")

echo "${cpu_formatted} ${mem_formatted} ${temp_formatted}"
