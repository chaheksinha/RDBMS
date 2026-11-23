-- Experiment 2
-- Data manipulation: insert, update, and delete rows
-- in the college database created in Experiment 1.

USE college_db;

-- =====================================================
-- 1. INSERT
-- =====================================================

INSERT INTO Department (dept_id, dept_name, location) VALUES
(1, 'Computer Science', 'Chandigarh'),
(2, 'Artificial Intelligence', 'Mohali'),
(3, 'Information Technology', DEFAULT);

INSERT INTO Student (
    student_id, student_name, email, phone, dept_id, admission_date, cgpa
) VALUES
(101, 'Aarav Sharma', 'aarav.sharma@college.edu', '9876500101', 1, '2024-08-01', 8.40),
(102, 'Priya Singh', 'priya.singh@college.edu', '9876500102', 1, '2024-08-01', 9.10),
(103, 'Rahul Verma', 'rahul.verma@college.edu', '9876500103', 2, '2023-08-12', 7.60),
(104, 'Ananya Gupta', 'ananya.gupta@college.edu', '9876500104', 2, '2023-08-12', 8.80),
(105, 'Rohan Mehta', 'rohan.mehta@college.edu', NULL, 3, '2025-08-04', 6.90),
(106, 'Sneha Kapoor', 'sneha.kapoor@college.edu', '9876500106', 3, '2025-08-04', 8.20);

INSERT INTO Course (course_id, course_name, credits, dept_id) VALUES
(201, 'Database Systems', 4, 1),
(202, 'Operating Systems', 4, 1),
(203, 'Machine Learning', 3, 2),
(204, 'Computer Networks', 3, 3);

-- CAPTURE output-01
SELECT student_id, student_name, email, dept_id, cgpa
FROM Student
ORDER BY student_id;

-- CAPTURE output-02
SELECT * FROM Department ORDER BY dept_id;

-- CAPTURE output-03
SELECT * FROM Course ORDER BY course_id;

-- =====================================================
-- 2. UPDATE
-- =====================================================

UPDATE Student
SET cgpa = 8.70
WHERE student_id = 101;

UPDATE Student
SET phone = '9876500105'
WHERE student_id = 105 AND phone IS NULL;

UPDATE Course
SET credits = credits + 1
WHERE course_name = 'Machine Learning';

-- CAPTURE output-04
SELECT student_id, student_name, phone, cgpa
FROM Student
WHERE student_id IN (101, 105)
ORDER BY student_id;

-- CAPTURE output-05
SELECT course_id, course_name, credits
FROM Course
WHERE course_id = 203;

-- =====================================================
-- 3. DELETE
-- =====================================================

DELETE FROM Course
WHERE course_id = 202;

-- CAPTURE output-06
SELECT course_id, course_name, credits, dept_id
FROM Course
ORDER BY course_id;

-- =====================================================
-- 4. BASIC RETRIEVAL AFTER THE CHANGES
-- =====================================================

-- CAPTURE output-07
SELECT
    s.student_id,
    s.student_name,
    d.dept_name,
    s.cgpa
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE s.cgpa >= 8.00
ORDER BY s.cgpa DESC;

-- CAPTURE output-08
SELECT COUNT(*) AS student_count FROM Student;
