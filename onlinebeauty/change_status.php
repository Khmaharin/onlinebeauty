<?php
include 'db_connect.php';

if (isset($_GET['order_id'])) {
    $order_id = $_GET['order_id'];

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $status = $_POST['status'];

        // Update the status of the order
        $stmt = $conn->prepare("UPDATE Orders SET status = ? WHERE order_id = ?");
        $stmt->bind_param("si", $status, $order_id);
        $stmt->execute();

        echo "<p>✅ Status updated successfully!</p>";
    }
} else {
    echo "❌ Order ID not provided.";
}
?>

<!-- Form for changing order status -->
<h2>Change Order Status</h2>
<form method="POST">
    Status: 
    <select name="status">
        <option value="Pending">Pending</option>
        <option value="Shipped">Shipped</option>
        <option value="Delivered">Delivered</option>
    </select><br>
    <button type="submit">Update Status</button>
</form>
