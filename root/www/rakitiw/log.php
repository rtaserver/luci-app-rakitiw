<?php
$log_file = '/var/log/modemngentod.log';
$file_size = filesize($file_path);
$max_size = 100 * 1024; // 100KB

if ($file_size > $max_size) {
    if (unlink($file_path)) {
        $log_message = shell_exec("date '+%Y-%m-%d %H:%M:%S'") . " - Log berhasil dihapus karena melebihi 100KB\n";
        file_put_contents($log_file, $log_message, FILE_APPEND);
    }
}
if (!file_exists($log_file)) {
    $log_message = shell_exec("date '+%Y-%m-%d %H:%M:%S'") . " - Belum Ada Log\n";
    file_put_contents($log_file, $log_message, FILE_APPEND);
} else {
    $log_lines = file($log_file);
    foreach ($log_lines as $line) {
        echo nl2br($line);
    }
}
?>