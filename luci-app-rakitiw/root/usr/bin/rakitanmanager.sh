#!/bin/bash
# Copyright 2024 RTA SERVER

log_file="/var/log/rakitanmanager.log"
exec 1>>"$log_file" 2>&1
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

status=""
setup_rakitiw()
{
if [ "$status" = "sukses" ]; then
    log "Setup Done | Modem Rakitiw Successfully Installed"
    exit 1
fi

# Begin setup
log "Starting Rakitan Manager Setup"

# Setup Modem Rakitiw
log "Setup Modem Rakitiw"
rpid=$(pgrep "rakitanmanager")
if [[ -n $rpid ]]; then
    kill $rpid
fi

# Setup php uhttpd
log "Setup php uhttpd"
if [ -f "/etc/config/uhttpd" ]; then
    if grep -q "option index_page 'index.php'" /etc/config/uhttpd; then
        log "uhttpd.main.index_page is already set to 'index.php'"
    else
        log "Setting uhttpd.main.index_page to 'index.php'..."
        if uci set uhttpd.main.index_page='index.php' && \
            uci commit uhttpd && \
            /etc/init.d/uhttpd restart; then
            log "uhttpd.main.index_page set to 'index.php' and uhttpd restarted."
        else
            log "Error setting uhttpd.main.index_page to 'index.php'"
            log "Setup php uhttpd failed"
            status="gagal"
            exit 1
        fi
    fi

    if grep -q "option interpreter '.php=/usr/bin/php-cgi'" /etc/config/uhttpd; then
        log "uhttpd.main.interpreter is already set to '.php=/usr/bin/php-cgi'"
    else
        log "Setting uhttpd.main.interpreter to '.php=/usr/bin/php-cgi'..."
        if uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi' && \
            uci commit uhttpd && \
            /etc/init.d/uhttpd restart; then
            log "uhttpd.main.interpreter set to '.php=/usr/bin/php-cgi' and uhttpd restarted."
        else
            log "Error setting uhttpd.main.interpreter to '.php=/usr/bin/php-cgi'"
            log "Setup php uhttpd failed"
            status="gagal"
            exit 1
        fi
    fi
    log "Setup php uhttpd Done"
else
    log "Error: uhttpd configuration file (/etc/config/uhttpd) not found."
    status="gagal"
    exit 1
fi

# Setup ModemManager
log "Setup ModemManager"
mm1="/usr/lib/ModemManager/connection.d/10-report-down"
mm2="/usr/lib/ModemManager/connection.d/10-report-down-and-reconnect"
mm3="/usr/lib/ModemManager/connection.d/rakitiw"

if [ -f "$mm1" ]; then
    rm /usr/lib/ModemManager/connection.d/10-report-down
fi
if [ -f "$mm2" ]; then
    rm /usr/lib/ModemManager/connection.d/10-report-down-and-reconnect
fi

if [ -f "$mm3" ]; then
    if mv "/usr/lib/ModemManager/connection.d/rakitiw" "/usr/lib/ModemManager/connection.d/10-report-down-and-reconnect" && \
        chmod +x /usr/lib/ModemManager/connection.d/10-report-down-and-reconnect; then
        log "Setup ModemManager Done"
    else
        log "Error setting up ModemManager"
        log "Setup ModemManager failed"
        status="gagal"
        exit 1
    fi
fi

# Setup Package For Python3
log "Setup Package For Python3"
if which pip3 >/dev/null; then
    # Instal paket 'requests' jika belum terinstal
    if ! pip3 show requests >/dev/null; then
        log "Installing package 'requests'..."
        if pip3 install requests >>"$log_file" 2>&1; then
            log "Package 'requests' installed successfully"
        else
            log "Error installing package 'requests'"
            log "Setup Package For Python3 failed"
            status="gagal"
            exit 1
        fi
    else
        log "Package 'requests' already installed"
    fi

    # Instal paket 'huawei-lte-api' jika belum terinstal
    if ! pip3 show huawei-lte-api >/dev/null; then
        log "Installing package 'huawei-lte-api'..."
        if pip3 install huawei-lte-api >>"$log_file" 2>&1; then
            log "Package 'huawei-lte-api' installed successfully"
        else
            log "Error installing package 'huawei-lte-api'"
            log "Setup Package For Python3 failed"
            status="gagal"
            exit 1
        fi
    else
        log "Package 'huawei-lte-api' already installed"
    fi
else
    log "Error: 'pip3' command not found"
    status="gagal"
    exit 1
fi

# Set permissions
log "Setting permissions"
if chmod +x /usr/bin/rakitanmanager.sh && \
    chmod +x /usr/bin/modem-orbit.py && \
    chmod +x /etc/init.d/rakitiw; then
    log "Permissions set successfully"
else
    log "Error setting permissions"
    log "Setting permissions failed"
    status="gagal"
    exit 1
fi

status="sukses"
# Setup completion message
log "Setup Done | Modem Rakitiw Successfully Installed"
exit 1
}


modem_status="Disabled"

# Baca file JSON
json_file="/www/rakitiw/data_modem.json"
jenis_modem=()
nama_modem=()
apn_modem=()
interface_modem=()
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
        iporbit_modem[$i]=$(jq -r ".modems[$i].iporbit" "$json_file")
        usernameorbit_modem[$i]=$(jq -r ".modems[$i].usernameorbit" "$json_file")
        passwordorbit_modem[$i]=$(jq -r ".modems[$i].passwordorbit" "$json_file")
        hostbug_modem[$i]=$(jq -r ".modems[$i].hostbug" "$json_file")
        devicemodem_modem[$i]=$(jq -r ".modems[$i].devicemodem" "$json_file")
        delayping_modem[$i]=$(jq -r ".modems[$i].delayping" "$json_file")
    done
}

perform_ping() {
    nama="${1:-}"
    jenis="${2:-}"
    host="${3:-}"
    devicemodem="${4:-}"
    delayping="${5:-}"
    apn="${6:-}"
    interface="${7:-}"
    iporbit="${8:-}"
    usernameorbit="${9:-}"
    passwordorbit="${10:-}"

    max_attempts=5
    attempt=1

    while true; do
        log_size=$(wc -c < "$log_file")
        max_size=$((2 * 2048))
        if [ "$log_size" -gt "$max_size" ]; then
            # Kosongkan isi file log
            echo -n "" > "$log_file"
            log "Log dibersihkan karena melebihi ukuran maksimum."
        fi

        status_Internet=false

        for pinghost in $host; do
            if [ "$devicemodem" = "" ]; then
                ping -q -c 3 -W 3 ${pinghost} > /dev/null
                if [ $? -eq 0 ]; then
                    log "[$jenis - $nama] $pinghost dapat dijangkau"
                    status_Internet=true
                    attempt=1
                else
                    log "[$jenis - $nama] $pinghost tidak dapat dijangkau"
                fi
            else
                ping -q -c 3 -W 3 -I ${devicemodem} ${pinghost} > /dev/null
                if [ $? -eq 0 ]; then
                    log "[$jenis - $nama] $pinghost dapat dijangkau Dengan Interface $devicemodem"
                    status_Internet=true
                    attempt=1
                else
                    log "[$jenis - $nama] $pinghost tidak dapat dijangkau Dengan Interface $devicemodem"
                fi
            fi
        done

        if [ "$status_Internet" = false ]; then
            if [ "$jenis" = "rakitan" ]; then
                log "[$jenis - $nama] Internet mati. Percobaan $attempt/$max_attempts"
                if [ "$attempt" = "1" ]; then
                    log "[$jenis - $nama] Mengaktifkan Mode Pesawat"
                    echo AT+CFUN=4 | atinout - "/dev/ttyUSB0" -
                    sleep 5
                elif [ "$attempt" = "2" ]; then
                    log "[$jenis - $nama] Mencoba Menghubungkan Kembali Modem Dengan APN : $apn"
                    modem_info=$(mmcli -L)
                    modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
                    mmcli -m "$modem_number" --simple-connect="apn=$apn"
                    ifdown "$interface"
                    sleep 5
                    ifup "$interface"
                elif [ "$attempt" = "3" ]; then
                    log "[$jenis - $nama] Restart Modem Manager"
                    /etc/init.d/modemmanager restart
                    sleep 5
                elif [ "$attempt" = "4" ]; then
                    log "[$jenis - $nama] Mencoba Menghubungkan Kembali Modem Dengan APN : $apn"
                    modem_info=$(mmcli -L)
                    modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
                    mmcli -m "$modem_number" --simple-connect="apn=$apn"
                    ifdown "$interface"
                    sleep 5
                    ifup "$interface"
                fi
                attempt=$((attempt + 1))
                
                if [ $attempt -ge $max_attempts ]; then
                    log "[$jenis - $nama] Upaya maksimal tercapai. Internet masih mati. Restart modem akan dijalankan"
                    echo AT^RESET | atinout - "/dev/ttyUSB0" - && sleep 20 && ifdown "$interface" && ifup "$interface"
                    attempt=1
                fi
            elif [ "$jenis" = "hp" ]; then
                log "[$jenis - $nama] Mencoba Menghubungkan Kembali"
                log "[$jenis - $nama] Mengaktifkan Mode Pesawat"
                adb shell cmd connectivity airplane-mode enable
                sleep 2
                log "[$jenis - $nama] Menonaktifkan Mode Pesawat"
                adb shell cmd connectivity airplane-mode disable
                sleep 7
                adb shell ip addr show rmnet_data0 | grep 'inet ' | cut -d ' ' -f 6 | cut -d / -f 1
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
        perform_ping "${nama_modem[$i]}" "${jenis_modem[$i]}" "${hostbug_modem[$i]}" "${devicemodem_modem[$i]}" "${delayping_modem[$i]}" "${apn_modem[$i]}" "${interface_modem[$i]}" "${iporbit_modem[$i]}" "${usernameorbit_modem[$i]}" "${passwordorbit_modem[$i]}" &
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
        setup)
            setup_rakitiw
            ;;
        s)
            main
            ;;
        k)
            rakitiw_stop
            ;;
    esac
done