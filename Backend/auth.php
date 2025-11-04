<?php
session_start();
require 'db_config.php';

// pastikan role dikirim dari halaman sebelumnya
$role = $_GET['role'] ?? null;
if (!$role) {
  header("Location: index.html");
  exit;
}

// Mapping nama role ke ID role (berdasarkan tabel roles)
$role_map = [
    'shipper_planner' => 1,
    'mining_planner' => 2
];

$role_display = ($role == 'shipper_planner') ? 'Shipper Planner' : 'Mining Planner';
$role_id = $role_map[$role] ?? null;
$message = "";

// Cek validitas role_id
if (!$role_id) {
  die("Role tidak dikenali!");
}

// ---------------------- REGISTER ----------------------
if (isset($_POST['register'])) {
    $username = trim($_POST['username']);
    $email = trim($_POST['email']);
    $password = password_hash($_POST['password'], PASSWORD_BCRYPT);

    // Cek apakah email sudah ada
    $check = $conn->prepare("SELECT id FROM tb_users WHERE email=?");
    $check->bind_param("s", $email);
    $check->execute();
    $result = $check->get_result();

    if ($result->num_rows > 0) {
        $message = "⚠️ Email sudah terdaftar!";
    } else {
        // Simpan data ke tabel tb_users dengan kolom 'pass'
        $stmt = $conn->prepare("INSERT INTO tb_users (username, email, pass, role_id) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssi", $username, $email, $password, $role_id);

        if ($stmt->execute()) {
            $message = "✅ Pendaftaran berhasil! Silakan login.";
        } else {
            $message = "❌ Gagal mendaftar: " . $conn->error;
        }
    }
}

// ---------------------- LOGIN ----------------------
if (isset($_POST['login'])) {
    $email = trim($_POST['email']);
    $password = $_POST['password'];

    // Ambil user dengan email dan role_id sesuai
    $stmt = $conn->prepare("
        SELECT u.*, r.name AS role_name 
        FROM tb_users u 
        JOIN tb_roles r ON u.role_id = r.id 
        WHERE u.email=? AND u.role_id=?");
    $stmt->bind_param("si", $email, $role_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();

    // Gunakan kolom 'pass' untuk verifikasi
    if ($user && password_verify($password, $user['pass'])) {
        $_SESSION['user'] = $user;

        if ($role_id == 1) {
            header("Location: dashboard_shipper.php");
        } else {
            header("Location: dashboard_mining.php");
        }
        exit;
    } else {
        $message = "⚠️ Email atau password salah.";
    }
}
?>

<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title><?= htmlspecialchars($role_display) ?> - Login & Register</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #f2f5f9;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
    }
    .container {
      background: white;
      border-radius: 10px;
      box-shadow: 0 6px 20px rgba(0,0,0,0.1);
      width: 400px;
      padding: 30px;
    }
    h2 { text-align: center; color: #333; }
    form {
      display: none;
      margin-top: 20px;
    }
    input {
      width: 100%;
      padding: 10px;
      margin: 8px 0;
      border: 1px solid #ccc;
      border-radius: 6px;
    }
    button {
      width: 100%;
      padding: 10px;
      background: #4A90E2;
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
    }
    button:hover { background: #357ABD; }
    .toggle {
      text-align: center;
      margin-top: 15px;
    }
    a { color: #4A90E2; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .message {
      color: #d9534f;
      text-align: center;
      margin-bottom: 10px;
    }
  </style>
  <script>
    function showForm(type) {
      document.getElementById('loginForm').style.display = (type === 'login') ? 'block' : 'none';
      document.getElementById('registerForm').style.display = (type === 'register') ? 'block' : 'none';
    }
  </script>
</head>
<body onload="showForm('login')">
  <div class="container">
    <h2><?= htmlspecialchars($role_display) ?></h2>
    <div class="message"><?= $message ?></div>

    <!-- LOGIN -->
    <form id="loginForm" method="POST">
      <input type="email" name="email" placeholder="Email" required>
      <input type="password" name="password" placeholder="Password" required>
      <button type="submit" name="login">Login</button>
      <div class="toggle">
        Belum punya akun? <a href="#" onclick="showForm('register')">Daftar</a>
      </div>
    </form>

    <!-- REGISTER -->
    <form id="registerForm" method="POST">
      <input type="text" name="username" placeholder="Username" required>
      <input type="email" name="email" placeholder="Email" required>
      <input type="password" name="password" placeholder="Password" required>
      <button type="submit" name="register">Daftar</button>
      <div class="toggle">
        Sudah punya akun? <a href="#" onclick="showForm('login')">Login</a>
      </div>
    </form>
  </div>
</body>
</html>
