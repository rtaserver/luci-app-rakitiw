<?php
    // Lokasi file bash
    $bash_file = '/usr/bin/modemngentod.sh';

    // Baca file bash
    $bash_content = file_get_contents($bash_file);

    // Ekstrak variabel dari file bash
    preg_match_all('/(\w+)="(.*)"/', $bash_content, $matches);

    // Buat array untuk menyimpan variabel
    $variables = array();
    for ($i = 0; $i < count($matches[1]); $i++) {
        if ($matches[1][$i] !== 'connect') {
            $variables[$matches[1][$i]] = $matches[2][$i];
        }
    }

    // Cek apakah form disubmit
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Update variabel dengan data dari form
        foreach ($_POST as $key => $value) {
            if (array_key_exists($key, $variables)) {
                $variables[$key] = $value;
            }
        }

        // Update file bash dengan variabel baru
        foreach ($variables as $key => $value) {
            if ($key !== 'connect') {
                $bash_content = preg_replace('/' . $key . '=".*"/', $key . '="' . $value . '"', $bash_content);
            }
        }
        file_put_contents($bash_file, $bash_content);
    }

    if (isset($_POST['enable'])) {
        // Tambahkan script ke cronjob
        exec('(crontab -l; echo "* * * * * /usr/bin/modemngentod.sh") | crontab -');
        $status = 'Enabled';
    } elseif (isset($_POST['disable'])) {
        // Hapus script dari cronjob
	exec('crontab -l | grep -v "/usr/bin/modemngentod.sh" | crontab -');
	// Hapus file /tmp/.script_modemreconnect
	exec('rm -f /tmp/.script_modemreconnect');
        $status = 'Disabled';
    } else {
        // Cek apakah script sudah ada di cronjob
        $output = shell_exec('crontab -l');
        $status = (strpos($output, '/usr/bin/modemngentod.sh') !== false) ? 'Enabled' : 'Disabled';
    }

    $contnetwork = file_get_contents('/etc/config/network'); // Membaca isi file
    $linesnetwork = explode("\n", $contnetwork); // Memisahkan setiap baris

    $interface_modem = [];
    foreach ($linesnetwork as $linenetwork) {
        if (strpos($linenetwork, 'config interface') !== false) {
            // Menemukan baris yang berisi 'config interface'
            $parts = explode(' ', $linenetwork);
            $interface = trim(end($parts), "'"); // Menghapus tanda petik
            $interface_modem[] = $interface; // Menambahkan nama interface ke array
        }
    }

    // Mendapatkan daftar device
    $cmddevice = 'ip link show'; // Perintah untuk mendapatkan daftar device
    $outdev = shell_exec($cmddevice); // Menjalankan perintah dan menyimpan outputnya

    // Menguraikan output
    $linesdevice = explode("\n", $outdev);
    $device_modem = [];
    foreach ($linesdevice as $linedevice) {
        if (preg_match('/^\d+: (\w+):/', $linedevice, $matches)) {
            $device_modem[] = $matches[1]; // Menambahkan nama device ke array
        }
    }


?>
<!doctype html>
<html lang="en">
<head>
    <?php
        $title = "Home";
        include("head.php");
		exec('chmod -R 755 /usr/bin/modemngentod.sh');
    ?>
</head>
<body>
<div id="app">
    <?php include('navbar.php'); ?>
    <form method="POST" class="mt-5">
    <div class="container-fluid" >
        <div class="row py-2">
            <div class="col-lg-8 col-md-9 mx-auto mt-3">
                <div class="card">
                    <div class="card-header">
                        <div class="text-center">
                            <h4><i class="fa fa-home"></i> Modem Rakitan Manager</h4>
                        </div>                        
                    </div>					
                    <div class="card-body">						
                        <div class="card-body py-0 px-0">
                            <div class="body">
                                <div class="text-center">
                                    <img src="curent.svg" alt="Curent Version">
                                    <img alt="Latest Version" src="https://img.shields.io/github/v/release/rtaserver/luci-app-rakitiw?display_name=tag&logo=openwrt&label=Latest%20Version&color=dark-green">
                                </div>
                                <br>  
                            </div>    
                            <div class="row">
                                <div class="col-lg-6 col-md-6">
									<i class="fa fa-inbox"></i>
                                    <?php if ($status == 'Enabled'): ?>
                                        <span class="text-primary">Status: </span><span class="text-success"><?= $status ?></span>
                                    <?php else: ?>
                                        <span class="text-primary">Status: </span><span class="text-danger"><?= $status ?></span>
                                    <?php endif; ?>
                                </div>
                                <div class="col-lg-6 col-md-6">
									<i class="fa fa-server"></i>
                                    <span class="text-primary">IP: {{ wan_ip }}</span>
                                </div>
                                <div class="col-lg-6 col-md-6 d-sm-block d-md-block d-lg-none">
									<i class="fa fa-globe"></i>
                                    <span class="text-primary">ISP: {{ wan_isp }}</span>
                                </div>
								<div class="col-lg-6 col-md-6 pb-lg-1" >
								<i class="fa fa-flag-o"></i>
                                    <span class="text-primary">Location	: {{ wan_country }}</span>
                                </div>
                                <div class="col-lg-6 col-md-6 d-none d-lg-block d-xl-block">
									<i class="fa fa-globe"></i>
                                    <span class="text-primary">ISP: {{ wan_isp }}</span>
                                </div>
                            </div>
                            <br><div class="card-header"></div><br>					
                            <div class="card-body py-0 px-0">
                                <div class="row">
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="apn">APN Modem</label>
                                        <input type="text" class="form-control" placeholder="internet" id="apn" name="apn" value="<?= $variables['apn'] ?>"required>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="host">Host / Bug Untuk Ping | Support Multi Host</label>
                                        <input type="text" class="form-control" placeholder="goole.com,xnxx.com,8.8.8.8,1.1.1.1 - Pisahkan Dengan koma" id="host" name="host" value="<?= $variables['host'] ?>"required>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="interface_modem">Nama Interface Modem</label>
                                        <select name="interface_modem" id="interface_modem" class="form-control" required>
                                        <?php
                                        foreach ($interface_modem as $interface) {
                                            echo "<option value=\"$interface\"";
                                            if ($interface == $variables['interface_modem']) {
                                                echo " selected";
                                            }
                                        echo ">$interface</option>";
                                        }
                                        ?>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="device_modem">Device Modem</label>
                                        <select name="device_modem" id="device_modem" class="form-control" required>
                                        <?php
                                        foreach ($device_modem as $device) {
                                            echo "<option value=\"$device\"";
                                            if ($device == $variables['interface']) {
                                                echo " selected";
                                            }
                                        echo ">$device</option>";
                                        }
                                        ?>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="modem_port">Port Modem</label>
                                        <input type="text" class="form-control" placeholder="/dev/ttyUSB0" id="modem_port" name="modem_port" value="<?= $variables['modem_port'] ?>"required>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="max_attempts">Jumlah Percobaan</label>
                                        <input type="number" class="form-control" placeholder="3" id="max_attempts" name="max_attempts" value="<?= $variables['max_attempts'] ?>"required>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                        <label for="delay">Jeda Waktu Atau Delay / Bentuk Detik</label>
                                        <input type="number" class="form-control" placeholder="10" id="delay" name="delay" value="<?= $variables['delay'] ?>"required>
                                    </div>
                                </div>
                                </div>
                            </div>
                            <br><div class="card-header"></div><br>
                            <div class="row">
                                <div class="col-lg-6 col-md-6">
                                    <div class="form-group">
                                    <!-- Tambahkan input lainnya di sini -->
                                    <button type="submit" class="btn btn-primary">Simpan</button>
                                    <?php if ($status == 'Enabled'): ?>
                                        <button type="submit" class="btn btn-danger" name="disable">Disable</button>
                                    <?php else: ?>
                                        <button type="submit" class="btn btn-success" name="enable">Enable</button>
                                    <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php include('footer.php'); ?>
    </div>
    </form>
</div>
<?php include("javascript.php"); ?>
<script src="js/index.js"></script>
</body>
</html>