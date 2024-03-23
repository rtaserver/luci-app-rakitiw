<?php
$log_file = '/var/log/modemngentod.log';
$log_lines = file($log_file);
foreach ($log_lines as $line) {
    echo nl2br($line);
}
?>
