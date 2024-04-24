<?php
if (isset($_POST['rakitiw'])) {
    $dt = $_POST['rakitiw'];
    if ($dt == 'enable')
        exec("uci set rakitiw.cfg.startup='1' && uci commit rakitiw");
    if ($dt == 'disable')
        exec("uci set rakitiw.cfg.startup='0' && uci commit rakitiw");
}

$startup_status = exec("uci -q get rakitiw.cfg.startup");

function is_internet_available()
{
    $connected = @fsockopen("www.google.com", 80); // Coba terhubung ke situs
    if ($connected) {
        fclose($connected);
        return true; // Jika terhubung, kembalikan true
    }
    return false; // Jika tidak terhubung, kembalikan false
}


function check_for_update()
{
    $url = "https://api.github.com/repos/rtaserver/luci-app-rakitiw/releases/latest"; // URL API untuk mendapatkan informasi terbaru

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_USERAGENT, 'My-App');
    $response = curl_exec($ch);

    if ($response) {
        $data = json_decode($response, true);
        $latest_tag = $data['tag_name']; // Mendapatkan tag terbaru
        curl_close($ch);
        return $latest_tag;
    } else {
        curl_close($ch);
        return false;
    }
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <?php
    $title = "Home";
    include ("head.php");
    ?>
    <script src="lib/vendor/jquery/jquery-3.6.0.slim.min.js"></script>
    <style>
        .container {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
        }

        .center-align {
            text-align: center;
        }

        .form-group {
            margin-bottom: 20px;
        }
    </style>
</head>

<body>
    <div id="app">
        <?php include ('navbar.php'); ?>
        <form id="myForm" method="POST" class="mt-5">
            <div class="container-fluid">
                <div class="row py-2">
                    <div class="col-lg-8 col-md-9 mx-auto mt-3">
                        <div class="card">
                            <div class="card-header">
                                <div class="text-center">
                                    <h4><i class="fa fa-home"></i> PENGATURAN</h4>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="card-body py-0 px-0">
                                    <div class="body">
                                        <div class="text-center">
                                            <img src="curent.svg" alt="Curent Version">
                                            <img alt="Latest Version"
                                                src="https://img.shields.io/github/v/release/rtaserver/luci-app-rakitiw?display_name=tag&logo=openwrt&label=Latest%20Version&color=dark-green">
                                        </div>
                                        <br>
                                    </div>
                                    <div class="container-fluid">
                                        <form action="index.php" method="post">
                                            <td class="d-grid">
                                                <div class="btn-group col" role="group" aria-label="ctrl">
                                                    <?php if ($startup_status == 1): ?>
                                                        <button type="submit" name="rakitiw" value="disable"
                                                            class="btn btn-danger">Disable Startup</button>
                                                    <?php else: ?>
                                                        <button type="submit" name="rakitiw" value="enable"
                                                            class="btn btn-success">Enable Startup</button>
                                                    <?php endif; ?>
                                                </div>
                                            </td>
                                        </form>
                                        <br></br>
                                        <?php
                                        // Cek ketersediaan koneksi internet
                                        if (is_internet_available()) {
                                            $latest_tag = check_for_update();
                                            if ($latest_tag) {
                                                // Tombol untuk memunculkan modal
                                                echo '<td class="d-grid">';
                                                echo '<div class="btn-group col" role="group" aria-label="ctrl">';
                                                echo '<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#versionModal">Cek Versi Terbaru</button>';
                                                echo '</div>';
                                                echo '</td>';
                                                // Modal untuk menampilkan informasi versi terbaru
                                                echo '
                                                <div class="modal fade" id="versionModal" tabindex="-1" role="dialog" aria-labelledby="versionModalLabel" aria-hidden="true">
                                                    <div class="modal-dialog" role="document">
                                                        <div class="modal-content">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title" id="versionModalLabel">Versi Terbaru</h5>
                                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                                    <span aria-hidden="true">&times;</span>
                                                                </button>
                                                            </div>
                                                            <div class="modal-body">
                                                                Versi terbaru: ' . $latest_tag . '
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Tutup</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>';
                                            } else {
                                                echo '<div class="alert alert-danger" role="alert">Gagal memeriksa update.</div>';
                                            }
                                        } else {
                                            echo '<div class="alert alert-danger" role="alert">Tidak ada koneksi internet. Gagal Memeriksa Update</div>'; // Pesan jika tidak ada koneksi internet
                                        }
                                        ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <?php include ('footer.php'); ?>
            </div>
        </form>
    </div>
    <?php include ("javascript.php"); ?>
</body>

</html>