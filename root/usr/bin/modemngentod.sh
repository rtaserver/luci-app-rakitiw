#!/bin/bash
# Copyright 2024 RTA SERVER

log_file="/var/log/modemngentod.log"
exec 1>>"$log_file" 2>&1
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Variabel
modem_rakitan="Disabled"
#===============================
modemmanager="true"
apn="internet"
host="google.com 1.1.1.1 facebook.com whatsapp.com"
device_modem="wwan0"
modem_port="/dev/ttyUSB0"
interface_modem="wan1"
max_attempts="5"
attempt="1"
delay="20"
#===============================

# Dapatkan Info jika menggunakan modemmanager
cfg_nodemmanager=$(awk '/option proto '"'"'modemmanager'"'"'/ {print NR}' /etc/config/network)

# Jika 'modemmanager' tidak ada, jangan lakukan apa-apa
if [ -z "$cfg_nodemmanager" ]; then
    modemmanager="true"
    log "Interface Modemmanager tidak ditemukan Menggunakan Manual Detect."
else
    log "Interface Modemmanager ditemukan."
    modemmanager="true"
    # Dapatkan nama interface
    cfg_interface=$(awk -v cfg_nodemmanager=$cfg_nodemmanager 'NR==cfg_nodemmanager-1 {print $3}' /etc/config/network | tr -d "'")

    # Dapatkan nilai apn
    cfg_apn=$(awk -v cfg_nodemmanager=$cfg_nodemmanager 'NR>cfg_nodemmanager {if ($1=="option" && $2=="apn") print $3; if ($1=="config") exit}' /etc/config/network | tr -d "'")

    interface_modem=$cfg_interface
    apn=$cfg_apn
fi

if [ "$modem_rakitan" = "Enabled" ]; then
    while true; do
        # Berfungsi untuk memeriksa konektivitas internet
        check_internet() {
            local reachable=false

            for pinghost in $host; do
                if ping -c 1 "$pinghost" &> /dev/null; then
                    log "$pinghost dapat dijangkau"
                    return 0
                    reachable=true
                else
                    log "$pinghost tidak dapat dijangkau"
                fi
            done

            if ! $reachable; then
                return 1
                log "Tidak ada host yang dapat dijangkau."
            fi
        }

        # Periksa konektivitas internet
        while ! check_internet && [ $attempt -lt $max_attempts ]; do
            log "Internet mati. Percobaan $attempt/$max_attempts"
            # Script untuk memperbarui IP
            echo AT+CFUN=4 | atinout - "$modem_port" -
            sleep 4
            echo AT+CFUN=1 | atinout - "$modem_port" -
            modem_info=$(mmcli -L)
            modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
            mmcli -m "$modem_number" --simple-connect="apn=$apn"
            ifup "$interface_modem"
            sleep $delay
            ((attempt++))
        done

        if check_internet; then
            log "Host dapat dijangkau. Melanjutkan ping..."
        else
            log "Upaya maksimal tercapai. Internet masih mati. Restart modem akan dijalankan"
            echo AT^RESET | atinout - "$modem_port" - && sleep 20 && ifdown "$interface_modem" && ifup "$interface_modem"
        fi
        sleep 5  # Tunggu sebelum memeriksa koneksi lagi
    done
else
    exit 1  # Keluar dari script jika status_rakitan adalah false
fi
