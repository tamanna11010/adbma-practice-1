-- Ensure rollback works correctly
SET autocommit = 0;

-- Drop and recreate table
DROP TABLE IF EXISTS StudentEnrollments;

CREATE TABLE StudentEnrollments (
    enrollment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL,
    CONSTRAINT uq_student_course UNIQUE (student_name, course_id)
);

-----------------------------------------------------------
-- PART A: Prevent Duplicate Enrollments
-----------------------------------------------------------
-- First valid enrollments
START TRANSACTION;
INSERT INTO StudentEnrollments VALUES (1, 'Ashish', 'CSE101', '2024-07-01');
INSERT INTO StudentEnrollments VALUES (2, 'Smaran', 'CSE102', '2024-07-01');
INSERT INTO StudentEnrollments VALUES (3, 'Vaibhav', 'CSE101', '2024-07-01');
COMMIT;

-- Attempt to insert duplicate (same student_name + course_id)
-- This will fail because of UNIQUE constraint
START TRANSACTION;
INSERT INTO StudentEnrollments VALUES (4, 'Ashish', 'CSE101', '2024-07-02');
ROLLBACK;

--  Output after Part A
SELECT * FROM StudentEnrollments;

-----------------------------------------------------------
-- PART B: SELECT FOR UPDATE (Row-Level Locking)
-----------------------------------------------------------
START TRANSACTION;
SELECT * FROM StudentEnrollments
WHERE student_name = 'Ashish' AND course_id = 'CSE101'
FOR UPDATE;

-- (Row is now locked until COMMIT/ROLLBACK)

-- Simulation: Run this in User B’s session (in parallel)
-- This will be blocked until User A commits/rolls back
--  UPDATE StudentEnrollments
--  SET enrollment_date = '2024-07-05'
--  WHERE student_name = 'Ashish' AND course_id = 'CSE101';

--  Once User A COMMITs, User B’s update can continue.

-----------------------------------------------------------
-- PART C: Demonstrate Consistency with Locking
-----------------------------------------------------------
-- Assume record exists for Ashish in CSE101

-- User A
START TRANSACTION;
UPDATE StudentEnrollments
SET enrollment_date = '2024-07-10'
WHERE student_name = 'Ashish' AND course_id = 'CSE101';
-- (Not committed yet, row is locked)

-- User B (simultaneously tries)
-- This update will wait until User A commits or rolls back
--  UPDATE StudentEnrollments
--  SET enrollment_date = '2024-07-15'
--  WHERE student_name = 'Ashish' AND course_id = 'CSE101';

--  Only the last COMMIT will be reflected, avoiding race conditions.

-- Final view of the table
SELECT * FROM StudentEnrollments;
