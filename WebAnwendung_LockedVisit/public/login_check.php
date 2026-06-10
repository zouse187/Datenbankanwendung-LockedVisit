<?php
session_start();
require_once __DIR__ . '/../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: login.php');
    exit;
}

$username = trim($_POST['username'] ?? '');
$password = $_POST['password'] ?? '';

$result = db_connect($username, $password);

if ($result['success']) {
    $_SESSION['db_user'] = $username;
    $_SESSION['connected'] = true;

    header('Location: dashboard.php');
    exit;
}

$_SESSION['login_error'] = 'Verbindung fehlgeschlagen: ' . $result['error'];
header('Location: login.php');
exit;
