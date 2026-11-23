-- Experiment 1
-- Data definition: create a college database, define tables
-- with keys and constraints, then change and remove a table.

DROP DATABASE IF EXISTS college_db;
CREATE DATABASE college_db;
USE college_db;

-- =====================================================
-- 1. CREATE TABLES
-- =====================================================

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50) DEFAULT 'Chandigarh'
);

CREATE TABLE Student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    dept_id INT,
    admission_date DATE NOT NULL,
    cgpa DECIMAL(3,2) DEFAULT 0.00,
    CONSTRAINT chk_cgpa CHECK (cgpa >= 0 AND cgpa <= 10),
    CONSTRAINT fk_student_dept FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL,
    dept_id INT,
    CONSTRAINT fk_course_dept FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- A table created only so it can be removed later.
CREATE TABLE Temp_Log (
    log_id INT PRIMARY KEY,
    note VARCHAR(100)
);

-- CAPTURE output-01
SHOW TABLES;

-- CAPTURE output-02
DESCRIBE Student;

-- CAPTURE output-03
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'college_db'
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- =====================================================
-- 2. ALTER TABLE
-- =====================================================

ALTER TABLE Student
ADD COLUMN phone VARCHAR(15) NULL AFTER email;

ALTER TABLE Course
MODIFY COLUMN credits INT NOT NULL DEFAULT 3;

ALTER TABLE Department
ADD CONSTRAINT chk_location CHECK (location <> '');

-- CAPTURE output-04
DESCRIBE Student;

-- CAPTURE output-05
DESCRIBE Course;

-- =====================================================
-- 3. DROP TABLE
-- =====================================================

DROP TABLE Temp_Log;

-- CAPTURE output-06
SHOW TABLES;
