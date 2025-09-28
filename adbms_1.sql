-- Ensure rollback works
SET autocommit = 0;

DROP TABLE IF EXISTS FeePayments;

CREATE TABLE FeePayments (
    payment_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) CHECK (amount > 0),
    payment_date DATE NOT NULL
);

-----------------------------------------------------------
-- PART A: Valid Inserts
-----------------------------------------------------------
START TRANSACTION;
INSERT INTO FeePayments VALUES (1, 'Ashish', 5000.00, '2024-06-01');
INSERT INTO FeePayments VALUES (2, 'Smaran', 4500.00, '2024-06-02');
INSERT INTO FeePayments VALUES (3, 'Vaibhav', 5500.00, '2024-06-03');
COMMIT;

-- After Part A
SELECT * FROM FeePayments;

-----------------------------------------------------------
-- PART B: Rollback Invalid (Kiran + duplicate Ashish)
-----------------------------------------------------------
START TRANSACTION;
INSERT INTO FeePayments VALUES (4, 'Kiran', 4800.00, '2024-06-04');
INSERT INTO FeePayments VALUES (1, 'Ashish', -2000.00, '2024-06-05'); -- fails
ROLLBACK;

-- After Part B
SELECT * FROM FeePayments;

-----------------------------------------------------------
-- PART C: Rollback (Mehul + NULL)
-----------------------------------------------------------
START TRANSACTION;
INSERT INTO FeePayments VALUES (5, 'Mehul', 6000.00, '2024-06-06');
INSERT INTO FeePayments VALUES (6, NULL, 4000.00, '2024-06-07'); -- fails
ROLLBACK;

-- After Part C
SELECT * FROM FeePayments;

-----------------------------------------------------------
-- PART D: ACID Test
-----------------------------------------------------------
-- Success
START TRANSACTION;
INSERT INTO FeePayments VALUES (7, 'Sneha', 4700.00, '2024-06-08');
INSERT INTO FeePayments VALUES (8, 'Arjun', 4900.00, '2024-06-09');
COMMIT;

-- Failure (duplicate PK)
START TRANSACTION;
INSERT INTO FeePayments VALUES (9, 'TempUser', 4100.00, '2024-06-10');
INSERT INTO FeePayments VALUES (2, 'Duplicate', 7000.00, '2024-06-11'); -- fails
ROLLBACK;

-- Final
SELECT * FROM FeePayments;
