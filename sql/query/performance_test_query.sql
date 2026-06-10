CREATE TABLE test_perf_device (
    device_id INT PRIMARY KEY AUTO_INCREMENT,
    device_name VARCHAR(50) NOT NULL
);

CREATE TABLE test_perf_monitoring (
    monitor_id INT PRIMARY KEY AUTO_INCREMENT,
    device_id INT NOT NULL,
    soc DECIMAL(5,2),
    power_output DECIMAL(10,2),
    voltage DECIMAL(10,2),
    current_a DECIMAL(10,2),
    record_time DATETIME NOT NULL,
    INDEX idx_test_device_time (device_id, record_time)
);

INSERT INTO test_perf_device (device_name)
WITH RECURSIVE device_seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM device_seq
    WHERE n < 100
)
SELECT CONCAT('TEST_ESS_', n)
FROM device_seq;

INSERT INTO test_perf_monitoring (
    device_id,
    soc,
    power_output,
    voltage,
    current_a,
    record_time
)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM seq
    WHERE n < 1000
)
SELECT
    d.device_id,
    ROUND(20 + RAND() * 80, 2),
    ROUND(1 + RAND() * 50, 2),
    ROUND(210 + RAND() * 30, 2),
    ROUND(5 + RAND() * 20, 2),
    DATE_ADD('2026-06-01 00:00:00', INTERVAL s.n MINUTE)
FROM test_perf_device d
CROSS JOIN seq s;

SELECT VERSION();

SELECT COUNT(*) FROM test_perf_monitoring;


EXPLAIN ANALYZE
SELECT
    m1.device_id,
    m1.soc,
    m1.power_output,
    m1.voltage,
    m1.current_a,
    m1.record_time
FROM test_perf_monitoring m1
JOIN (
    SELECT
        device_id,
        MAX(record_time) AS max_record_time
    FROM test_perf_monitoring
    GROUP BY device_id
) m2
ON m1.device_id = m2.device_id
AND m1.record_time = m2.max_record_time;


EXPLAIN ANALYZE
SELECT
    t.device_id,
    t.soc,
    t.power_output,
    t.voltage,
    t.current_a,
    t.record_time
FROM (
    SELECT
        m.device_id,
        m.soc,
        m.power_output,
        m.voltage,
        m.current_a,
        m.record_time,
        ROW_NUMBER() OVER (
            PARTITION BY m.device_id
            ORDER BY m.record_time DESC
        ) AS rn
    FROM test_perf_monitoring m
) t
WHERE t.rn = 1;