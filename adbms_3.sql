-- Step 1: Setup Database and Table
DROP DATABASE IF EXISTS nimbus_demo;
CREATE DATABASE nimbus_demo;
USE nimbus_demo;

DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    course_id VARCHAR(10),
    enrollment_date DATE
);

INSERT INTO StudentEnrollments VALUES
(1, 'Ashish', 'CSE101', '2024-06-01'),
(2, 'Smaran', 'CSE102', '2024-06-01'),
(3, 'Vaibhav', 'CSE103', '2024-06-01');

-- ==========================
-- Part A: Deadlock Simulation (Simulated Sequentially)
-- ==========================
-- Normally done with 2 terminals, here we simulate sequentially
START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-01' WHERE student_id = 1;
-- COMMIT or leave open if testing deadlock manually

START TRANSACTION;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-05' WHERE student_id = 2;
-- COMMIT or leave open if testing deadlock manually

-- Update after previous transactions
UPDATE StudentEnrollments SET enrollment_date = '2024-07-10' WHERE student_id = 2;
UPDATE StudentEnrollments SET enrollment_date = '2024-07-15' WHERE student_id = 1;
COMMIT;

-- ==========================
-- Part B: MVCC Demo (REPEATABLE READ)
-- ==========================
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;

-- Simulate another transaction updating the value
UPDATE StudentEnrollments SET enrollment_date = '2024-07-10' WHERE student_id = 1;
COMMIT;

-- Original transaction sees old value until commit
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;
COMMIT;
SELECT enrollment_date FROM StudentEnrollments WHERE student_id = 1;

-- ==========================
-- Part C: Locking vs MVCC
-- ==========================
-- Lock the row
START TRANSACTION;
SELECT * FROM StudentEnrollments WHERE student_id = 1 FOR UPDATE;

-- Simulate another transaction reading (will see old value)
SELECT * FROM StudentEnrollments WHERE student_id = 1;

-- Update the locked row
UPDATE StudentEnrollments SET enrollment_date = '2024-07-20' WHERE student_id = 1;
COMMIT;

-- Final check
SELECT * FROM StudentEnrollments;

