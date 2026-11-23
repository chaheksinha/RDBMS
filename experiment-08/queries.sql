-- Experiment 8
-- Banking transactions: COMMIT, ROLLBACK, SAVEPOINT,
-- and isolation anomalies across two sessions.
-- The block after END BATCH is run in two clients, step by step.

DROP DATABASE IF EXISTS BankingDB;
CREATE DATABASE BankingDB;
USE BankingDB;

CREATE TABLE Accounts (
    account_no   INT PRIMARY KEY,
    holder_name  VARCHAR(100) NOT NULL,
    account_type VARCHAR(20)  NOT NULL,
    balance      DECIMAL(12, 2) NOT NULL CHECK (balance >= 0)
);

CREATE TABLE Transaction_Logs (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    from_acc     INT,
    to_acc       INT,
    amount       DECIMAL(12, 2),
    status       VARCHAR(20),
    log_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Accounts (account_no, holder_name, account_type, balance) VALUES
(101, 'Ananya Gupta',   'Savings', 62000.00),
(102, 'Rohan Malhotra', 'Savings', 41000.00),
(103, 'Divya Nair',     'Current', 88000.00);

-- CAPTURE output-01
SELECT * FROM Accounts ORDER BY account_no;

-- =====================================================
-- 1. SUCCESSFUL TRANSFER WITH COMMIT
-- Move 10000 from account 101 to account 102.
-- =====================================================

START TRANSACTION;

UPDATE Accounts
SET balance = balance - 10000.00
WHERE account_no = 101;

UPDATE Accounts
SET balance = balance + 10000.00
WHERE account_no = 102;

INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
VALUES (101, 102, 10000.00, 'SUCCESS');

COMMIT;

-- CAPTURE output-02
SELECT * FROM Accounts ORDER BY account_no;

-- CAPTURE output-03
SELECT log_id, from_acc, to_acc, amount, status FROM Transaction_Logs;

-- =====================================================
-- 2. FAILED TRANSFER WITH COMPLETE ROLLBACK
-- 60000 is more than account 101 holds. The CHECK constraint
-- rejects the debit and the handler rolls the transaction back.
-- =====================================================

DROP PROCEDURE IF EXISTS try_overdraft;

DELIMITER //

CREATE PROCEDURE try_overdraft()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Rolled back. The debit was rejected and no balance changed.' AS message;
    END;

    START TRANSACTION;

    UPDATE Accounts
    SET balance = balance - 60000.00
    WHERE account_no = 101;

    UPDATE Accounts
    SET balance = balance + 60000.00
    WHERE account_no = 103;

    INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
    VALUES (101, 103, 60000.00, 'SUCCESS');

    COMMIT;
END //

DELIMITER ;

-- CAPTURE output-04
CALL try_overdraft();

-- CAPTURE output-05
SELECT * FROM Accounts WHERE account_no IN (101, 103) ORDER BY account_no;

-- =====================================================
-- 3. PARTIAL FAILURE WITH SAVEPOINT
-- Keep the 5000 transfer. Undo only the transfer to account 999.
-- =====================================================

START TRANSACTION;

UPDATE Accounts SET balance = balance - 5000.00 WHERE account_no = 101;
UPDATE Accounts SET balance = balance + 5000.00 WHERE account_no = 102;

INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
VALUES (101, 102, 5000.00, 'SUCCESS');

SAVEPOINT sp_transfer1;

UPDATE Accounts SET balance = balance - 10000.00 WHERE account_no = 101;
UPDATE Accounts SET balance = balance + 10000.00 WHERE account_no = 999;

-- Account 999 does not exist, so the credit changed zero rows.
ROLLBACK TO SAVEPOINT sp_transfer1;

INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
VALUES (101, 999, 10000.00, 'FAILED_INVALID_ACC');

COMMIT;

-- CAPTURE output-06
SELECT * FROM Accounts ORDER BY account_no;

-- CAPTURE output-07
SELECT log_id, from_acc, to_acc, amount, status FROM Transaction_Logs ORDER BY log_id;

-- END BATCH

-- Two-session demonstrations. Do not run this half as one script.
-- Each STEP is one client. Balances are reset first so the figures
-- match a known starting point.

-- STEP A
UPDATE Accounts SET balance = 35000.00 WHERE account_no = 101;

-- STEP A
UPDATE Accounts SET balance = 45000.00 WHERE account_no = 102;

-- STEP A
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- STEP B
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- STEP A
START TRANSACTION;

-- STEP B
START TRANSACTION;

-- STEP A
UPDATE Accounts SET balance = 90000.00 WHERE account_no = 101;

-- STEP B
-- CAPTURE output-08
SELECT account_no, balance FROM Accounts WHERE account_no = 101;

-- STEP A
ROLLBACK;

-- STEP B
-- CAPTURE output-09
SELECT account_no, balance FROM Accounts WHERE account_no = 101;

-- STEP B
COMMIT;

-- STEP A
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- STEP B
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- STEP A
START TRANSACTION;

-- STEP B
START TRANSACTION;

-- STEP A
-- CAPTURE output-10
SELECT account_no, balance FROM Accounts WHERE account_no = 102;

-- STEP B
UPDATE Accounts SET balance = balance + 5000.00 WHERE account_no = 102;

-- STEP B
COMMIT;

-- STEP A
-- CAPTURE output-11
SELECT account_no, balance FROM Accounts WHERE account_no = 102;

-- STEP A
COMMIT;

-- STEP A
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- STEP A
START TRANSACTION;

-- STEP A
-- CAPTURE output-12
SELECT COUNT(*) AS accounts_at_least_50000 FROM Accounts WHERE balance >= 50000.00;

-- STEP B
START TRANSACTION;

-- STEP B
INSERT INTO Accounts (account_no, holder_name, account_type, balance)
VALUES (104, 'Ananya Sen', 'Savings', 60000.00);

-- STEP B
COMMIT;

-- STEP A
-- CAPTURE output-13
SELECT COUNT(*) AS accounts_at_least_50000 FROM Accounts WHERE balance >= 50000.00;

-- STEP A
COMMIT;
