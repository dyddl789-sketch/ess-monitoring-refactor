DROP PROCEDURE IF EXISTS seed_busan_demo_data;

DELIMITER $$

CREATE PROCEDURE seed_busan_demo_data()
BEGIN
    DECLARE v_member_id INT;
    DECLARE v_group_id INT;
    DECLARE v_device_id INT;
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_day INT DEFAULT 0;
    DECLARE v_month_day DATE;
    DECLARE v_time DATETIME;
    DECLARE v_end_time DATETIME;
    DECLARE v_soc DECIMAL(5,2);
    DECLARE v_capacity DECIMAL(10,2);

    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE ess_control_log;
    TRUNCATE TABLE weather_data;
    TRUNCATE TABLE ess_alert;
    TRUNCATE TABLE energy_log;
    TRUNCATE TABLE monitoring;
    TRUNCATE TABLE ess_device;
    TRUNCATE TABLE ess_device_group;

    SET FOREIGN_KEY_CHECKS = 1;

    SELECT member_id
    INTO v_member_id
    FROM ess_member
    WHERE member_userid = 'company'
    LIMIT 1;

    INSERT INTO ess_device_group (
        member_id,
        group_name,
        description
    )
    VALUES (
        v_member_id,
        '부산 그룹',
        '포트폴리오 시연용 부산 ESS 그룹'
    );

    SET v_group_id = LAST_INSERT_ID();

    WHILE v_i <= 5 DO

        SET v_capacity = 80 + (v_i * 20);

        INSERT INTO ess_device (
            member_id,
            group_id,
            device_name,
            location,
            capacity_kw,
            device_type,
            status,
            install_date,
            latitude,
            longitude,
            nx,
            ny,
            is_main,
            ess_capacity_kwh,
            current_charge_kwh,
            charge_efficiency,
            discharge_efficiency,
            electricity_rate,
            deleted_yn,
            deleted_at
        )
        VALUES (
            v_member_id,
            v_group_id,
            CONCAT('부산기기', v_i),
            '부산광역시 해운대구',
            v_capacity,
            'HYBRID',
            'NORMAL',
            DATE_SUB(CURDATE(), INTERVAL 180 DAY),
            35.1796000,
            129.0756000,
            98,
            76,
            IF(v_i = 1, 'Y', 'N'),
            v_capacity * 2,
            v_capacity * 1.5,
            90.00,
            90.00,
            150.00,
            'N',
            NULL
        );

        SET v_device_id = LAST_INSERT_ID();

        /* 6개월치 energy_log 생성 */
        SET v_day = 179;

        WHILE v_day >= 0 DO

            SET v_month_day = DATE_SUB(CURDATE(), INTERVAL v_day DAY);

            INSERT INTO energy_log (
                device_id,
                daily_kwh,
                cost,
                efficiency,
                log_date
            )
            VALUES (
                v_device_id,
                ROUND(v_capacity * (2.4 + (RAND() * 1.2)), 2),
                ROUND(v_capacity * (2.4 + (RAND() * 1.2)) * 150, 2),
                ROUND(78 + (RAND() * 12), 2),
                v_month_day
            );

            SET v_day = v_day - 1;

        END WHILE;

        /* 20일치 monitoring 생성 */
        SET v_day = 19;

        WHILE v_day >= 0 DO

            SET v_time = TIMESTAMP(
                DATE_SUB(CURDATE(), INTERVAL v_day DAY),
                '08:00:00'
            );

            /*
             * 과거 날짜는 18:00까지 생성
             * 오늘 날짜는 현재 시간 1분 전까지만 생성
             */
            IF v_day = 0 THEN
                SET v_end_time = DATE_SUB(NOW(), INTERVAL 1 MINUTE);
            ELSE
                SET v_end_time = TIMESTAMP(
                    DATE_SUB(CURDATE(), INTERVAL v_day DAY),
                    '18:00:00'
                );
            END IF;

            SET v_soc = 82 - (v_i * 2);

            WHILE v_time <= v_end_time DO

                INSERT INTO monitoring (
                    device_id,
                    voltage,
                    current_a,
                    soc,
                    power_output,
                    solar_generation_kwh,
                    charged_energy_kwh,
                    used_energy_kwh,
                    saved_cost,
                    record_time
                )
                VALUES (
                    v_device_id,
                    ROUND(220 + (RAND() * 10), 2),
                    ROUND(20 + (RAND() * 8), 2),
                    ROUND(v_soc, 2),
                    ROUND(v_capacity * (0.45 + RAND() * 0.25), 2),
                    ROUND(v_capacity * (0.20 + RAND() * 0.12), 2),
                    ROUND(v_capacity * (0.08 + RAND() * 0.05), 2),
                    ROUND(v_capacity * (0.10 + RAND() * 0.06), 2),
                    ROUND(v_capacity * (0.20 + RAND() * 0.12) * 150, 2),
                    v_time
                );

                SET v_soc = v_soc - (RAND() * 0.45);

                /*
                 * 과거 날짜는 1시간 단위
                 * 오늘 날짜는 스케줄러와 자연스럽게 이어지도록 10분 단위
                 */
                IF v_day = 0 THEN
                    SET v_time = DATE_ADD(v_time, INTERVAL 10 MINUTE);
                ELSE
                    SET v_time = DATE_ADD(v_time, INTERVAL 1 HOUR);
                END IF;

            END WHILE;

            SET v_day = v_day - 1;

        END WHILE;

        /*
         * 장비 현재 상태는 오늘 마지막 SOC 기준과 유사하게 설정
         */
        UPDATE ess_device
        SET current_charge_kwh = ess_capacity_kwh * (v_soc / 100),
            status = 'NORMAL'
        WHERE device_id = v_device_id;

        SET v_i = v_i + 1;

    END WHILE;

END $$

DELIMITER ;

CALL seed_busan_demo_data();