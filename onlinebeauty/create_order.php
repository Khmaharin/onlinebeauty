<?php include 'db_connect.php'; ?>

<h2>Place New Order</h2>
<form method="POST">
  Customer ID: <input name="customer_id" type="number" required><br>
  Product ID: <input name="product_id" type="number" required><br>
  Quantity: <input name="quantity" type="number" required><br>
  Order Date: <input name="order_date" type="date" required><br>
  <button type="submit">Place Order</button>
</form>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // First, insert the order into the Orders table
    $stmt = $conn->prepare("INSERT INTO Orders (customer_id, order_date) VALUES (?, ?)");
    $stmt->bind_param("is", $_POST['customer_id'], $_POST['order_date']);
    $stmt->execute();

    // Get the inserted order_id
    $order_id = $stmt->insert_id;

    // Now, insert products into the OrderItems table
    $stmt = $conn->prepare("INSERT INTO OrderItems (order_id, product_id, quantity) VALUES (?, ?, ?)");
    $stmt->bind_param("iii", $order_id, $_POST['product_id'], $_POST['quantity']);
    $stmt->execute();

    // Update the total amount in the Orders table
    $totalAmount = 0;
    $stmt = $conn->prepare("SELECT price FROM Products WHERE product_id = ?");
    $stmt->bind_param("i", $_POST['product_id']);
    $stmt->execute();
    $stmt->bind_result($price);
    while ($stmt->fetch()) {
        $totalAmount = $price * $_POST['quantity'];
    }
    $stmt = $conn->prepare("UPDATE Orders SET total_amount = ? WHERE order_id = ?");
    $stmt->bind_param("di", $totalAmount, $order_id);
    $stmt->execute();

    echo "✅ Order placed successfully!";
}
?>
