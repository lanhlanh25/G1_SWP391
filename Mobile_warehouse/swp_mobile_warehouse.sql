-- ======================================================
-- SWP MOBILE WAREHOUSE - FULL DATABASE + SAMPLE DATA
-- Supports functions 1 -> 17
-- ======================================================

-- =========================
-- 0) DROP & CREATE DATABASE
-- =========================
DROP DATABASE IF EXISTS swp_mobile_warehouse;

CREATE DATABASE swp_mobile_warehouse
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE swp_mobile_warehouse;

-- =========================
-- 1) ROLES
-- =========================
CREATE TABLE roles (
  role_id     INT AUTO_INCREMENT PRIMARY KEY,
  role_name   VARCHAR(50) NOT NULL UNIQUE,
  description VARCHAR(255),
  is_active   TINYINT NOT NULL DEFAULT 1,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================
-- 2) USERS
-- =========================
CREATE TABLE users (
  user_id       INT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(120) NOT NULL,
  email         VARCHAR(120) UNIQUE,
  phone         VARCHAR(30),
  role_id       INT NOT NULL,
  status        TINYINT NOT NULL DEFAULT 1,
  last_login_at DATETIME,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_status ON users(status);

-- =========================
-- 3) PERMISSIONS
-- =========================
CREATE TABLE permissions (
  permission_id  INT AUTO_INCREMENT PRIMARY KEY,
  code           VARCHAR(80) NOT NULL UNIQUE,
  name           VARCHAR(120) NOT NULL,
  module         VARCHAR(60) NOT NULL,
  description    VARCHAR(255),
  is_active      TINYINT NOT NULL DEFAULT 1,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- 4) ROLE_PERMISSIONS
-- =========================
CREATE TABLE role_permissions (
  role_id       INT NOT NULL,
  permission_id INT NOT NULL,
  granted_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  granted_by    INT NULL,
  PRIMARY KEY (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES roles(role_id),
  FOREIGN KEY (permission_id) REFERENCES permissions(permission_id),
  FOREIGN KEY (granted_by) REFERENCES users(user_id)
);

-- =========================
-- 5) PASSWORD RESETS
-- =========================
CREATE TABLE password_resets (
  reset_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  token_hash   VARCHAR(255) NOT NULL,
  expires_at   DATETIME NOT NULL,
  used_at      DATETIME NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- =========================
-- 6) AUDIT LOGS
-- =========================
CREATE TABLE audit_logs (
  log_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NULL,
  action      VARCHAR(80) NOT NULL,
  entity      VARCHAR(60),
  entity_id   VARCHAR(60),
  detail      VARCHAR(500),
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ======================================================
-- INSERT SAMPLE DATA
-- ======================================================

-- =========================
-- ROLES
-- =========================
INSERT INTO roles (role_name, description) VALUES
('ADMIN',   'System administrator'),
('MANAGER', 'Warehouse manager'),
('STAFF',   'Warehouse staff'),
('SALE',    'Sales staff');

-- =========================
-- USERS
-- =========================
INSERT INTO users
(username, password_hash, full_name, email, phone, role_id, status, last_login_at)
VALUES
('admin01',   '123456', 'Admin User',    'admin@swp.com',   '0900000001',
 (SELECT role_id FROM roles WHERE role_name='ADMIN'),   1, NOW()),
('manager01', '123456', 'Manager User',  'manager@swp.com', '0900000002',
 (SELECT role_id FROM roles WHERE role_name='MANAGER'), 1, NOW()),
('staff01',   '123456', 'Staff User',    'staff@swp.com',   '0900000003',
 (SELECT role_id FROM roles WHERE role_name='STAFF'),   1, NOW()),
('sale01',    '123456', 'Sale User',     'sale@swp.com',    '0900000004',
 (SELECT role_id FROM roles WHERE role_name='SALE'),    1, NULL),
('sale02',    '123456', 'Sale Inactive', 'sale2@swp.com',   '0900000005',
 (SELECT role_id FROM roles WHERE role_name='SALE'),    0, NULL);

-- =========================
-- PERMISSIONS (1–17)
-- =========================
INSERT INTO permissions (code, name, module) VALUES
-- Common
('HOME_VIEW',        'Homepage',               'COMMON'),
('LOGIN',            'Login',                  'COMMON'),
('LOGOUT',           'Logout',                 'COMMON'),
('FORGOT_PASSWORD',  'Forgot password',        'COMMON'),
('PROFILE_VIEW',     'View my profile',        'COMMON'),
('PASSWORD_CHANGE',  'Change password',        'COMMON'),

-- Admin
('USER_VIEW_LIST',   'View user list',         'ADMIN'),
('USER_VIEW_DETAIL', 'View user information',  'ADMIN'),
('USER_CREATE',      'Add new user',           'ADMIN'),
('USER_TOGGLE',      'Active/deactive user',   'ADMIN'),
('USER_UPDATE',      'Update user information','ADMIN'),

-- Admin Advanced
('ROLE_VIEW_LIST',   'View role list',          'ADMIN_ADV'),
('ROLE_VIEW_DETAIL', 'View role details',       'ADMIN_ADV'),
('ROLE_UPDATE',      'Update role information','ADMIN_ADV'),
('ROLE_TOGGLE',      'Active/deactive role',    'ADMIN_ADV'),
('ROLE_PERM_VIEW',   'View role permissions',   'ADMIN_ADV'),
('ROLE_PERM_EDIT',   'Edit role permissions',   'ADMIN_ADV');

-- =========================
-- ROLE PERMISSIONS
-- =========================

-- ADMIN: all permissions
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_name='ADMIN';

-- MANAGER: common + view users
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_name='MANAGER'
  AND p.code IN (
    'HOME_VIEW','LOGIN','LOGOUT','PROFILE_VIEW','PASSWORD_CHANGE',
    'USER_VIEW_LIST','USER_VIEW_DETAIL'
  );

-- STAFF: common
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_name='STAFF'
  AND p.module='COMMON';

-- SALE: common
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r
JOIN permissions p
WHERE r.role_name='SALE'
  AND p.module='COMMON';

-- =========================
-- PASSWORD RESET (DEMO)
-- =========================
INSERT INTO password_resets (user_id, token_hash, expires_at, used_at)
VALUES
((SELECT user_id FROM users WHERE username='sale01'),
 'TOKEN_SALE01', DATE_ADD(NOW(), INTERVAL 30 MINUTE), NULL),
((SELECT user_id FROM users WHERE username='staff01'),
 'TOKEN_STAFF01_USED', DATE_ADD(NOW(), INTERVAL 30 MINUTE), NOW());

-- =========================
-- AUDIT LOGS (DEMO)
-- =========================
INSERT INTO audit_logs (user_id, action, entity, entity_id, detail)
VALUES
((SELECT user_id FROM users WHERE username='admin01'), 'LOGIN', 'users', NULL, 'Admin logged in'),
((SELECT user_id FROM users WHERE username='admin01'), 'USER_UPDATE', 'users', '2', 'Updated manager01'),
((SELECT user_id FROM users WHERE username='admin01'), 'ROLE_TOGGLE', 'roles', '4', 'Toggled SALE role'),
((SELECT user_id FROM users WHERE username='staff01'), 'LOGIN', 'users', NULL, 'Staff logged in'),
((SELECT user_id FROM users WHERE username='sale01'),  'FORGOT_PASS', 'users', NULL, 'Request password reset');

-- ======================================================
-- END
-- ======================================================
