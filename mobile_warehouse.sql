-- =========================
-- 1) CREATE DATABASE
-- =========================
CREATE DATABASE IF NOT EXISTS mobile_warehouse
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mobile_warehouse;

-- =========================
-- 2) USERS & ROLES
-- =========================
CREATE TABLE roles (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(20) NOT NULL UNIQUE  -- ADMIN, STAFF, MANAGER
);

INSERT INTO roles(role_name) VALUES ('ADMIN'), ('STAFF'), ('MANAGER');

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120),
  phone VARCHAR(30),
  role_id INT NOT NULL,
  status TINYINT NOT NULL DEFAULT 1, -- 1 active, 0 inactive
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- =========================
-- 3) WAREHOUSE STRUCTURE
-- =========================
CREATE TABLE warehouses (
  warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
  warehouse_code VARCHAR(30) NOT NULL UNIQUE,
  warehouse_name VARCHAR(120) NOT NULL,
  address VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locations (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  warehouse_id INT NOT NULL,
  location_code VARCHAR(50) NOT NULL,   -- e.g., A1-01, RACK-02
  location_name VARCHAR(120),
  is_active TINYINT NOT NULL DEFAULT 1,
  UNIQUE (warehouse_id, location_code),
  FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

-- =========================
-- 4) MASTER DATA (BRANDS, SUPPLIERS, PRODUCTS)
-- =========================
CREATE TABLE brands (
  brand_id INT AUTO_INCREMENT PRIMARY KEY,
  brand_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(120) NOT NULL,
  phone VARCHAR(30),
  email VARCHAR(120),
  address VARCHAR(255),
  UNIQUE (supplier_name)
);

CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50) NOT NULL UNIQUE,
  product_name VARCHAR(160) NOT NULL,
  brand_id INT,
  model VARCHAR(80),
  color VARCHAR(50),
  storage_gb INT,
  ram_gb INT,
  warranty_months INT DEFAULT 12,
  is_active TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
);

-- Each physical phone tracked by IMEI/Serial
CREATE TABLE product_units (
  unit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  imei VARCHAR(30) NOT NULL UNIQUE,
  serial_no VARCHAR(50),
  unit_status VARCHAR(30) NOT NULL DEFAULT 'IN_STOCK', 
  -- IN_STOCK, RESERVED, SOLD, DEFECTIVE, WARRANTY, LOST
  warehouse_id INT,
  location_id INT,
  last_moved_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
  FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- =========================
-- 5) INVENTORY SUMMARY (optional but useful)
-- =========================
CREATE TABLE inventory_balance (
  balance_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  warehouse_id INT NOT NULL,
  product_id INT NOT NULL,
  qty INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE (warehouse_id, product_id),
  FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =========================
-- 6) STOCK TRANSACTIONS (RECEIPT / ISSUE / TRANSFER)
-- =========================
CREATE TABLE stock_vouchers (
  voucher_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_type VARCHAR(20) NOT NULL,
  -- GRN (Goods Receipt), GIN (Goods Issue), TRF (Transfer), ADJ (Adjustment), CNT (Stock Count)
  voucher_code VARCHAR(40) NOT NULL UNIQUE,
  created_by INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  -- DRAFT, SUBMITTED, APPROVED, REJECTED, COMPLETED, CANCELLED
  from_warehouse_id INT,
  to_warehouse_id INT,
  note VARCHAR(255),
  approved_by INT,
  approved_at DATETIME,
  FOREIGN KEY (created_by) REFERENCES users(user_id),
  FOREIGN KEY (approved_by) REFERENCES users(user_id),
  FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id),
  FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE stock_voucher_lines (
  line_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  qty INT NOT NULL DEFAULT 1,
  from_location_id INT,
  to_location_id INT,
  note VARCHAR(255),
  FOREIGN KEY (voucher_id) REFERENCES stock_vouchers(voucher_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (from_location_id) REFERENCES locations(location_id),
  FOREIGN KEY (to_location_id) REFERENCES locations(location_id)
);

-- Link units (IMEI) to voucher line (for phone-by-phone tracking)
CREATE TABLE stock_unit_movements (
  movement_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id BIGINT NOT NULL,
  line_id BIGINT NOT NULL,
  unit_id BIGINT NOT NULL,
  action VARCHAR(20) NOT NULL,
  -- IN, OUT, TRANSFER, ADJUST
  from_warehouse_id INT,
  to_warehouse_id INT,
  from_location_id INT,
  to_location_id INT,
  moved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  moved_by INT NOT NULL,
  FOREIGN KEY (voucher_id) REFERENCES stock_vouchers(voucher_id),
  FOREIGN KEY (line_id) REFERENCES stock_voucher_lines(line_id),
  FOREIGN KEY (unit_id) REFERENCES product_units(unit_id),
  FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id),
  FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(warehouse_id),
  FOREIGN KEY (from_location_id) REFERENCES locations(location_id),
  FOREIGN KEY (to_location_id) REFERENCES locations(location_id),
  FOREIGN KEY (moved_by) REFERENCES users(user_id)
);

-- =========================
-- 7) STOCK COUNT (INVENTORY AUDIT)
-- =========================
CREATE TABLE stock_counts (
  count_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id BIGINT NOT NULL UNIQUE, -- link to stock_vouchers where voucher_type='CNT'
  warehouse_id INT NOT NULL,
  counted_by INT NOT NULL,
  counted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  -- OPEN, CLOSED
  FOREIGN KEY (voucher_id) REFERENCES stock_vouchers(voucher_id),
  FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
  FOREIGN KEY (counted_by) REFERENCES users(user_id)
);

CREATE TABLE stock_count_lines (
  count_line_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  count_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  system_qty INT NOT NULL DEFAULT 0,
  counted_qty INT NOT NULL DEFAULT 0,
  difference_qty INT NOT NULL DEFAULT 0,
  note VARCHAR(255),
  FOREIGN KEY (count_id) REFERENCES stock_counts(count_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =========================
-- 8) SIMPLE AUDIT LOG
-- =========================
CREATE TABLE audit_logs (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(60) NOT NULL,
  entity VARCHAR(60),
  entity_id VARCHAR(60),
  detail VARCHAR(500),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

DROP TABLE suppliers;

USE mobile_warehouse;

-- =========================
-- 1) ROLES
-- =========================
INSERT INTO roles (role_name)
VALUES ('ADMIN'), ('STAFF'), ('MANAGER')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

-- =========================
-- 2) USERS
-- =========================
INSERT INTO users (username, password_hash, full_name, email, role_id, status)
VALUES
('admin01', '123456', 'Admin User', 'admin@warehouse.com',
 (SELECT role_id FROM roles WHERE role_name='ADMIN'), 1),

('staff01', '123456', 'Staff User', 'staff@warehouse.com',
 (SELECT role_id FROM roles WHERE role_name='STAFF'), 1),

('manager01', '123456', 'Manager User', 'manager@warehouse.com',
 (SELECT role_id FROM roles WHERE role_name='MANAGER'), 1)
ON DUPLICATE KEY UPDATE
full_name = VALUES(full_name),
email     = VALUES(email),
role_id   = VALUES(role_id),
status    = VALUES(status);

-- =========================
-- 3) WAREHOUSE
-- =========================
INSERT INTO warehouses (warehouse_code, warehouse_name, address)
VALUES ('WH-HN', 'Hanoi Main Warehouse', 'Ha Noi')
ON DUPLICATE KEY UPDATE
warehouse_name = VALUES(warehouse_name),
address        = VALUES(address);

-- =========================
-- 4) LOCATIONS
-- =========================
INSERT INTO locations (warehouse_id, location_code, location_name, is_active)
VALUES
((SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 'A1-01', 'Rack A1 - Slot 01', 1),

((SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 'A1-02', 'Rack A1 - Slot 02', 1)
ON DUPLICATE KEY UPDATE
location_name = VALUES(location_name),
is_active     = VALUES(is_active);

-- =========================
-- 5) BRANDS
-- =========================
INSERT INTO brands (brand_name)
VALUES ('Apple'), ('Samsung')
ON DUPLICATE KEY UPDATE brand_name = VALUES(brand_name);

-- =========================
-- 6) PRODUCTS
-- =========================
INSERT INTO products
(sku, product_name, brand_id, model, color, storage_gb, ram_gb)
VALUES
('IP14-B-128', 'iPhone 14',
 (SELECT brand_id FROM brands WHERE brand_name='Apple'),
 'iPhone 14', 'Black', 128, 6),

('SS23-W-256', 'Samsung S23',
 (SELECT brand_id FROM brands WHERE brand_name='Samsung'),
 'Galaxy S23', 'White', 256, 8)
ON DUPLICATE KEY UPDATE
product_name = VALUES(product_name),
brand_id     = VALUES(brand_id),
model        = VALUES(model),
color        = VALUES(color),
storage_gb   = VALUES(storage_gb),
ram_gb       = VALUES(ram_gb);

-- =========================
-- 7) PRODUCT UNITS (IMEI)
-- =========================
INSERT INTO product_units
(product_id, imei, unit_status, warehouse_id, location_id)
VALUES
((SELECT product_id FROM products WHERE sku='IP14-B-128'),
 '356789012345671', 'IN_STOCK',
 (SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 (SELECT location_id FROM locations WHERE location_code='A1-01')),

((SELECT product_id FROM products WHERE sku='IP14-B-128'),
 '356789012345672', 'IN_STOCK',
 (SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 (SELECT location_id FROM locations WHERE location_code='A1-01')),

((SELECT product_id FROM products WHERE sku='SS23-W-256'),
 '866543210987651', 'IN_STOCK',
 (SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 (SELECT location_id FROM locations WHERE location_code='A1-02'))
ON DUPLICATE KEY UPDATE
unit_status = VALUES(unit_status),
warehouse_id = VALUES(warehouse_id),
location_id  = VALUES(location_id);

-- =========================
-- 8) INVENTORY BALANCE
-- =========================
INSERT INTO inventory_balance (warehouse_id, product_id, qty)
VALUES
((SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 (SELECT product_id FROM products WHERE sku='IP14-B-128'), 2),

((SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 (SELECT product_id FROM products WHERE sku='SS23-W-256'), 1)
ON DUPLICATE KEY UPDATE
qty = VALUES(qty);

-- =========================
-- 9) STOCK VOUCHER
-- =========================
INSERT INTO stock_vouchers
(voucher_type, voucher_code, created_by, status, to_warehouse_id, note)
VALUES
('GRN', 'GRN-0001',
 (SELECT user_id FROM users WHERE username='staff01'),
 'SUBMITTED',
 (SELECT warehouse_id FROM warehouses WHERE warehouse_code='WH-HN'),
 'Initial stock import')
ON DUPLICATE KEY UPDATE
status = VALUES(status),
note   = VALUES(note);

-- =========================
-- 10) STOCK VOUCHER LINES
-- =========================
INSERT INTO stock_voucher_lines
(voucher_id, product_id, qty, to_location_id)
VALUES
((SELECT voucher_id FROM stock_vouchers WHERE voucher_code='GRN-0001'),
 (SELECT product_id FROM products WHERE sku='IP14-B-128'), 2,
 (SELECT location_id FROM locations WHERE location_code='A1-01')),

((SELECT voucher_id FROM stock_vouchers WHERE voucher_code='GRN-0001'),
 (SELECT product_id FROM products WHERE sku='SS23-W-256'), 1,
 (SELECT location_id FROM locations WHERE location_code='A1-02'))
ON DUPLICATE KEY UPDATE
qty = VALUES(qty);

-- =========================
-- 11) STOCK UNIT MOVEMENTS
-- =========================
INSERT INTO stock_unit_movements
(voucher_id, line_id, unit_id, action, to_warehouse_id, to_location_id, moved_by)
SELECT
 v.voucher_id,
 l.line_id,
 u.unit_id,
 'IN',
 w.warehouse_id,
 loc.location_id,
 usr.user_id
FROM stock_vouchers v
JOIN stock_voucher_lines l ON v.voucher_id = l.voucher_id
JOIN products p ON l.product_id = p.product_id
JOIN product_units u ON u.product_id = p.product_id
JOIN warehouses w ON w.warehouse_code='WH-HN'
JOIN locations loc ON loc.location_code IN ('A1-01','A1-02')
JOIN users usr ON usr.username='staff01'
WHERE v.voucher_code='GRN-0001'
ON DUPLICATE KEY UPDATE
action = VALUES(action);



