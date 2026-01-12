/* =========================================================
   MOBILE WAREHOUSE - MERGED SINGLE SQL (MySQL 8.0)
   Merge of:
   - RBAC (roles/permissions/user_roles) + auth tables (forgot/change pass)
   - mobile_warehouse.sql (warehouse/products/vouchers/unit tracking)
   ========================================================= */

-- =========================
-- 0) DATABASE
-- =========================
CREATE DATABASE IF NOT EXISTS mobile_warehouse
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mobile_warehouse;

-- =========================
-- (Optional) DROP FOR RE-RUN
-- =========================
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_role_permissions;
DROP VIEW IF EXISTS v_user_roles;

DROP TABLE IF EXISTS stock_count_lines;
DROP TABLE IF EXISTS stock_counts;

DROP TABLE IF EXISTS stock_unit_movements;
DROP TABLE IF EXISTS stock_voucher_lines;
DROP TABLE IF EXISTS stock_vouchers;

DROP TABLE IF EXISTS inventory_balance;
DROP TABLE IF EXISTS product_units;   -- IMEI units
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS brands;

DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS warehouses;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS password_history;

DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- 1) ROLES / PERMISSIONS (RBAC)
-- =========================
CREATE TABLE roles (
  role_id        INT AUTO_INCREMENT PRIMARY KEY,
  role_code      VARCHAR(30) NOT NULL UNIQUE,   -- ADMIN, MANAGER, STAFF, SALER
  role_name      VARCHAR(80) NOT NULL,
  description    VARCHAR(255),
  is_active      TINYINT NOT NULL DEFAULT 1,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE (role_name)
) ENGINE=InnoDB;

CREATE TABLE permissions (
  permission_id  INT AUTO_INCREMENT PRIMARY KEY,
  perm_code      VARCHAR(80) NOT NULL UNIQUE,   -- USER_VIEW, ROLE_PERMISSION_EDIT...
  perm_name      VARCHAR(120) NOT NULL,
  description    VARCHAR(255),
  module         VARCHAR(40) NOT NULL DEFAULT 'SYSTEM', -- SYSTEM/ADMIN/INVENTORY/REPORT...
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
  role_id        INT NOT NULL,
  permission_id  INT NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
  CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permissions(permission_id)
) ENGINE=InnoDB;

-- =========================
-- 2) USERS + USER_ROLES (1 user có thể có nhiều role)
-- =========================
CREATE TABLE users (
  user_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  username       VARCHAR(50) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,
  full_name      VARCHAR(120) NOT NULL,
  email          VARCHAR(120) UNIQUE,
  phone          VARCHAR(30),
  status         TINYINT NOT NULL DEFAULT 1, -- 1 active, 0 inactive (Task 10)
  last_login_at  DATETIME NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE user_roles (
  user_id   BIGINT NOT NULL,
  role_id   INT NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
) ENGINE=InnoDB;

-- Optional: password history (để cấm dùng lại mật khẩu cũ)
CREATE TABLE password_history (
  history_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id        BIGINT NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  changed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ph_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  INDEX idx_ph_user_time (user_id, changed_at)
) ENGINE=InnoDB;

-- Forgot password tokens (Task 4)
CREATE TABLE password_reset_tokens (
  token_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      BIGINT NOT NULL,
  token_hash   VARCHAR(255) NOT NULL,   -- lưu hash token
  expires_at   DATETIME NOT NULL,
  used_at      DATETIME NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prt_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  INDEX idx_prt_user (user_id),
  INDEX idx_prt_exp (expires_at)
) ENGINE=InnoDB;

-- Audit logs (merge bản cũ + bản mới)
CREATE TABLE audit_logs (
  log_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT NULL,
  action      VARCHAR(60) NOT NULL,
  entity      VARCHAR(60) NULL,
  entity_id   VARCHAR(60) NULL,
  detail      VARCHAR(500) NULL, -- text detail (compatible with old)
  details     JSON NULL,         -- richer detail (new)
  ip_address  VARCHAR(45) NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_al_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  INDEX idx_al_user_time (user_id, created_at)
) ENGINE=InnoDB;

-- =========================
-- 3) WAREHOUSE / LOCATION (1 kho duy nhất nhưng mở rộng được)
-- =========================
CREATE TABLE warehouses (
  warehouse_id   INT AUTO_INCREMENT PRIMARY KEY,
  warehouse_code VARCHAR(30) NOT NULL UNIQUE,
  warehouse_name VARCHAR(120) NOT NULL,
  address        VARCHAR(255),
  is_active      TINYINT NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE locations (
  location_id    INT AUTO_INCREMENT PRIMARY KEY,
  warehouse_id   INT NOT NULL,
  location_code  VARCHAR(30) NOT NULL,
  location_name  VARCHAR(120) NOT NULL,
  is_active      TINYINT NOT NULL DEFAULT 1,
  UNIQUE (warehouse_id, location_code),
  CONSTRAINT fk_loc_wh FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB;

-- =========================
-- 4) MASTER DATA: BRANDS / SUPPLIERS / PRODUCTS
-- =========================
CREATE TABLE brands (
  brand_id    INT AUTO_INCREMENT PRIMARY KEY,
  brand_name  VARCHAR(120) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE suppliers (
  supplier_id   INT AUTO_INCREMENT PRIMARY KEY,
  supplier_name VARCHAR(120) NOT NULL UNIQUE,
  phone         VARCHAR(30),
  email         VARCHAR(120),
  address       VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE products (
  product_id       INT AUTO_INCREMENT PRIMARY KEY,
  sku              VARCHAR(50) NOT NULL UNIQUE,
  product_name     VARCHAR(160) NOT NULL,
  brand_id         INT,
  model            VARCHAR(80),
  color            VARCHAR(50),
  storage_gb       INT,
  ram_gb           INT,
  warranty_months  INT DEFAULT 12,
  is_active        TINYINT NOT NULL DEFAULT 1,
  created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_p_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
) ENGINE=InnoDB;

-- Tồn kho tổng theo sản phẩm (nhanh cho SALER xem số lượng)
CREATE TABLE inventory_balance (
  balance_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
  warehouse_id  INT NOT NULL,
  product_id    INT NOT NULL,
  qty           INT NOT NULL DEFAULT 0,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE (warehouse_id, product_id),
  CONSTRAINT fk_ib_wh FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
  CONSTRAINT fk_ib_p  FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- Theo dõi từng máy theo IMEI (phù hợp nghiệp vụ mobile)
CREATE TABLE product_units (
  unit_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id     INT NOT NULL,
  imei           VARCHAR(30) NOT NULL UNIQUE,
  serial_no      VARCHAR(50),
  unit_status    VARCHAR(30) NOT NULL DEFAULT 'IN_STOCK',
  -- IN_STOCK, RESERVED, SOLD, DEFECTIVE, WARRANTY, LOST
  warehouse_id   INT,
  location_id    INT,
  last_moved_at  DATETIME,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_u_p   FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_u_wh  FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
  CONSTRAINT fk_u_loc FOREIGN KEY (location_id) REFERENCES locations(location_id),
  INDEX idx_unit_prod_status (product_id, unit_status)
) ENGINE=InnoDB;

-- =========================
-- 5) STOCK VOUCHERS + LINES + UNIT MOVEMENTS
-- =========================
CREATE TABLE stock_vouchers (
  voucher_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_type      VARCHAR(20) NOT NULL,
  -- GRN (Goods Receipt), GIN (Goods Issue), TRF (Transfer), ADJ (Adjustment), CNT (Stock Count)
  voucher_code      VARCHAR(40) NOT NULL UNIQUE,
  created_by        BIGINT NOT NULL,
  created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status            VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  -- DRAFT, SUBMITTED, APPROVED, REJECTED, COMPLETED, CANCELLED
  from_warehouse_id  INT,
  to_warehouse_id    INT,
  note              VARCHAR(255),
  approved_by       BIGINT,
  approved_at       DATETIME,
  CONSTRAINT fk_sv_created  FOREIGN KEY (created_by) REFERENCES users(user_id),
  CONSTRAINT fk_sv_approved FOREIGN KEY (approved_by) REFERENCES users(user_id),
  CONSTRAINT fk_sv_from_wh  FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id),
  CONSTRAINT fk_sv_to_wh    FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(warehouse_id),
  INDEX idx_sv_type_time (voucher_type, created_at),
  INDEX idx_sv_status (status)
) ENGINE=InnoDB;

CREATE TABLE stock_voucher_lines (
  line_id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id        BIGINT NOT NULL,
  product_id        INT NOT NULL,
  qty               INT NOT NULL DEFAULT 1,
  from_location_id  INT,
  to_location_id    INT,
  note              VARCHAR(255),
  CONSTRAINT fk_svl_v   FOREIGN KEY (voucher_id) REFERENCES stock_vouchers(voucher_id),
  CONSTRAINT fk_svl_p   FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_svl_floc FOREIGN KEY (from_location_id) REFERENCES locations(location_id),
  CONSTRAINT fk_svl_tloc FOREIGN KEY (to_location_id) REFERENCES locations(location_id),
  INDEX idx_svl_v (voucher_id)
) ENGINE=InnoDB;

CREATE TABLE stock_unit_movements (
  movement_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id        BIGINT NOT NULL,
  line_id           BIGINT NOT NULL,
  unit_id           BIGINT NOT NULL,
  action            VARCHAR(20) NOT NULL,
  -- IN, OUT, TRANSFER, ADJUST
  from_warehouse_id INT,
  to_warehouse_id   INT,
  from_location_id  INT,
  to_location_id    INT,
  moved_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  moved_by          BIGINT NOT NULL,
  CONSTRAINT fk_sum_v     FOREIGN KEY (voucher_id) REFERENCES stock_vouchers(voucher_id),
  CONSTRAINT fk_sum_line  FOREIGN KEY (line_id) REFERENCES stock_voucher_lines(line_id),
  CONSTRAINT fk_sum_unit  FOREIGN KEY (unit_id) REFERENCES product_units(unit_id),
  CONSTRAINT fk_sum_fwh   FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id),
  CONSTRAINT fk_sum_twh   FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(warehouse_id),
  CONSTRAINT fk_sum_floc  FOREIGN KEY (from_location_id) REFERENCES locations(location_id),
  CONSTRAINT fk_sum_tloc  FOREIGN KEY (to_location_id) REFERENCES locations(location_id),
  CONSTRAINT fk_sum_by    FOREIGN KEY (moved_by) REFERENCES users(user_id),
  INDEX idx_sum_unit_time (unit_id, moved_at)
) ENGINE=InnoDB;

-- =========================
-- 6) STOCK COUNT (kiểm kê) - link voucher CNT
-- =========================
CREATE TABLE stock_counts (
  count_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id    BIGINT NOT NULL UNIQUE, -- link to stock_vouchers where voucher_type='CNT'
  warehouse_id  INT NOT NULL,
  counted_by    BIGINT NOT NULL,
  counted_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status        VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  -- OPEN, CLOSED
  CONSTRAINT fk_sc_v   FOREIGN KEY (voucher_id) REFERENCES stock_vouchers(voucher_id),
  CONSTRAINT fk_sc_wh  FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
  CONSTRAINT fk_sc_by  FOREIGN KEY (counted_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE stock_count_lines (
  count_line_id  BIGINT AUTO_INCREMENT PRIMARY KEY,
  count_id       BIGINT NOT NULL,
  product_id     INT NOT NULL,
  system_qty     INT NOT NULL DEFAULT 0,
  counted_qty    INT NOT NULL DEFAULT 0,
  difference_qty INT NOT NULL DEFAULT 0,
  note           VARCHAR(255),
  CONSTRAINT fk_scl_c  FOREIGN KEY (count_id) REFERENCES stock_counts(count_id),
  CONSTRAINT fk_scl_p  FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_scl_count (count_id)
) ENGINE=InnoDB;

-- =========================
-- 7) SEED DATA (Roles/Perms/Users/Warehouse/Product demo)
-- =========================
INSERT INTO roles(role_code, role_name, description) VALUES
('ADMIN',   'System Admin', 'Manage users/roles/permissions'),
('MANAGER', 'Warehouse Manager', 'View reports, approve/monitor'),
('STAFF',   'Warehouse Staff', 'Handle stock in/out and stock count'),
('SALER',   'Sales', 'View stock and create outbound request');

INSERT INTO permissions(perm_code, perm_name, description, module) VALUES
-- Common (Tasks 1-6)
('PROFILE_VIEW', 'View my profile', 'View own profile', 'SYSTEM'),
('PROFILE_EDIT', 'Edit my profile', 'Edit own profile fields', 'SYSTEM'),
('PASSWORD_CHANGE', 'Change password', 'Change own password', 'SYSTEM'),

-- Admin Users (Tasks 7-11)
('USER_VIEW', 'View user list/info', 'View users', 'ADMIN'),
('USER_CREATE', 'Add new user', 'Create users', 'ADMIN'),
('USER_UPDATE', 'Update user info', 'Edit users', 'ADMIN'),
('USER_ACTIVATE', 'Active/deactive user', 'Enable/disable users', 'ADMIN'),

-- Admin Advanced (Tasks 12-17)
('ROLE_VIEW', 'View roles', 'View role list/details', 'ADMIN'),
('ROLE_UPDATE', 'Update role', 'Edit role info', 'ADMIN'),
('ROLE_ACTIVATE', 'Active/deactive role', 'Enable/disable roles', 'ADMIN'),
('ROLE_PERMISSION_VIEW', 'View role permissions', 'View permissions of role', 'ADMIN'),
('ROLE_PERMISSION_EDIT', 'Edit role permissions', 'Assign/unassign permissions', 'ADMIN'),

-- Inventory/Report (mở rộng)
('INVENTORY_VIEW', 'View inventory', 'View stock on hand', 'INVENTORY'),
('VOUCHER_CREATE_OUT', 'Create outbound request', 'Saler creates outbound voucher', 'INVENTORY'),
('VOUCHER_POST_IN', 'Post inbound voucher', 'Staff posts inbound', 'INVENTORY'),
('VOUCHER_POST_OUT', 'Post outbound voucher', 'Staff posts outbound', 'INVENTORY'),
('STOCKCOUNT_CREATE', 'Create stock count', 'Create stock count', 'INVENTORY'),
('REPORT_WEEKLY_VIEW', 'View weekly report', 'Weekly in/out and discrepancies', 'REPORT');

-- ADMIN gets all permissions
INSERT INTO role_permissions(role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_code='ADMIN';

-- MANAGER permissions
INSERT INTO role_permissions(role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_code='MANAGER'
  AND p.perm_code IN ('INVENTORY_VIEW','REPORT_WEEKLY_VIEW','PROFILE_VIEW','PASSWORD_CHANGE');

-- STAFF permissions
INSERT INTO role_permissions(role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_code='STAFF'
  AND p.perm_code IN ('INVENTORY_VIEW','VOUCHER_POST_IN','VOUCHER_POST_OUT','STOCKCOUNT_CREATE','PROFILE_VIEW','PASSWORD_CHANGE');

-- SALER permissions
INSERT INTO role_permissions(role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_code='SALER'
  AND p.perm_code IN ('INVENTORY_VIEW','VOUCHER_CREATE_OUT','PROFILE_VIEW','PASSWORD_CHANGE');

-- Users demo (password_hash tạm: '123456' - khi làm thật bạn hash trong Java rồi update)
INSERT INTO users(username,password_hash,full_name,email,phone,status) VALUES
('admin01',   '123456', 'Admin User',   'admin@warehouse.com',   '0900000001', 1),
('manager01', '123456', 'Manager User', 'manager@warehouse.com', '0900000002', 1),
('staff01',   '123456', 'Staff User',   'staff@warehouse.com',   '0900000003', 1),
('saler01',   '123456', 'Saler User',   'saler@warehouse.com',   '0900000004', 1);

-- Assign roles
INSERT INTO user_roles(user_id, role_id)
SELECT u.user_id, r.role_id
FROM users u JOIN roles r
WHERE (u.username='admin01'   AND r.role_code='ADMIN')
   OR (u.username='manager01' AND r.role_code='MANAGER')
   OR (u.username='staff01'   AND r.role_code='STAFF')
   OR (u.username='saler01'   AND r.role_code='SALER');

-- Single warehouse + locations
INSERT INTO warehouses(warehouse_code,warehouse_name,address) VALUES
('WH-HN','Main Warehouse - Hanoi','Hanoi');

INSERT INTO locations(warehouse_id, location_code, location_name) VALUES
(1,'A-101','Area A - Shelf 101'),
(1,'A-102','Area A - Shelf 102');

-- Brands / suppliers
INSERT INTO brands(brand_name) VALUES ('Apple'), ('Samsung');
INSERT INTO suppliers(supplier_name, phone, email, address) VALUES
('Mobile Supplier A','0909111222','supplierA@mail.com','Hanoi'),
('Mobile Supplier B','0909222333','supplierB@mail.com','Hanoi');

-- Products demo (mobile)
INSERT INTO products(sku, product_name, brand_id, model, color, storage_gb, ram_gb, warranty_months) VALUES
('IP14-128-BLK','iPhone 14 128GB Black', 1, 'iPhone 14', 'Black', 128, 6, 12),
('SS-S23-256-GRY','Samsung S23 256GB Gray', 2, 'Galaxy S23', 'Gray', 256, 8, 12);

-- Init inventory
INSERT INTO inventory_balance(warehouse_id, product_id, qty) VALUES
(1,1,0),
(1,2,0);

-- IMEI units demo
INSERT INTO product_units(product_id, imei, serial_no, unit_status, warehouse_id, location_id) VALUES
(1,'111111111111111','SN-IP14-001','IN_STOCK',1,1),
(1,'111111111111112','SN-IP14-002','IN_STOCK',1,1),
(2,'222222222222221','SN-S23-001','IN_STOCK',1,2);

-- Example: 1 phiếu nhập (GRN) đã COMPLETED (demo)
INSERT INTO stock_vouchers(voucher_type, voucher_code, created_by, status, from_warehouse_id, to_warehouse_id, note, approved_by, approved_at)
VALUES
('GRN','GRN-20260112-0001',
 (SELECT user_id FROM users WHERE username='staff01'),
 'COMPLETED',
 NULL, 1,
 'Goods receipt demo',
 (SELECT user_id FROM users WHERE username='manager01'),
 NOW()
);

-- Lines
INSERT INTO stock_voucher_lines(voucher_id, product_id, qty, from_location_id, to_location_id, note)
VALUES
((SELECT voucher_id FROM stock_vouchers WHERE voucher_code='GRN-20260112-0001'), 1, 2, NULL, 1, 'iPhone 14 units'),
((SELECT voucher_id FROM stock_vouchers WHERE voucher_code='GRN-20260112-0001'), 2, 1, NULL, 2, 'Samsung S23 unit');

-- Unit movements link to lines (demo)
SET @v_grn := (SELECT voucher_id FROM stock_vouchers WHERE voucher_code='GRN-20260112-0001');
SET @staff_id := (SELECT user_id FROM users WHERE username='staff01');

SET @line_ip14 := (
  SELECT line_id FROM stock_voucher_lines
  WHERE voucher_id=@v_grn AND product_id=1
  ORDER BY line_id LIMIT 1
);

SET @line_s23 := (
  SELECT line_id FROM stock_voucher_lines
  WHERE voucher_id=@v_grn AND product_id=2
  ORDER BY line_id LIMIT 1
);

SET @u1 := (SELECT unit_id FROM product_units WHERE imei='111111111111111');
SET @u2 := (SELECT unit_id FROM product_units WHERE imei='111111111111112');
SET @u3 := (SELECT unit_id FROM product_units WHERE imei='222222222222221');

INSERT INTO stock_unit_movements
(voucher_id, line_id, unit_id, action, to_warehouse_id, to_location_id, moved_by)
VALUES
(@v_grn, @line_ip14, @u1, 'IN', 1, 1, @staff_id),
(@v_grn, @line_ip14, @u2, 'IN', 1, 1, @staff_id),
(@v_grn, @line_s23,  @u3, 'IN', 1, 2, @staff_id);

-- Update inventory_balance demo (+2 iPhone14, +1 S23)
UPDATE inventory_balance SET qty = qty + 2 WHERE warehouse_id=1 AND product_id=1;
UPDATE inventory_balance SET qty = qty + 1 WHERE warehouse_id=1 AND product_id=2;

-- =========================
-- 8) VIEWS (dùng cho Task 7-17 cực tiện)
-- =========================
CREATE VIEW v_user_roles AS
SELECT
  u.user_id, u.username, u.full_name, u.email, u.phone, u.status,
  r.role_id, r.role_code, r.role_name, r.is_active AS role_active
FROM users u
JOIN user_roles ur ON ur.user_id = u.user_id
JOIN roles r ON r.role_id = ur.role_id;

CREATE VIEW v_role_permissions AS
SELECT
  r.role_id, r.role_code, r.role_name,
  p.permission_id, p.perm_code, p.perm_name, p.module
FROM roles r
JOIN role_permissions rp ON rp.role_id = r.role_id
JOIN permissions p ON p.permission_id = rp.permission_id;

-- =========================
-- DONE
-- =========================
SELECT 'mobile_warehouse merged DB created successfully' AS status;
