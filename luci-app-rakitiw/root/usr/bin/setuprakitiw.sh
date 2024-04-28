#!/bin/bash
# Copyright 2024 RTA SERVER

log_file="/var/log/rakitanmanager.log"
exec 1>>"$log_file" 2>&1
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}


log "Setup Modem Rakitiw"
if [[ $(uci -q get rakitiw.cfg.setup) == "nothong" ]]; then

rpid=$(pgrep "rakitanmanager")
if [[ -n $rpid ]]; then
    kill $rpid
fi

log "Setup php uhttpd"
uci set uhttpd.main.index_page='index.php'
uci set uhttpd.main.interpreter='.php=/usr/bin/php-cgi'
uci commit uhttpd

/etc/init.d/uhttpd restart
log "Setup php uhttpd Done"

log "Setup ModemManager"
mm1="/usr/lib/ModemManager/connection.d/10-report-down"
mm2="/usr/lib/ModemManager/connection.d/10-report-down-and-reconnect"
mm3="/usr/lib/ModemManager/connection.d/rakitiw"

if [ -f "$mm1" ]; then
    rm /usr/lib/ModemManager/connection.d/10-report-down
fi
if [ -f "$mm3" ]; then
    if [ -f "$mm2" ]; then
        rm /usr/lib/ModemManager/connection.d/10-report-down-and-reconnect
    fi
    mv "/usr/lib/ModemManager/connection.d/rakitiw" "/usr/lib/ModemManager/connection.d/10-report-down-and-reconnect"
    chmod +x /usr/lib/ModemManager/connection.d/10-report-down-and-reconnect
fi

log "Setup ModemManager Done"

log "Setup Package For Python3"
if which pip3 >/dev/null; then
    # Instal paket 'requests' jika belum terinstal
    if ! pip3 show requests >/dev/null; then
        log "Installing package 'requests'"
        if ! pip3 install requests >>"$log_file" 2>&1; then
            log "Error installing package 'requests'"
            log "Setup Gagal | Mohon Coba Kembali"
            uci set rakitiw.cfg.setup='nothing'
            uci commit rakitiw
            exit 1  # Keluar dari skrip dengan status error
        fi
    else
        log "Package 'requests' already installed"
    fi

    # Instal paket 'huawei-lte-api' jika belum terinstal
    if ! pip3 show huawei-lte-api >/dev/null; then
        log "Installing package 'huawei-lte-api'"
        if ! pip3 install huawei-lte-api >>"$log_file" 2>&1; then
            log "Error installing package 'huawei-lte-api'"
            log "Setup Gagal | Mohon Coba Kembali"
            uci set rakitiw.cfg.setup='nothing'
            uci commit rakitiw
            exit 1  # Keluar dari skrip dengan status error
        fi
    else
        log "Package 'huawei-lte-api' already installed"
    fi
else
    log "Error: 'pip3' command not found"
    log "Setup Gagal | Mohon Coba Kembali"
    uci set rakitiw.cfg.setup='nothing'
    uci commit rakitiw
    exit 1  # Keluar dari skrip dengan status error
fi

else
uci set rakitiw.cfg.setup='sukses'
uci commit rakitiw
log "Setup Done | Modem Rakitiw Berhasil Di Install"
sleep 3
echo -n "" > "$log_file"
log "Clear."
fi