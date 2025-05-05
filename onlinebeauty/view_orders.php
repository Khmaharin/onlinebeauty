<?php
include 'db_connect.php';

$result = $conn->query("SELECT * FROM Orders");

echo "<h2>Orders List</h2><table border='1' cellpadding='5'>
<tr>
    <th>Order ID</th>
    <th>Customer ID</th>
    <th>Order Date</th>
    <th>Total Amount</th>
    <th>Status</th>
    <th>Actions</th>
</tr>";

while ($row = $result->fetch_assoc()) {
    echo "<tr>
        <td>{$row['order_id']}</td>
        <td>{$row['customer_id']}</td>
        <td>{$row['order_date']}</td>
        <td>\${$row['total_amount']}</td>
        <td>{$row['status']}</td>
        <td>
            <a href='change_status.php?order_id={$row['order_id']}'>Update Status</a>
        </td>
    </tr>";
}
echo "</table>";
?>
