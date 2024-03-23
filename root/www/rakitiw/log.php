<?php
$log_file = '/var/log/modemngentod.log';

if (!file_exists($log_file)) {
    echo "File Log belum ada.";
} else {
    $log_lines = file($log_file);
    foreach ($log_lines as $line) {
        echo nl2br($line);
    }
}
?>