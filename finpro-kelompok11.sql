-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 31, 2024 at 09:06 AM
-- Server version: 11.4.2-MariaDB-4
-- PHP Version: 8.2.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `finpro2`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `add_recently_added` ()   BEGIN
    -- Menghapus semua data sebelumnya dari tabel recently_added
    DELETE FROM recently_added$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `add_to_cart` (IN `customer_id` VARCHAR(10), IN `products_id` INT)   BEGIN
    DECLARE existing_product INT$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `count_view_website` ()   BEGIN
    DECLARE done INT DEFAULT 0$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `CreateOrder` (IN `p_user_id` VARCHAR(10), IN `p_total_price` DECIMAL(10,2), IN `p_name` VARCHAR(50), IN `p_email` VARCHAR(100), IN `p_address` TEXT, IN `p_phone` VARCHAR(20), IN `p_postal_code` VARCHAR(5), IN `p_city` VARCHAR(50), IN `p_province` VARCHAR(50), IN `p_payment_method` VARCHAR(50))   BEGIN
    DECLARE v_order_id INT$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `GetDailyTransactions` ()   BEGIN
    SELECT 
        DATE_FORMAT(oi.created_at, '%Y-%m-%d') AS transaction_date, -- Format tanggal harian
        SUM(oi.subtotal) AS total_revenue,                         -- Total pendapatan harian
        SUM(oi.subtotal - (p.price_buy * oi.quantity)) AS total_profit, -- Total profit harian
        SUM(p.price_buy * oi.quantity) AS total_cost               -- Total biaya harian
    FROM 
        order_items oi
    JOIN 
        products p ON oi.product_id = p.product_id                 -- Gabungkan data produk dengan harga beli
    GROUP BY 
        DATE_FORMAT(oi.created_at, '%Y-%m-%d')                     -- Kelompokkan berdasarkan tanggal harian
    ORDER BY 
        transaction_date$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `GetOrderDetail` (IN `p_order_id` INT)   BEGIN
    -- Cek apakah metode pembayaran adalah bank_transfer
    DECLARE v_payment_method VARCHAR(50)$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `GetProductPopularity` ()   BEGIN
    SELECT 
        p.product_id,
        p.name,
        COUNT(oi.product_id) AS total_purchased
    FROM 
        order_items oi
    JOIN 
        products p ON oi.product_id = p.product_id
    GROUP BY 
        p.product_id, p.name
    ORDER BY 
        total_purchased DESC
    LIMIT 5$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `get_monthly_financial_report` ()   BEGIN
    SELECT
        DATE_FORMAT(oi.created_at, '%Y-%m') AS transaction_month,  -- Format bulan-tahun
        SUM(oi.subtotal) AS total_revenue,                          -- Total pendapatan
        SUM(oi.subtotal - (p.price_buy * oi.quantity)) AS total_profit,  -- Total profit per produk
        SUM(p.price_buy * oi.quantity) AS total_cost  -- Total biaya berdasarkan harga beli dan kuantitas
    FROM 
        order_items oi
    JOIN 
        products p ON oi.product_id = p.product_id                 -- Gabungkan data produk dengan harga beli yang berbeda
    GROUP BY 
        DATE_FORMAT(oi.created_at, '%Y-%m')                         -- Kelompokkan berdasarkan bulan
    ORDER BY 
        transaction_month DESC$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `get_top_products` ()   BEGIN
    SELECT 
        p.product_id, 
        p.name, 
        p.price_sell, 
        p.description, 
        p.image, 
        SUM(oi.quantity) AS total_bought
    FROM 
        products p
    JOIN 
        order_items oi ON p.product_id = oi.product_id
    JOIN 
        orders o ON oi.order_id = o.order_id
    GROUP BY 
        p.product_id
    ORDER BY 
        total_bought DESC
    LIMIT 9$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `SavePayment` (IN `p_order_id` INT, IN `p_payment_method` VARCHAR(50), IN `p_transfer_proof` VARCHAR(255), IN `p_payment_status` VARCHAR(50))   BEGIN
    INSERT INTO order_payments (order_id, payment_method, transfer_proof, payment_status)
    VALUES (p_order_id, p_payment_method, p_transfer_proof, p_payment_status)$$

CREATE DEFINER=`titikkoma`@`localhost` PROCEDURE `UpdateCartQuantity` (IN `p_user_id` VARCHAR(10), IN `p_product_id` INT, IN `p_action` VARCHAR(10))   BEGIN
    IF p_action = 'increase' THEN
        -- Tambah jumlah produk
        UPDATE cart
        SET quantity = quantity + 1
        WHERE Customer_id = p_user_id AND product_id = p_product_id$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` varchar(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `role` enum('admin') NOT NULL DEFAULT 'admin',
  `fullname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `username`, `password`, `email`, `created_at`, `updated_at`, `role`, `fullname`) VALUES
('ADMIN0001', 'halo', 'scrypt:32768:8:1$4NdJxpVfWQ0IO20s$31059123bb9d4eaab955960db8fbceabe24305b6d98597ff8791443f65b76b967de0ff75efa8edbb5c548d67d67e52eba5eabbddbd225fab49ef1ddb30861103', 'halo@gmail.com', '2024-12-19 22:22:17', '2024-12-21 22:08:59', 'admin', 'deva nadindra'),
('ADMIN0002', 'lienka@gmail.com', 'scrypt:32768:8:1$xXCO8LegMDpEkrUF$c047839774197ae56ceaef138a4fb441e72cd598615ab6e2c4b3f68e6709f3f4cca25e3727fd54cd8c1e25c48afe60145b516cf1fb038e4607df83f7516ecad1', 'firdagheitsa11@gmail.com', '2024-12-22 08:30:42', '2024-12-22 08:38:17', 'admin', 'defa\r\n'),
('ADMIN0003', 'admin5', 'scrypt:32768:8:1$vQRVmyyo0Hrjqj41$64ccfea7c8196c77e6c320c727335ddf76c2dcb5a46d9c37dcd5da2ec8b5db52bf9f0471b5cd1e75bc488ca99895a86e877a626662d921b0f8c30a150c66f396', 'admin5@gmail.com', '2024-12-22 14:38:07', '2024-12-22 14:38:07', 'admin', 'elsa');

--
-- Triggers `admin`
--
DELIMITER $$
CREATE TRIGGER `generate_admin_id` BEFORE INSERT ON `admin` FOR EACH ROW BEGIN
    DECLARE new_admin_id VARCHAR(10)$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `cart_id` int(11) NOT NULL,
  `customer_id` varchar(10) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `added_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`cart_id`, `customer_id`, `product_id`, `quantity`, `added_at`) VALUES
(39, 'CUST0001', 33, 1, '2024-12-22 07:35:50');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `created_at`, `updated_at`, `image`) VALUES
(1, 'Notebook', '2024-12-07 17:34:16', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(2, 'Audio', '2024-12-07 17:34:49', '2024-12-14 14:33:41', 'audio.jpg'),
(3, 'Mainboard', '2024-12-07 17:34:49', '2024-12-14 14:33:41', 'mainboard.jpg'),
(4, 'Processor', '2024-12-07 17:34:49', '2024-12-14 14:33:41', 'procesor.jpg'),
(5, 'Gaming Notebook', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'gamin_notebook.jpg'),
(6, 'Desktop - Mini PC', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'pc.jpg'),
(7, 'Memory', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'memory.jpg'),
(8, 'HardDisk - SSD', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'ssd.jpg'),
(9, 'VGA Card', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'vga_card.jpg'),
(10, 'Casing PC', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'casing_pc.jpg'),
(11, 'Cooler - Modding Kit', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'cooler.jpg'),
(12, 'Power Suplly', '2024-12-09 01:03:21', '2024-12-14 14:33:41', 'power_supply.jpg'),
(13, 'Monitor - Bracket', '2024-12-09 01:03:21', '2024-12-20 21:36:19', 'DM_EF318588A316A9F4AC9986788DF73D67_230522110501_ll.jpg'),
(14, 'Keyboard - Mouse - Pen Tablet', '2024-12-09 01:03:21', '2024-12-20 21:37:28', 'KB_MS_Pen_Kit_573x430.png'),
(15, 'Streaming Recording', '2024-12-09 01:03:21', '2024-12-20 21:38:38', '71iQA7aw-QL.jpg'),
(16, 'Gaming Chair', '2024-12-09 01:03:21', '2024-12-20 21:39:24', '02.5114001.jpg'),
(17, 'Gaming Desk', '2024-12-09 01:03:21', '2024-12-20 21:42:44', 'images.jpeg'),
(18, 'UPS - Stabilizer', '2024-12-09 01:03:21', '2024-12-20 21:43:57', 'images (1).jpeg'),
(19, 'Printer - Scanner', '2024-12-09 01:03:21', '2024-12-20 21:45:26', 'printer-canon-pixma-g201020191112164608_thumb.jpg'),
(20, 'Printer Kasir - Alat Kasir', '2024-12-09 01:03:21', '2024-12-20 21:46:32', 'tablet-pos-system-android.jpg'),
(21, 'Cartridge - Toner - Ink', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(22, 'Networking - NAS Storage', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(23, 'Flash Disk - Memory Card', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(24, 'Aksesoris', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(25, 'CCTV - Security', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(26, 'Rak Server', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(27, 'Projector - Presentasi', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg'),
(28, 'Console', '2024-12-09 01:03:21', '2024-12-09 10:32:04', 'notebook-bg.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `customer_id` varchar(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `role` enum('customer') NOT NULL,
  `fullname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`customer_id`, `username`, `password`, `email`, `created_at`, `updated_at`, `role`, `fullname`) VALUES
('CUST0001', 'tes', 'scrypt:32768:8:1$VspOMlLjpHuTjFLW$78d442996bd45edee24c3c1cade5311cadebaf24210ca5bc8e7359ea9f015eb8991bf6ee201329a26e54793c70a1b44cb54f373af301529cea2e245bf4fbab9b', 'tes@gmail.com', '2024-12-18 22:16:39', '2024-12-19 21:20:52', 'customer', 'tes'),
('CUST0002', 'zain', 'scrypt:32768:8:1$5CCNNcPuP6Ia6hG7$eb6f89201fe8d870ad7397483420a9699596108b0fbe6718516cc7b34244a2b2dbf4b0497a01410512e76a3ed21487f5d7faf11288497b5511873c71986c519c', 'zain@gmail.com', '2024-12-20 16:13:24', '2024-12-20 16:25:33', 'customer', 'zain'),
('CUST0003', 'firda', 'scrypt:32768:8:1$onbQpFd888HOX06k$c8e8fa48fe7389859866659af36e45a4455247e5f0066f8b4e126c104602076d2be1dc3c3260fd599a023d57e7824f1459e98dbbc2491a41ef491841cf942f94', 'firda@gmail.com', '2024-12-21 21:49:19', '2024-12-21 21:49:19', 'customer', 'elsa');

--
-- Triggers `customers`
--
DELIMITER $$
CREATE TRIGGER `generate_customer_id` BEFORE INSERT ON `customers` FOR EACH ROW BEGIN
    DECLARE new_id VARCHAR(10)$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `customer_profile`
--

CREATE TABLE `customer_profile` (
  `cp_id` int(11) NOT NULL,
  `customer_id` varchar(10) DEFAULT NULL,
  `phonenumber` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `province_id` int(11) DEFAULT NULL,
  `city` varchar(255) DEFAULT '',
  `postal_code` varchar(5) DEFAULT '',
  `profile_picture` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `customer_profile`
--

INSERT INTO `customer_profile` (`cp_id`, `customer_id`, `phonenumber`, `address`, `province_id`, `city`, `postal_code`, `profile_picture`) VALUES
(1, 'CUST0001', '081330234066', 'faniah', 1, 'Malang', '31231', 'CUST0001_jpeg'),
(2, 'CUST0002', '42141231231232', 'araya blok m', 2, 'malang', '31231', 'CUST0002_images.jpeg');

-- --------------------------------------------------------

--
-- Table structure for table `employee`
--

CREATE TABLE `employee` (
  `employee_id` varchar(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `role` enum('employee') NOT NULL,
  `fullname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `employee`
--

INSERT INTO `employee` (`employee_id`, `username`, `password`, `email`, `created_at`, `updated_at`, `role`, `fullname`) VALUES
('EMP0001', 'depa', 'scrypt:32768:8:1$qw1PsMXFN8DNfHJj$9df28b6b443981b2286ab2a2429cde53d88ec55c80344d7b0dc1b26f70e598ef28d56e5d7a12b264bc35e0e608ae9e0708b2e8533b4a54156d8b763e4e5e5e2f', 'depa@gmail.com', '2024-12-19 02:02:33', '2024-12-19 21:37:19', 'employee', 'depa');

--
-- Triggers `employee`
--
DELIMITER $$
CREATE TRIGGER `generate_employee_id` BEFORE INSERT ON `employee` FOR EACH ROW BEGIN
    DECLARE new_employee_id VARCHAR(10)$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `customer_id` varchar(10) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `status_order` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp(),
  `postal_code` varchar(5) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `province` varchar(50) DEFAULT NULL,
  `admin_id` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `customer_id`, `total_price`, `name`, `email`, `address`, `phone`, `payment_method`, `status_order`, `created_at`, `updated_at`, `postal_code`, `city`, `province`, `admin_id`) VALUES
(9, 'CUST0001', 1883000.00, 'tes', 'tes@gmail.com', 'faniah', '081330234066', 'Cash on Delivery', 'completed', '2024-12-19 16:25:36', '2024-12-19 16:25:36', '31231', 'Malang', '1', 'ADMIN0001'),
(10, 'CUST0001', 33690000.00, 'tes', 'tes@gmail.com', 'faniah', '081330234066', 'Cash on Delivery', 'pending', '2024-12-19 19:12:58', '2024-12-19 19:12:58', '31231', 'Malang', '1', 'ADMIN0002'),
(11, 'CUST0001', 43852000.00, 'tes', 'tes@gmail.com', 'faniah', '081330234066', 'Cash on Delivery', 'pending', '2024-12-19 19:46:09', '2024-12-19 19:46:09', '31231', 'Malang', '1', 'ADMIN0002'),
(12, 'CUST0002', 18160000.00, 'zain', 'zain@gmail.com', 'araya blok m', '42141231231232', 'Cash on Delivery', 'processing', '2024-12-20 09:26:38', '2024-12-20 09:26:38', '31231', 'malang', '2', 'ADMIN0002'),
(14, 'CUST0002', 8000000.00, 'zain', 'zain@gmail.com', 'araya blok m', '42141231231232', 'Cash on Delivery', 'pending', '2024-11-21 03:34:42', '2024-11-21 03:34:42', '31231', 'malang', '2', 'ADMIN0002'),
(15, 'CUST0002', 20468000.00, 'zain', 'zain@gmail.com', 'araya blok m', '42141231231232', 'Cash on Delivery', 'pending', '2024-12-21 03:51:07', '2024-12-21 03:51:07', '31231', 'malang', '2', 'ADMIN0001'),
(16, 'CUST0003', 2138000.00, 'Firda Gheitsa Sahira', 'firda@gmail.com', 'aaaaaaaa', '081234491324', 'Cash on Delivery', 'completed', '2024-12-21 14:50:12', '2024-12-21 14:50:12', '12345', 'KABUPATEN MALANG', '15', 'ADMIN0001'),
(17, 'CUST0001', 562000.00, 'tes', 'tes@gmail.com', 'faniah', '081330234066', 'Cash on Delivery', 'pending', '2024-12-21 15:04:36', '2024-12-21 15:04:36', '31231', 'Malang', '1', 'ADMIN0001'),
(18, 'CUST0003', 15500000.00, 'Firda Gheitsa Sahira', 'firda@gmail.com', 'aaaaa', '081234491324', 'bank_transfer', 'pending', '2024-12-22 01:46:52', '2024-12-22 01:46:52', '65153', 'KABUPATEN MALANG', '15', NULL),
(19, 'CUST0001', 1850000.00, 'Firda Gheitsa Sahira', 'tes@gmail.com', 'Perumahan Banjararum Asri Blok AG-18', '081234491324', 'bank_transfer', 'pending', '2024-12-22 01:48:26', '2024-12-22 01:48:26', '31231', 'KABUPATEN MALANG', '15', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp(),
  `review_status` varchar(20) DEFAULT 'not yet'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price`, `subtotal`, `created_at`, `updated_at`, `review_status`) VALUES
(42, 9, 23, 1, 1883000.00, 1883000.00, '2024-12-19 16:25:36', '2024-12-19 16:25:36', 'not yet'),
(43, 10, 26, 3, 4000000.00, 12000000.00, '2024-12-19 19:12:58', '2024-12-19 19:12:58', 'not yet'),
(44, 10, 25, 3, 7230000.00, 21690000.00, '2024-12-19 19:12:58', '2024-12-19 19:12:58', 'not yet'),
(46, 11, 25, 4, 7230000.00, 28920000.00, '2024-12-19 19:46:09', '2024-12-19 19:46:09', 'not yet'),
(47, 11, 23, 4, 1883000.00, 7532000.00, '2024-12-19 19:46:09', '2024-12-19 19:46:09', 'not yet'),
(48, 11, 22, 4, 1850000.00, 7400000.00, '2024-12-19 19:46:09', '2024-12-19 19:46:09', 'not yet'),
(49, 12, 25, 2, 7230000.00, 14460000.00, '2024-12-20 09:26:38', '2024-12-20 09:26:38', 'not yet'),
(50, 12, 22, 2, 1850000.00, 3700000.00, '2024-12-20 09:26:38', '2024-12-20 09:26:38', 'not yet'),
(53, 14, 26, 2, 4000000.00, 8000000.00, '2024-11-21 03:34:42', '2024-11-21 03:34:42', 'not yet'),
(54, 15, 32, 1, 1675000.00, 1675000.00, '2024-12-21 03:51:07', '2024-12-21 03:51:07', 'not yet'),
(55, 15, 34, 1, 463000.00, 463000.00, '2024-12-21 03:51:07', '2024-12-21 03:51:07', 'not yet'),
(56, 15, 24, 1, 8500000.00, 8500000.00, '2024-12-21 03:51:07', '2024-12-21 03:51:07', 'not yet'),
(57, 15, 25, 1, 7230000.00, 7230000.00, '2024-12-21 03:51:07', '2024-12-21 03:51:07', 'not yet'),
(58, 15, 30, 1, 2600000.00, 2600000.00, '2024-12-21 03:51:07', '2024-12-21 03:51:07', 'not yet'),
(61, 16, 32, 1, 1675000.00, 1675000.00, '2024-12-21 14:50:12', '2024-12-21 14:50:12', 'not yet'),
(62, 16, 34, 1, 463000.00, 463000.00, '2024-12-21 14:50:12', '2024-12-21 14:50:12', 'not yet'),
(64, 17, 33, 1, 562000.00, 562000.00, '2024-12-21 15:04:36', '2024-12-21 15:04:36', 'not yet'),
(65, 18, 31, 2, 7750000.00, 15500000.00, '2024-12-22 01:46:52', '2024-12-22 01:46:52', 'not yet'),
(66, 19, 22, 1, 1850000.00, 1850000.00, '2024-12-22 01:48:26', '2024-12-22 01:48:26', 'not yet');

-- --------------------------------------------------------

--
-- Table structure for table `order_payments`
--

CREATE TABLE `order_payments` (
  `payment_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `payment_method` varchar(50) NOT NULL,
  `transfer_proof` varchar(255) DEFAULT NULL,
  `payment_status` varchar(20) DEFAULT 'pending',
  `payment_date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `order_payments`
--

INSERT INTO `order_payments` (`payment_id`, `order_id`, `payment_method`, `transfer_proof`, `payment_status`, `payment_date`) VALUES
(8, 18, 'bank_transfer', 'CUST0003-18.jpeg', 'pending', '2024-12-22 01:46:52'),
(9, 19, 'bank_transfer', 'CUST0001-19.png', 'pending', '2024-12-22 01:48:26');

-- --------------------------------------------------------

--
-- Table structure for table `owner`
--

CREATE TABLE `owner` (
  `owner_id` varchar(10) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `role` enum('owner') NOT NULL,
  `fullname` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `owner`
--

INSERT INTO `owner` (`owner_id`, `username`, `password`, `email`, `created_at`, `updated_at`, `role`, `fullname`) VALUES
('OWNER0001', 'lienka', 'scrypt:32768:8:1$zT9CHzhUSLfQ5y2Q$8f8de40a24d0e3ada2838af2655c872289b36b79044cdce4e1318af99863c173cbf979c54026398970602275e4d0179ba12bf07da4c40e3faecba7a6f28fe618', 'lienka@gmail.com', '2024-12-19 01:46:33', '2024-12-19 01:46:33', 'owner', 'lienka');

--
-- Triggers `owner`
--
DELIMITER $$
CREATE TRIGGER `before_insert_owner` BEFORE INSERT ON `owner` FOR EACH ROW BEGIN
    DECLARE new_id VARCHAR(10)$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `image` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `price_sell` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL,
  `price_buy` decimal(10,2) DEFAULT NULL,
  `specifications` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `category_id`, `created_at`, `updated_at`, `image`, `description`, `price_sell`, `stock`, `price_buy`, `specifications`) VALUES
(22, 'MSI G2422C MONITOR', 13, '2024-12-19 23:01:06', '2024-12-22 08:48:26', '0160642e-c4af-4c82-852e-430738e44ba1.jpg', 'MSI G2422C MONITOR [1080p, 180Hz]', 1850000.00, 18, 1350000.00, '#GARANSI RESMI MSI 3TAHUN\r\n\r\n-Curved Gaming display (1500R) – The best gameplay immersion.\r\n-180Hz Refresh Rate – Real smooth gaming.\r\n-1ms response time - eliminate screen tearing and choppy frame rates.\r\n-Wide Color Gamut - Game colors and details will look more realistic and refined, to push game immersion to its limits.\r\n-Anti-Flicker and Less Blue Light – game even longer and prevent eye strain and fatique.\r\n-Frameless design – Ultimate gameplay experience.\r\n-178° wide view angle.\r\n\r\nBrand Type : G2422C\r\nPanel Size(Inch) : 24”\r\nPanel Type : VA\r\nPanel Resolution : 1920 x 1080 (FHD)\r\nAspect Ratio : 16 : 9\r\nCurvature : 1500R\r\n\r\nBrightness (cd/) : 250 cd/m2\r\nRefresh Rate(hz) : 180Hz\r\nResponse Time : 1ms (GTG)\r\nSync : Adaptive sync\r\nConnectivity :\r\n2x HDMI™ (Supports 1920 x 1080 P@180Hz as speciﬁed in HDMI™ 2.0b)\r\n1x DP (Supports 21920 x 1080 P@180Hz as speciﬁed in DisplayPort 1.2a)\r\n\r\nAudio port :Audio Out / Mic in\r\nVESA mounting (mm) : 75 x 75 mm\r\nErgonomic Stand : No\r\n\r\nPower Input : 110~240V, 50/60Hz\r\nProduct Weight (nw/kg) : 3.3kg / 4.9kg\r\nDimension : 537.4 x 215.6 x 414.7 mm\r\n537.4 x 88.4 x 319.7 (without stand)'),
(23, 'Monitor LED Xiaomi G27i 27', 13, '2024-12-19 23:03:39', '2024-12-20 02:46:09', '1793e5a9-958d-47fb-b554-2e5f6e67f0b4.jpg', 'Monitor LED Xiaomi G27i 27\" IPS 1080p FHD 165Hz 1ms HDMI DP VESA', 1883000.00, 45, 1383000.00, '#GARANSI RESMI 3TAHUN\r\n\r\nBrand Type : Xiaomi G27i\r\nPanel Size(Inch) : 27 Inch\r\nPanel Type : IPS Flat\r\nPanel Resolution : 1920 x 1080 (Full HD)\r\nAspect Ratio : 16:9 Wide\r\n\r\nBrightness (cd/㎡) : 250\r\nRefresh Rate(hz) : 165\r\nResponse Time (ms) : 1\r\nSync : AMD FreeSync™ Premium + Adaptive Sync\r\nConnectivity : HDMI 2.0 x1 + DP 1.2 x1\r\nSpeaker : No\r\n\r\nAudio port : 1 x 3.5mm Audio Out\r\nVESA mounting (mm) : 75x75\r\nErgonomic Stand : No\r\n\r\nPanel bit : 8 bits\r\nHDR : HDR10\r\nNTSC (%) : -\r\nSRGB (%) : 99\r\nAdobe RGB (%) : -\r\nDCI-P3 (%) : -\r\n\r\nPower Cons (watt) : 36\r\nProduct Weight (nw/kg) : 3.6\r\nBox Dimension (cm) : 68 x 43 x 11\r\nVolume Weight (kg) : 6\r\n\r\nInclude :\r\nAdapter + Power Cable\r\nHDMI Cable'),
(24, 'Sony PS5 Slim', 28, '2024-12-19 23:28:24', '2024-12-21 10:51:07', '80161e1e-0b24-4ac6-abab-17f18fcae4cb.jpg', 'Sony PS5 Slim Console Disc Edition Sony Playstation 5 - Unit Only', 8500000.00, 49, 8000000.00, 'The PS5® console* unleashes new gaming possibilities that you never anticipated.\r\n\r\nRelease Date : 20 February 2024\r\n\r\nExperience lightning fast loading with an ultra-high speed SSD, deeper immersion with support for haptic feedback, adaptive triggers, and 3D Audio**, and an all-new generation of incredible PlayStation® games.\r\n\r\nSlim Design\r\nWith PS5®, players get powerful gaming technology packed inside a sleek and compact console design.\r\n\r\n1TB of Storage\r\nKeep your favorite games ready and waiting for you to jump in and play with 1TB of SSD storage built in.***\r\n\r\nUltra-High Speed SSD\r\nMaximize your play sessions with near instant load times for installed PS5® games.\r\n\r\nIntegrated I/O\r\nThe custom integration of the PS5® console\'s systems lets creators pull data from the SSD so quickly that they can design games in ways never before possible.\r\n\r\nWhat\'s in the Box\r\n\r\nPlayStation®5 console\r\nDualSense™ Wireless Controller\r\n1TB SSD\r\n2 Horizontal stand feet\r\nHDMI® cable\r\nAC power cord\r\nUSB cable\r\nPrinted materials\r\nASTRO\'s PLAYROOM (Pre-installed game)****'),
(25, 'Intel Core Ultra 7-265K', 4, '2024-12-20 01:43:18', '2024-12-21 10:51:07', 'f72e0313-87a4-4a46-a208-2c9272b6e739.jpg', 'Intel Core Ultra 7-265K 20 Cores 20 Threads LGA1851 Arrow Lake Processor\r\n', 7230000.00, 13, 6730000.00, 'CPU Specifications\r\nTotal Cores\r\n20\r\n# of Performance-cores\r\n8\r\n# of Efficient-cores\r\n12\r\nTotal Threads\r\n20\r\nMax Turbo Frequency\r\n5.5 GHz\r\nIntel® Turbo Boost Max Technology 3.0 Frequency ‡\r\n5.5 GHz\r\nPerformance-core Max Turbo Frequency\r\n5.4 GHz\r\nEfficient-core Max Turbo Frequency\r\n4.6 GHz\r\nPerformance-core Base Frequency\r\n3.9 GHz\r\nEfficient-core Base Frequency\r\n3.3 GHz\r\nCache\r\n30 MB Intel® Smart Cache\r\nTotal L2 Cache\r\n36 MB\r\nProcessor Base Power\r\n125 W\r\nMaximum Turbo Power\r\n250 W\r\nIntel® Deep Learning Boost (Intel® DL Boost) on CPU\r\nYes\r\nAI Software Frameworks Supported by CPU\r\nOpenVINO™, WindowsML, DirectML, ONNX RT, WebNN\r\nCPU Lithography\r\nTSMC N3B\r\n\r\n\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146\r\n'),
(26, 'PAKET Asrock DESKMINI X300', 6, '2024-12-20 01:44:55', '2024-12-21 10:36:36', 'efb19f94-1506-41f6-b626-178123007d7f.jpg', 'PAKET Asrock DESKMINI X300 - Ryzen 3200G + SSD 128GB + Memory RAM 16Gb', 4000000.00, 10, 3000000.00, 'Asrock DESKMINI X300\r\n\r\nPaket Ryzen 3200G + SSD 128Gb + Memory RAM 16Gb 3200MHz\r\n\r\nSPECIFICATION:\r\n\r\nCPU\r\n- Supports AMD AM4 Socket CPUs (Renoir, Picasso, Raven Ridge, up to 65W)\r\nMemory\r\n- Supports 2 x SO-DIMM DDR4 Memory, Max. 64GB\r\n- AMD Ryzen 4000 series 3200MHz\r\n- AMD Ryzen 3000/2000 series 2933MHz\r\nChipset\r\n- AMD X300\r\nGraphics Output\r\n- HDMI(4K @60Hz)\r\n- DisplayPort, D-Sub\r\nAudio\r\n- 1 x Head Phone with MIC Jack, 1 x MIC-In (RealtekALC233)\r\nFront USB\r\n- 1 x USB 3.2 Gen1 Type-C, 1 x USB 3.2 Gen1 Type-A\r\nRear USB\r\n- 1 x USB 3.2 Gen1 Type-A, 1 x USB 2.0 Type-A,\r\nStorage\r\n- 2 x SATA3 with Power connectors (RAID 0/1)\r\n- 1 x Ultra M.2 (2280) PCIe Gen3 x4 SSD Slot\r\n- 1 x Ultra M.2 (2280) Slot\r\n- PCIe Gen3 x4 (Renoir, Picasso and Raven Ridge APU)\r\n- PCIe Gen3 x2 (Athlon 2xxGE series APU)\r\nLAN\r\n- Gigabit LAN (RealtekRTL8111H)\r\nWLAN\r\n- 1 x M.2 (key E 2230) Slot for Wi-Fi + BT Module\r\nConnectors\r\n- 1 x USB 2.0 Header\r\n- 1 x Front Panel Header\r\n- 2 x 4-Pin fan connectors (CPU, SYS)\r\n- 1 x DC-In Jack (Supports 19V Power Adapters)\r\n- 1 x Internal Speaker Header (4-Pin)\r\n- 1 x Chassis Intrusion Header (2-Pin)\r\n- 1 x Audio Header (4-Pin)\r\nAccessory\r\n- 2 x SATA Data with Power Cable\r\n- 1 x 120W/19V adapter\r\n- 1 x Screws Pack\r\nDimension\r\n- 155 x 155 x 80 mm (1.92L)\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146'),
(27, 'ASUS ROG Zephyrus G14 GA402', 5, '2024-12-20 21:30:41', '2024-12-20 21:30:41', 'baa5a4a3-bd07-44b6-b763-16d113049ee9.jpg', 'ASUS ROG Zephyrus G14 GA402NJ-R735A6G-O Ryzen 7-7735HS RTX3050 16GB 512GB 14\" FHD W11 - Eclipse Gray - LAPTOP, 16/512GB', 22000000.00, 35, 21000000.00, 'ASUS ROG Zephyrus G14 (2023) GA402NJ-R735A6G-O Eclipse Gray\r\n\r\nFREE WIRELESS MOUSE *hurry up, limited stock\r\n\r\n• Processor : AMD Ryzen™ 7 7735HS Mobile Processor (8-core/16-thread, 16MB L3 cache, up to 4.7 GHz max boost)\r\n• Graphics : NVIDIA® GeForce RTX™ 3050 Laptop GPU 6GB GDDR6\r\nROG Boost: 1782MHz* at 95W (1732MHz Boost Clock+50MHz OC, 80W+15W Dynamic Boost)*\r\n• Display :14 Inch FHD\r\n,Support Dolby Vision HDR : Yes\r\n• Memory : 16GB / 24GB / 40GB DDR5-4800 SO-DIMM\r\n• Storage : 512GB PCIe® 4.0 NVMe™ M.2 SSD\r\n\r\n• I/O Ports :\r\n1x 3.5mm Combo Audio Jack\r\n1x HDMI 2.1 FRL\r\n2x USB 3.2 Gen 2 Type-A\r\n1x USB 3.2 Gen 2 Type-C support DisplayPort™\r\n1x Type C USB 4 support DisplayPort™ / power delivery\r\n1x card reader (microSD) (UHS-II)\r\n\r\n• Keyboard : Backlit Chiclet Keyboard 1-Zone RGB\r\n• Camera : 1080P FHD IR Camera for Windows Hello\r\n\r\n• Audio :\r\nSmart Amp Technology\r\nDolby Atmos\r\nAI noise-canceling technology\r\nHi-Res certification\r\nBuilt-in 3-microphone array\r\n4-speaker system with Smart Amplifier Technology\r\n\r\n• Network and Communication : Wi-Fi 6E(802.11ax) (Triple band) 2*2 + Bluetooth® 5.3 Wireless Card (*Bluetooth® version may change with OS version different.)\r\n• Battery : 76WHrs, 4S1P, 4-cell Li-ion\r\n• Power Supply : ø6.0, 240W AC Adapter, Output: 20V DC, 12A, 240W, Input: 100~240C AC 50/60Hz universal\r\n• Weight : 1.72 Kg (3.79 lbs)\r\n• Dimensions (W x D x H) : 31.2 x 22.7 x 1.95 ~ 2.05 cm (12.28\" x 8.94\" x 0.77\" ~ 0.81\")\r\n\r\n• Security :\r\nBIOS Administrator Password and User Password Protection\r\nTrusted Platform Module (Firmware TPM)\r\n\r\n• Bundle :\r\nROG Zephyrus G14 Sleeve (2022)\r\n\r\nGaransi Resmi ASUS Indonesia 2 Tahun (1st year perfect warranty)'),
(28, 'Asus TUF A15 FA506', 5, '2024-12-20 21:31:52', '2024-12-20 21:31:52', '7b4ae56b-c1a7-45d1-950a-ef8e9d34e98d.jpg', 'Asus TUF A15 FA506NCR-R735B6T-O AMD Ryzen 7-7435HS 16GB 512GB SSD RTX3050 4GB 15.6″ FHD 144Hz Win 11 Graphite Black - LAPTOP, 16/512GB', 13000000.00, 15, 12000000.00, 'TUF A15 FA506NCR-R735B6T-O\r\n\r\nFREE WIRELESS MOUSE *hurry up, limited stock\r\n\r\nSpesifikasi:\r\n\r\nProcessor : AMD Ryzen™ 7 7435HS Mobile Processor 3.1GHz (20MB Cache, up to 4.5 GHz, 8 cores, 16 Threads)\r\nDisplay : 15.6-inch FHD (1920 x 1080) 16:9 144Hz Adaptive-Sync Value IPS-level 250nits 1000:1 62.5% sRGB Anti-glare display\r\nMemory : 16GB DDR5-5600 SO-DIMM, 2x SO-DIMM slots, Max 32GB\r\nStorage : 512GB PCIe® 4.0 NVMe™ M.2 SSD (2 Slot Include Used)\r\nGraphics : NVIDIA® GeForce RTX™ 3050 Laptop GPU 4GB GDDR6\r\nKeyboard : Backlit Chiclet Keyboard 1-Zone RGB\r\nWireless : Wi-Fi 6(802.11ax) (Dual band) 2*2 + Bluetooth® 5.3 Wireless Card (*Bluetooth® version may change with OS version different.)\r\nPorts : 1x RJ45 LAN port; 1x USB 3.2 Gen 2 Type-C support DisplayPort™; 3x USB 3.2 Gen 2 Type-A; 1x HDMI 2.0b; 1x 3.5mm Combo Audio Jack\r\nSpeakers : 2-speaker system\r\nCamera : 720P HD camera\r\nBattery : 48WHrs, 3S1P, 3-cell Li-ion 150W AC Adapter\r\nSku : FA506NCR-R735B6T-O\r\nColor : Graphite Black\r\nOS : Windows 11 Home + Office Home and Student 2021\r\nFree : TUF Gaming backpack\r\nGaransi Resmi Asus 2 Years Global Warranty (with 1st year Perfect Warranty)'),
(29, 'Lenovo Ideapad 5 PRO 14AHP9', 1, '2024-12-21 10:39:58', '2024-12-21 10:39:58', '8cd1fb6a-f7fa-4bba-86fb-5335d0242612.jpg', 'Lenovo Ideapad 5 PRO 14AHP9-3LID RTX3050 AMD Ryzen 7-8845HS 1TB SSD 16GB RAM Notebook Laptop', 19000000.00, 25, 17000000.00, '\"BELI OFFLINE LEBIH MURAH\"\r\n.\r\n.\r\n\r\n\r\nGaransi RESMI 3 Tahun ADP 3 Tahun Premium Care LENOVO INDONESIA\r\nPastikan membeli PRODUK RESMI INDONESIA untuk kemudahan CLAIM GARANSI di Service Center Resmi Di Seluruh Indonesia\r\n\r\nSPECIFICATIONS:\r\n\r\nProcessor\r\nAMD Ryzen™ 7 8845HS (8C / 16T, 3.8 / 5.1GHz, 8MB L2 / 16MB L3)\r\nAI PC Category\r\nAI PC\r\nNPU\r\nIntegrated AMD Ryzen™ AI, up to 16 TOPS\r\nGraphics\r\nNVIDIA® GeForce RTX™ 3050 6GB GDDR6\r\nChipset\r\nAMD SoC Platform\r\nMemory\r\n16GB Soldered LPDDR5x-6400\r\nMemory Slots\r\nMemory soldered to systemboard, no slots, dual-channel\r\nMax Memory\r\n16GB soldered memory, not upgradable\r\nStorage\r\n1TB SSD M.2 2242 PCIe® 4.0x4 NVMe®\r\nStorage Support\r\n\r\nOne drive, up to 1TB M.2 2242 SSD\r\nStorage Slot\r\nOne M.2 2280 PCIe® 4.0 x4 slot\r\nCard Reader\r\nSD Card Reader\r\nOptical\r\nNone\r\nAudio Chip\r\nHigh Definition (HD) Audio\r\nSpeakers\r\nStereo speakers, 2W x2, optimized with Dolby Atmos®\r\nCamera\r\nFHD 1080p + IR with Privacy Shutter, ToF Sensor\r\nMicrophone\r\n2x, Array\r\nBattery\r\nIntegrated 84Wh\r\nPower Adapter\r\n140W USB-C® Slim (3-pin)\r\nDESIGN\r\nDisplay\r\n14\" 2.8K (2880x1800) OLED 400nits (Typical) / 600nits (Peak) Glossy, 100% DCI-P3, 120Hz, Eyesafe®, DisplayHDR™ True Black 500\r\nTouchscreen\r\nNone\r\nKeyboard\r\nBacklit, English\r\nTouchpad\r\nButtonless glass surface multi-touch touchpad, supports Precision TouchPad (PTP), 75 x 120 mm (2.95 x 4.72 inches)\r\nSurface Treatment\r\nAluminium Stamping (Anodized)\r\nCase Material\r\nAluminium (Top), Aluminium (Bottom)\r\nPen\r\nPen Not Supported\r\nSOFTWARE\r\nOperating System\r\nWindows® 11 Home Single Language, English\r\nBundled Software\r\nOffice Home & Student 2021\r\nCONNECTIVITY\r\nEthernet\r\nNo Onboard Ethernet\r\nWLAN + Bluetooth\r\n\r\nWi-Fi® 6E, 802.11ax 2x2 + BT5.2\r\nWWAN\r\nNon-WWAN\r\nStandard Ports\r\n\r\n1x USB-A (USB 5Gbps / USB 3.2 Gen 1)\r\n1x USB-A (USB 5Gbps / USB 3.2 Gen 1), Always On\r\n1x USB-C® (USB 10Gbps / USB 3.2 Gen 2), with USB PD 3.0 and DisplayPort™ 1.4\r\n1x USB-C® (USB4® 40Gbps), with USB PD 3.0 and DisplayPort™ 1.4\r\n1x HDMI® 2.1, up to 4K/60Hz\r\n1x Headphone / microphone combo jack (3.5mm)\r\n1x SD card reader\r\n\r\nOffline Store Kami Berada Di Cyber Mall SF/245 (Lantai 3) (depan cynema21) Jl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146'),
(30, 'PULSAR PCMK 2 HE 87 TKL Gaming Keyboard', 14, '2024-12-21 10:41:09', '2024-12-21 10:51:07', '5109e2a4-676b-4f8e-8010-790e8c0ce930.jpg', 'PULSAR PCMK 2 HE 87 TKL Gaming Keyboard - Hall Effect Magnetic Linear Switc', 2600000.00, 17, 2000000.00, '\"BELI OFFLINE LEBIH MURAH\"\r\n.\r\n.\r\n\r\nThe Hall Effect Keyboard for Competitive Gamers\r\n\r\nExperience peak gaming performance with our Hall Effect keyboard, specifically optimized for FPS and competitive play. Featuring an 87-key ANSI Tenkeyless layout and lightning-fast magnetic switches, it delivers rapid response times essential for quick actions. With Rapid Trigger technology and adjustable actuation from 0.1mm to 4mm, you can customize your key sensitivity for ultimate precision. Use the web-based software \'Bibimbap\' to explore 44 preset RGB lighting effects, all housed in a durable design with hot-swappable switches. Elevate your gaming experience and gain the competitive edge you need!\r\n\r\nSPECIFICATION :\r\n\r\nDIMENSIONS\r\n\r\nLength: 355mm (13.9in)\r\nWidth: 127mm (5in)\r\nHeight: 37mm (1.45in)\r\nWeight: 963g (± 1g) / 33.9oz\r\n\r\nTECHNICAL SPECIFICATION\r\n\r\n87Key ANSI Tenkeyless\r\nMagnetic switch\r\nTrue 8K Polling Rate\r\nRapid Trigger\r\nQuick Tap\r\nWeb based Software \'Bibimbap\'\r\n44 Preset RGB lighting effects\r\nTriple absorption structure\r\nAdjustable Actuation 0.1mm-4mm\r\nMagnetic Switch N-S Pole Hot-swappable\r\nWindows/Mac Compatibility\r\nSupport for 3 Profiles\r\nAnti-ghosting\r\nAluminum Alloy Plate and Transparent body\r\nPBT Double-shot keycaps\r\nDetachable USB-C to A Cable\r\nSuper Flexible Paracord Cable\r\n\r\nSWITCH SPECIFICATION\r\n\r\nType: Linear\r\nInitial Force: 30±7gf\r\nTotal travel: 4.1±0.2mm\r\nInitial Magnetic Flux: 75±15Gs\r\nBottom-out Magnetic Flux: 700±80Gs\r\nLifespan: 150 million keystrokes\r\n\r\nREQUIREMENT\r\n\r\nUSB 2.0 port or higher\r\nWindows 7 or higher\r\nMac OS x 10.10 or later\r\n\r\nLatest browser with Web HID support\r\n\r\nChrome - version 129 and above\r\nEdge - 128 version or later\r\nOpera - 113 version or later\r\n\r\nPACKAGE CONTENTS\r\n\r\nKeyboard x 1\r\nUSB-C Cable x 1\r\nSwitch + Keycap puller x 1\r\nHard Dust Cover x 1\r\nKeyboard Pouch x 1\r\nBrand Sticker x 1\r\nManual Set x 1\r\n\r\n\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146'),
(31, 'GIGABYTE GeForce RTX 4060 TI', 9, '2024-12-21 10:42:54', '2024-12-22 08:46:52', 'baacdd3e-efdc-4ad8-b2be-1fe101b63537.jpg', 'GIGABYTE GeForce RTX 4060 TI WINDFORCE 16GB OC GDDR6 - VGA RTX4060 DDR6', 7750000.00, 18, 7000000.00, 'GeForce RTX™ 4060 Ti WINDFORCE OC 16G\r\n\r\nFeature\r\n\r\nPowered by NVIDIA DLSS 3, ultra-efficient Ada Lovelace arch, and full ray tracing\r\n4th Generation Tensor Cores: Up to 4x performance with DLSS 3 vs. brute-force rendering\r\n3rd Generation RT Cores: Up to 2X ray tracing performance\r\nPowered by GeForce RTX™ 4060 Ti (16GB)\r\nIntegrated with 16GB GDDR6 128bit memory interface\r\nWINDFORCE cooling system\r\nProtection metal back plate\r\n\r\nSPECIFICATION :\r\n\r\nChipset\r\nGeForce RTX™ 4060 Ti (16GB)\r\nCore Clock\r\n2565 MHz (Reference Card: 2535 MHz)\r\nCUDA® Cores\r\n4352\r\nMemory Clock\r\n18 Gbps\r\nMemory Size\r\n16 GB\r\nMemory Type\r\nGDDR6\r\nMemory Bus\r\n128 bit\r\nCard Bus\r\nPCI-E 4.0\r\nDigital max resolution\r\n7680x4320\r\nMulti-view\r\n4\r\nCard size\r\nL=201 W=120 H=41 mm\r\nPCB Form\r\nATX\r\nDirectX\r\n12 Ultimate\r\nOpenGL\r\n4.6\r\nPower requirement\r\n500W\r\nPower Connectors\r\n8 pin*1\r\nOutput\r\nDisplayPort 1.4a*2\r\nHDMI 2.1a*2\r\nAccessories\r\nQuick guide\r\n\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146'),
(32, 'G.Skill Ripjaws S5 32GB', 7, '2024-12-21 10:44:44', '2024-12-21 21:50:12', '2ba2ba69-241b-4c8b-8af6-6f6ed8ea8f65.jpg', 'G.Skill Ripjaws S5 32GB (2x16) DDR5 6000Mhz Dual Kit - F5-6000J3238F16GX2-RS5 Black White - Hitam', 1675000.00, 18, 1175000.00, 'Ripjaws S5\r\nDDR5-6000 CL32-38-38-96 1.35V\r\n32GB (2x16GB)\r\nIntel XMP\r\n\r\nRipjaws S5 is a performance DDR5 DRAM memory series made with hand-screened memory ICs that passed G.SKILL rigorous validation tests. Each Ripjaws S5 memory kit strikes an ideal balance between performance, compatibility, and stability and is available in matte black or matte white aluminum heatspreaders.\r\n\r\nSPECIFICATION :\r\n\r\nMemory Type\r\nDDR5\r\nCapacity\r\n32GB (16GBx2)\r\nMulti-Channel Kit\r\nDual Channel Kit\r\nOC Profile Support\r\nIntel XMP 3.0\r\nTested Speed (XMP)\r\n6000 MT/s\r\nTested Latency (XMP)\r\n32-38-38-96\r\nTested Voltage (XMP)\r\n1.35V\r\nRegistered/Unbuffered\r\nUnbuffered\r\nError Checking (ECC)\r\nNon-ECC\r\nSPD Speed (Default)\r\n4800 MT/s\r\nSPD Voltage (Default)\r\n1.10V\r\nFan Included\r\nNo\r\nWarranty\r\nLimited Lifetime\r\nFeatures\r\nIntel XMP 3.0 (Extreme Memory Profile) Ready\r\n\r\n\r\n\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146'),
(33, 'IWARE XS-80UL 80mm Thermal Printer', 20, '2024-12-21 10:46:12', '2024-12-21 22:04:36', 'ff1be0fd-f180-45f7-b20e-abc68d3d8698.jpg', 'IWARE XS-80UL 80mm Thermal Printer With Auto Cutter - X Series', 562000.00, 29, 500000.00, 'SPECIFICATION :\r\n\r\nMetode Cetak : Thermal Line Printing\r\n- Print Speed : 200 mm/detik\r\n- Interface : USB + LAN\r\n- Roll Paper : 80 mm ( Width : 79.5 ±0.5mm, Roll Diameter: ≤80mm, Peper\r\n- Thickness Roll Paper : 0.056~0.1mm )\r\n- Dot Density : 203 Dpi, 8 Dots mm/detik\r\n- Column Capacity : 576 dots/line or 512 dots/line\r\n- Character per line : 42 or 48 karakter\r\n- Character Size : Font A 12- 24 dots, Font B 9 - 17 dots\r\n- Command : Compatible dengan ESC/POS\r\n- Barcode : UPC-A/, EAN13/8, CODE39, CODABA, CODE93, CODE128\r\n- AUTO CUTTER : YES\r\n\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146'),
(34, 'REXUS DAXA SVARA QW1', 2, '2024-12-21 10:47:44', '2024-12-21 21:50:12', '10ce5cd7-f838-41a6-a8f4-494147730f0b.jpg', 'REXUS DAXA SVARA QW1 Wireless Gaming Headset - Black', 463000.00, 23, 400000.00, 'Feature\r\n\r\nElegant Black Color Design\r\nHigh Quality Audio Performance\r\nDual Connection (Bluetooth 5.3 &3.5mm AUX Cable)\r\nSupported by ANC and Transparency Mode Technology\r\nLow Latency Mode for Gaming\r\nTalk Easily Anywhere with Built-in Microphone\r\nComfort Over-Ear Protein Leather Earmuff\r\nTravel Safe with Hard-Case Pouch\r\nOffers Convenient Portability Foldable Headset\r\nEasy to Control\r\n2,5 hours Charging Time &Bigger Battery Capacity: 500mAh Lithium Battery\r\nPlay Time up to 60 hours &35 hours (with ANC)\r\n\r\nSPECIFICATION :\r\n\r\nBluetooth Version : V5.3\r\nBaterry Capacity : 500mah\r\nBluetooth Play Time : 60H (60%Vol.)\r\nANC Playtime : 50H\r\nBluetooth &ANC Play Time : 35H (60%Vol)\r\nANC Range : 20-1.000Hz\r\nNoice Cancellation : -30 +- 3db\r\nPower Supply : DC 5V/1A\r\nCharging Time : 2.5H\r\nDriver Size : 40mm\r\nImpedance : 32 +- 10%\r\nReted Power : 20MW\r\nFrequency Range : 20Hz-20KHz\r\nSensitivity : 105dB+/-3dB\r\nDistortion : <-1% At 1KHz\r\n\r\nToko Official Kami Berada di Jl. Cyber Mall SF/245 (Lantai 3) (depan cynema21)\r\nJl. Raya Langsep No.2 Kecamatan Sukun Kota Malang Jawa Timur - 65146');

-- --------------------------------------------------------

--
-- Table structure for table `provinsi`
--

CREATE TABLE `provinsi` (
  `id` int(11) NOT NULL,
  `province` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `provinsi`
--

INSERT INTO `provinsi` (`id`, `province`) VALUES
(1, 'Aceh'),
(2, 'Sumatera Utara'),
(3, 'Sumatera Barat'),
(4, 'Riau'),
(5, 'Kepulauan Riau'),
(6, 'Jambi'),
(7, 'Sumatera Selatan'),
(8, 'Bengkulu'),
(9, 'Lampung'),
(10, 'Kepulauan Bangka Belitung'),
(11, 'DKI Jakarta'),
(12, 'Jawa Barat'),
(13, 'Jawa Tengah'),
(14, 'DI Yogyakarta'),
(15, 'Jawa Timur'),
(16, 'Banten'),
(17, 'Bali'),
(18, 'Nusa Tenggara Barat'),
(19, 'Nusa Tenggara Timur'),
(20, 'Kalimantan Barat'),
(21, 'Kalimantan Tengah'),
(22, 'Kalimantan Selatan'),
(23, 'Kalimantan Timur'),
(24, 'Kalimantan Utara'),
(25, 'Sulawesi Utara'),
(26, 'Sulawesi Tengah'),
(27, 'Sulawesi Selatan'),
(28, 'Sulawesi Barat'),
(29, 'Sulawesi Tenggara'),
(30, 'Gorontalo'),
(31, 'Maluku'),
(32, 'Maluku Utara'),
(33, 'Papua'),
(34, 'Papua Barat');

-- --------------------------------------------------------

--
-- Table structure for table `recently_added`
--

CREATE TABLE `recently_added` (
  `id` int(11) NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `added_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `recently_added`
--

INSERT INTO `recently_added` (`id`, `product_id`, `name`, `description`, `price`, `stock`, `category_id`, `image`, `added_at`) VALUES
(162, 34, 'REXUS DAXA SVARA QW1', 'REXUS DAXA SVARA QW1 Wireless Gaming Headset - Black', 463000.00, 25, 2, '10ce5cd7-f838-41a6-a8f4-494147730f0b.jpg', '2024-12-21 03:47:48'),
(163, 33, 'IWARE XS-80UL 80mm Thermal Printer', 'IWARE XS-80UL 80mm Thermal Printer With Auto Cutter - X Series', 562000.00, 30, 20, 'ff1be0fd-f180-45f7-b20e-abc68d3d8698.jpg', '2024-12-21 03:47:48'),
(164, 32, 'G.Skill Ripjaws S5 32GB', 'G.Skill Ripjaws S5 32GB (2x16) DDR5 6000Mhz Dual Kit - F5-6000J3238F16GX2-RS5 Black White - Hitam', 1675000.00, 20, 7, '2ba2ba69-241b-4c8b-8af6-6f6ed8ea8f65.jpg', '2024-12-21 03:47:48'),
(165, 31, 'GIGABYTE GeForce RTX 4060 TI', 'GIGABYTE GeForce RTX 4060 TI WINDFORCE 16GB OC GDDR6 - VGA RTX4060 DDR6', 7750000.00, 20, 9, 'baacdd3e-efdc-4ad8-b2be-1fe101b63537.jpg', '2024-12-21 03:47:48');

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `customer_id` varchar(10) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `review` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `view_product`
--

CREATE TABLE `view_product` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `customer_id` varchar(10) NOT NULL,
  `view_date` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `view_product`
--

INSERT INTO `view_product` (`id`, `product_id`, `customer_id`, `view_date`) VALUES
(1, 23, 'CUST0001', '2024-12-20 01:37:26'),
(2, 24, 'CUST0001', '2024-12-20 01:39:41'),
(3, 26, 'CUST0001', '2024-12-20 02:12:35'),
(4, 25, 'CUST0001', '2024-12-20 02:12:44'),
(5, 22, 'CUST0001', '2024-12-20 02:45:51'),
(6, 25, 'CUST0002', '2024-12-20 16:25:38'),
(7, 22, 'CUST0002', '2024-12-20 16:25:51'),
(8, 26, 'CUST0002', '2024-12-20 16:27:14'),
(9, 32, 'CUST0002', '2024-12-21 10:49:58'),
(10, 34, 'CUST0002', '2024-12-21 10:50:23'),
(11, 24, 'CUST0002', '2024-12-21 10:50:29'),
(12, 30, 'CUST0002', '2024-12-21 10:50:49'),
(13, 32, 'CUST0003', '2024-12-21 21:49:34'),
(14, 34, 'CUST0003', '2024-12-21 21:49:49'),
(15, 33, 'CUST0001', '2024-12-21 22:04:19'),
(16, 31, 'CUST0003', '2024-12-22 08:45:55'),
(17, 32, 'CUST0001', '2024-12-22 08:55:45');

-- --------------------------------------------------------

--
-- Table structure for table `view_website`
--

CREATE TABLE `view_website` (
  `id` int(11) NOT NULL,
  `customer_id` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `view_website`
--

INSERT INTO `view_website` (`id`, `customer_id`, `created_at`) VALUES
(1, 'CUST0001', '2024-12-19 19:52:34'),
(2, 'CUST0001', '2024-12-19 19:52:48'),
(3, 'CUST0001', '2024-12-19 21:07:19'),
(4, 'CUST0001', '2024-12-19 21:44:55'),
(5, 'CUST0001', '2024-12-19 21:45:03'),
(6, 'CUST0001', '2024-12-20 04:00:39'),
(7, 'CUST0001', '2024-12-19 20:05:40'),
(8, 'CUST0001', '2024-12-19 22:05:48'),
(9, 'CUST0001', '2024-12-19 22:05:56'),
(10, 'CUST0001', '2024-12-20 02:06:04'),
(11, 'CUST0001', '2024-12-20 03:06:14'),
(12, 'CUST0001', '2024-12-19 23:06:21'),
(13, 'CUST0001', '2024-12-19 23:19:51'),
(14, 'CUST0001', '2024-12-20 00:19:59'),
(15, 'CUST0001', '2024-12-20 01:20:08'),
(16, 'CUST0001', '2024-12-20 01:20:16'),
(17, 'CUST0001', '2024-12-20 04:35:33'),
(18, 'CUST0001', '2024-12-20 04:35:41'),
(19, 'CUST0001', '2024-12-20 04:35:50'),
(20, 'CUST0001', '2024-12-20 05:35:57'),
(21, 'CUST0001', '2024-12-20 04:37:34'),
(22, 'CUST0001', '2024-12-20 06:37:34'),
(23, 'CUST0001', '2024-12-20 06:37:34'),
(24, 'CUST0001', '2024-12-20 06:37:34'),
(25, 'CUST0001', '2024-12-20 06:37:34'),
(26, 'CUST0001', '2024-12-20 07:37:34'),
(27, 'CUST0001', '2024-12-20 07:37:34'),
(28, 'CUST0001', '2024-12-20 08:37:34'),
(29, 'CUST0001', '2024-12-20 08:37:34'),
(30, 'CUST0001', '2024-12-20 08:37:34'),
(31, 'CUST0001', '2024-12-20 09:37:34'),
(32, 'CUST0001', '2024-12-20 10:37:34'),
(33, 'CUST0001', '2024-12-20 10:37:34'),
(34, 'CUST0001', '2024-12-20 11:37:34'),
(35, 'CUST0001', '2024-12-20 11:37:34'),
(36, 'CUST0001', '2024-12-20 12:37:34'),
(37, 'CUST0002', '2024-12-20 09:13:29'),
(38, 'CUST0001', '2024-12-20 10:27:52'),
(39, 'CUST0001', '2024-12-20 10:59:01'),
(40, 'CUST0001', '2024-12-20 14:26:36'),
(41, 'CUST0002', '2024-12-21 03:34:14'),
(42, 'CUST0002', '2024-12-21 03:49:53'),
(43, 'CUST0003', '2024-12-21 14:49:27'),
(44, 'CUST0003', '2024-12-21 14:52:56'),
(45, 'CUST0001', '2024-12-21 15:04:14'),
(46, 'CUST0003', '2024-12-22 01:05:56'),
(47, 'CUST0003', '2024-12-22 01:45:50'),
(48, 'CUST0001', '2024-12-22 01:47:23'),
(49, 'CUST0001', '2024-12-22 07:35:10');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `cart_ibfk_1` (`customer_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `category_name` (`category_name`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customer_id`);

--
-- Indexes for table `customer_profile`
--
ALTER TABLE `customer_profile`
  ADD PRIMARY KEY (`cp_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employee_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `fk_customer_id` (`customer_id`),
  ADD KEY `fk_admin_id` (`admin_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `order_payments`
--
ALTER TABLE `order_payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `owner`
--
ALTER TABLE `owner`
  ADD PRIMARY KEY (`owner_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `provinsi`
--
ALTER TABLE `provinsi`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recently_added`
--
ALTER TABLE `recently_added`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_recently_product_id` (`product_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `view_product`
--
ALTER TABLE `view_product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `view_website`
--
ALTER TABLE `view_website`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `customer_profile`
--
ALTER TABLE `customer_profile`
  MODIFY `cp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `order_payments`
--
ALTER TABLE `order_payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `provinsi`
--
ALTER TABLE `provinsi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `recently_added`
--
ALTER TABLE `recently_added`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=169;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `view_product`
--
ALTER TABLE `view_product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `view_website`
--
ALTER TABLE `view_website`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `customer_profile`
--
ALTER TABLE `customer_profile`
  ADD CONSTRAINT `customer_profile_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_admin_id` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `order_payments`
--
ALTER TABLE `order_payments`
  ADD CONSTRAINT `fk_order_proof_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_category_id` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Constraints for table `recently_added`
--
ALTER TABLE `recently_added`
  ADD CONSTRAINT `fk_recently_product_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `view_product`
--
ALTER TABLE `view_product`
  ADD CONSTRAINT `view_product_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `view_product_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

--
-- Constraints for table `view_website`
--
ALTER TABLE `view_website`
  ADD CONSTRAINT `view_website_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
