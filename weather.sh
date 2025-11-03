#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

LAT="56.01"
LON="92.77"

URL="https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&APPID=${API_KEY}&units=metric"

MAX_REQUEST_ATTEMPTS=5
REQUEST_ATTEMPT=0
while true; do
    weather_json=$(curl -s $URL)
    curl_exit_code=$?
    if [ $curl_exit_code -eq 0 ] && [ -n "$weather_json" ]; then
       break
    else
       ((REQUEST_ATTEMPT++))
       if [ $REQUEST_ATTEMPT -eq $MAX_REQUEST_ATTEMPTS ]; then
            echo " Weather N/A "
            exit
       fi 
       sleep 5
    fi
done

get_wind_direction_short() {
   local deg=$1
   local directions=("N" "NE" "E" "SE" "S" "SW" "W" "NW")
   local index=$(( (($deg + 22) % 360) / 45 ))
   echo "${directions[$index]}"
}

get_weather_icon_by_code() {
   case $1 in
      "01d") echo "☀️" ;;
      "01n") echo "🌙" ;;
      "02d"|"03d") echo "⛅" ;;
      "02n"|"03n"|"04d"|"04n") echo "☁️" ;;
      "09d"|"09n"|"10d"|"10n") echo "🌧️" ;;
      "11d"|"11n") echo "⛈️" ;;
      "13d"|"13n") echo "❄️" ;;
      "50d"|"50n") echo "🌫️" ;;
      *) echo "Unknown icon code" ;;
   esac
}

celsius_temp=$(echo "$weather_json" | jq -r '.main.temp')
celsius_int=$(echo "$celsius_temp" | awk '{printf "%.0f", $1}')

sunset_timestamp=$(echo "$weather_json" | jq -r '.sys.sunset')
sunset_time=$(date -d "@$sunset_timestamp" +%H:%M)

wind_speed=$(echo "$weather_json" | jq -r '.wind.speed')
wind_speed_int="${wind_speed%.*}"

wind_deg=$(echo "$weather_json" | jq -r '.wind.deg')
wind_direction_short=$(get_wind_direction_short $wind_deg)

pressure=$(echo "$weather_json" | jq -r '.main.pressure')
pressure_hg=$(echo "scale=0; ( $pressure / 1.333 ) + 0.5 / 1" | bc)

humidity=$(echo "$weather_json" | jq -r '.main.humidity')

icon_code=$(echo "$weather_json" | jq -r '.weather[0].icon')
weather_icon=$(get_weather_icon_by_code $icon_code)


echo " ${weather_icon} ${celsius_int}°C ${wind_speed_int} m/s (${wind_direction_short}) ${pressure_hg} mmHg ${humidity}% ${sunset_time} ↓"



