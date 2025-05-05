<?php
include('db_connect.php');
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer Feedback</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f7fa;
            color: #333;
            padding: 30px;
        }

        h2 {
            color: #2c3e50;
        }

        form {
            background: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 2px 8px rgba(0,0,0,0.1);
            max-width: 600px;
            margin-bottom: 30px;
        }

        label {
            display: block;
            margin-top: 10px;
            font-weight: bold;
        }

        input[type="number"],
        input[type="text"],
        select,
        textarea {
            width: 100%;
            padding: 8px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        input[type="submit"] {
            background-color: #3498db;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            margin-top: 15px;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: #2980b9;
        }

        .message {
            margin-top: 15px;
            font-weight: bold;
        }

        .success {
            color: green;
        }

        .error {
            color: red;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #ffffff;
            box-shadow: 0px 2px 6px rgba(0,0,0,0.1);
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #2c3e50;
            color: white;
        }

        tr:hover {
            background-color: #f1f1f1;
        }
    </style>
</head>
<body>

    <h2>Customer Feedback Form</h2>

    <form method="POST" action="">
        <label for="customer_id">Customer ID:</label>
        <input type="number" name="customer_id" id="customer_id" required>

        <label for="product_id">Select a Product:</label>
        <select name="product_id" id="product_id" required>
            <option value="">-- Select Product --</option>
            <?php
            $product_query = $conn->query("SELECT product_id, product_name FROM products");
            if ($product_query && $product_query->num_rows > 0) {
                while ($row = $product_query->fetch_assoc()) {
                    echo "<option value='{$row['product_id']}'>{$row['product_name']}</option>";
                }
            } else {
                echo "<option value=''>No products available</option>";
            }
            ?>
        </select>

        <label for="subject">Subject:</label>
        <input type="text" name="subject" id="subject" required>

        <label for="message">Message:</label>
        <textarea name="message" id="message" rows="5" required></textarea>

        <input type="submit" name="submit" value="Send Message">
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['submit'])) {
        $customer_id = $_POST['customer_id'];
        $product_id = !empty($_POST['product_id']) ? $_POST['product_id'] : null;
        $subject = $_POST['subject'];
        $message = $_POST['message'];
        $contact_date = date("Y-m-d H:i:s");

        $stmt = $conn->prepare("SELECT customer_name FROM customer WHERE customer_id = ?");
        $stmt->bind_param("i", $customer_id);
        $stmt->execute();
        $stmt->bind_result($customer_name);
        $stmt->fetch();
        $stmt->close();

        if (empty($customer_name)) {
            echo "<p class='message error'>Customer ID not found.</p>";
        } else {
            $insert = $conn->prepare("INSERT INTO feedback (customer_id, customer_name, product_id, subject, message, contact_date) 
                                      VALUES (?, ?, ?, ?, ?, ?)");
            $insert->bind_param("isisss", $customer_id, $customer_name, $product_id, $subject, $message, $contact_date);

            if ($insert->execute()) {
                echo "<p class='message success'>Message sent successfully by <strong>$customer_name</strong>!</p>";
            } else {
                echo "<p class='message error'>Error: " . $conn->error . "</p>";
            }

            $insert->close();
        }
    }
    ?>

    <h2>All Customer Messages</h2>
    <table>
        <tr>
            <th>Customer ID</th>
            <th>Customer Name</th>
            <th>Product Name</th>
            <th>Subject</th>
            <th>Message</th>
            <th>Date</th>
        </tr>
        <?php
        $query = "
            SELECT f.customer_id, f.customer_name, p.product_name, f.subject, f.message, f.contact_date
            FROM feedback f
            LEFT JOIN products p ON f.product_id = p.product_id
            ORDER BY f.contact_date DESC
        ";
        $result = $conn->query($query);
        while ($row = $result->fetch_assoc()) {
            echo "<tr>
                    <td>{$row['customer_id']}</td>
                    <td>{$row['customer_name']}</td>
                    <td>" . ($row['product_name'] ?? 'N/A') . "</td>
                    <td>{$row['subject']}</td>
                    <td>{$row['message']}</td>
                    <td>{$row['contact_date']}</td>
                  </tr>";
        }
        $conn->close();
        ?>
    </table>

</body>
</html>

