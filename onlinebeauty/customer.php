<?php
include 'db_connect.php';

// Add customer data
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit'])) {
    $customer_name = $_POST['customer_name'];
    $email = $_POST['email'];
    $phone_number = $_POST['phone_number'];
    $address = $_POST['address'];

    $stmt = $conn->prepare("INSERT INTO Customer (customer_name, email, phone_number, address) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $customer_name, $email, $phone_number, $address);
    $stmt->execute();
    echo "Customer registered successfully.";
    $stmt->close();
}

// Edit customer data
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['edit'])) {
    $customer_id = $_POST['customer_id'];
    $customer_name = $_POST['customer_name'];
    $email = $_POST['email'];
    $phone_number = $_POST['phone_number'];
    $address = $_POST['address'];

    $stmt = $conn->prepare("UPDATE Customer SET customer_name = ?, email = ?, phone_number = ?, address = ? WHERE customer_id = ?");
    $stmt->bind_param("ssssi", $customer_name, $email, $phone_number, $address, $customer_id);
    $stmt->execute();
    echo "Customer data updated successfully.";
    $stmt->close();
}

// Delete customer data
if (isset($_GET['delete'])) {
    $customer_id = $_GET['delete'];
    $stmt = $conn->prepare("DELETE FROM Customer WHERE customer_id = ?");
    $stmt->bind_param("i", $customer_id);
    $stmt->execute();
    echo "Customer data deleted successfully.";
    $stmt->close();
}

// Fetch all customers
$result = $conn->query("SELECT * FROM Customer");
?>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: white;
            color: black;
            margin: 0;
            padding: 0;
        }

        h1 {
            background-color: black;
            color: white;
            text-align: center;
            padding: 20px;
            margin-bottom: 30px;
            font-size: 2em;
        }

        h2 {
            color: black;
            margin: 20px 0;
            font-size: 1.5em;
        }

        .form-container {
            width: 50%;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border: 1px solid black;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        form {
            display: flex;
            flex-direction: column;
        }

        label {
            margin-bottom: 10px;
            color: black;
            font-size: 1em;
        }

        input[type="text"], input[type="email"], textarea {
            width: 100%;
            padding: 12px;
            margin: 8px 0;
            border-radius: 4px;
            border: 1px solid black;
            background-color: white;
            color: black;
            font-size: 1em;
        }

        input[type="text"]:focus, input[type="email"]:focus, textarea:focus {
            outline: none;
            border-color: #888;
        }

        button {
            background-color: black;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1.1em;
            margin-top: 10px;
        }

        button:hover {
            background-color: #555;
        }

        table {
            width: 90%;
            margin: 30px auto;
            border-collapse: collapse;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid black;
            font-size: 1em;
        }

        th {
            background-color: #f2f2f2;
            color: black;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        a {
            color: black;
            text-decoration: none;
            font-size: 1em;
        }

        a:hover {
            text-decoration: underline;
        }

        .confirmation {
            font-weight: bold;
            color: green;
            text-align: center;
            margin: 20px;
        }

        .error {
            font-weight: bold;
            color: red;
            text-align: center;
            margin: 20px;
        }
    </style>
</head>
<body>
<h1>Manage Customers</h1>

<!-- Registration Form -->
<h2>Register Customer</h2>
<div class="form-container">
    <form method="POST">
        <label>Full Name: <input type="text" name="customer_name" required></label>
        <label>Email: <input type="email" name="email" required></label>
        <label>Phone: <input type="text" name="phone_number" required></label>
        <label>Address: <textarea name="address" required></textarea></label>
        <button type="submit" name="submit">Register</button>
    </form>
</div>

<hr>

<!-- Customer Table -->
<h2>Customer List</h2>
<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Address</th>
        <th>Actions</th>
    </tr>
    <?php while ($row = $result->fetch_assoc()): ?>
        <tr>
            <td><?= htmlspecialchars($row['customer_id']) ?></td>
            <td><?= htmlspecialchars($row['customer_name']) ?></td>
            <td><?= htmlspecialchars($row['email']) ?></td>
            <td><?= htmlspecialchars($row['phone_number']) ?></td>
            <td><?= htmlspecialchars($row['address']) ?></td>
            <td>
                <a href="customer.php?edit=<?= $row['customer_id'] ?>">Edit</a> |
                <a href="customer.php?delete=<?= $row['customer_id'] ?>" onclick="return confirm('Are you sure you want to delete this customer?');">Delete</a>
            </td>
        </tr>
    <?php endwhile; ?>
</table>

<?php
// Edit form display
if (isset($_GET['edit'])):
    $customer_id = $_GET['edit'];
    $stmt = $conn->prepare("SELECT * FROM Customer WHERE customer_id = ?");
    $stmt->bind_param("i", $customer_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $customer = $result->fetch_assoc();
?>
<hr>
<h2>Edit Customer</h2>
<div class="form-container">
    <form method="POST">
        <input type="hidden" name="customer_id" value="<?= $customer['customer_id'] ?>">
        <label>Full Name: <input type="text" name="customer_name" value="<?= htmlspecialchars($customer['customer_name']) ?>" required></label>
        <label>Email: <input type="email" name="email" value="<?= htmlspecialchars($customer['email']) ?>" required></label>
        <label>Phone: <input type="text" name="phone_number" value="<?= htmlspecialchars($customer['phone_number']) ?>" required></label>
        <label>Address: <textarea name="address" required><?= htmlspecialchars($customer['address']) ?></textarea></label>
        <button type="submit" name="edit">Save Changes</button>
    </form>
</div>
<?php endif; ?>

</body>
</html>
