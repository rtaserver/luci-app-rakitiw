<?php
// Proses kueri POST jika ada
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if(isset($_POST['startup_status'])) {
        $startup_status = $_POST['startup_status'];
        exec("uci set rakitiw.cfg.startup=$startup_status");
        exec("uci commit rakitiw");
        exit; // Keluar dari skrip setelah menangani permintaan POST
    }
}

// Mendapatkan status startup saat halaman dimuat
$startup_status = exec("uci -q get rakitiw.cfg.startup");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <?php
    $title = "Home";
    include("head.php");
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
    <?php include('navbar.php'); ?>
    <form id="myForm" method="POST" class="mt-5">
    <div class="container-fluid" >
        <div class="row py-2">
            <div class="col-lg-8 col-md-9 mx-auto mt-3">
                <div class="card">
                    <div class="card-header">
                        <div class="text-center">
                            <h4><i class="fa fa-home"></i> Modem HP Manager</h4>
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
                            <div class="container-fluid">
                                <div class="form-group">
                                    <div class="center-align">
                                        <input type="checkbox" id="checkok" name="checkok" <?php if($startup_status == '1') echo 'checked'; ?>>
                                        <label for="checkok">Aktifkan Startup</label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="center-align">
                                        <button type="button" id="submitBtn" class="btn btn-primary">Simpan</button>
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
<script>
    $(document).ready(function(){
        // Menangani klik tombol Simpan
        $('#submitBtn').click(function(){
            var startup_status = $('#checkok').prop('checked') ? '1' : '0';
            $.post("<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>", { startup_status: startup_status }, function(data) {
                alert('Status startup berhasil disimpan!');
            });
        });
    });
</script>
</body>
</html>
