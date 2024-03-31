<?php
if(isset($_POST['rakitiw'])){
    $dt = $_POST['rakitiw'];
    if ($dt == 'enable') shell_exec("uci set rakitiw.cfg.startup='1' && uci commit rakitiw");
    if ($dt == 'disable') shell_exec("uci set rakitiw.cfg.startup='0' && uci commit rakitiw");
}


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
                            <form action="index.php" method="post">
                            <td class="d-grid">
                                <div class="btn-group col" role="group" aria-label="ctrl">
                                    <button type="submit" name="rakitiw" value="enable" class="btn btn<?php if($startup_status==1) echo "-outline" ?>-success <?php if($startup_status==1) echo "disabled" ?> d-grid">Enable Startup</button>
                                    <button type="submit" name="rakitiw" value="disable" class="btn btn<?php if($startup_status==0) echo "-outline" ?>-danger <?php if($startup_status==0) echo "disabled" ?> d-grid">Disable Startup</button>
                                </div>
                            </td>
                            </form>
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
</body>
</html>
