-- ============================================================
--  LPGChain — Database Schema
--  Pune, Maharashtra | Blockchain-Grade LPG Supply Chain
-- ============================================================

CREATE DATABASE IF NOT EXISTS lpgchain;
USE lpgchain;

-- ============================================================
-- 1. COMPANIES (IOCL / HPCL / BPCL)
-- ============================================================
CREATE TABLE companies (
  company_id          VARCHAR(10)  PRIMARY KEY,          -- e.g. COMP001
  company_name        VARCHAR(100) NOT NULL,
  brand               VARCHAR(50),                       -- IndaneGas / HP Gas / Bharat Gas
  warehouse_location  VARCHAR(200),
  total_cylinder_stock       INT DEFAULT 0,
  authorized_distributors_count INT DEFAULT 0,
  contact_email       VARCHAR(100),
  contact_phone       VARCHAR(20)
);

-- ============================================================
-- 2. DISTRIBUTORS
-- ============================================================
CREATE TABLE distributors (
  distributor_id      VARCHAR(10)  PRIMARY KEY,          -- e.g. DIST001
  company_id          VARCHAR(10),
  name                VARCHAR(100) NOT NULL,
  agency_name         VARCHAR(100),
  license_number      VARCHAR(50)  UNIQUE,
  contact_phone       VARCHAR(15),
  address             VARCHAR(255),
  area_covered        VARCHAR(50),
  pincode             VARCHAR(10),
  total_cylinders_received   INT DEFAULT 0,
  current_stock              INT DEFAULT 0,
  cylinders_delivered        INT DEFAULT 0,
  pending_deliveries         INT DEFAULT 0,
  total_customers            INT DEFAULT 0,
  active_customers           INT DEFAULT 0,
  monthly_demand_estimate    INT DEFAULT 0,
  FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

-- ============================================================
-- 3. AREAS / REGIONS
-- ============================================================
CREATE TABLE areas (
  area_id             VARCHAR(10)  PRIMARY KEY,          -- e.g. AREA001
  area_name           VARCHAR(50)  NOT NULL,
  assigned_distributor_id    VARCHAR(10),
  city                VARCHAR(50)  DEFAULT 'Pune',
  district            VARCHAR(50)  DEFAULT 'Pune',
  state               VARCHAR(50)  DEFAULT 'Maharashtra',
  population          INT DEFAULT 0,
  estimated_lpg_households          INT DEFAULT 0,
  estimated_monthly_demand_cylinders INT DEFAULT 0,
  FOREIGN KEY (assigned_distributor_id) REFERENCES distributors(distributor_id)
);

-- ============================================================
-- 4. USERS  (Admin / Distributor / Customer login)
-- ============================================================
CREATE TABLE users (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  name                VARCHAR(100) NOT NULL,
  email               VARCHAR(100) UNIQUE NOT NULL,
  password            VARCHAR(255) NOT NULL,             -- store hashed
  role                ENUM('admin','distributor','customer') NOT NULL,
  linked_entity_id    VARCHAR(20),                       -- distributor_id or customer_id
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 5. CUSTOMERS
-- ============================================================
CREATE TABLE customers (
  customer_id         VARCHAR(10)  PRIMARY KEY,          -- e.g. CUST00001
  name                VARCHAR(100) NOT NULL,
  mobile_number       VARCHAR(15),
  address             VARCHAR(255),
  area_id             VARCHAR(10),
  area_name           VARCHAR(50),
  linked_distributor_id VARCHAR(10),
  connection_number   VARCHAR(20)  UNIQUE,
  cylinder_type       VARCHAR(30),                       -- 14.2kg Domestic / 5kg FTL etc.
  subsidy_status      ENUM('Active','Surrendered','Not Eligible') DEFAULT 'Active',
  last_delivery_date  DATE,
  avg_cylinders_per_month    DECIMAL(4,1) DEFAULT 1.0,
  booking_frequency_days     INT DEFAULT 30,
  FOREIGN KEY (area_id)               REFERENCES areas(area_id),
  FOREIGN KEY (linked_distributor_id) REFERENCES distributors(distributor_id)
);

-- ============================================================
-- 6. CYLINDER INVENTORY
-- ============================================================
CREATE TABLE cylinders (
  cylinder_id         VARCHAR(12)  PRIMARY KEY,          -- e.g. CYL000001
  batch_id            VARCHAR(12),
  type                VARCHAR(30),                       -- 14.2kg Domestic / 19kg Commercial
  category            ENUM('Domestic','Commercial') DEFAULT 'Domestic',
  status              ENUM('Full','Empty','In Transit') DEFAULT 'Full',
  current_holder_id   VARCHAR(10),                       -- company_id / distributor_id / customer_id
  manufacture_year    YEAR,
  last_inspection_date DATE
);

-- ============================================================
-- 7. TRANSACTIONS  (Blockchain Ledger — CORE)
-- ============================================================
CREATE TABLE transactions (
  transaction_id      VARCHAR(10)  PRIMARY KEY,          -- e.g. TX000001
  timestamp           DATETIME     NOT NULL,
  from_entity_id      VARCHAR(10)  NOT NULL,
  to_entity_id        VARCHAR(10)  NOT NULL,
  cylinder_count      INT          NOT NULL,
  transaction_type    ENUM('Dispatch','Receive','Delivery','Return') NOT NULL,
  previous_hash       VARCHAR(64)  NOT NULL,             -- SHA-256 of previous block
  current_hash        VARCHAR(64)  NOT NULL,             -- SHA-256 of this block
  block_index         INT          NOT NULL               -- position in chain
);

-- ============================================================
-- 8. BOOKINGS  (Customer requests a cylinder)
-- ============================================================
CREATE TABLE bookings (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  customer_id         VARCHAR(10),
  distributor_id      VARCHAR(10),
  cylinder_type       VARCHAR(30),
  booking_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status              ENUM('Pending','Confirmed','Delivered','Cancelled') DEFAULT 'Pending',
  FOREIGN KEY (customer_id)    REFERENCES customers(customer_id),
  FOREIGN KEY (distributor_id) REFERENCES distributors(distributor_id)
);

-- ============================================================
-- 9. DELIVERIES
-- ============================================================
CREATE TABLE deliveries (
  delivery_id         VARCHAR(10)  PRIMARY KEY,          -- e.g. DEL00001
  customer_id         VARCHAR(10),
  distributor_id      VARCHAR(10),
  delivery_agent_id   VARCHAR(8),
  cylinder_count      INT DEFAULT 1,
  delivery_date       DATE,
  delivery_status     ENUM('Delivered','Failed','Pending') DEFAULT 'Pending',
  otp_verified        ENUM('Yes','No') DEFAULT 'No',
  otp_code            VARCHAR(6),
  cylinder_type       VARCHAR(30),
  FOREIGN KEY (customer_id)    REFERENCES customers(customer_id),
  FOREIGN KEY (distributor_id) REFERENCES distributors(distributor_id)
);

-- ============================================================
-- 10. DELIVERY AGENTS
-- ============================================================
CREATE TABLE delivery_agents (
  agent_id            VARCHAR(8)   PRIMARY KEY,          -- e.g. AGT001
  name                VARCHAR(100) NOT NULL,
  phone_number        VARCHAR(15),
  assigned_distributor_id VARCHAR(10),
  vehicle_number      VARCHAR(15),
  deliveries_completed INT DEFAULT 0,
  deliveries_failed   INT DEFAULT 0,
  joining_date        DATE,
  status              ENUM('Active','On Leave') DEFAULT 'Active',
  FOREIGN KEY (assigned_distributor_id) REFERENCES distributors(distributor_id)
);

-- ============================================================
-- 11. COMPLAINTS  (kept from original schema)
-- ============================================================
CREATE TABLE complaints (
  id                  INT AUTO_INCREMENT PRIMARY KEY,
  customer_id         VARCHAR(10),
  distributor_id      VARCHAR(10),
  complaint_text      TEXT,
  status              ENUM('Open','Resolved') DEFAULT 'Open',
  created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id)    REFERENCES customers(customer_id),
  FOREIGN KEY (distributor_id) REFERENCES distributors(distributor_id)
);

-- ============================================================
-- STOCK VIEW  (replaces original stock table — auto-computed)
-- ============================================================
CREATE OR REPLACE VIEW stock AS
  SELECT
    d.distributor_id,
    d.name                      AS distributor_name,
    d.total_cylinders_received  AS total_allocated,
    d.cylinders_delivered       AS delivered,
    d.current_stock             AS remaining
  FROM distributors d;
