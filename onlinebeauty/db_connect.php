<?php
// db_connect.php
$host = 'localhost';
$db   = 'onlinebeauty';
$user = 'root';
$pass = '';
$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die('Connection failed: ' . $conn->connect_error);
}
?>