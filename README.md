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


---
INFORMATION TESTED
---
#### Modem Rakitan:
* Dell Dw5821e
* Fibocom L850 GL
* Fibocom L860 GL

#### Modem HP:
* Semua Tipe HP Root / Non Root
> Jangan Lupa USB Debugging Aktif

#### Modem Huawei / Orbit:
* Huawei B310s-22
* Huawei B312-926
* Huawei B315s-22
* Huawei B525s-23a
* Huawei B525s-65a
* Huawei B715s-23c
* Huawei B528s
* Huawei B535-232
* Huawei B628-265
* Huawei B612-233
* Huawei B818-263
* Huawei E5186s-22a
* Huawei E5576-320
* Huawei E5577Cs-321
* Huawei E8231
* SoyeaLink B535-333
* Huawei E3131
* Huawei E3372
* Huawei E3531
* Huawei 5G CPE Pro 2 (H122-373)
* Huawei 5G CPE Pro (H112-372)

(probably will work for other Huawei LTE devices too)
---
INSTALL & UPGRADE
---
1. Upload File IPK Ke Folder Root (biar gampang)
2. Buka / Akses Terminal Openwrt
3. Stop Dan Hapus `luci-app-rakitiw` dahulu Jalankan di Terminal. Jika Fresh Install Bisa Skip Ini Lanjut No 4
```
$ /etc/init.d/rakitiw stop
$ opkg remove luci-app-rakitiw
```
4. Setelah Terhapus Jalankan Kembali Perintah ini di Terminal
```
$ opkg update
$ cd /root
$ opkg install luci-app-rakitiw*.ipk
```
5. Tunggu Hingga Proses Instalasi Selesai. *Pastika Ada Koneksi Internet*
6. Jika Gagal Install Atau Upgrade Coba Update Depends Secara Manual
```
$ opkg update
$ opkg install modemmanager
$ opkg install python3-pip
$ pip3 install requests
$ pip3 install huawei-lte-api
$ opkg install luci-app-rakitiw*.ipk --force-reinstall
```
> Abaikan Jika Ada Error Atau Warning
7. Jika Proses Instalasi Berhasil Buka Modem Rakitan Di Tab Modem
8. Atau Bisa : http://192.168.1.1/rakitiw - Sesuaikan Dengan IP OpenWrt

Preview
---


* Full View
<p align="center">
    <img src="pc.png">
</p>
