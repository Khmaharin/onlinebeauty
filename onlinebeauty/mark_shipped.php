include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['order_id'])) {
    $order_id = intval($_POST['order_id']);
    $confirmation_number = strtoupper(uniqid('SHIP-'));

    $stmt = $conn->prepare("
        UPDATE Shipping 
        SET shipping_status = 'Shipped',
            shipped_date = NOW(),
            shipping_confirmation = ?
        WHERE order_id = ?
    ");
    $stmt->bind_param("si", $confirmation_number, $order_id);

    if ($stmt->execute()) {
        echo "<p>✅ Shipping marked complete. Confirmation #: <strong>$confirmation_number</strong></p>";
        echo "<a href='shipping.php?customer_id={$_GET['customer_id']}'>← Back to Order</a>";
    } else {
        echo "❌ Failed to update shipping.";
    }

    $stmt->close();
}
