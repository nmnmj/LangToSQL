CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(15),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  category_name VARCHAR(100) NOT NULL,
  description TEXT
);
CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100) NOT NULL,
  category_id INT,
  price DECIMAL(10,2),
  stock INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Pending', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
  total_amount DECIMAL(10,2),
  shipping_address_id INT,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id)
);
CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments (
  payment_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT,
  payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Wallet', 'Cash'),
  amount DECIMAL(10,2),
  payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
  payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE reviews (
  review_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  product_id INT,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE addresses (
  address_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  line1 VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100),
  postal_code VARCHAR(20),
  address_type ENUM('Home', 'Office', 'Other') DEFAULT 'Home',
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users (first_name, last_name, email, phone, created_at) VALUES
('Amit', 'Sharma', 'amit.sharma@example.com', '9876543210', '2024-12-15 10:00:00'),
('Neha', 'Patel', 'neha.patel@example.com', '9876543211', '2024-12-16 11:00:00'),
('Ravi', 'Kumar', 'ravi.kumar@example.com', '9876543212', '2024-12-17 12:00:00'),
('Sneha', 'Verma', 'sneha.verma@example.com', '9876543213', '2025-01-05 09:30:00'),
('Karan', 'Mehta', 'karan.mehta@example.com', '9876543214', '2025-01-08 08:45:00');

INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Devices and gadgets'),
('Clothing', 'Men and women apparels'),
('Home Appliances', 'Kitchen and home utilities'),
('Books', 'Educational and fictional books'),
('Sports', 'Fitness and sports equipment');

INSERT INTO products (product_name, category_id, price, stock, created_at) VALUES
('iPhone 14', 1, 79999.00, 25, '2024-12-01 10:00:00'),
('Samsung Galaxy S23', 1, 74999.00, 20, '2024-12-02 11:00:00'),
('Men Cotton Shirt', 2, 1499.00, 50, '2024-12-05 10:30:00'),
('Air Fryer', 3, 6999.00, 15, '2024-12-07 14:00:00'),
('Yoga Mat', 5, 899.00, 40, '2024-12-08 09:00:00'),
('Cooking Made Easy', 4, 499.00, 100, '2024-12-09 12:00:00'),
('Nike Running Shoes', 5, 4999.00, 30, '2024-12-10 15:00:00'),
('LG Refrigerator', 3, 45999.00, 10, '2024-12-11 10:45:00'),
('Women Kurti', 2, 1299.00, 60, '2024-12-12 16:00:00'),
('Bluetooth Headphones', 1, 2999.00, 35, '2024-12-13 13:00:00');

INSERT INTO addresses (user_id, line1, city, state, country, postal_code, address_type) VALUES
(1, '123 MG Road', 'Bangalore', 'Karnataka', 'India', '560001', 'Home'),
(1, 'Tech Park, Whitefield', 'Bangalore', 'Karnataka', 'India', '560066', 'Office'),
(2, '45 Nehru Nagar', 'Mumbai', 'Maharashtra', 'India', '400001', 'Home'),
(3, '12 Civil Lines', 'Delhi', 'Delhi', 'India', '110001', 'Home'),
(4, '9A Park Street', 'Kolkata', 'West Bengal', 'India', '700016', 'Home'),
(5, '8 Sector 22', 'Chandigarh', 'Chandigarh', 'India', '160022', 'Home');

INSERT INTO orders (user_id, order_date, status, total_amount, shipping_address_id) VALUES
(1, '2025-01-05 11:00:00', 'Delivered', 82998.00, 1),
(2, '2025-01-08 15:30:00', 'Delivered', 74999.00, 3),
(3, '2025-02-02 10:45:00', 'Shipped', 6498.00, 4),
(4, '2025-02-10 18:00:00', 'Pending', 5898.00, 5),
(5, '2025-03-01 14:00:00', 'Cancelled', 1299.00, 6),
(1, '2025-03-10 12:00:00', 'Delivered', 5498.00, 2);

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 79999.00),
(1, 10, 1, 2999.00),
(2, 2, 1, 74999.00),
(3, 4, 1, 6999.00),
(3, 5, 1, 899.00),
(4, 3, 2, 1499.00),
(4, 9, 2, 1299.00),
(5, 9, 1, 1299.00),
(6, 7, 1, 4999.00),
(6, 6, 1, 499.00);

INSERT INTO payments (order_id, payment_method, amount, payment_status, payment_date) VALUES
(1, 'Credit Card', 82998.00, 'Completed', '2025-01-05 11:05:00'),
(2, 'UPI', 74999.00, 'Completed', '2025-01-08 15:35:00'),
(3, 'Wallet', 6498.00, 'Completed', '2025-02-02 10:50:00'),
(4, 'Debit Card', 5898.00, 'Pending', '2025-02-10 18:10:00'),
(5, 'Credit Card', 1299.00, 'Failed', '2025-03-01 14:05:00'),
(6, 'UPI', 5498.00, 'Completed', '2025-03-10 12:05:00');

INSERT INTO reviews (user_id, product_id, rating, comment, created_at) VALUES
(1, 1, 5, 'Excellent phone, super fast!', '2025-01-10 10:00:00'),
(2, 2, 4, 'Camera is amazing, battery could be better.', '2025-01-12 11:30:00'),
(3, 4, 5, 'Very useful in kitchen.', '2025-02-05 09:00:00'),
(4, 9, 3, 'Average quality material.', '2025-02-15 10:30:00'),
(5, 7, 4, 'Comfortable and light shoes.', '2025-03-05 08:45:00'),
(1, 10, 5, 'Sound quality is crystal clear.', '2025-03-12 09:00:00');