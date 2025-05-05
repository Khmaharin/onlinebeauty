<?php
include 'db_connect.php';

$customer_id = isset($_GET['customer_id']) ? intval($_GET['customer_id']) : 0;

if ($customer_id > 0) {

    $stmt = $conn->prepare("
        SELECT 
            c.customer_name, 
            c.email, 
            c.phone_number, 
            c.address AS customer_address,
            o.order_id, 
            o.order_date, 
            o.status AS order_status, 
            o.total_amount, 
            p.shipping_method, 
            s.shipping_status, 
            s.shipped_date, 
            s.shipping_confirmation,
            p.payment_method, 
            p.payment_status, 
            p.amount AS payment_amount  
        FROM customer c
        JOIN orders o ON c.customer_id = o.customer_id
        LEFT JOIN payment p ON o.order_id = p.order_id
        LEFT JOIN shipping s ON o.order_id = s.order_id AND c.customer_id = s.customer_id
        WHERE c.customer_id = ?
        ORDER BY o.order_id DESC
        LIMIT 1
    ");

    $stmt->bind_param("i", $customer_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        $order_id = $row['order_id'];
        echo "<h2>Customer Details</h2>";
        echo "Customer Name: {$row['customer_name']}<br>";
        echo "Email: {$row['email']}<br>";
        echo "Phone Number: {$row['phone_number']}<br>";
        echo "Customer Address: {$row['customer_address']}<br><br>";

        echo "<h2>Order Details</h2>";
        echo "Order ID: {$row['order_id']}<br>";
        echo "Order Date: {$row['order_date']}<br>";
        echo "Order Status: {$row['order_status']}<br>";
        echo "Total Amount: \${$row['total_amount']}<br><br>";

        echo "<h2>Shipping Information</h2>";
        echo "Shipping Method: " . ($row['shipping_method'] ?? 'N/A') . "<br>";

        echo "<h2>Payment Information</h2>";
        echo "Payment Method: {$row['payment_method']}<br>";
        echo "Payment Status: {$row['payment_status']}<br>";
        echo "Payment Amount: \${$row['payment_amount']}<br><br>";

        if ($row['shipping_status'] !== 'Shipped') {
            echo "<form method='post' action='?customer_id={$customer_id}'>
                    <input type='hidden' name='order_id' value='{$row['order_id']}'>
                    <input type='submit' name='mark_shipped' value='🚚 Mark as Shipped'>
                  </form>";
        } else {
            echo "<strong>✅ Order has already been shipped. Confirmation #: {$row['shipping_confirmation']}</strong>";
        }
    } else {
        echo "<p>❌ No matching customer/order found.</p>";
    }

    $stmt->close();
} else {
    echo '<h2>Enter Customer ID to View Details</h2>
    <form method="GET">
        Customer ID: <input name="customer_id" type="number" required>
        <button type="submit">Submit</button>
    </form>';
}

// Handle Mark as Shipped
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mark_shipped'])) {
    $order_id = intval($_POST['order_id']);
    $confirmation_number = strtoupper(uniqid('SHIP-'));

    // Get customer address
    $address_stmt = $conn->prepare("SELECT address FROM customer WHERE customer_id = ?");
    $address_stmt->bind_param("i", $customer_id);
    $address_stmt->execute();
    $address_result = $address_stmt->get_result();
    $customer_address = '';
    if ($row = $address_result->fetch_assoc()) {
        $customer_address = $row['address'];
    }
    $address_stmt->close();

    // Check if shipping record already exists
    $check_stmt = $conn->prepare("SELECT shipping_id FROM shipping WHERE order_id = ? AND customer_id = ?");
    $check_stmt->bind_param("ii", $order_id, $customer_id);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows === 0) {
        // Insert new shipping record
        $insert_stmt = $conn->prepare("
            INSERT INTO shipping (order_id, customer_id, shipping_address, shipping_method, shipping_status, shipped_date, shipping_confirmation)
            VALUES (?, ?, ?, 'Express', 'Shipped', NOW(), ?)
        ");
        $insert_stmt->bind_param("iiss", $order_id, $customer_id, $customer_address, $confirmation_number);

        if ($insert_stmt->execute()) {
            echo "<p>✅ Shipping record created. Confirmation #: <strong>$confirmation_number</strong></p>";
        } else {
            echo "<p>❌ Failed to insert shipping record. Error: " . $insert_stmt->error . "</p>";
        }

        $insert_stmt->close();
    } else {
        // Update existing shipping record
        $update_stmt = $conn->prepare("
            UPDATE shipping 
            SET shipping_status = 'Shipped',
                shipped_date = NOW(),
                shipping_confirmation = ?
            WHERE order_id = ? AND customer_id = ?
        ");
        $update_stmt->bind_param("sii", $confirmation_number, $order_id, $customer_id);

        if ($update_stmt->execute()) {
            echo "<p>✅ Shipping marked complete. Confirmation #: <strong>$confirmation_number</strong></p>";
        } else {
            echo "<p>❌ Failed to update shipping record. Error: " . $update_stmt->error . "</p>";
        }

        $update_stmt->close();
    }

    $check_stmt->close();
}

$conn->close();
?>
