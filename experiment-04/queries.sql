-- Experiment 4
-- Joins, correlated subqueries, EXISTS, simulated INTERSECT and EXCEPT, EXPLAIN.
-- Run experiment 3 first. These queries use company_db.

USE company_db;

-- =====================================================
-- 1. INNER JOIN
-- Display employees with their department names
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    e.salary
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

-- =====================================================
-- 2. LEFT JOIN
-- Display all departments and their employees
-- =====================================================

SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name,
    e.salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;

-- =====================================================
-- 3. SELF JOIN
-- Find pairs of employees working in the same department
-- =====================================================

SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee e1
INNER JOIN Employee e2
    ON e1.dept_id = e2.dept_id
    AND e1.emp_id < e2.emp_id;

-- =====================================================
-- 4. THREE-WAY JOIN
-- Employee + Department + Project
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id
INNER JOIN Project p
    ON e.project_id = p.project_id;

-- =====================================================
-- 5. CORRELATED SUBQUERY
-- Find employees earning more than the average salary
-- of their own department
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- =====================================================
-- 6. CORRELATED SUBQUERY
-- Find the highest-paid employee in each department
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- =====================================================
-- 7. EXISTS
-- Find departments having at least one employee
-- =====================================================

SELECT
    d.dept_id,
    d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
);

-- =====================================================
-- 8. EXISTS
-- Find employees working on projects
-- whose budget is greater than 2,000,000
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name,
    e.salary
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Project p
    WHERE p.project_id = e.project_id
    AND p.budget > 2000000
);

-- =====================================================
-- 9. SIMULATED INTERSECT
-- Employees who are in IT department
-- AND earn more than 80,000
-- =====================================================

SELECT emp_id, emp_name
FROM Employee
WHERE dept_id = 1

INTERSECT

SELECT emp_id, emp_name
FROM Employee
WHERE salary > 80000;

-- =====================================================
-- 10. INTERSECT USING INNER JOIN
-- MySQL-compatible simulation
-- =====================================================

SELECT DISTINCT
    e.emp_id,
    e.emp_name
FROM Employee e
INNER JOIN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
) i
    ON e.emp_id = i.emp_id
WHERE e.salary > 80000;

-- =====================================================
-- 11. SIMULATED EXCEPT
-- Employees who are NOT in the IT department
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
WHERE NOT EXISTS (
    SELECT 1
    FROM Employee e2
    WHERE e2.emp_id = e.emp_id
    AND e2.dept_id = 1
);

-- =====================================================
-- 12. EXCEPT USING LEFT JOIN
-- MySQL-compatible simulation
-- =====================================================

SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
LEFT JOIN (
    SELECT emp_id
    FROM Employee
    WHERE dept_id = 1
) i
    ON e.emp_id = i.emp_id
WHERE i.emp_id IS NULL;

-- =====================================================
-- 13. EXPLAIN - INNER JOIN
-- =====================================================

EXPLAIN
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

-- =====================================================
-- 14. EXPLAIN - LEFT JOIN
-- =====================================================

EXPLAIN
SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name,
    e.salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;

-- =====================================================
-- 15. EXPLAIN - CORRELATED SUBQUERY
-- =====================================================

EXPLAIN
SELECT
    e.emp_id,
    e.emp_name,
    e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);

-- =====================================================
-- 16. EXPLAIN - EXISTS
-- =====================================================

EXPLAIN
SELECT
    d.dept_id,
    d.dept_name
FROM Department d
WHERE EXISTS (
    SELECT 1
    FROM Employee e
    WHERE e.dept_id = d.dept_id
);
