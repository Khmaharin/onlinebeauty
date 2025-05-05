-- Create the `customer` table first
CREATE TABLE customer (
  customer_id INT NOT NULL AUTO_INCREMENT,
  customer_name VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20) DEFAULT NULL,
  address TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (customer_id),
  UNIQUE KEY email (email)
);

-- Create the `products` table second
CREATE TABLE products (
  product_id INT NOT NULL AUTO_INCREMENT,
  product_name VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT DEFAULT 0,
  category VARCHAR(50) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (product_id)
);

-- Create the `orders` table third
CREATE TABLE orders (
  order_id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  total_amount DECIMAL(10,2) DEFAULT NULL,
  status VARCHAR(20) DEFAULT 'Pending',
  shipping_method VARCHAR(255) DEFAULT NULL,
  shipping_confirmation VARCHAR(100) DEFAULT NULL,
  order_status VARCHAR(50) NOT NULL,
  shipping_status VARCHAR(50) DEFAULT 'Pending',
  shipped_date DATETIME DEFAULT NULL,
  PRIMARY KEY (order_id),
  KEY customer_id (customer_id),
  CONSTRAINT orders_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

-- Create the `orderitems` table after `orders`
CREATE TABLE orderitems (
  item_id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  PRIMARY KEY (item_id),
  KEY order_id (order_id),
  KEY product_id (product_id),
  CONSTRAINT orderitems_ibfk_1 FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
  CONSTRAINT orderitems_ibfk_2 FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE CASCADE
);

-- Create the `payment` table
CREATE TABLE payment (
  payment_id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50) DEFAULT NULL,
  payment_status VARCHAR(20) DEFAULT 'Pending',
  shipping_method VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (payment_id),
  KEY order_id (order_id),
  CONSTRAINT payment_ibfk_1 FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE
);

-- Create the `shipping` table
CREATE TABLE shipping (
  shipping_id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  customer_id INT NOT NULL,
  shipping_address TEXT NOT NULL,
  shipping_method VARCHAR(50) DEFAULT NULL,
  shipping_status VARCHAR(20) DEFAULT 'Processing',
  shipped_date TIMESTAMP NULL DEFAULT NULL,
  shipping_confirmation VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (shipping_id),
  KEY order_id (order_id),
  KEY customer_id (customer_id),
  CONSTRAINT shipping_ibfk_1 FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
  CONSTRAINT shipping_ibfk_2 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

-- Create the `contact` table
CREATE TABLE contact (
  contact_id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  subject VARCHAR(100) DEFAULT NULL,
  message TEXT NOT NULL,
  contact_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (contact_id)
);

-- Create the `feedback` table
CREATE TABLE feedback (
  contact_id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  subject VARCHAR(100) DEFAULT NULL,
  message TEXT DEFAULT NULL,
  contact_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  customer_name VARCHAR(255) DEFAULT NULL,
  product_id INT DEFAULT NULL,
  PRIMARY KEY (contact_id),
  KEY customer_id (customer_id),
  CONSTRAINT contact_ibfk_1 FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE CASCADE
);

