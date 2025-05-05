

<?php include 'db_connect.php'; ?>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Portal</title>
</head>

<style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: black;
        }
        h2 {
            color: black;
            font-size: 24px;
            text-align: center;
        }
        form {
            background-color: white;
            padding: 20px;
            margin: 20px auto;
            width: 90%;
            max-width: 600px;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        }
        input[type="number"],
        select {
            padding: 10px;
            margin: 10px 0;
            width: 100%;
            box-sizing: border-box;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        button {
            background-color: #000;
            color: white;
            border: none;
            padding: 10px 20px;
            margin-top: 10px;
            cursor: pointer;
            border-radius: 5px;
            width: 100%;
            font-size: 16px;
        }
        button:hover {
            background-color: #333;
        }
        div {
            background-color: white;
            padding: 20px;
            margin: 20px auto;
            width: 90%;
            max-width: 800px;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        }
        p {
            font-size: 16px;
            line-height: 1.6;
        }
    </style>
</head>
<body>


<body>

<!-- Payment Submission Form -->
<h2>💳 Enter Payment</h2>
<form method="POST">
    <label>Order ID:</label> 
    <input name="order_id" type="number" required><br><br>

    <label>Payment Method:</label>
    <select name="payment_method" required>
        <option value="Credit Card">Credit Card</option>
        <option value="PayPal">PayPal</option>
        <option value="Cash">Cash</option>
    </select><br><br>

    <label>Shipping Method:</label>
    <select name="shipping_method" required>
        <option value="Standard">Standard</option>
        <option value="Express">Express</option>
        <option value="Overnight">Overnight</option>
    </select><br><br>

    <button type="submit" name="submit_payment">Submit Payment</button>
</form>

<!-- View Payment Form -->
<h2>🔍 View Payment Details</h2>
<form method="POST">
    <label>Order ID:</label>
    <input name="order_id" type="number" required><br><br>

    <button type="submit" name="view_payment">View Payment</button>
</form>

<!-- Results Section -->
<div>
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['submit_payment'])) {
        $order_id = $_POST['order_id'];
        $payment_method = $_POST['payment_method'];
        $shipping_method = $_POST['shipping_method'];

        $stmt = $conn->prepare("
            SELECT 
                o.total_amount, 
                c.customer_name,
                GROUP_CONCAT(p.product_name SEPARATOR ', ') AS product_names
            FROM Orders o
            JOIN Customer c ON o.customer_id = c.customer_id
            JOIN OrderItems oi ON o.order_id = oi.order_id
            JOIN Products p ON oi.product_id = p.product_id
            WHERE o.order_id = ?
            GROUP BY o.order_id
        ");
        $stmt->bind_param("i", $order_id);
        $stmt->execute();
        $stmt->bind_result($total_amount, $customer_name, $product_names);

        if ($stmt->fetch()) {
            $stmt->close();

            $stmt = $conn->prepare("INSERT INTO Payment (order_id, amount, payment_method, shipping_method, payment_status) VALUES (?, ?, ?, ?, 'Paid')");
            $stmt->bind_param("idss", $order_id, $total_amount, $payment_method, $shipping_method);
            $stmt->execute();
            $payment_id = $stmt->insert_id;
            $stmt->close();

            $stmt = $conn->prepare("
                SELECT 
                    pay.payment_id, 
                    pay.payment_method, 
                    pay.shipping_method,
                    pay.payment_status, 
                    pay.payment_date 
                FROM Payment pay 
                WHERE pay.payment_id = ?
            ");
            $stmt->bind_param("i", $payment_id);
            $stmt->execute();
            $stmt->bind_result($payment_id, $payment_method, $shipping_method, $payment_status, $payment_date);
            $stmt->fetch();
            $stmt->close();

            echo "<h2>✅ Payment Recorded</h2>";
            echo "<p><strong>Payment ID:</strong> $payment_id</p>";
            echo "<p><strong>Customer:</strong> $customer_name</p>";
            echo "<p><strong>Order ID:</strong> $order_id</p>";
            echo "<p><strong>Product(s):</strong> $product_names</p>";
            echo "<p><strong>Total Amount:</strong> $$total_amount</p>";
            echo "<p><strong>Payment Method:</strong> $payment_method</p>";
            echo "<p><strong>Shipping Method:</strong> $shipping_method</p>";
            echo "<p><strong>Status:</strong> $payment_status</p>";
            echo "<p><strong>Date:</strong> $payment_date</p>";
        } else {
            echo "❌ Order not found.";
        }
    }

    if (isset($_POST['view_payment'])) {
        $order_id = $_POST['order_id'];

        $stmt = $conn->prepare("
            SELECT 
                p.payment_id,
                p.payment_date,
                p.amount AS payment_amount,
                p.payment_method,
                p.shipping_method,
                p.payment_status,
                o.order_id,
                o.total_amount,
                o.status AS order_status,
                c.customer_id,
                c.customer_name
            FROM Payment p
            JOIN Orders o ON p.order_id = o.order_id
            JOIN Customer c ON o.customer_id = c.customer_id
            WHERE o.order_id = ?
        ");
        $stmt->bind_param("i", $order_id);
        $stmt->execute();
        $stmt->bind_result($payment_id, $payment_date, $payment_amount, $payment_method, $shipping_method, $payment_status, $order_id, $total_amount, $order_status, $customer_id, $customer_name);

        if ($stmt->fetch()) {
            echo "<h2>📋 Payment Details for Order ID: $order_id</h2>";
            echo "<p><strong>Payment ID:</strong> $payment_id</p>";
            echo "<p><strong>Payment Date:</strong> $payment_date</p>";
            echo "<p><strong>Payment Method:</strong> $payment_method</p>";
            echo "<p><strong>Shipping Method:</strong> $shipping_method</p>";
            echo "<p><strong>Payment Status:</strong> $payment_status</p>";
            echo "<p><strong>Total Order Amount:</strong> $$total_amount</p>";
            echo "<p><strong>Order Status:</strong> $order_status</p>";
            echo "<p><strong>Payment Amount:</strong> $$payment_amount</p>";
            echo "<p><strong>Customer ID:</strong> $customer_id</p>";
            echo "<p><strong>Customer Name:</strong> $customer_name</p>";
        } else {
            echo "❌ No payment found for Order ID: $order_id.";
        }
        $stmt->close();
    }
}
?>
</div>

</body>
</html>
