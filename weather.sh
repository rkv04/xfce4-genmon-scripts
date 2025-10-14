#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

LAT="56.01"
LON="92.77"

URL="https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&APPID=${API_KEY}&units=metric"

while true; do
    data=$(curl -s $URL)
    if [ $? -eq 0 ] && [ -n "$data" ]; then
       break
    else
       sleep 10
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

celsius_temp=$(echo "$data" | jq -r '.main.temp')
celsius_int="${celsius_temp%.*}"

sunset_timestamp=$(echo "$data" | jq -r '.sys.sunset')
sunset_time=$(date -d "@$sunset_timestamp" +%H:%M)

wind_speed=$(echo "$data" | jq -r '.wind.speed')
wind_speed_int="${wind_speed%.*}"

wind_deg=$(echo "$data" | jq -r '.wind.deg')
wind_direction_short=$(get_wind_direction_short $wind_deg)

icon_code=$(echo "$data" | jq -r '.weather[0].icon')
weather_icon=$(get_weather_icon_by_code $icon_code)


echo " $weather_icon ${celsius_int}°C ${wind_speed_int} m/s ${wind_direction_short} $sunset_time ↓"

