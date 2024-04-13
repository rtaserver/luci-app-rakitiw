#!/bin/bash
# Copyright 2024 RTA SERVER

log_file="/var/log/rakitanmanager.log"
exec 1>>"$log_file" 2>&1
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Variabel
modem_status="Disabled"
#===============================
modem_rakitan="Enabled"
modem_hp="Disabled"
modem_orbit="Disabled"
#===============================
apn="internet"
host="google.com 1.1.1.1 facebook.com whatsapp.com"
device_modem="wwan0"
modem_port="/dev/ttyUSB0"
interface_modem="wan1"
max_attempts=5
attempt=1
delay="10"
#===============================

rakitiw_start() {
cfg_nodemmanager=$(awk '/option proto '"'"'modemmanager'"'"'/ {print NR}' /etc/config/network)

if [ -z "$cfg_nodemmanager" ]; then
    apn=$apn
else
    cfg_apn=$(awk -v cfg_nodemmanager=$cfg_nodemmanager 'NR>cfg_nodemmanager {if ($1=="option" && $2=="apn") print $3; if ($1=="config") exit}' /etc/config/network | tr -d "'")
    apn=$cfg_apn
fi

    while true; do

	    log_size=$(wc -c < "$log_file")
    	max_size=$((2 * 1024))
    	if [ "$log_size" -gt "$max_size" ]; then
            # Kosongkan isi file log
            echo -n "" > "$log_file"
            log "Log dibersihkan karena melebihi ukuran maksimum."
        fi

        status_Interrnet=false

        for pinghost in $host; do
            if [ "$device_modem" = "" ]; then
                if curl -s -m 5 http://$pinghost &> /dev/null; then
                    log "$pinghost dapat dijangkau"
                    status_Interrnet=true
                else
                    log "$pinghost tidak dapat dijangkau"
                fi
            else
                if curl -s -m 5 --interface $device_modem http://$pinghost &> /dev/null; then
                    log "$pinghost dapat dijangkau Dengan Interface $device_modem"
                    status_Interrnet=true
                else
                    log "$pinghost tidak dapat dijangkau Dengan Interface $device_modem"
                fi
            fi
        done

        if $status_Interrnet; then
            attempt=1
            log "Lanjut NgePING..."
        fi

        if ! $status_Interrnet; then
            log "Internet mati. Percobaan $attempt/$max_attempts"
            if [ "$attempt" = "1" ]; then
                log "Melakukan Restart Interface $interface_modem"
                ifdown "$interface_modem"
            elif [ "$attempt" = "2" ]; then
                log "Mencoba Menghubungkan Kembali Modem Dengan APN : $apn"
                modem_info=$(mmcli -L)
                modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
                mmcli -m "$modem_number" --simple-connect="apn=$apn"
                ifdown "$interface_modem"
                sleep 5      
            elif [ "$attempt" = "3" ]; then
                if [ -z "$cfg_nodemmanager" ]; then
                    log "Mengaktifkan Mode Pesawat $modem_port"
                    echo AT+CFUN=4 | atinout - "$modem_port" -
                    sleep 4
                    log "Menonaktifkan Mode Pesawat $modem_port"
                    echo AT+CFUN=1 | atinout - "$modem_port" -
                else
                    log "Restart Modem Manager"
                    /etc/init.d/modemmanager restart
                fi
                sleep 5
            elif [ "$attempt" = "4" ]; then
                log "Mencoba Menghubungkan Kembali Modem Dengan APN : $apn"
                modem_info=$(mmcli -L)
                modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
                mmcli -m "$modem_number" --simple-connect="apn=$apn"
                ifdown "$interface_modem"
                sleep 5      
            fi
            ifup "$interface_modem"
            attempt=$((attempt + 1))
            sleep $delay
        fi

        if [ $attempt -ge $max_attempts ]; then
            log "Upaya maksimal tercapai. Internet masih mati. Restart modem akan dijalankan"
            echo AT^RESET | atinout - "$modem_port" - && sleep 20 && ifdown "$interface_modem" && ifup "$interface_modem"
            attempt=1
        fi
        sleep 5
    done
}

rakitiw_stop() {
    # Hentikan skrip jika sedang berjalan
    if [ -f /var/run/rakitanmanager.pid ]; then
        modem_status="Enabled"
        kill $(cat /var/run/rakitanmanager.pid)
        rm /var/run/rakitanmanager.pid
        pid=$(pgrep -f rakitanmanager.sh) && kill $pid
    else
        log "Rakitiw is not running."
    fi
}

while getopts ":skrpcvh" rakitiw ; do
    case $rakitiw in
        s)
            if [ -f /var/run/rakitanmanager.pid ]; then
                log "Rakitiw is running now"
            else
                rakitiw_start
            fi
            ;;
        k)
            rakitiw_stop
            ;;
    esac
done