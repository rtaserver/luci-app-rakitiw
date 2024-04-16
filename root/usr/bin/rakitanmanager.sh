#!/bin/bash
# Copyright 2024 RTA SERVER

log_file="/var/log/rakitanmanager.log"
exec 1>>"$log_file" 2>&1
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

modem_status="Disabled"

# Baca file JSON
json_file="/www/rakitiw/data_modem.json"
jenis_modem=()
nama_modem=()
apn_modem=()
interface_modem=()
portat_modem=()
iporbit_modem=()
usernameorbit_modem=()
passwordorbit_modem=()
hostbug_modem=()
devicemodem_modem=()
delayping_modem=()

parse_json() {
    modems=$(jq -r '.modems | length' "$json_file")
    for ((i = 0; i < modems; i++)); do
        jenis_modem[$i]=$(jq -r ".modems[$i].jenis" "$json_file")
        nama_modem[$i]=$(jq -r ".modems[$i].nama" "$json_file")
        apn_modem[$i]=$(jq -r ".modems[$i].apn" "$json_file")
        interface_modem[$i]=$(jq -r ".modems[$i].interface" "$json_file")
        portat_modem[$i]=$(jq -r ".modems[$i].portat" "$json_file")
        iporbit_modem[$i]=$(jq -r ".modems[$i].iporbit" "$json_file")
        usernameorbit_modem[$i]=$(jq -r ".modems[$i].usernameorbit" "$json_file")
        passwordorbit_modem[$i]=$(jq -r ".modems[$i].passwordorbit" "$json_file")
        hostbug_modem[$i]=$(jq -r ".modems[$i].hostbug" "$json_file")
        devicemodem_modem[$i]=$(jq -r ".modems[$i].devicemodem" "$json_file")
        delayping_modem[$i]=$(jq -r ".modems[$i].delayping" "$json_file")
    done
}

perform_ping() {
    local nama="${1:-}"
    local jenis="${2:-}"
    local host="${3:-}"
    local devicemodem="${4:-}"
    local delayping="${5:-}"
    local apn="${6:-}"
    local modemport="${7:-}"
    local interface="${8:-}"
    local iporbit="${9:-}"
    local usernameorbit="${10:-}"
    local passwordorbit="${11:-}"

    local max_attempts=5
    local attempt=1

    local cfg_nodemmanager=$(awk '/option proto '"'"'modemmanager'"'"'/ {print NR}' /etc/config/network)

    if [ -z "$cfg_nodemmanager" ]; then
        apn=$apn
    else
        cfg_apn=$(awk -v cfg_nodemmanager=$cfg_nodemmanager 'NR>cfg_nodemmanager {if ($1=="option" && $2=="apn") print $3; if ($1=="config") exit}' /etc/config/network | tr -d "'")
        apn=$cfg_apn
    fi

    if ["$modemport" = ""]; then
        modemport="/dev/ttyUSB0"
    fi

    while true; do
        log_size=$(wc -c < "$log_file")
        max_size=$((2 * 1024))
        if [ "$log_size" -gt "$max_size" ]; then
            # Kosongkan isi file log
            echo -n "" > "$log_file"
            log "Log dibersihkan karena melebihi ukuran maksimum."
        fi

        status_Internet=false

        for pinghost in $host; do
            if [ "$devicemodem" = "" ]; then
                ping -q -c 1 -W 1 ${pinghost} > /dev/null
                if [ $? -eq 0 ]; then
                    log "[$jenis - $nama] $pinghost dapat dijangkau"
                    status_Internet=true
                    attempt=1
                    log "[$jenis - $nama] Lanjut NgePING..."
                else
                    log "[$jenis - $nama] $pinghost tidak dapat dijangkau"
                fi
            else
                ping -q -c 3 -W 3 -I ${devicemodem} ${pinghost} > /dev/null
                if [ $? -eq 0 ]; then
                    log "[$jenis - $nama] $pinghost dapat dijangkau Dengan Interface $devicemodem"
                    status_Internet=true
                else
                    log "[$jenis - $nama] $pinghost tidak dapat dijangkau Dengan Interface $devicemodem"
                fi
            fi
        done

        if [ "$status_Internet" = false ]; then
            if [ "$jenis" = "rakitan" ]; then
                log "[$jenis - $nama] Internet mati. Percobaan $attempt/$max_attempts"
                if [ "$attempt" = "1" ]; then
                    log "[$jenis - $nama] Melakukan Restart Interface $interface"
                    ifdown "$interface"
                elif [ "$attempt" = "2" ]; then
                    log "[$jenis - $nama] Mencoba Menghubungkan Kembali Modem Dengan APN : $apn"
                    modem_info=$(mmcli -L)
                    modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
                    mmcli -m "$modem_number" --simple-connect="apn=$apn"
                    ifdown "$interface"
                    sleep 5      
                elif [ "$attempt" = "3" ]; then
                    if [ -z "$cfg_nodemmanager" ]; then
                        log "[$jenis - $nama] Mengaktifkan Mode Pesawat $modemport"
                        echo AT+CFUN=4 | atinout - "$modemport" -
                        sleep 4
                        log "[$jenis - $nama] Menonaktifkan Mode Pesawat $modemport"
                        echo AT+CFUN=1 | atinout - "$modemport" -
                    else
                        log "[$jenis - $nama] Restart Modem Manager"
                        /etc/init.d/modemmanager restart
                    fi
                    sleep 5
                elif [ "$attempt" = "4" ]; then
                    log "[$jenis - $nama] Mencoba Menghubungkan Kembali Modem Dengan APN : $apn"
                    modem_info=$(mmcli -L)
                    modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
                    mmcli -m "$modem_number" --simple-connect="apn=$apn"
                    ifdown "$interface"
                    sleep 5      
                fi

                ifup "$interface"
                attempt=$((attempt + 1))
                
                if [ $attempt -ge $max_attempts ]; then
                    log "[$jenis - $nama] Upaya maksimal tercapai. Internet masih mati. Restart modem akan dijalankan"
                    echo AT^RESET | atinout - "$modemport" - && sleep 20 && ifdown "$interface" && ifup "$interface"
                    attempt=1
                fi
            elif [ "$jenis" = "hp" ]; then
                log "[$jenis - $nama] Mencoba Menghubungkan Kembali"
                log "[$jenis - $nama] Mengaktifkan Mode Pesawat"
                sleep 2
                log "[$jenis - $nama] Menonaktifkan Mode Pesawat"
                adb shell cmd connectivity airplane-mode disable
            elif [ "$jenis" = "orbit" ]; then
                log "[$jenis - $nama] Mencoba Menghubungkan Kembali Modem Orbit / Huawei"
                python3 /usr/bin/modem-orbit.py $iporbit $usernameorbit $passwordorbit
            fi
        fi
        sleep "$delayping"
    done
}

main() {
    parse_json

    # Loop through each modem and perform actions
    for ((i = 0; i < ${#jenis_modem[@]}; i++)); do
        perform_ping "${nama_modem[$i]}" "${jenis_modem[$i]}" "${hostbug_modem[$i]}" "${devicemodem_modem[$i]}" "${delayping_modem[$i]}" "${apn_modem[$i]}" "${portat_modem[$i]}" "${interface_modem[$i]}" "${iporbit_modem[$i]}" "${usernameorbit_modem[$i]}" "${passwordorbit_modem[$i]}" &
    done
}

rakitiw_stop() {
    # Hentikan skrip jika sedang berjalan
    if pidof rakitanmanager.sh > /dev/null; then
        modem_status="Disabled"
        killall -9 rakitanmanager.sh
        log "Rakitiw Berhasil Di Hentikan."
    else
        log "Rakitiw is not running."
    fi
}

while getopts ":skrpcvh" rakitiw ; do
    case $rakitiw in
        s)
            main
            ;;
        k)
            rakitiw_stop
            ;;
    esac
done
