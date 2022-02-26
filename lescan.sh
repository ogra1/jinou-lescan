#! /bin/sh

clear

ADDR="F0 F1 FB E0 CE D6"

cleanup(){
  kill -9 $HCI_PID >/dev/null 2>&1 || true
}

hcitool lescan --duplicates >/dev/null 2>&1 &
HCI_PID=$!

trap cleanup 0 1 2 3 13 15

hcidump --raw | grep --line-buffered "$ADDR" | while read line; do
    DATA="$(echo $line  | sed "s/^AA 0E FF //;s/$ADDR //")"
    echo $DATA | while read -r prefix temp1 temp2 reserved hum1 hum2 batt rssi; do

    PREFIX="+"
    if [ "$prefix" -ne "00" ]; then
        PREFIX="-"
    fi
    TEMP="${PREFIX}$(printf "%d" 0x$temp1),$(printf "%0d" $temp2) °C"
    HUM="$(printf "%d" 0x$hum1),$(printf "%0d" $hum2) %"
    BATTERY="$(printf "%d" 0x$batt)%"
    RSSI="-$(($(printf "%d" 0x$rssi)-100))%"

    clear
    date +"%d.%m.%Y %H:%M"
    echo
    echo "Temperature:\t$TEMP"
    echo "Humidity:\t $HUM"
    echo "Battery:\t $BATTERY"
    echo "RSSI:\t\t$RSSI"
  done
done
