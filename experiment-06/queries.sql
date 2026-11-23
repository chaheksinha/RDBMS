-- Experiment 6
-- Stored procedure transfer_employee, salary validation triggers,
-- and a salary audit log.
-- Run experiments 3 and 5 first. Employee.manager_id must already exist.

USE company_db;

-- =====================================================
-- 1. CREATE AUDIT TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS salary_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(20)
);

-- =====================================================
-- 2. SALARY VALIDATION TRIGGER
-- Salary must be greater than 0
-- =====================================================

DROP TRIGGER IF EXISTS validate_salary;

DELIMITER //

CREATE TRIGGER validate_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than 0';
    END IF;
END //

DELIMITER ;

-- =====================================================
-- 3. SALARY VALIDATION FOR UPDATE
-- =====================================================

DROP TRIGGER IF EXISTS validate_salary_update;

DELIMITER //

CREATE TRIGGER validate_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than 0';
    END IF;
END //

DELIMITER ;

-- =====================================================
-- 4. AUDIT TRIGGER
-- Record salary changes
-- =====================================================

DROP TRIGGER IF EXISTS salary_audit_trigger;

DELIMITER //

CREATE TRIGGER salary_audit_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO salary_audit
        (
            emp_id,
            old_salary,
            new_salary,
            action
        )
        VALUES
        (
            OLD.emp_id,
            OLD.salary,
            NEW.salary,
            'SALARY UPDATE'
        );
    END IF;
END //

DELIMITER ;

-- =====================================================
-- 5. STORED PROCEDURE
-- transfer_employee(emp_id, new_dept_id)
-- =====================================================

DROP PROCEDURE IF EXISTS transfer_employee;

DELIMITER //

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE employee_count INT DEFAULT 0;
    DECLARE department_count INT DEFAULT 0;
    DECLARE current_dept_id INT DEFAULT 0;

    -- Error handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    -- Check whether employee exists

    SELECT COUNT(*)
    INTO employee_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF employee_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee does not exist';
    END IF;

    -- Check whether department exists

    SELECT COUNT(*)
    INTO department_count
    FROM Department
    WHERE dept_id = p_new_dept_id;

    IF department_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist';
    END IF;

    -- Get current department

    SELECT dept_id
    INTO current_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id;

    -- Check if employee is already in department

    IF current_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee is already in this department';
    END IF;

    -- Transfer employee

    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;

    COMMIT;

    SELECT
        'Employee transferred successfully' AS message,
        p_emp_id AS employee_id,
        p_new_dept_id AS new_department;
END //

DELIMITER ;

-- =====================================================
-- 6. TEST THE STORED PROCEDURE
-- =====================================================

-- Successful transfer
CALL transfer_employee(1, 2);

-- Check employee
SELECT *
FROM Employee
WHERE emp_id = 1;

-- =====================================================
-- 7. EDGE CASE: INVALID EMPLOYEE
-- =====================================================

CALL transfer_employee(999, 2);

-- =====================================================
-- 8. EDGE CASE: INVALID DEPARTMENT
-- =====================================================

CALL transfer_employee(1, 999);

-- =====================================================
-- 9. EDGE CASE: SAME DEPARTMENT
-- =====================================================

CALL transfer_employee(1, 2);

-- =====================================================
-- 10. EDGE CASE: INVALID SALARY DURING INSERT
-- =====================================================

INSERT INTO Employee
(
    emp_id,
    emp_name,
    salary,
    hire_date,
    dept_id,
    project_id,
    manager_id
)
VALUES
(
    31,
    'Test Employee',
    -5000,
    '2026-09-30',
    1,
    101,
    NULL
);

-- =====================================================
-- 11. EDGE CASE: INVALID SALARY DURING UPDATE
-- =====================================================

UPDATE Employee
SET salary = -1000
WHERE emp_id = 2;

-- =====================================================
-- 12. VALID SALARY UPDATE
-- This should succeed and create an audit record
-- =====================================================

UPDATE Employee
SET salary = 90000
WHERE emp_id = 2;

-- =====================================================
-- 13. CHECK AUDIT LOG
-- =====================================================

SELECT *
FROM salary_audit
ORDER BY changed_at DESC;

-- =====================================================
-- 14. VERIFY EMPLOYEE DATA
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
