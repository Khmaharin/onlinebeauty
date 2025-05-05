<?php
include 'db_connect.php';

// Handle Edit
$editing = false;
$edit_product = [
    'product_id' => '',
    'product_name' => '',
    'description' => '',
    'price' => '',
    'stock_quantity' => '',
    'category' => ''
];

if (isset($_GET['edit'])) {
    $editing = true;
    $id = intval($_GET['edit']);
    $stmt = $conn->prepare("SELECT * FROM products WHERE product_id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    $edit_product = $result->fetch_assoc();
}

// Handle Add or Update
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['product_name'];
    $desc = $_POST['description'];
    $price = $_POST['price'];
    $stock = $_POST['stock'];
    $cat = $_POST['category'];

    if (!empty($_POST['product_id'])) {
        // Update
        $id = $_POST['product_id'];
        $stmt = $conn->prepare("UPDATE products SET product_name=?, description=?, price=?, stock_quantity=?, category=? WHERE product_id=?");
        $stmt->bind_param("ssdisi", $name, $desc, $price, $stock, $cat, $id);
        $stmt->execute();
        echo "<p class='message success'>✅ Product updated.</p>";
    } else {
        // Insert
        $stmt = $conn->prepare("INSERT INTO products (product_name, description, price, stock_quantity, category) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("ssdis", $name, $desc, $price, $stock, $cat);
        $stmt->execute();
        echo "<p class='message success'>✅ Product added.</p>";
    }
}

// Handle Delete
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    $stmt = $conn->prepare("DELETE FROM products WHERE product_id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    echo "<p class='message deleted'>🗑️ Product deleted.</p>";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Product Management</title>
  
<style>
    body {
        font-family: Arial, sans-serif;
        background: #f9fafc;
        margin: 0;
        padding: 20px;
    }

    h2 {
        text-align: center;
        color: #222;
    }

    form {
        max-width: 600px;
        margin: 20px auto;
        background: #fff;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    input, textarea {
        width: 100%;
        padding: 10px;
        margin-top: 10px;
        margin-bottom: 15px;
        border: 1px solid #ccc;
        border-radius: 6px;
    }

    button {
        background-color: #000;
        color: white;
        border: none;
        padding: 12px;
        width: 100%;
        border-radius: 6px;
        cursor: pointer;
    }

    button:hover {
        background-color: #333;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 30px;
    }

    table, th, td {
        border: 1px solid #ddd;
    }

    th, td {
        padding: 12px;
        text-align: left;
    }

    th {
        background-color: #f2f2f2;
    }

    .actions a {
        margin-right: 10px;
        color: #000;
        text-decoration: none;
    }

    .actions a:hover {
        text-decoration: underline;
    }

    .message {
        text-align: center;
        padding: 10px;
        margin: 10px auto;
        max-width: 600px;
        border-radius: 6px;
    }

    .success {
        background-color: #d4edda;
        color: #155724;
    }

    .deleted {
        background-color: #f8d7da;
        color: #721c24;
    }
</style>

</head>
<body>

<h2><?= $editing ? "Edit Product" : "Add Product" ?></h2>

<form method="POST">
    <input type="hidden" name="product_id" value="<?= htmlspecialchars($edit_product['product_id']) ?>">
    <label>Name</label>
    <input name="product_name" required value="<?= htmlspecialchars($edit_product['product_name']) ?>">

    <label>Description</label>
    <textarea name="description"><?= htmlspecialchars($edit_product['description']) ?></textarea>

    <label>Price ($)</label>
    <input name="price" type="number" step="0.01" required value="<?= htmlspecialchars($edit_product['price']) ?>">

    <label>Stock Quantity</label>
    <input name="stock" type="number" required value="<?= htmlspecialchars($edit_product['stock_quantity']) ?>">

    <label>Category</label>
    <input name="category" value="<?= htmlspecialchars($edit_product['category']) ?>">

    <button type="submit"><?= $editing ? "Update Product" : "Add Product" ?></button>
</form>

<h2>Products List</h2>
<table>
    <tr>
        <th>ID</th><th>Name</th><th>Price</th><th>Stock</th><th>Category</th><th>Actions</th>
    </tr>
    <?php
    $result = $conn->query("SELECT * FROM products");
    while ($row = $result->fetch_assoc()) {
        echo "<tr>
            <td>{$row['product_id']}</td>
            <td>".htmlspecialchars($row['product_name'])."</td>
            <td>\${$row['price']}</td>
            <td>{$row['stock_quantity']}</td>
            <td>".htmlspecialchars($row['category'])."</td>
            <td class='actions'>
                <a href='?edit={$row['product_id']}'>✏️ Edit</a>
                <a href='?delete={$row['product_id']}' onclick=\"return confirm('Delete this product?')\">🗑️ Delete</a>
            </td>
        </tr>";
    }
    ?>
</table>

</body>
</html>

