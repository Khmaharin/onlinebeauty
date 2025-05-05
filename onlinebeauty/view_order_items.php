<?php
include 'db_connect.php';

if (isset($_GET['order_id'])) {
    $order_id = $_GET['order_id'];

    $stmt = $conn->prepare("SELECT oi.item_id, p.product_name, oi.quantity, p.price, (oi.quantity * p.price) AS total_price
                            FROM OrderItems oi
                            JOIN Products p ON oi.product_id = p.product_id
                            WHERE oi.order_id = ?");
    $stmt->bind_param("i", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();

    echo "<h2>Order Items for Order #$order_id</h2><table border='1' cellpadding='5'>
    <tr>
        <th>Item ID</th>
        <th>Product Name</th>
        <th>Quantity</th>
        <th>Price</th>
        <th>Total</th>
    </tr>";

    while ($row = $result->fetch_assoc()) {
        echo "<tr>
            <td>{$row['item_id']}</td>
            <td>{$row['product_name']}</td>
            <td>{$row['quantity']}</td>
            <td>\${$row['price']}</td>
            <td>\${$row['total_price']}</td>
        </tr>";
    }
    echo "</table>";
} else {
    echo "❌ Order ID not provided.";
}
?>
