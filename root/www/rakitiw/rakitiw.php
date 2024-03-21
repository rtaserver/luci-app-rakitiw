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
        $status = 'Disabled';
    } else {
        // Cek apakah script sudah ada di cronjob
        $output = shell_exec('crontab -l');
        $status = (strpos($output, '/usr/bin/modemngentod.sh') !== false) ? 'Enabled' : 'Disabled';
    }

?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="css/font-awesome.min.css">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="lib/vendor/bootstrap/css/bootstrap.min.css">
    <!-- Main CSS -->
    <link rel="stylesheet" href="css/style.css">
    <link rel="icon" type="image/png" href="img/icon1.png">
    <title>Modem Penyakitan | <?= $title ?></title>
</head>
<body>
<div class="container-fluid" >
        <div class="row py-2">
            <div class="col-lg-8 col-md-9 mx-auto mt-3">
                <div class="card">
                    <div class="card-header">
                        <div class="text-center">
                            <h4>Auto Connect Modem Penyakitan</h4>
                        </div>                        
                    </div>					
                    <div class="card-body">
                        <form method="POST" class="mt-5">
                            <div class="form-group">
                                <label for="apn">APN Modem</label>
                                <input type="text" class="form-control" placeholder="internet" id="apn" name="apn" value="<?= $variables['apn'] ?>"required>
                            </div>
                            <div class="form-group">
                                <label for="host">Host / Bug Untuk Ping</label>
                                <input type="text" class="form-control" placeholder="bug.com" id="host" name="host" value="<?= $variables['host'] ?>"required>
                            </div>
                            <div class="form-group">
                                <label for="interface_modem">Nama Interface Modem</label>
                                <input type="text" class="form-control" placeholder="wan" id="interface_modem" name="interface_modem" value="<?= $variables['interface_modem'] ?>"required>
                            </div>
                            <div class="form-group">
                                <label for="interface">Interface Modem</label>
                                <input type="text" class="form-control" placeholder="wwan0" id="interface" name="interface" value="<?= $variables['interface'] ?>"required>
                            </div>
                            <div class="form-group">
                                <label for="modem_port">Port Modem</label>
                                <input type="text" class="form-control" placeholder="/dev/ttyUSB0" id="modem_port" name="modem_port" value="<?= $variables['modem_port'] ?>"required>
                            </div>
                            <div class="form-group">
                                <label for="max_attempts">Jumlah Percobaan</label>
                                <input type="number" class="form-control" placeholder="3" id="max_attempts" name="max_attempts" value="<?= $variables['max_attempts'] ?>"required>
                            </div>
                            <div class="form-group">
                                <label for="delay">Jeda Waktu Atau Delay / Bentuk Detik</label>
                                <input type="number" class="form-control" placeholder="10" id="delay" name="delay" value="<?= $variables['delay'] ?>"required>
                            </div>
                            <!-- Tambahkan input lainnya di sini -->
                            <button type="submit" class="btn btn-primary">Simpan</button>
                            <button type="submit" class="btn btn-success" name="enable">Enable</button>
                            <button type="submit" class="btn btn-danger" name="disable">Disable</button> <p>
                            <p>Status: <span class="badge badge-primary"><?= $status ?></span></p>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    <footer class="text-center">
        <font color="white">© 2024 RTA SERVER - RIZKIKOTET</a>
    </footer>
</div>
    <!-- JavaScript Bootstrap -->
    <script src="lib/vendor/jquery/jquery-3.6.0.slim.min.js"></script>
    <script src="lib/vendor/bootstrap/js/bootstrap.min.js"></script>
    <script src="lib/vendor/vuejs/vue.min.js"></script>
    <script src="lib/vendor/axios/axios.min.js"></script>
    <script src="lib/vendor/sweetalert2/sweetalert2.all.min.js"></script>
    <script src="lib/vendor/lodash/lodash.min.js"></script>
</body>
</html>