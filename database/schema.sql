CREATE DATABASE IF NOT EXISTS lpgchain;
USE lpgchain;

-- USERS TABLE
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(50) UNIQUE,
  password VARCHAR(100),
  role ENUM('admin', 'distributor', 'customer') NOT NULL
);

-- DISTRIBUTORS TABLE
CREATE TABLE distributors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50),
  area VARCHAR(50),
  contact VARCHAR(15)
);

-- STOCK TABLE
CREATE TABLE stock (
  id INT AUTO_INCREMENT PRIMARY KEY,
  distributor_id INT,
  total_allocated INT,
  delivered INT DEFAULT 0,
  remaining INT,
  FOREIGN KEY (distributor_id) REFERENCES distributors(id)
);

-- BOOKINGS TABLE
CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  distributor_id INT,
  booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Pending', 'Delivered') DEFAULT 'Pending',
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (distributor_id) REFERENCES distributors(id)
);

-- TRANSACTIONS TABLE (Blockchain Simulation)
CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  action VARCHAR(100),
  quantity INT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COMPLAINTS TABLE
CREATE TABLE complaints (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  distributor_id INT,
  complaint_text TEXT,
  status ENUM('Open', 'Resolved') DEFAULT 'Open',
  FOREIGN KEY (customer_id) REFERENCES users(id),
  FOREIGN KEY (distributor_id) REFERENCES distributors(id)
);