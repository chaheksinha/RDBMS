-- Experiment 9
-- Build 5000 railway bookings, then compare EXPLAIN
-- before and after a single-column index and a composite index.

DROP DATABASE IF EXISTS RailwayDB;
CREATE DATABASE RailwayDB;
USE RailwayDB;

CREATE TABLE Railway_Bookings (
    booking_id       INT AUTO_INCREMENT PRIMARY KEY,
    pnr_no           VARCHAR(12) NOT NULL,
    train_no         INT NOT NULL,
    train_name       VARCHAR(100) NOT NULL,
    passenger_name   VARCHAR(100) NOT NULL,
    age              INT,
    gender           CHAR(1),
    travel_date      DATE NOT NULL,
    source_station   VARCHAR(50) NOT NULL,
    dest_station     VARCHAR(50) NOT NULL,
    coach_class      VARCHAR(10) NOT NULL,
    fare             DECIMAL(8,2) NOT NULL,
    booking_status   VARCHAR(15) NOT NULL,
    booking_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS PopulateBookings;

DELIMITER //

CREATE PROCEDURE PopulateBookings(IN total_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE rand_pnr VARCHAR(12);
    DECLARE rand_train INT;
    DECLARE rand_class VARCHAR(10);
    DECLARE rand_status VARCHAR(15);
    DECLARE rand_date DATE;

    SET autocommit = 0;

    WHILE i <= total_rows DO
        SET rand_pnr = LPAD(FLOOR(1000000000 + (RAND() * 9000000000)), 10, '0');
        SET rand_train = 12000 + FLOOR(RAND() * 50);
        SET rand_class = ELT(FLOOR(1 + (RAND() * 5)), '1A', '2A', '3A', 'SL', 'CC');
        SET rand_status = ELT(FLOOR(1 + (RAND() * 3)), 'CONFIRMED', 'RAC', 'WAITLIST');
        SET rand_date = DATE_ADD('2026-06-01', INTERVAL FLOOR(RAND() * 90) DAY);

        INSERT INTO Railway_Bookings (
            pnr_no, train_no, train_name, passenger_name, age, gender,
            travel_date, source_station, dest_station, coach_class, fare, booking_status
        ) VALUES (
            rand_pnr,
            rand_train,
            CONCAT('Express-', rand_train),
            CONCAT('Passenger_', i),
            18 + FLOOR(RAND() * 60),
            IF(RAND() > 0.5, 'M', 'F'),
            rand_date,
            ELT(FLOOR(1 + (RAND() * 4)), 'New Delhi', 'Mumbai CST', 'Howrah', 'Chennai Central'),
            ELT(FLOOR(1 + (RAND() * 4)), 'Bangalore City', 'Ahmedabad', 'Pune', 'Secunderabad'),
            rand_class,
            500.00 + (RAND() * 2500.00),
            rand_status
        );

        SET i = i + 1;
    END WHILE;

    COMMIT;
    SET autocommit = 1;
END //

DELIMITER ;

CALL PopulateBookings(5000);

-- One known PNR and one known train/date/status so the later
-- lookups hit rows that exist. Random rows alone can miss.
INSERT INTO Railway_Bookings (
    pnr_no, train_no, train_name, passenger_name, age, gender,
    travel_date, source_station, dest_station, coach_class, fare, booking_status
) VALUES
('4829104821', 12015, 'Express-12015', 'Meera Iyer', 29, 'F',
 '2026-07-15', 'New Delhi', 'Pune', '3A', 1450.00, 'CONFIRMED'),
('4829104822', 12015, 'Express-12015', 'Kabir Das', 41, 'M',
 '2026-07-15', 'Howrah', 'Ahmedabad', 'SL', 980.00, 'CONFIRMED'),
('4829104823', 12015, 'Express-12015', 'Sara Khan', 22, 'F',
 '2026-07-15', 'Mumbai CST', 'Secunderabad', '2A', 2100.00, 'CONFIRMED');

-- CAPTURE output-01
SELECT COUNT(*) AS total_bookings FROM Railway_Bookings;

-- =====================================================
-- 1. SINGLE-COLUMN LOOKUP ON pnr_no
-- =====================================================

-- CAPTURE output-02
EXPLAIN SELECT * FROM Railway_Bookings WHERE pnr_no = '4829104821';

CREATE INDEX idx_pnr ON Railway_Bookings (pnr_no);

-- CAPTURE output-03
EXPLAIN SELECT * FROM Railway_Bookings WHERE pnr_no = '4829104821';

-- CAPTURE output-04
SELECT booking_id, pnr_no, train_no, passenger_name, booking_status
FROM Railway_Bookings
WHERE pnr_no = '4829104821';

-- =====================================================
-- 2. COMPOSITE INDEX ON train_no, travel_date, booking_status
-- =====================================================

-- CAPTURE output-05
EXPLAIN SELECT passenger_name, coach_class, fare
FROM Railway_Bookings
WHERE train_no = 12015
  AND travel_date = '2026-07-15'
  AND booking_status = 'CONFIRMED';

CREATE INDEX idx_train_date_status
ON Railway_Bookings (train_no, travel_date, booking_status);

-- CAPTURE output-06
EXPLAIN SELECT passenger_name, coach_class, fare
FROM Railway_Bookings
WHERE train_no = 12015
  AND travel_date = '2026-07-15'
  AND booking_status = 'CONFIRMED';

-- CAPTURE output-07
SELECT passenger_name, coach_class, fare
FROM Railway_Bookings
WHERE train_no = 12015
  AND travel_date = '2026-07-15'
  AND booking_status = 'CONFIRMED'
ORDER BY passenger_name;

-- CAPTURE output-08
SHOW INDEX FROM Railway_Bookings;
