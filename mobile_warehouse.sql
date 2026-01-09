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

-- USERS
INSERT INTO dbo.Users (Username, PasswordHash, FullName, Email, RoleId)
VALUES
('admin01',   '123456', N'Admin User',   'admin@warehouse.com',   1),
('staff01',   '123456', N'Staff User',   'staff@warehouse.com',   2),
('manager01', '123456', N'Manager User', 'manager@warehouse.com', 3);

-- WAREHOUSE
INSERT INTO dbo.Warehouses (WarehouseCode, WarehouseName, Address)
VALUES ('WH-HN', N'Hanoi Main Warehouse', N'Hà Nội');

-- LOCATIONS
INSERT INTO dbo.Locations (WarehouseId, LocationCode, LocationName)
VALUES
(1, 'A1-01', N'Rack A1 - Slot 01'),
(1, 'A1-02', N'Rack A1 - Slot 02');

-- BRANDS
INSERT INTO dbo.Brands (BrandName)
VALUES (N'Apple'), (N'Samsung');

-- PRODUCTS
INSERT INTO dbo.Products
(SKU, ProductName, BrandId, Model, Color, StorageGB, RamGB)
VALUES
('IP14-B-128', N'iPhone 14', 1, 'iPhone 14', 'Black', 128, 6),
('SS23-W-256', N'Samsung S23', 2, 'Galaxy S23', 'White', 256, 8);

INSERT INTO dbo.ProductUnits
(ProductId, IMEI, UnitStatus, WarehouseId, LocationId)
VALUES
(1, '356789012345671', 'IN_STOCK', 1, 1),
(1, '356789012345672', 'IN_STOCK', 1, 1),
(2, '866543210987651', 'IN_STOCK', 1, 2);

INSERT INTO dbo.InventoryBalance (WarehouseId, ProductId, Qty)
VALUES
(1, 1, 2),  -- iPhone 14
(1, 2, 1);  -- Samsung S23

INSERT INTO dbo.StockVouchers
(VoucherType, VoucherCode, CreatedBy, Status, ToWarehouseId, Note)
VALUES
('GRN', 'GRN-0001', 2, 'SUBMITTED', 1, N'Initial stock import');

INSERT INTO dbo.StockVoucherLines
(VoucherId, ProductId, Qty, ToLocationId)
VALUES
(1, 1, 2, 1),  -- iPhone 14 x2
(1, 2, 1, 2);  -- Samsung S23 x1

INSERT INTO dbo.StockUnitMovements
(VoucherId, LineId, UnitId, Action, ToWarehouseId, ToLocationId, MovedBy)
VALUES
(1, 1, 1, 'IN', 1, 1, 2),
(1, 1, 2, 'IN', 1, 1, 2),
(1, 2, 3, 'IN', 1, 2, 2);


