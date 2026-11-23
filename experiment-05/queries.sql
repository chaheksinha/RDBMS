-- Experiment 5
-- Views, updatability, and a recursive CTE for reporting chains.
-- Run experiments 3 and 4 first. This script alters Employee.

USE company_db;

-- =====================================================
-- 1. ADD MANAGER COLUMN TO EMPLOYEE
-- =====================================================

ALTER TABLE Employee
ADD COLUMN manager_id INT NULL;

-- Add self-referencing foreign key
ALTER TABLE Employee
ADD CONSTRAINT fk_manager
FOREIGN KEY (manager_id) REFERENCES Employee(emp_id);

-- =====================================================
-- 2. SET UP EMPLOYEE HIERARCHY
-- =====================================================

-- Top-level employees have NULL manager_id
UPDATE Employee SET manager_id = NULL;

-- IT
UPDATE Employee SET manager_id = 1 WHERE emp_id IN (2, 3, 5);
UPDATE Employee SET manager_id = 2 WHERE emp_id = 4;
UPDATE Employee SET manager_id = 1 WHERE emp_id = 6;

-- HR
UPDATE Employee SET manager_id = 7 WHERE emp_id IN (8, 9, 10);
UPDATE Employee SET manager_id = 8 WHERE emp_id = 11;
UPDATE Employee SET manager_id = 7 WHERE emp_id = 12;

-- Finance
UPDATE Employee SET manager_id = 13 WHERE emp_id IN (14, 15, 16);
UPDATE Employee SET manager_id = 14 WHERE emp_id = 17;
UPDATE Employee SET manager_id = 13 WHERE emp_id = 18;

-- Marketing
UPDATE Employee SET manager_id = 19 WHERE emp_id IN (20, 21, 22);
UPDATE Employee SET manager_id = 20 WHERE emp_id = 23;
UPDATE Employee SET manager_id = 19 WHERE emp_id = 24;

-- Operations
UPDATE Employee SET manager_id = 25 WHERE emp_id IN (26, 27, 28);
UPDATE Employee SET manager_id = 26 WHERE emp_id = 29;
UPDATE Employee SET manager_id = 25 WHERE emp_id = 30;

-- =====================================================
-- 3. VIEW: DEPARTMENT SALARY SUMMARY
-- =====================================================

CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

-- Display department salary summary
SELECT *
FROM department_salary_summary;

-- =====================================================
-- 4. VIEW: EMPLOYEE HIERARCHY
-- =====================================================

CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
    e.emp_id,
    e.emp_name AS employee_name,
    e.salary,
    e.dept_id,
    e.manager_id,
    m.emp_name AS manager_name
FROM Employee e
LEFT JOIN Employee m
    ON e.manager_id = m.emp_id;

-- Display employee hierarchy
SELECT *
FROM employee_hierarchy;

-- =====================================================
-- 5. TEST UPDATABILITY OF EMPLOYEE HIERARCHY VIEW
-- =====================================================

-- This view is based mainly on one Employee table,
-- so simple updates can be performed.

UPDATE employee_hierarchy
SET salary = 80000
WHERE emp_id = 1;

SELECT *
FROM employee_hierarchy
WHERE emp_id = 1;

-- Test INSERT/UPDATE/DELETE concept
-- The following UPDATE demonstrates that the view
-- can modify the underlying Employee table.

UPDATE employee_hierarchy
SET manager_id = 1
WHERE emp_id = 3;

SELECT *
FROM Employee
WHERE emp_id = 3;

-- =====================================================
-- 6. TEST UPDATABILITY OF DEPARTMENT SALARY SUMMARY
-- =====================================================

-- This view contains GROUP BY and aggregate functions.
-- Therefore, it is NOT directly updatable.

UPDATE department_salary_summary
SET average_salary = 80000
WHERE dept_id = 1;

-- =====================================================
-- 7. RECURSIVE CTE
-- DISPLAY REPORTING CHAIN
-- =====================================================

WITH RECURSIVE employee_chain AS
(
    -- Anchor query: top-level employees
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level,
        CAST(emp_name AS CHAR(1000)) AS reporting_chain
    FROM Employee
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive query: find employees reporting
    -- to the previous employee
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        ec.level + 1,
        CONCAT(ec.reporting_chain, ' -> ', e.emp_name)
    FROM Employee e
    INNER JOIN employee_chain ec
        ON e.manager_id = ec.emp_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level,
    reporting_chain
FROM employee_chain
ORDER BY reporting_chain;

-- =====================================================
-- 8. RECURSIVE CTE FOR ONE PARTICULAR EMPLOYEE
-- =====================================================

WITH RECURSIVE reporting_chain AS
(
    -- Start with employee 4
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level
    FROM Employee
    WHERE emp_id = 4

    UNION ALL

    -- Move upward to the manager
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1
    FROM Employee e
    INNER JOIN reporting_chain rc
        ON e.emp_id = rc.manager_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level
FROM reporting_chain;

-- =====================================================
-- 9. DISPLAY HIERARCHY WITH DEPARTMENT
-- =====================================================

WITH RECURSIVE employee_tree AS
(
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.dept_id,
        0 AS level,
        CAST(e.emp_name AS CHAR(1000)) AS hierarchy
    FROM Employee e
    WHERE e.manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        e.dept_id,
        et.level + 1,
        CONCAT(et.hierarchy, ' -> ', e.emp_name)
    FROM Employee e
    INNER JOIN employee_tree et
        ON e.manager_id = et.emp_id
)
SELECT
    et.emp_id,
    et.emp_name,
    d.dept_name,
    et.level,
    et.hierarchy
FROM employee_tree et
INNER JOIN Department d
    ON et.dept_id = d.dept_id
ORDER BY et.hierarchy;
