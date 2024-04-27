<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Rakitan Manager Setup</title>
  <meta charset="utf-8">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="css/font-awesome.min.css">
  <!-- Bootstrap CSS -->
  <link rel="stylesheet" href="lib/vendor/bootstrap/css/bootstrap.min.css">
</head>
<body>
  <div class="container">
    <h1 class="mt-5">Rakitan Manager Setup</h1>
    <div class="card mt-4">
      <div class="card-body">
        <?php
          session_start();
          // Run the bash script
          shell_exec("/usr/bin/rakitanmanager.sh -setup");

          // Display logs
          $log_file = "/var/log/rakitanmanager.log";
          if (file_exists($log_file)) {
            $logs = file_get_contents($log_file);
            echo nl2br(htmlspecialchars($logs));
          } else {
            echo "Log file not found.";
          }

          // Check status directly from the log file
          if (strpos($logs, "Setup Done | Modem Rakitiw Successfully Installed") !== false) {
            $_SESSION['setup_done'] = true;
            echo '<script>window.location.href = "main.php";</script>';
          } elseif (strpos($logs, "Setup Done") === false) {
            echo '<form action="" method="post">';
            echo '<button type="submit" name="retry" class="btn btn-danger">Coba Instal Ulang</button>';
            echo '</form>';
          }

          // Retry installation
          if (isset($_POST['retry'])) {
            shell_exec("/usr/bin/rakitanmanager.sh -setup");
            // Redirect to the same page after retrying the installation
            echo '<script>window.location.href = "index.php";</script>';
          }
        ?>
      </div>
    </div>
  </div>
</body>
</html>