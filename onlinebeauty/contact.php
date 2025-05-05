<?php
include('db_connect.php');
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Us</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 50%;
            margin: 50px auto;
            background-color: white;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        h2 {
            text-align: center;
            color: #333;
        }
        label {
            font-size: 16px;
            color: #555;
        }
        input[type="text"], input[type="email"], textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        .message {
            text-align: center;
            margin-top: 20px;
            font-weight: bold;
        }
        .message.success {
            color: green;
        }
        .message.error {
            color: red;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Contact Us</h2>

    <form method="POST" action="">
        <label for="full_name">Full Name:</label><br>
        <input type="text" name="full_name" id="full_name" required><br>

        <label for="email">Email:</label><br>
        <input type="email" name="email" id="email" required><br>

        <label for="subject">Subject:</label><br>
        <input type="text" name="subject" id="subject"><br>

        <label for="message">Message:</label><br>
        <textarea name="message" id="message" rows="5" cols="40" required></textarea><br>

        <input type="submit" name="submit" value="Send">
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['submit'])) {
        $full_name = $_POST['full_name'];
        $email = $_POST['email'];
        $subject = $_POST['subject'];
        $message = $_POST['message'];

        $stmt = $conn->prepare("INSERT INTO contact (full_name, email, subject, message) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $full_name, $email, $subject, $message);

        if ($stmt->execute()) {
            echo "<p class='message success'>Your message has been sent successfully!</p>";
        } else {
            echo "<p class='message error'>Error: " . $conn->error . "</p>";
        }

        $stmt->close();
    }
    ?>
</div>

</body>
</html>

