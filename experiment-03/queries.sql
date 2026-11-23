-- Experiment 3
-- Employee-Department-Project schema.
-- Selection, projection, aggregates, GROUP BY, HAVING, CASE, ORDER BY.

CREATE DATABASE company_db;
USE company_db;

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    project_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);

INSERT INTO Department VALUES
(1, 'IT', 'Delhi'),
(2, 'HR', 'Mumbai'),
(3, 'Finance', 'Bangalore'),
(4, 'Marketing', 'Pune'),
(5, 'Operations', 'Hyderabad');

INSERT INTO Project VALUES
(101, 'E-Commerce Platform', 1500000, 1),
(102, 'AI Chatbot', 2000000, 1),
(103, 'Employee Portal', 800000, 2),
(104, 'Financial Analytics', 1800000, 3),
(105, 'Digital Marketing', 1200000, 4),
(106, 'Supply Chain System', 2500000, 5),
(107, 'Cloud Migration', 2200000, 1),
(108, 'Customer Management', 1300000, 4);

INSERT INTO Employee VALUES
(1, 'Aarav Sharma', 75000, '2021-01-15', 1, 101),
(2, 'Priya Singh', 85000, '2020-03-20', 1, 102),
(3, 'Rahul Verma', 65000, '2022-06-10', 1, 107),
(4, 'Ananya Gupta', 95000, '2019-08-12', 1, 102),
(5, 'Rohan Mehta', 70000, '2021-11-05', 1, 101),
(6, 'Sneha Kapoor', 80000, '2020-09-18', 1, 107),
(7, 'Vikas Kumar', 55000, '2022-01-10', 2, 103),
(8, 'Neha Joshi', 60000, '2021-04-22', 2, 103),
(9, 'Karan Malhotra', 58000, '2022-07-15', 2, 103),
(10, 'Simran Kaur', 72000, '2020-12-01', 2, 103),
(11, 'Pooja Agarwal', 68000, '2021-10-11', 2, 103),
(12, 'Aditya Jain', 62000, '2023-02-14', 2, 103),
(13, 'Amit Shah', 90000, '2019-05-10', 3, 104),
(14, 'Kavya Rao', 88000, '2020-08-19', 3, 104),
(15, 'Manish Gupta', 76000, '2021-02-25', 3, 104),
(16, 'Isha Patel', 82000, '2020-06-30', 3, 104),
(17, 'Nitin Yadav', 70000, '2022-03-17', 3, 104),
(18, 'Meera Nair', 95000, '2018-11-21', 3, 104),
(19, 'Sakshi Mishra', 65000, '2021-07-12', 4, 105),
(20, 'Arjun Kapoor', 72000, '2020-10-09', 4, 108),
(21, 'Tanya Sethi', 78000, '2022-01-28', 4, 108),
(22, 'Yash Thakur', 60000, '2023-04-15', 4, 108),
(23, 'Riya Bansal', 85000, '2019-09-23', 4, 105),
(24, 'Mohit Arora', 69000, '2021-12-05', 4, 108),
(25, 'Deepak Singh', 70000, '2020-02-18', 5, 106),
(26, 'Nisha Verma', 75000, '2021-05-25', 5, 106),
(27, 'Varun Khanna', 68000, '2022-08-14', 5, 106),
(28, 'Ayesha Khan', 82000, '2019-10-30', 5, 106),
(29, 'Suresh Reddy', 90000, '2018-06-12', 5, 106),
(30, 'Divya Menon', 77000, '2021-03-09', 5, 106);

-- 1. Selection
SELECT *
FROM Employee
WHERE salary > 80000;

-- 2. Projection
SELECT emp_name, salary
FROM Employee;

-- 3. Aggregate Functions
SELECT
    COUNT(*) AS total_employees,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary,
    SUM(salary) AS total_salary
FROM Employee;

-- 4. GROUP BY
-- Employee count in each department
SELECT
    dept_id,
    COUNT(emp_id) AS employee_count
FROM Employee
GROUP BY dept_id;

-- 5. Department-wise Employee Count
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- 6. HAVING
-- Departments whose average salary is greater than 75000
SELECT
    dept_id,
    AVG(salary) AS average_salary
FROM Employee
GROUP BY dept_id
HAVING AVG(salary) > 75000;

-- 7. CASE expression
-- High: 90000 and above. Medium: 70000 to 89999. Low: below 70000.
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'High Salary'
        WHEN salary >= 70000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM Employee;

-- 8. ORDER BY
SELECT emp_name, salary
FROM Employee
ORDER BY salary DESC;

-- 9. Join Employee, Department and Project
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
JOIN Project p ON e.project_id = p.project_id;

-- 10. Project-wise Employee Count
SELECT
    p.project_name,
    COUNT(e.emp_id) AS employee_count
FROM Project p
LEFT JOIN Employee e ON p.project_id = e.project_id
GROUP BY p.project_name
ORDER BY employee_count DESC;

-- 11. Department-wise Total Salary
SELECT
    d.dept_name,
    SUM(e.salary) AS total_salary
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
ORDER BY total_salary DESC;

-- 12. Combined GROUP BY, HAVING and ORDER BY
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS highest_salary
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING AVG(e.salary) > 70000
ORDER BY average_salary DESC;
