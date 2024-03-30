<?php
    include('config.inc.php');

    function json_response($data) {
        $resp = array(
            'status' => 'OK',
            'data' => $data
        );
        header("Content-Type: application/json; charset=UTF-8");
        echo json_encode($resp, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Ambil nilai startup dari permintaan POST
        $startup = $_POST['startup'];
    
        // Periksa apakah nilai startup adalah 1 atau 0
        if ($startup == 1 || $startup == 0) {
            // Atur nilai UCI rakitiw.startup sesuai dengan nilai yang diterima
            exec("uci set rakitiw.cfg.startup=$startup");
            exec("uci commit rakitiw");
            echo "UCI rakitiw.startup berhasil diatur menjadi $startup";
        } else {
            // Jika nilai startup tidak valid
            echo "Nilai startup tidak valid";
        }
    } else {
        // Jika bukan permintaan POST, kirimkan pesan kesalahan
        echo "Hanya menerima permintaan POST";
    }

?>
