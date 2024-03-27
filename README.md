<h1 align="center">
  <br>RTA App Rakitiw<br>

</h1>

  <p align="center">
	<img src="https://img.shields.io/github/actions/workflow/status/rtaserver/luci-app-rakitiw/.github%2Fworkflows%2Fbuild.yaml?logo=openwrt&label=Build%20App">
    <img src="https://img.shields.io/github/v/release/rtaserver/luci-app-rakitiw?label=Release%20App">
    <img src="https://img.shields.io/github/downloads/rtaserver/luci-app-rakitiw/total?label=Downloads&color=dark-green">
  </p>
  

<p align="center">
luci-app-rakitiw
</p>
<p align="center">
This OpenWRT Custom Script For Modem
</p>
<br>


Tutor Install Dan Upgrade
---
### Install : 
  1. Download File IPK : https://github.com/rtaserver/luci-app-rakitiw/releases/latest
  2. Pada Bagian Assets Pilih File luci-app-rakitiw_{VersiApp}_all.ipk
  3. Login OpenWrt -> Masuk Ke Tab System -> Software
  4. Klik Update List Tunggu Hingga Selesai Update
  5. Klik Upload Package -> Browse -> Pilih .ipk Yang Sudah Di Download Tadi -> Kilik Upload -> Klik Install
  7. Setelah Selesai Silahkan Cek Pada Bagian Tab Modem
  8. Jika Tidak Muncul Bisa Akses Manual Di : http://192.168.1.1/rakitiw - sesuaikan dengan IP OpenWrt Masing-Masing

## INFO : Jika Update Jangan Lupa Disable Terlebihdahulu :) Kalo Mau Aman Bisa Disable Terus Uninstall Baru Install Yang Baru
---
1. Sebelum Memasukan Script Ini Di Crontabs Alangkah Baiknya Cek PING Internet Di CMD Terlebihdahulu
   Cara Cek Ping Di Terminal OpenWrt "ping -I wwan0 bug.com"
2. Tentang Variabel Untuk Di Edit
   1. APN Modem = Masukan APN kalian Atau Samakan Dengan Di Interface Modem Manager Jika Menggunakan Modem Manager
   2. Host / Bug Untuk Ping = Tempat Pengisian Host / Bug Untuk Cek Internet
   3. Nama Interface Modem = Ini Untuk Interface Device Modem Biasanya Default wwan0
   4. mInterface Modem = Port Modem Untuk AT Command
   5. interface_modem = Nama Interface Modem
   6. Port Modem = Ini Untuk Upaya Percobaan Sebelemum Eksekusi Restart Modem
   7. Jumlah Percobaan = Default 1 Agar Balik ke Percobaan Pertama
   8. Jeda Waktu Atau Delay / Bentuk Detik = Waktu / Jeda Sebelum Melanjutkan Eksekusi Berikutnya Untuk attempt Yang Ada Di Atas

3. Button Save Untuk Menyimpan Konfigurasi
4. Button Enable Untuk Mengaktifkan
5. Button Disable Untuk Monenaktifkan




Preview
---


* Full View
<p align="center">
    <img src="pc.png">
</p>
