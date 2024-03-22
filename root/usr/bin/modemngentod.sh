#!/bin/bash
# Copyright 2024 - RTA SERVER
# By : RizkiKotet
#
# Tutor Singkat Script
# 1. Sebelum Memasukan Script Ini Di Crontabs Alangkah Baiknya Cek PING Internet Di CMD Terlebihdahulu
#    Cara Cek Ping Di Terminal OpenWrt "ping -I wwan0 bug.com"
# 2. Tentang Variabel Untuk Di Edit
#    > flag_file = File Temp Untuk Cek Script Yang Di Jalankan Apakah Sudah Ada Apa Belum
#    > apn = Masukan APN kalian Atau Samakan Dengan Di Interface Modem Manager Jika Menggunakan Modem Manager
#    > host = Tempat Pengisian Host / Bug Untuk Cek Internet
#    > interface = Ini Untuk Interface Device Modem Biasanya Default wwan0
#    > modem_port = Port Modem Untuk AT Command
#    > interface_modem = Nama Interface Modem
#    > max_attempts = Ini Untuk Upaya Percobaan Sebelemum Eksekusi Restart Modem
#    > attempt = Default 1 Agar Balik ke Percobaan Pertama
#    > delay = Waktu / Jeda Sebelum Melanjutkan Eksekusi Berikutnya Untuk attempt Yang Ada Di Atas
# 3. Penerapan Di CronJobs : Kalo Saya Di Sini Biar Simpel
#    > * * * * * /root/modemngentod.sh
#    > Untuk "* * * * *" Dimana Script Akan Di Jalankan Setiap Menit
#      Gak Usah Khawatir Modem Rekonek Rekonek Terus Karena Script Ini
#      Gak Bakal Jalan Lebih Dari 1 Kali Sebelum Script Sebelumnya Selesai 
#      Jadi Aman Saja :v 
#    > Untuk "/root/modemngentod.sh" Ini Dimana Ente Nyimpenin Script nya
#      Jangan Lupa Permissions nya di Ubah ke "0755"
#      Atau di CMD Ketik "chmod +x /root/modemngentod.sh"

# Variabel
#===============================
flag_file="/tmp/.script_modemreconnect"
apn="internet"
host="google.com,8.8.8.8,1.1.1.1"
interface="wwan0"
modem_port="/dev/ttyUSB0"
interface_modem="wan1"
max_attempts="5"
attempt="1"
delay="20"
#===============================

# Berfungsi untuk memeriksa konektivitas internet
check_internet() {
    for current_host in $(echo $host | tr "," "\n")
    do
        ping -q -c 1 -W 1 -I ${interface} ${current_host} > /dev/null
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
        echo "Skrip sudah berjalan sebelumnya. Tunggu sampai selesai atau hapus file $flag_file jika skrip sebelumnya tidak selesai."
        exit 1
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
    echo "Internet mati. Percobaan $attempt/$max_attempts"
    
    # Script untuk memperbarui IP
    echo  AT+CFUN=4 | atinout - "$modem_port" -
    sleep 4
    echo  AT+CFUN=1 | atinout - "$modem_port" -
    modem_info=$(mmcli -L)
    modem_number=$(echo "$modem_info" | awk -F 'Modem/' '{print $2}' | awk '{print $1}')
    mmcli -m "$modem_number" --simple-connect="apn=$apn"
    ifup "$interface_modem"
    sleep $delay
    ((attempt++))
done

if check_internet; then
    echo "Internet aktif. Keluar dari skrip..."
    # Membersihkan file penanda setelah selesai
    cleanup
    exit 0
else
    echo "Upaya maksimal tercapai. Internet masih mati. Restart modem akan dijalankan"
    echo  AT^RESET | atinout - "$modem_port" - && sleep 20 && ifdown "$interface_modem" && ifup "$interface_modem"
    # Membersihkan file penanda setelah selesai
    cleanup
    exit 1
fi