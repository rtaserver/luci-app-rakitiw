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
flag_file="/tmp/.script_modemreconnect"
apn="internet"
host="google.com,1.1.1.1"
device_modem="ppp0"
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
            for current_host in $(echo $host | tr "," "\n")
            do
                ping -q -c 1 -W 1 -I ${device_modem} ${current_host} > /dev/null
                if [ $? -eq 0 ]
                then
                    return 0
                fi
            done
            return 1
        }

        # Fungsi untuk memeriksa apakah skrip sudah berjalan sebelumnya
        check_previous_execution() {
            if [ -e "$flag_file" ]; then
                log "Skrip sudah berjalan sebelumnya. Tunggu sampai selesai atau hapus file $flag_file jika skrip sebelumnya tidak selesai."
                #exit 1
            else
                touch "$flag_file"
            fi
        }

        # Fungsi untuk membersihkan file penanda setelah skrip selesai
        cleanup() {
            rm -f "$flag_file"
        }

        # Memanggil fungsi pemeriksaan
        check_previous_execution

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
            log "Internet aktif. Keluar dari skrip..."
            # Membersihkan file penanda setelah selesai
            cleanup
            # exit 0
        else
            log "Upaya maksimal tercapai. Internet masih mati. Restart modem akan dijalankan"
            echo AT^RESET | atinout - "$modem_port" - && sleep 20 && ifdown "$interface_modem" && ifup "$interface_modem"
            # Membersihkan file penanda setelah selesai
            cleanup
            # exit 1
        fi
        sleep 5  # Tunggu sebelum memeriksa koneksi lagi
    done
else
    exit 1  # Keluar dari script jika status_rakitan adalah false
fi
