-- ============================================================
-- INIT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS db_mining_app;
USE db_mining_app;

-- Drop existing tables in correct FK order
DROP TABLE IF EXISTS tb_blending_plan;
DROP TABLE IF EXISTS tb_maintenance_schedule;
DROP TABLE IF EXISTS tb_karyawan;
DROP TABLE IF EXISTS tb_pit;
DROP TABLE IF EXISTS tb_equipment;
DROP TABLE IF EXISTS tb_users;
DROP TABLE IF EXISTS tb_roles;

-- ============================================================
-- TABLE: tb_roles
-- ============================================================

CREATE TABLE tb_roles (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  description VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_roles (id, name, description) VALUES
(1, 'shipper_planner', 'Perencana pengiriman kapal'),
(2, 'mining_planner', 'Perencana penambangan');

-- ============================================================
-- TABLE: tb_users
-- ============================================================

CREATE TABLE tb_users (
  id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  pass VARCHAR(255) NOT NULL,
  role_id INT NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY username (username),
  UNIQUE KEY email (email),
  KEY role_fk (role_id),
  CONSTRAINT fk_role FOREIGN KEY (role_id)
    REFERENCES tb_roles (id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_users VALUES
(1,'budi_shipper','budi@example.com','$2y$10$abcdefg1234567890example',1,'2025-11-04 07:55:39'),
(2,'andi_mining','andi@example.com','$2y$10$hijklmn0987654321example',2,'2025-11-04 07:55:39'),
(3,'kin','waw@gmail.com','$2y$10$hUgDxYUGnmO7GLcHsErshecRi439S4R6TiG86KemwC2tYhdoTtTAO',1,'2025-11-04 08:49:45');

-- ============================================================
-- TABLE: tb_equipment
-- ============================================================

CREATE TABLE tb_equipment (
  id INT NOT NULL AUTO_INCREMENT,
  unit_id VARCHAR(20) NOT NULL,
  type VARCHAR(50) NOT NULL,
  location VARCHAR(100) DEFAULT 'Workshop',
  status ENUM('Available','Breakdown','Maintenance','Standby') DEFAULT 'Available',
  is_available TINYINT(1) DEFAULT 1,
  productivity_rate DECIMAL(6,2) DEFAULT 0.00,
  last_update TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY unit_id (unit_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_equipment VALUES
(1,'DT-01','Dump Truck','Pit A','Available',1,55.00,'2025-11-17 09:18:06'),
(2,'EX-01','Excavator','Pit A','Available',1,150.00,'2025-11-17 09:18:06'),
(3,'DT-02','Dump Truck','Workshop','Breakdown',0,0.00,'2025-11-17 09:18:06'),
(4,'DZ-01','Dozer','Pit B','Available',1,30.00,'2025-11-17 09:18:06'),
(5,'DT-03','Dump Truck','Pit C','Maintenance',0,0.00,'2025-11-17 09:18:06');

-- ============================================================
-- TABLE: tb_pit
-- ============================================================

CREATE TABLE tb_pit (
  id INT NOT NULL AUTO_INCREMENT,
  pit_name VARCHAR(50) NOT NULL,
  geotech_status VARCHAR(50) DEFAULT 'Stabil',
  current_elevasi DECIMAL(8,2) DEFAULT 0.00,
  bench_readiness ENUM('Ready','Delayed','Not Ready') DEFAULT 'Ready',
  hauling_route VARCHAR(150) DEFAULT NULL,
  last_update TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY pit_name (pit_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_pit VALUES
(1,'Pit A','Stabil',150.50,'Ready','Pit A - ROM 1 (Rute Utama)','2025-11-17 09:17:54'),
(2,'Pit B','Rawan Longsor',120.00,'Delayed','Pit B - ROM 2 (Rute Berbukit)','2025-11-17 09:17:54'),
(3,'Pit C','Stabil',180.25,'Not Ready','Pit C - ROM 1 (Jalan Licin)','2025-11-17 09:17:54');

-- ============================================================
-- TABLE: tb_karyawan
-- ============================================================

CREATE TABLE tb_karyawan (
  id INT NOT NULL AUTO_INCREMENT,
  nama VARCHAR(100) NOT NULL,
  user_id INT DEFAULT NULL,
  competency VARCHAR(150) NOT NULL,
  current_unit_id INT DEFAULT NULL,
  current_shift VARCHAR(20) DEFAULT 'Day 1',
  presence ENUM('Hadir','Absen','Sakit','Cuti') DEFAULT 'Hadir',
  PRIMARY KEY (id),
  KEY unit_fk (current_unit_id),
  CONSTRAINT tb_karyawan_ibfk_1 FOREIGN KEY (current_unit_id)
    REFERENCES tb_equipment (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_karyawan VALUES
(2,'Budi Cahyo',NULL,'Heavy Excavator Certified',2,'Day 1','Hadir'),
(3,'Cintya Putri',NULL,'Dump Truck',4,'Day 1','Hadir'),
(4,'Doni Rian',NULL,'Dozer, Scraper',5,'Night 1','Hadir'),
(5,'Eva Melisa',NULL,'Dump Truck',NULL,'Day 1','Absen');

-- ============================================================
-- TABLE: tb_maintenance_schedule
-- ============================================================

CREATE TABLE tb_maintenance_schedule (
  id INT NOT NULL AUTO_INCREMENT,
  unit_id INT NOT NULL,
  type VARCHAR(50) NOT NULL,
  scheduled_date DATE NOT NULL,
  duration_hours INT DEFAULT 8,
  status ENUM('Scheduled','In Progress','Completed','Cancelled') DEFAULT 'Scheduled',
  PRIMARY KEY (id),
  KEY unit_fk (unit_id),
  CONSTRAINT tb_maintenance_schedule_ibfk_1 FOREIGN KEY (unit_id)
    REFERENCES tb_equipment (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_maintenance_schedule VALUES
(1,3,'Emergency Repair','2025-11-18',24,'In Progress'),
(2,1,'Periodic Service','2025-11-25',8,'Scheduled'),
(3,5,'Major Overhaul','2025-11-20',48,'Scheduled');

-- ============================================================
-- TABLE: tb_blending_plan
-- ============================================================

CREATE TABLE tb_blending_plan (
  id INT NOT NULL AUTO_INCREMENT,
  plan_week INT NOT NULL,
  plan_year INT NOT NULL,
  target_tonnage_weekly INT NOT NULL,
  target_calori DECIMAL(6,2) DEFAULT 4800.00,
  target_ash_max DECIMAL(4,2) DEFAULT 12.00,
  initial_ash_draft DECIMAL(4,2) DEFAULT 12.50,
  final_ash_result DECIMAL(4,2) DEFAULT NULL,
  is_approved_mine TINYINT(1) DEFAULT 0,
  is_approved_shipping TINYINT(1) DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO tb_blending_plan VALUES
(1,47,2025,112000,4800.00,12.00,12.50,NULL,0,0);
