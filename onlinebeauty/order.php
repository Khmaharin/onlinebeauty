<?php
include 'db_connect.php';
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Handle form submissions
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['place_order'])) {
    $customer_id = $_POST['customer_id'];
    $product_id = $_POST['product_id'];
    $quantity = $_POST['quantity'];

    // Step 1: Create new order
    $stmt = $conn->prepare("INSERT INTO Orders (customer_id) VALUES (?)");
    $stmt->bind_param("i", $customer_id);
    $stmt->execute();
    $order_id = $conn->insert_id;

    // Step 2: Get product price
    $stmt = $conn->prepare("SELECT price FROM Products WHERE product_id = ?");
    $stmt->bind_param("i", $product_id);
    $stmt->execute();
    $stmt->bind_result($price);
    $stmt->fetch();
    $stmt->close();

    if (!isset($price)) {
        echo "<p style='color:red;'>❌ Product not found.</p>";
        exit();
    }

    // Step 3: Insert into OrderItems
    $stmt = $conn->prepare("INSERT INTO OrderItems (order_id, product_id, quantity) VALUES (?, ?, ?)");
    $stmt->bind_param("iii", $order_id, $product_id, $quantity);
    $stmt->execute();

    // Step 4: Update total
    $total = $price * $quantity;
    $stmt = $conn->prepare("UPDATE Orders SET total_amount = ? WHERE order_id = ?");
    $stmt->bind_param("di", $total, $order_id);
    $stmt->execute();

    echo "<p style='color:green;'>✅ Order placed successfully! Total: \$$total</p>";
}

// Handle status update
if (isset($_GET['change_status']) && isset($_GET['order_id'])) {
    $order_id = $_GET['order_id'];
    $new_status = $_GET['change_status'];

    $stmt = $conn->prepare("UPDATE Orders SET status = ? WHERE order_id = ?");
    $stmt->bind_param("si", $new_status, $order_id);
    $stmt->execute();

    echo "<p style='color:blue;'>✅ Order status updated to '$new_status'.</p>";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: black; /* Changed to black */
        }
        header {
            background-color: #000; /* Black header */
            color: white;
            padding: 10px 0;
            text-align: center;
        }
        h2 {
            color: black; /* Changed to black */
            font-size: 24px;
            text-align: center; /* Centered the heading */
        }
        form {
            background-color: white;
            padding: 20px;
            margin: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        input[type="number"] {
            padding: 8px;
            margin: 5px 0;
            width: 100%;
            box-sizing: border-box;
        }
        button {
            background-color: #000; /* Black button */
            color: white;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
            border-radius: 5px;
        }
        button:hover {
            background-color: #333; /* Darker black on hover */
        }
        table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        a {
            color: #000; /* Black links */
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<header>
    <h1>Order Management System</h1>
</header>

<h2>🌟 Place New Order</h2>
<form method="POST">
    Customer ID: <input name="customer_id" type="number" required><br>
    Product ID: <input name="product_id" type="number" required><br>
    Quantity: <input name="quantity" type="number" min="1" required><br>
    <button type="submit" name="place_order">Place Order</button>
</form>

<hr>

<h2>📦 Orders List</h2>
<table>
<tr>
    <th>Order ID</th>
    <th>Customer ID</th>
    <th>Order Date</th>
    <th>Total</th>
    <th>Status</th>
    <th>Change Status</th>
    <th>View Items</th>
</tr>

<?php
$result = $conn->query("SELECT * FROM Orders");

while ($row = $result->fetch_assoc()) {
    echo "<tr>
        <td>{$row['order_id']}</td>
        <td>{$row['customer_id']}</td>
        <td>{$row['order_date']}</td>
        <td>\${$row['total_amount']}</td>
        <td>{$row['status']}</td>
        <td>
            <a href='?order_id={$row['order_id']}&change_status=Shipped'>Mark Shipped</a> | 
            <a href='?order_id={$row['order_id']}&change_status=Delivered'>Mark Delivered</a>
        </td>
        <td>
            <a href='?view_items={$row['order_id']}'>View Items</a>
        </td>
    </tr>";
}
?>
</table>

<?php
// Show Order Items
if (isset($_GET['view_items'])) {
    $order_id = $_GET['view_items'];
    echo "<hr><h2>📋 Items in Order #$order_id</h2>";

    $stmt = $conn->prepare("SELECT Products.product_name, OrderItems.quantity 
                            FROM OrderItems 
                            JOIN Products ON OrderItems.product_id = Products.product_id 
                            WHERE OrderItems.order_id = ?");
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();

    echo "<table>
    <tr><th>Product</th><th>Quantity</th></tr>";
    while ($item = $result->fetch_assoc()) {
        echo "<tr><td>{$item['product_name']}</td><td>{$item['quantity']}</td></tr>";
    }
    echo "</table>";
}
?>

</body>
</html>
