-- Experiment 7
-- Normalize a repeating registration table from UNF to BCNF.
-- Check that the decomposition is a lossless join and that
-- each functional dependency can be checked in one table.

DROP DATABASE IF EXISTS normalization_db;
CREATE DATABASE normalization_db;
USE normalization_db;

-- =====================================================
-- 1. UNNORMALIZED REGISTRATION TABLE
-- registration_id -> student_id, course_id, semester, grade
-- student_id      -> student_name
-- course_id       -> course_name, instructor_id
-- instructor_id   -> instructor_name, department
-- =====================================================

CREATE TABLE Registration_UNF (
    registration_id INT,
    student_id INT,
    student_name VARCHAR(100),
    course_id INT,
    course_name VARCHAR(100),
    instructor_id INT,
    instructor_name VARCHAR(100),
    department VARCHAR(50),
    semester VARCHAR(20),
    grade CHAR(2)
);

INSERT INTO Registration_UNF VALUES
(501, 101, 'Aarav Sharma', 201, 'Database Systems', 301, 'Dr Mehta', 'CSE', 'Semester 3', 'A'),
(502, 102, 'Priya Singh', 202, 'Operating Systems', 302, 'Dr Rao', 'CSE', 'Semester 3', 'B'),
(503, 103, 'Rahul Verma', 203, 'Computer Networks', 303, 'Dr Sen', 'IT', 'Semester 4', 'A'),
(504, 104, 'Ananya Gupta', 201, 'Database Systems', 301, 'Dr Mehta', 'CSE', 'Semester 3', 'B'),
(505, 105, 'Rohan Mehta', 204, 'Artificial Intelligence', 304, 'Dr Nair', 'AIML', 'Semester 5', 'A'),
(506, 101, 'Aarav Sharma', 202, 'Operating Systems', 302, 'Dr Rao', 'CSE', 'Semester 3', 'A');

-- CAPTURE output-01
SELECT * FROM Registration_UNF ORDER BY registration_id;

-- =====================================================
-- 2. FIRST NORMAL FORM
-- Every column is already atomic, so 1NF is a copy
-- of the source with a primary key.
-- =====================================================

CREATE TABLE Registration_1NF (
    registration_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    course_id INT NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    semester VARCHAR(20) NOT NULL,
    grade CHAR(2) NOT NULL
);

INSERT INTO Registration_1NF
SELECT * FROM Registration_UNF;

-- =====================================================
-- 3. SECOND NORMAL FORM
-- Split partial dependencies into Students, Courses, Registrations.
-- Courses is still only in 2NF: instructor attributes depend on
-- instructor_id, not on course_id.
-- =====================================================

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE TABLE Registrations (
    registration_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    grade CHAR(2) NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

INSERT INTO Students (student_id, student_name)
SELECT DISTINCT student_id, student_name
FROM Registration_1NF;

INSERT INTO Courses (course_id, course_name, instructor_id, instructor_name, department)
SELECT DISTINCT course_id, course_name, instructor_id, instructor_name, department
FROM Registration_1NF;

INSERT INTO Registrations (registration_id, student_id, course_id, semester, grade)
SELECT registration_id, student_id, course_id, semester, grade
FROM Registration_1NF;

-- =====================================================
-- 4. THIRD NORMAL FORM AND BCNF
-- course_id -> instructor_id -> instructor_name, department
-- is a transitive dependency. Move instructor attributes out.
-- =====================================================

CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE TABLE Courses_3NF (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT NOT NULL,
    FOREIGN KEY (instructor_id) REFERENCES Instructors(instructor_id)
);

INSERT INTO Instructors (instructor_id, instructor_name, department)
SELECT DISTINCT instructor_id, instructor_name, department
FROM Courses;

INSERT INTO Courses_3NF (course_id, course_name, instructor_id)
SELECT course_id, course_name, instructor_id
FROM Courses;

-- CAPTURE output-02
SELECT student_id, student_name FROM Students ORDER BY student_id;

-- CAPTURE output-03
SELECT instructor_id, instructor_name, department
FROM Instructors
ORDER BY instructor_id;

-- CAPTURE output-04
SELECT course_id, course_name, instructor_id
FROM Courses_3NF
ORDER BY course_id;

-- CAPTURE output-05
SELECT registration_id, student_id, course_id, semester, grade
FROM Registrations
ORDER BY registration_id;

-- =====================================================
-- 5. LOSSLESS JOIN
-- Joining the BCNF tables must rebuild every source row
-- and must not invent extra rows.
-- =====================================================

CREATE OR REPLACE VIEW Registration_Rebuilt AS
SELECT
    r.registration_id,
    s.student_id,
    s.student_name,
    c.course_id,
    c.course_name,
    i.instructor_id,
    i.instructor_name,
    i.department,
    r.semester,
    r.grade
FROM Registrations r
JOIN Students s ON r.student_id = s.student_id
JOIN Courses_3NF c ON r.course_id = c.course_id
JOIN Instructors i ON c.instructor_id = i.instructor_id;

-- CAPTURE output-06
SELECT
    (SELECT COUNT(*) FROM Registration_UNF) AS source_rows,
    (SELECT COUNT(*) FROM Registration_Rebuilt) AS rebuilt_rows,
    (
        SELECT COUNT(*)
        FROM (
            SELECT * FROM Registration_UNF
            UNION
            SELECT * FROM Registration_Rebuilt
        ) AS combined
    ) AS rows_after_union;

-- Rows present in the source but missing after the join.
-- CAPTURE output-07
SELECT * FROM Registration_UNF
WHERE registration_id NOT IN (SELECT registration_id FROM Registration_Rebuilt);

-- =====================================================
-- 6. DEPENDENCY PRESERVATION
-- Each query must return an empty set.
-- =====================================================

-- CAPTURE output-08
SELECT student_id
FROM Students
GROUP BY student_id
HAVING COUNT(DISTINCT student_name) > 1;

-- CAPTURE output-09
SELECT instructor_id
FROM Instructors
GROUP BY instructor_id
HAVING COUNT(DISTINCT instructor_name) > 1
    OR COUNT(DISTINCT department) > 1;

-- CAPTURE output-10
SELECT course_id
FROM Courses_3NF
GROUP BY course_id
HAVING COUNT(DISTINCT course_name) > 1
    OR COUNT(DISTINCT instructor_id) > 1;
