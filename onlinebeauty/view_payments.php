<?php
include 'db_connect.php';

$sql = "
SELECT 
    pay.payment_id,
    o.order_id,
    c.customer_name,
    GROUP_CONCAT(p.product_name SEPARATOR ', ') AS product_names,
    o.total_amount,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date,
    o.shipping_method  -- Add shipping method from the Orders table
FROM Payment pay
JOIN Orders o ON pay.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY pay.payment_id
ORDER BY pay.payment_date DESC
";

$result = $conn->query($sql);

echo "<h2>📋 All Payments</h2>";
if ($result->num_rows > 0) {
    echo "<table border='1' cellpadding='8'>
            <tr>
                <th>Payment ID</th>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Product(s)</th>
                <th>Total ($)</th>
                <th>Method</th>
                <th>Status</th>
                <th>Date</th>
                <th>Shipping Method</th>  <!-- Add a column for shipping method -->
            </tr>";
    while ($row = $result->fetch_assoc()) {
        echo "<tr>
                <td>{$row['payment_id']}</td>
                <td>{$row['order_id']}</td>
                <td>{$row['customer_name']}</td>
                <td>{$row['product_names']}</td>
                <td>{$row['total_amount']}</td>
                <td>{$row['payment_method']}</td>
                <td>{$row['payment_status']}</td>
                <td>{$row['payment_date']}</td>
                <td>{$row['shipping_method']}</td>  <!-- Display the shipping method -->
              </tr>";
    }
    echo "</table>";
} else {
    echo "<p>No payments recorded yet.</p>";
}
?>





<?php
include 'db_connect.php';

// Make sure to join the Orders table to get the shipping_method
$sql = "
SELECT 
    pay.payment_id,
    o.order_id,
    c.customer_name,
    GROUP_CONCAT(p.product_name SEPARATOR ', ') AS product_names,
    o.total_amount,
    pay.payment_method,
    pay.payment_status,
    pay.payment_date,
    o.shipping_method  -- Ensure that the shipping_method is selected
FROM Payment pay
JOIN Orders o ON pay.order_id = o.order_id
JOIN Customer c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY pay.payment_id
ORDER BY pay.payment_date DESC
";

$result = $conn->query($sql);

echo "<h2>📋 Payment Details</h2>";
if ($result->num_rows > 0) {
    echo "<table border='1' cellpadding='8'>
            <tr>
                <th>Payment ID</th>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Product(s)</th>
                <th>Total ($)</th>
                <th>Method</th>
                <th>Status</th>
                <th>Date</th>
                <th>Shipping Method</th>  <!-- Add column for shipping method -->
            </tr>";
    while ($row = $result->fetch_assoc()) {
        echo "<tr>
                <td>{$row['payment_id']}</td>
                <td>{$row['order_id']}</td>
                <td>{$row['customer_name']}</td>
                <td>{$row['product_names']}</td>
                <td>{$row['total_amount']}</td>
                <td>{$row['payment_method']}</td>
                <td>{$row['payment_status']}</td>
                <td>{$row['payment_date']}</td>
                <td>{$row['shipping_method']}</td> <!-- Show shipping method -->
              </tr>";
    }
    echo "</table>";
} else {
    echo "<p>No payments recorded yet.</p>";
}
?>
