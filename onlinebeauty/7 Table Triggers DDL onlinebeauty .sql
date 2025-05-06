-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 06, 2025 at 12:32 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `onlinebeauty`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddFeedback` (IN `p_customer_id` INT, IN `p_product_id` INT, IN `p_subject` VARCHAR(100), IN `p_message` TEXT)   BEGIN
  DECLARE v_name VARCHAR(255);

  SELECT customer_name INTO v_name FROM customer WHERE customer_id = p_customer_id;

  INSERT INTO feedback (customer_id, customer_name, product_id, subject, message, contact_date)
  VALUES (p_customer_id, v_name, p_product_id, p_subject, p_message, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteCustomer` (IN `p_customer_id` INT)   BEGIN
  DELETE FROM customer
  WHERE customer_id = p_customer_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCustomerOrders` (IN `p_customer_id` INT)   BEGIN
  SELECT o.order_id, o.order_date, o.total_amount, o.order_status, o.shipping_status
  FROM orders o
  WHERE o.customer_id = p_customer_id
  ORDER BY o.order_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ListProductInventory` ()   BEGIN
  SELECT product_id, product_name, stock_quantity, price, category
  FROM products
  ORDER BY product_name ASC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `PlaceOrder` (IN `p_customer_id` INT, IN `p_product_id` INT, IN `p_quantity` INT, IN `p_amount` DECIMAL(10,2), IN `p_payment_method` VARCHAR(50))   BEGIN
  DECLARE v_order_id INT;

  -- Insert into orders
  INSERT INTO orders (customer_id, order_date, total_amount, order_status, shipping_status)
  VALUES (p_customer_id, NOW(), p_amount, 'Confirmed', 'Pending');

  SET v_order_id = LAST_INSERT_ID();

  -- Insert into orderitems
  INSERT INTO orderitems (order_id, product_id, quantity)
  VALUES (v_order_id, p_product_id, p_quantity);

  -- Update stock
  UPDATE products
  SET stock_quantity = stock_quantity - p_quantity
  WHERE product_id = p_product_id;

  -- Insert payment
  INSERT INTO payment (order_id, payment_date, amount, payment_method, payment_status)
  VALUES (v_order_id, NOW(), p_amount, p_payment_method, 'Paid');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RestockProduct` (IN `p_product_id` INT, IN `p_quantity` INT)   BEGIN
  UPDATE products
  SET stock_quantity = stock_quantity + p_quantity
  WHERE product_id = p_product_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateShippingStatus` (IN `p_order_id` INT, IN `p_status` VARCHAR(50), IN `p_confirmation` VARCHAR(50))   BEGIN
  UPDATE shipping
  SET shipping_status = p_status,
      shipping_confirmation = p_confirmation,
      shipped_date = NOW()
  WHERE order_id = p_order_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `contact`
--

CREATE TABLE `contact` (
  `contact_id` int(11) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `message` text NOT NULL,
  `contact_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contact`
--

INSERT INTO `contact` (`contact_id`, `full_name`, `email`, `subject`, `message`, `contact_date`) VALUES
(1, 'Maharin Khondoker', 'khmaharin@gmail.com', 'Product', 'I need to buy a facewash', '2025-05-05 00:16:48');

--
-- Triggers `contact`
--
DELIMITER $$
CREATE TRIGGER `trg_create_feedback` AFTER INSERT ON `contact` FOR EACH ROW BEGIN
  INSERT INTO feedback (customer_id, subject, message, contact_date, customer_name)
  SELECT customer_id, NEW.subject, NEW.message, NEW.contact_date, customer_name
  FROM customer
  WHERE email = NEW.email;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `customer_name` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`customer_id`, `customer_name`, `email`, `phone_number`, `address`, `created_at`) VALUES
(1, 'Maharin Khondoker', 'khmaharin@gmail.com', '9294626642', '32-50 70th Street apt 3F', '2025-05-04 05:20:47'),
(2, 'KHONDOKER REZAUL KAWNAIN', 'krkawnain@gmail.com', '3474217502', '171-09 jamica', '2025-05-04 06:26:53'),
(3, 'Tahmina Begum	', 'tbegum@gmail.com', '9164856624', '77-11 56st woodside', '2025-05-04 06:39:41'),
(4, 'Baqer Mollah', 'baqer@gmail.com', '7169816780', '15 boston ave', '2025-05-04 06:59:35'),
(5, 'Milli Khan', 'milli@yahoo.com', '712-662-9501', '123-44 long st', '2025-05-04 10:29:28'),
(6, 'Mable Gomz', 'gmable@yahoo.com', '9152837615', '23-98 woodside', '2025-05-04 18:44:52'),
(7, 'Tama Hok', 'hok@gmail.com', '2357928762', '91-26 74th st', '2025-05-05 01:28:46');

-- --------------------------------------------------------

--
-- Stand-in structure for view `customer_full_info`
-- (See below for the actual view)
--
CREATE TABLE `customer_full_info` (
`customer_id` int(11)
,`customer_name` varchar(255)
,`customer_email` varchar(100)
,`phone_number` varchar(20)
,`address` text
,`customer_created_at` timestamp
,`order_id` int(11)
,`order_date` timestamp
,`total_amount` decimal(10,2)
,`order_payment_status` varchar(20)
,`order_shipping_method` varchar(255)
,`shipping_confirmation` varchar(100)
,`full_order_status` varchar(50)
,`order_shipping_status` varchar(50)
,`order_shipped_date` datetime
,`item_id` int(11)
,`product_id` int(11)
,`product_name` varchar(255)
,`product_description` text
,`price` decimal(10,2)
,`category` varchar(50)
,`stock_quantity` int(11)
,`quantity` int(11)
,`payment_id` int(11)
,`payment_date` timestamp
,`payment_amount` decimal(10,2)
,`payment_method` varchar(50)
,`payment_status` varchar(20)
,`shipping_id` int(11)
,`shipping_address` text
,`shipping_method_detail` varchar(50)
,`shipping_shipping_status` varchar(20)
,`shipping_shipped_date` timestamp
,`shipping_confirmation_detail` varchar(50)
,`feedback_id` int(11)
,`feedback_subject` varchar(100)
,`feedback_message` text
,`feedback_date` timestamp
);

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `contact_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `contact_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `customer_name` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feedback`
--

INSERT INTO `feedback` (`contact_id`, `customer_id`, `subject`, `message`, `contact_date`, `customer_name`, `product_id`) VALUES
(1, 3, 'Product', 'well enough', '2025-05-05 03:38:59', 'Tahmina Begum	', 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `full_order_details`
-- (See below for the actual view)
--
CREATE TABLE `full_order_details` (
`customer_id` int(11)
,`customer_name` varchar(255)
,`email` varchar(100)
,`order_id` int(11)
,`order_date` timestamp
,`total_amount` decimal(10,2)
,`order_status` varchar(50)
,`payment_status` varchar(20)
,`shipping_status` varchar(20)
,`product_name` varchar(255)
,`price` decimal(10,2)
,`quantity` int(11)
,`feedback_subject` varchar(100)
,`feedback_message` text
);

-- --------------------------------------------------------

--
-- Table structure for table `orderitems`
--

CREATE TABLE `orderitems` (
  `item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orderitems`
--

INSERT INTO `orderitems` (`item_id`, `order_id`, `product_id`, `quantity`) VALUES
(1, 1, 3, 1),
(2, 2, 2, 1),
(3, 3, 2, 2),
(4, 4, 2, 5),
(5, 5, 4, 1),
(6, 6, 2, 4),
(7, 8, 2, 2),
(8, 9, 2, 2),
(9, 10, 5, 2),
(10, 11, 5, 2),
(11, 12, 3, 1),
(12, 13, 1, 4);

--
-- Triggers `orderitems`
--
DELIMITER $$
CREATE TRIGGER `trg_check_stock` BEFORE INSERT ON `orderitems` FOR EACH ROW BEGIN
  DECLARE current_stock INT;

  SELECT stock_quantity INTO current_stock
  FROM products
  WHERE product_id = NEW.product_id;

  IF current_stock < NEW.quantity THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Not enough stock available for this product.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_reduce_stock` AFTER INSERT ON `orderitems` FOR EACH ROW BEGIN
  UPDATE products
  SET stock_quantity = stock_quantity - NEW.quantity
  WHERE product_id = NEW.product_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_amount` decimal(10,2) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `shipping_method` varchar(255) DEFAULT NULL,
  `shipping_confirmation` varchar(100) DEFAULT NULL,
  `order_status` varchar(50) NOT NULL,
  `shipping_status` varchar(50) DEFAULT 'Pending',
  `shipped_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `customer_id`, `order_date`, `total_amount`, `status`, `shipping_method`, `shipping_confirmation`, `order_status`, `shipping_status`, `shipped_date`) VALUES
(1, 2, '2025-05-04 07:26:51', 5.00, 'Delivered', 'Standard Shipping', NULL, '', 'Pending', NULL),
(2, 2, '2025-05-04 07:32:45', 10.00, 'Pending', NULL, 'SHIP-68174D522648B', '', 'Shipped', '2025-05-04 07:19:46'),
(3, 1, '2025-05-04 08:09:09', 20.00, 'Shipped', NULL, NULL, '', 'Pending', NULL),
(4, 1, '2025-05-04 08:12:03', 50.00, 'Shipped', NULL, 'SHIP-68174D3D97E3E', '', 'Shipped', '2025-05-04 07:19:25'),
(5, 4, '2025-05-04 09:42:15', 35.00, 'Shipped', NULL, 'SHIP-6817540BB13DC', '', 'Shipped', '2025-05-04 07:48:27'),
(6, 3, '2025-05-04 09:51:45', 40.00, 'Shipped', NULL, 'SHIP-68174DFAC7C39', '', 'Shipped', '2025-05-04 07:22:34'),
(8, 5, '2025-05-04 10:30:25', 20.00, 'Pending', NULL, NULL, '', 'Pending', NULL),
(9, 5, '2025-05-04 10:31:23', 20.00, 'Pending', NULL, 'SHIP-68175638E1E12', '', 'Shipped', '2025-05-04 08:06:53'),
(10, 6, '2025-05-04 18:46:29', 15.98, 'Shipped', NULL, NULL, '', 'Pending', NULL),
(11, 6, '2025-05-05 00:08:59', 15.98, 'Shipped', NULL, NULL, '', 'Pending', NULL),
(12, 7, '2025-05-05 01:29:11', 5.00, 'Shipped', NULL, NULL, '', 'Pending', NULL),
(13, 1, '2025-05-05 04:01:23', 40.00, 'Pending', NULL, NULL, '', 'Pending', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `payment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT 'Pending',
  `shipping_method` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`payment_id`, `order_id`, `payment_date`, `amount`, `payment_method`, `payment_status`, `shipping_method`) VALUES
(1, 1, '2025-05-04 08:04:47', 5.00, 'Cash', 'Paid', NULL),
(2, 2, '2025-05-04 08:08:33', 10.00, 'Credit Card', 'Paid', NULL),
(3, 1, '2025-05-04 08:08:41', 5.00, 'Cash', 'Paid', NULL),
(4, 1, '2025-05-04 08:09:58', 5.00, 'PayPal', 'Paid', NULL),
(5, 4, '2025-05-04 08:13:00', 50.00, 'PayPal', 'Paid', NULL),
(6, 2, '2025-05-04 08:42:17', 10.00, 'Credit Card', 'Paid', NULL),
(7, 2, '2025-05-04 08:42:17', 10.00, 'Credit Card', 'Paid', NULL),
(8, 2, '2025-05-04 08:42:52', 10.00, 'Credit Card', 'Paid', NULL),
(9, 1, '2025-05-04 08:52:09', 5.00, 'Cash', 'Paid', NULL),
(10, 1, '2025-05-04 09:11:56', 5.00, 'Cash', 'Paid', NULL),
(11, 1, '2025-05-04 09:14:59', 5.00, 'Credit Card', 'Paid', NULL),
(12, 1, '2025-05-04 09:25:30', 5.00, 'PayPal', 'Paid', NULL),
(13, 1, '2025-05-04 09:29:18', 5.00, 'PayPal', 'Paid', NULL),
(14, 1, '2025-05-04 09:32:54', 5.00, 'PayPal', 'Paid', NULL),
(15, 1, '2025-05-04 09:33:08', 5.00, NULL, 'Paid', NULL),
(16, 5, '2025-05-04 09:42:44', 35.00, 'PayPal', 'Paid', NULL),
(17, 5, '2025-05-04 09:43:15', 35.00, NULL, 'Paid', NULL),
(18, 5, '2025-05-04 09:44:54', 35.00, NULL, 'Paid', NULL),
(19, 5, '2025-05-04 09:44:57', 35.00, NULL, 'Paid', NULL),
(20, 5, '2025-05-04 09:47:43', 35.00, NULL, 'Paid', NULL),
(21, 2, '2025-05-04 09:48:30', 10.00, 'PayPal', 'Paid', NULL),
(22, 2, '2025-05-04 09:49:15', 10.00, NULL, 'Paid', NULL),
(23, 6, '2025-05-04 09:52:25', 40.00, 'PayPal', 'Paid', NULL),
(24, 6, '2025-05-04 10:04:21', 40.00, 'PayPal', 'Paid', NULL),
(25, 6, '2025-05-04 10:04:21', 40.00, 'PayPal', 'Paid', 'Overnight'),
(26, 6, '2025-05-04 10:05:20', 40.00, 'PayPal', 'Paid', 'Overnight'),
(27, 6, '2025-05-04 10:05:29', 40.00, 'PayPal', 'Paid', 'Overnight'),
(28, 1, '2025-05-04 10:05:40', 5.00, 'Cash', 'Paid', 'Express'),
(29, 1, '2025-05-04 10:06:13', 5.00, 'Cash', 'Paid', 'Express'),
(30, 1, '2025-05-04 10:11:58', 5.00, 'Cash', 'Paid', 'Express'),
(31, 2, '2025-05-04 10:23:52', 10.00, 'Credit Card', 'Paid', 'Express'),
(32, 9, '2025-05-04 10:31:57', 20.00, 'PayPal', 'Paid', 'Express'),
(33, 10, '2025-05-04 18:47:01', 15.98, 'PayPal', 'Paid', 'Overnight'),
(34, 10, '2025-05-04 19:09:47', 15.98, 'PayPal', 'Paid', 'Express'),
(35, 3, '2025-05-04 23:55:07', 20.00, 'PayPal', 'Paid', 'Express'),
(36, 11, '2025-05-05 00:10:21', 15.98, 'PayPal', 'Paid', 'Express'),
(37, 12, '2025-05-05 01:29:24', 5.00, 'PayPal', 'Paid', 'Express');

--
-- Triggers `payment`
--
DELIMITER $$
CREATE TRIGGER `trg_payment_complete` AFTER INSERT ON `payment` FOR EACH ROW BEGIN
  DECLARE order_total DECIMAL(10,2);

  SELECT total_amount INTO order_total
  FROM orders
  WHERE order_id = NEW.order_id;

  IF NEW.amount >= order_total THEN
    UPDATE payment
    SET payment_status = 'Completed'
    WHERE payment_id = NEW.payment_id;
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_update_order_status` AFTER INSERT ON `payment` FOR EACH ROW BEGIN
  UPDATE orders
  SET status = 'Paid', order_status = 'Confirmed'
  WHERE order_id = NEW.order_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) DEFAULT 0,
  `category` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `product_name`, `description`, `price`, `stock_quantity`, `category`, `created_at`) VALUES
(1, 'Facepack', 'Glowing skin', 10.00, 6, '1', '2025-05-04 05:39:26'),
(2, 'Facepack', 'Glowing skin', 10.00, 20, '1', '2025-05-04 05:40:27'),
(3, 'Hairclip', 'Make your hair beautiful', 5.00, 20, '3', '2025-05-04 06:26:11'),
(4, 'Eyeshadow', 'Make your eye bright', 35.00, 10, '4', '2025-05-04 06:40:21'),
(5, 'Eyeliner', 'Flawless', 7.99, 20, '5', '2025-05-04 18:46:10'),
(6, 'Soup', 'Smooth feeling', 5.00, 25, '6', '2025-05-05 00:08:40');

-- --------------------------------------------------------

--
-- Table structure for table `shipping`
--

CREATE TABLE `shipping` (
  `shipping_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `shipping_address` text NOT NULL,
  `shipping_method` varchar(50) DEFAULT NULL,
  `shipping_status` varchar(20) DEFAULT 'Processing',
  `shipped_date` timestamp NULL DEFAULT NULL,
  `shipping_confirmation` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `shipping`
--

INSERT INTO `shipping` (`shipping_id`, `order_id`, `customer_id`, `shipping_address`, `shipping_method`, `shipping_status`, `shipped_date`, `shipping_confirmation`) VALUES
(1, 9, 5, '123-44 long st', 'Express', 'Shipped', '2025-05-05 01:25:22', 'SHIP-6818138262DA3'),
(2, 12, 7, '91-26 74th st', 'Express', 'Shipped', '2025-05-05 01:30:34', 'SHIP-681814BA247CA');

--
-- Triggers `shipping`
--
DELIMITER $$
CREATE TRIGGER `trg_order_shipping_processing` AFTER INSERT ON `shipping` FOR EACH ROW BEGIN
  UPDATE orders
  SET order_status = 'Processing', shipping_status = 'Processing'
  WHERE order_id = NEW.order_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_shipping_status` BEFORE UPDATE ON `shipping` FOR EACH ROW BEGIN
  IF NEW.shipped_date IS NOT NULL THEN
    SET NEW.shipping_status = 'Shipped';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_contact_summary`
-- (See below for the actual view)
--
CREATE TABLE `view_contact_summary` (
`contact_id` int(11)
,`full_name` varchar(255)
,`email` varchar(255)
,`subject` varchar(100)
,`message` text
,`contact_date` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_customers`
-- (See below for the actual view)
--
CREATE TABLE `view_customers` (
`customer_id` int(11)
,`customer_name` varchar(255)
,`email` varchar(100)
,`phone_number` varchar(20)
,`address` text
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_feedback_summary`
-- (See below for the actual view)
--
CREATE TABLE `view_feedback_summary` (
`feedback_id` int(11)
,`customer_id` int(11)
,`customer_name` varchar(255)
,`product_id` int(11)
,`subject` varchar(100)
,`message` text
,`contact_date` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_orders`
-- (See below for the actual view)
--
CREATE TABLE `view_orders` (
`order_id` int(11)
,`customer_id` int(11)
,`order_date` timestamp
,`total_amount` decimal(10,2)
,`status` varchar(20)
,`order_status` varchar(50)
,`shipping_status` varchar(50)
,`shipping_method` varchar(255)
,`shipping_confirmation` varchar(100)
,`shipped_date` datetime
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_order_items`
-- (See below for the actual view)
--
CREATE TABLE `view_order_items` (
`item_id` int(11)
,`order_id` int(11)
,`product_id` int(11)
,`product_name` varchar(255)
,`quantity` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_payments`
-- (See below for the actual view)
--
CREATE TABLE `view_payments` (
`payment_id` int(11)
,`order_id` int(11)
,`payment_date` timestamp
,`amount` decimal(10,2)
,`payment_method` varchar(50)
,`payment_status` varchar(20)
,`shipping_method` varchar(50)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_product_catalog`
-- (See below for the actual view)
--
CREATE TABLE `view_product_catalog` (
`product_id` int(11)
,`product_name` varchar(255)
,`description` text
,`price` decimal(10,2)
,`stock_quantity` int(11)
,`category` varchar(50)
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_shipping_info`
-- (See below for the actual view)
--
CREATE TABLE `view_shipping_info` (
`shipping_id` int(11)
,`order_id` int(11)
,`customer_id` int(11)
,`shipping_address` text
,`shipping_method` varchar(50)
,`shipping_status` varchar(20)
,`shipped_date` timestamp
,`shipping_confirmation` varchar(50)
);

-- --------------------------------------------------------

--
-- Structure for view `customer_full_info`
--
DROP TABLE IF EXISTS `customer_full_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customer_full_info`  AS SELECT `cu`.`customer_id` AS `customer_id`, `cu`.`customer_name` AS `customer_name`, `cu`.`email` AS `customer_email`, `cu`.`phone_number` AS `phone_number`, `cu`.`address` AS `address`, `cu`.`created_at` AS `customer_created_at`, `o`.`order_id` AS `order_id`, `o`.`order_date` AS `order_date`, `o`.`total_amount` AS `total_amount`, `o`.`status` AS `order_payment_status`, `o`.`shipping_method` AS `order_shipping_method`, `o`.`shipping_confirmation` AS `shipping_confirmation`, `o`.`order_status` AS `full_order_status`, `o`.`shipping_status` AS `order_shipping_status`, `o`.`shipped_date` AS `order_shipped_date`, `oi`.`item_id` AS `item_id`, `p`.`product_id` AS `product_id`, `p`.`product_name` AS `product_name`, `p`.`description` AS `product_description`, `p`.`price` AS `price`, `p`.`category` AS `category`, `p`.`stock_quantity` AS `stock_quantity`, `oi`.`quantity` AS `quantity`, `pay`.`payment_id` AS `payment_id`, `pay`.`payment_date` AS `payment_date`, `pay`.`amount` AS `payment_amount`, `pay`.`payment_method` AS `payment_method`, `pay`.`payment_status` AS `payment_status`, `s`.`shipping_id` AS `shipping_id`, `s`.`shipping_address` AS `shipping_address`, `s`.`shipping_method` AS `shipping_method_detail`, `s`.`shipping_status` AS `shipping_shipping_status`, `s`.`shipped_date` AS `shipping_shipped_date`, `s`.`shipping_confirmation` AS `shipping_confirmation_detail`, `f`.`contact_id` AS `feedback_id`, `f`.`subject` AS `feedback_subject`, `f`.`message` AS `feedback_message`, `f`.`contact_date` AS `feedback_date` FROM ((((((`customer` `cu` left join `orders` `o` on(`cu`.`customer_id` = `o`.`customer_id`)) left join `orderitems` `oi` on(`o`.`order_id` = `oi`.`order_id`)) left join `products` `p` on(`oi`.`product_id` = `p`.`product_id`)) left join `payment` `pay` on(`o`.`order_id` = `pay`.`order_id`)) left join `shipping` `s` on(`o`.`order_id` = `s`.`order_id` and `cu`.`customer_id` = `s`.`customer_id`)) left join `feedback` `f` on(`cu`.`customer_id` = `f`.`customer_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `full_order_details`
--
DROP TABLE IF EXISTS `full_order_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `full_order_details`  AS SELECT `c`.`customer_id` AS `customer_id`, `c`.`customer_name` AS `customer_name`, `c`.`email` AS `email`, `o`.`order_id` AS `order_id`, `o`.`order_date` AS `order_date`, `o`.`total_amount` AS `total_amount`, `o`.`order_status` AS `order_status`, `p`.`payment_status` AS `payment_status`, `s`.`shipping_status` AS `shipping_status`, `pr`.`product_name` AS `product_name`, `pr`.`price` AS `price`, `oi`.`quantity` AS `quantity`, `f`.`subject` AS `feedback_subject`, `f`.`message` AS `feedback_message` FROM ((((((`customer` `c` join `orders` `o` on(`c`.`customer_id` = `o`.`customer_id`)) left join `payment` `p` on(`o`.`order_id` = `p`.`order_id`)) left join `shipping` `s` on(`o`.`order_id` = `s`.`order_id`)) left join `orderitems` `oi` on(`o`.`order_id` = `oi`.`order_id`)) left join `products` `pr` on(`oi`.`product_id` = `pr`.`product_id`)) left join `feedback` `f` on(`c`.`customer_id` = `f`.`customer_id` and `pr`.`product_id` = `f`.`product_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_contact_summary`
--
DROP TABLE IF EXISTS `view_contact_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_contact_summary`  AS SELECT `contact`.`contact_id` AS `contact_id`, `contact`.`full_name` AS `full_name`, `contact`.`email` AS `email`, `contact`.`subject` AS `subject`, `contact`.`message` AS `message`, `contact`.`contact_date` AS `contact_date` FROM `contact` ;

-- --------------------------------------------------------

--
-- Structure for view `view_customers`
--
DROP TABLE IF EXISTS `view_customers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_customers`  AS SELECT `customer`.`customer_id` AS `customer_id`, `customer`.`customer_name` AS `customer_name`, `customer`.`email` AS `email`, `customer`.`phone_number` AS `phone_number`, `customer`.`address` AS `address`, `customer`.`created_at` AS `created_at` FROM `customer` ;

-- --------------------------------------------------------

--
-- Structure for view `view_feedback_summary`
--
DROP TABLE IF EXISTS `view_feedback_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_feedback_summary`  AS SELECT `feedback`.`contact_id` AS `feedback_id`, `feedback`.`customer_id` AS `customer_id`, `feedback`.`customer_name` AS `customer_name`, `feedback`.`product_id` AS `product_id`, `feedback`.`subject` AS `subject`, `feedback`.`message` AS `message`, `feedback`.`contact_date` AS `contact_date` FROM `feedback` ;

-- --------------------------------------------------------

--
-- Structure for view `view_orders`
--
DROP TABLE IF EXISTS `view_orders`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_orders`  AS SELECT `orders`.`order_id` AS `order_id`, `orders`.`customer_id` AS `customer_id`, `orders`.`order_date` AS `order_date`, `orders`.`total_amount` AS `total_amount`, `orders`.`status` AS `status`, `orders`.`order_status` AS `order_status`, `orders`.`shipping_status` AS `shipping_status`, `orders`.`shipping_method` AS `shipping_method`, `orders`.`shipping_confirmation` AS `shipping_confirmation`, `orders`.`shipped_date` AS `shipped_date` FROM `orders` ;

-- --------------------------------------------------------

--
-- Structure for view `view_order_items`
--
DROP TABLE IF EXISTS `view_order_items`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_order_items`  AS SELECT `oi`.`item_id` AS `item_id`, `oi`.`order_id` AS `order_id`, `oi`.`product_id` AS `product_id`, `p`.`product_name` AS `product_name`, `oi`.`quantity` AS `quantity` FROM (`orderitems` `oi` join `products` `p` on(`oi`.`product_id` = `p`.`product_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_payments`
--
DROP TABLE IF EXISTS `view_payments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_payments`  AS SELECT `payment`.`payment_id` AS `payment_id`, `payment`.`order_id` AS `order_id`, `payment`.`payment_date` AS `payment_date`, `payment`.`amount` AS `amount`, `payment`.`payment_method` AS `payment_method`, `payment`.`payment_status` AS `payment_status`, `payment`.`shipping_method` AS `shipping_method` FROM `payment` ;

-- --------------------------------------------------------

--
-- Structure for view `view_product_catalog`
--
DROP TABLE IF EXISTS `view_product_catalog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_product_catalog`  AS SELECT `products`.`product_id` AS `product_id`, `products`.`product_name` AS `product_name`, `products`.`description` AS `description`, `products`.`price` AS `price`, `products`.`stock_quantity` AS `stock_quantity`, `products`.`category` AS `category`, `products`.`created_at` AS `created_at` FROM `products` ;

-- --------------------------------------------------------

--
-- Structure for view `view_shipping_info`
--
DROP TABLE IF EXISTS `view_shipping_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_shipping_info`  AS SELECT `shipping`.`shipping_id` AS `shipping_id`, `shipping`.`order_id` AS `order_id`, `shipping`.`customer_id` AS `customer_id`, `shipping`.`shipping_address` AS `shipping_address`, `shipping`.`shipping_method` AS `shipping_method`, `shipping`.`shipping_status` AS `shipping_status`, `shipping`.`shipped_date` AS `shipped_date`, `shipping`.`shipping_confirmation` AS `shipping_confirmation` FROM `shipping` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `contact`
--
ALTER TABLE `contact`
  ADD PRIMARY KEY (`contact_id`);

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`contact_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `shipping`
--
ALTER TABLE `shipping`
  ADD PRIMARY KEY (`shipping_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `contact`
--
ALTER TABLE `contact`
  MODIFY `contact_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `contact_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orderitems`
--
ALTER TABLE `orderitems`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `shipping`
--
ALTER TABLE `shipping`
  MODIFY `shipping_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `feedback`
--
ALTER TABLE `feedback`
  ADD CONSTRAINT `contact_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE;

--
-- Constraints for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD CONSTRAINT `orderitems_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orderitems_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE;

--
-- Constraints for table `shipping`
--
ALTER TABLE `shipping`
  ADD CONSTRAINT `shipping_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `shipping_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
