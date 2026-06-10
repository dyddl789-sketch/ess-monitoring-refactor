/*
 * 시연용 부산 ESS 더미데이터 생성 SQL
 * 실행 위치: sql/data/seed_busan_demo_data.sql
 * 실행 전제: sql/schema/create_tables.sql 실행 완료
 *
 * 생성 데이터
 * - 시연용 회원(company/admin)
 * - 부산 ESS 그룹 2개
 * - ESS 장비 8대
 * - 최근 6개월 energy_log
 * - 최근 6개월 monitoring 이력
 * - 오늘 데이터는 현재 시각 직전까지만 생성
 * - 최근 7일 weather_data
 * - 알림 / 게시판 / 댓글 일부
 *
 * 목적
 * - 프로시저를 활용해 시연용 더미데이터 자동 생성
 * - 과거 데이터와 현재 시각 데이터가 자연스럽게 이어지도록 구성
 * - 이후 실시간 데이터는 Spring Scheduler가 계속 생성
 */

DROP PROCEDURE IF EXISTS seed_busan_demo_data;

DELIMITER $$

CREATE PROCEDURE seed_busan_demo_data()
BEGIN
    DECLARE v_company_id INT DEFAULT NULL;
    DECLARE v_admin_id INT DEFAULT NULL;
    DECLARE v_group_main_id INT DEFAULT NULL;
    DECLARE v_group_sub_id INT DEFAULT NULL;
    DECLARE v_device_id INT DEFAULT NULL;

    DECLARE v_i INT DEFAULT 1;
    DECLARE v_day INT DEFAULT 0;
    DECLARE v_hour INT DEFAULT 0;

    DECLARE v_date DATE;
    DECLARE v_time DATETIME;
    DECLARE v_end_time DATETIME;
    DECLARE v_step_min INT DEFAULT 60;

    DECLARE v_capacity_kw DECIMAL(10,2);
    DECLARE v_ess_capacity DECIMAL(10,2);
    DECLARE v_rate DECIMAL(10,2);

    DECLARE v_soc DECIMAL(5,2);
    DECLARE v_charge_kwh DECIMAL(10,2);
    DECLARE v_power_output DECIMAL(10,2);
    DECLARE v_generated DECIMAL(10,2);
    DECLARE v_charged DECIMAL(10,2);
    DECLARE v_used DECIMAL(10,2);
    DECLARE v_saved_cost DECIMAL(12,2);
    DECLARE v_efficiency DECIMAL(5,2);
    DECLARE v_solar_factor DECIMAL(6,3);
    DECLARE v_status VARCHAR(20);
    DECLARE v_daily_kwh DECIMAL(10,2);

    SET FOREIGN_KEY_CHECKS = 0;

    TRUNCATE TABLE board_comment;
    TRUNCATE TABLE ess_control_log;
    TRUNCATE TABLE weather_data;
    TRUNCATE TABLE ess_alert;
    TRUNCATE TABLE energy_log;
    TRUNCATE TABLE monitoring;
    TRUNCATE TABLE ess_device;
    TRUNCATE TABLE ess_device_group;
    TRUNCATE TABLE board;

    SET FOREIGN_KEY_CHECKS = 1;

    /* 회원 데이터 */
    INSERT INTO ess_member (
        member_name,
        member_userid,
        member_pw,
        user_type,
        role,
        phone,
        email,
        address
    ) VALUES (
        '에너지코리아',
        'company',
        '1234',
        'COMPANY',
        'USER',
        '010-1111-2222',
        'company@test.com',
        '부산광역시 해운대구'
    )
    ON DUPLICATE KEY UPDATE
        member_name = VALUES(member_name),
        member_pw = VALUES(member_pw),
        user_type = VALUES(user_type),
        role = VALUES(role),
        phone = VALUES(phone),
        address = VALUES(address);

    INSERT INTO ess_member (
        member_name,
        member_userid,
        member_pw,
        user_type,
        role,
        phone,
        email,
        address
    ) VALUES (
        '관리자',
        'admin',
        '1234',
        NULL,
        'ADMIN',
        '010-9999-0000',
        'admin@test.com',
        '부산광역시 부산진구'
    )
    ON DUPLICATE KEY UPDATE
        member_name = VALUES(member_name),
        member_pw = VALUES(member_pw),
        role = VALUES(role),
        phone = VALUES(phone),
        address = VALUES(address);

    SELECT member_id
    INTO v_company_id
    FROM ess_member
    WHERE member_userid = 'company'
    LIMIT 1;

    SELECT member_id
    INTO v_admin_id
    FROM ess_member
    WHERE member_userid = 'admin'
    LIMIT 1;

    /* 장비 그룹 */
    INSERT INTO ess_device_group (
        member_id,
        group_name,
        description
    ) VALUES
        (
            v_company_id,
            '부산 해운대 ESS 그룹',
            '대시보드 시연용 부산 해운대 ESS 그룹'
        ),
        (
            v_company_id,
            '부산 강서 ESS 그룹',
            '성능 비교 및 필터 시연용 부산 강서 ESS 그룹'
        );

    SELECT group_id
    INTO v_group_main_id
    FROM ess_device_group
    WHERE member_id = v_company_id
      AND group_name = '부산 해운대 ESS 그룹'
    LIMIT 1;

    SELECT group_id
    INTO v_group_sub_id
    FROM ess_device_group
    WHERE member_id = v_company_id
      AND group_name = '부산 강서 ESS 그룹'
    LIMIT 1;

    /*
     * ESS 장비 8대 생성
     */
    SET v_i = 1;

    WHILE v_i <= 8 DO

        SET v_capacity_kw = 70 + (v_i * 15);
        SET v_ess_capacity = v_capacity_kw * 2.2;
        SET v_rate = 145 + (v_i * 2);

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
        ) VALUES (
            v_company_id,
            IF(v_i <= 5, v_group_main_id, v_group_sub_id),
            CONCAT('부산 ESS-', LPAD(v_i, 2, '0')),
            CASE
                WHEN v_i <= 3 THEN '부산광역시 해운대구'
                WHEN v_i <= 5 THEN '부산광역시 수영구'
                ELSE '부산광역시 강서구'
            END,
            v_capacity_kw,
            'HYBRID',
            'NORMAL',
            DATE_SUB(CURDATE(), INTERVAL (210 + v_i) DAY),
            CASE
                WHEN v_i <= 3 THEN 35.1796000
                WHEN v_i <= 5 THEN 35.1595000
                ELSE 35.2122000
            END,
            CASE
                WHEN v_i <= 3 THEN 129.0756000
                WHEN v_i <= 5 THEN 129.1132000
                ELSE 128.9806000
            END,
            98,
            76,
            IF(v_i = 1, 'Y', 'N'),
            v_ess_capacity,
            ROUND(v_ess_capacity * (0.55 + RAND() * 0.25), 2),
            ROUND(88 + RAND() * 6, 2),
            ROUND(87 + RAND() * 7, 2),
            v_rate,
            'N',
            NULL
        );

        SET v_device_id = LAST_INSERT_ID();

        /*
         * 최근 7일 weather_data 생성
         * 기상청 API 수집 결과와 유사한 시연용 데이터
         */
        SET v_day = 6;

        WHILE v_day >= 0 DO
            SET v_date = DATE_SUB(CURDATE(), INTERVAL v_day DAY);
            SET v_hour = 6;

            WHILE v_hour <= 18 DO

                INSERT INTO weather_data (
                    device_id,
                    base_date,
                    base_time,
                    fcst_date,
                    fcst_time,
                    sky_status,
                    rain_type,
                    rain_prob,
                    temperature,
                    humidity,
                    wind_speed,
                    solar_radiation,
                    sunrise,
                    sunset,
                    ess_status
                ) VALUES (
                    v_device_id,
                    DATE_FORMAT(v_date, '%Y%m%d'),
                    '0500',
                    DATE_FORMAT(v_date, '%Y%m%d'),
                    CONCAT(LPAD(v_hour, 2, '0'), '00'),
                    CASE
                        WHEN v_hour BETWEEN 10 AND 15 THEN '맑음'
                        WHEN v_hour BETWEEN 8 AND 17 THEN '구름많음'
                        ELSE '흐림'
                    END,
                    '없음',
                    CASE
                        WHEN v_hour BETWEEN 10 AND 15 THEN 10 + FLOOR(RAND() * 15)
                        ELSE 25 + FLOOR(RAND() * 25)
                    END,
                    ROUND(19 + RAND() * 11, 2),
                    45 + FLOOR(RAND() * 35),
                    ROUND(1.2 + RAND() * 4.0, 2),
                    CASE
                        WHEN v_hour < 7 OR v_hour > 18 THEN 0
                        WHEN v_hour BETWEEN 10 AND 14 THEN ROUND(700 + RAND() * 180, 2)
                        WHEN v_hour BETWEEN 8 AND 16 THEN ROUND(380 + RAND() * 220, 2)
                        ELSE ROUND(120 + RAND() * 130, 2)
                    END,
                    '0510',
                    '1935',
                    CASE
                        WHEN v_hour BETWEEN 10 AND 15 THEN '발전 양호'
                        ELSE '발전 보통'
                    END
                )
                ON DUPLICATE KEY UPDATE
                    sky_status = VALUES(sky_status),
                    rain_type = VALUES(rain_type),
                    rain_prob = VALUES(rain_prob),
                    temperature = VALUES(temperature),
                    humidity = VALUES(humidity),
                    wind_speed = VALUES(wind_speed),
                    solar_radiation = VALUES(solar_radiation),
                    sunrise = VALUES(sunrise),
                    sunset = VALUES(sunset),
                    ess_status = VALUES(ess_status);

                SET v_hour = v_hour + 1;

            END WHILE;

            SET v_day = v_day - 1;

        END WHILE;

        /*
         * 최근 6개월 energy_log + monitoring 생성
         *
         * 과거 날짜:
         * - 06:00 ~ 20:00
         * - 1시간 단위
         *
         * 오늘 날짜:
         * - 06:00 ~ 현재 시간 1분 전
         * - 10분 단위
         * - 이후 데이터는 Spring Scheduler가 생성
         */
        SET v_day = 179;

        WHILE v_day >= 0 DO

            SET v_date = DATE_SUB(CURDATE(), INTERVAL v_day DAY);
            SET v_daily_kwh = 0;
            SET v_soc = 68 + (RAND() * 18) - (v_i * 0.7);

            IF v_day = 0 THEN
                SET v_time = TIMESTAMP(v_date, '06:00:00');
                SET v_end_time = DATE_SUB(NOW(), INTERVAL 1 MINUTE);
                SET v_step_min = 10;
            ELSE
                SET v_time = TIMESTAMP(v_date, '06:00:00');
                SET v_end_time = TIMESTAMP(v_date, '20:00:00');
                SET v_step_min = 60;
            END IF;

            WHILE v_time <= v_end_time DO

                SET v_hour = HOUR(v_time);

                SET v_solar_factor = CASE
                    WHEN v_hour < 7 OR v_hour >= 19 THEN 0.03
                    WHEN v_hour < 9 THEN 0.22 + RAND() * 0.10
                    WHEN v_hour < 12 THEN 0.58 + RAND() * 0.18
                    WHEN v_hour < 15 THEN 0.82 + RAND() * 0.20
                    WHEN v_hour < 17 THEN 0.50 + RAND() * 0.18
                    ELSE 0.20 + RAND() * 0.12
                END;

                SET v_power_output =
                    ROUND(v_capacity_kw * v_solar_factor * (0.85 + RAND() * 0.25), 2);

                SET v_generated =
                    ROUND(v_power_output * (0.35 + RAND() * 0.15), 2);

                SET v_used =
                    ROUND(v_capacity_kw * (0.05 + RAND() * 0.08), 2);

                SET v_charged =
                    ROUND(
                        GREATEST(v_generated - (v_used * 0.55), 0)
                        * (0.70 + RAND() * 0.20),
                        2
                    );

                SET v_charge_kwh =
                    LEAST(
                        v_ess_capacity,
                        GREATEST(
                            0,
                            (v_ess_capacity * v_soc / 100)
                            + v_charged
                            - (v_used * 0.55)
                        )
                    );

                SET v_soc = ROUND((v_charge_kwh / v_ess_capacity) * 100, 2);

                SET v_saved_cost = ROUND(v_generated * v_rate, 2);

                SET v_daily_kwh = v_daily_kwh + v_generated;

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
                ) VALUES (
                    v_device_id,
                    ROUND(360 + RAND() * 30, 2),
                    ROUND(
                        IF(
                            v_power_output > 0,
                            (v_power_output * 1000) / (360 + RAND() * 30),
                            0
                        ),
                        2
                    ),
                    v_soc,
                    v_power_output,
                    v_generated,
                    v_charged,
                    v_used,
                    v_saved_cost,
                    v_time
                );

                SET v_time = DATE_ADD(v_time, INTERVAL v_step_min MINUTE);

            END WHILE;

            SET v_efficiency = ROUND(76 + RAND() * 16, 2);

            INSERT INTO energy_log (
                device_id,
                daily_kwh,
                monthly_kwh,
                cost,
                efficiency,
                log_date
            ) VALUES (
                v_device_id,
                ROUND(v_daily_kwh, 2),
                ROUND(v_daily_kwh, 2),
                ROUND(v_daily_kwh * v_rate, 2),
                v_efficiency,
                v_date
            )
            ON DUPLICATE KEY UPDATE
                daily_kwh = VALUES(daily_kwh),
                monthly_kwh = VALUES(monthly_kwh),
                cost = VALUES(cost),
                efficiency = VALUES(efficiency);

            SET v_day = v_day - 1;

        END WHILE;

        /*
         * 장비 현재 상태 갱신
         */
        SET v_status = CASE
            WHEN v_soc <= 10 THEN 'ERROR'
            WHEN v_soc <= 25 THEN 'WARNING'
            ELSE 'NORMAL'
        END;

        UPDATE ess_device
        SET current_charge_kwh = ROUND(v_ess_capacity * (v_soc / 100), 2),
            status = v_status
        WHERE device_id = v_device_id;

        SET v_i = v_i + 1;

    END WHILE;

    /*
     * 시연용 알림 데이터
     */
    INSERT INTO ess_alert (
        device_id,
        alert_type,
        alert_level,
        message,
        status,
        control_action,
        created_at
    )
    SELECT
        device_id,
        'SOC_WARNING',
        'WARNING',
        CONCAT(device_name, ' 배터리 충전량이 낮습니다.'),
        'OPEN',
        'MONITORING_CHECK',
        DATE_SUB(NOW(), INTERVAL FLOOR(10 + RAND() * 240) MINUTE)
    FROM ess_device
    WHERE member_id = v_company_id
      AND device_id MOD 3 = 0;

    INSERT INTO ess_alert (
        device_id,
        alert_type,
        alert_level,
        message,
        status,
        control_action,
        created_at
    )
    SELECT
        device_id,
        'POWER_LOW',
        'INFO',
        CONCAT(device_name, ' 발전 출력이 일시적으로 낮습니다.'),
        'CLOSED',
        'AUTO_LOG',
        DATE_SUB(NOW(), INTERVAL FLOOR(300 + RAND() * 1800) MINUTE)
    FROM ess_device
    WHERE member_id = v_company_id
      AND device_id MOD 2 = 0;

    /*
     * 게시판 / 댓글 시연 데이터
     */
    INSERT INTO board (
        member_id,
        board_title,
        board_hit,
        board_content,
        created_at,
        board_type
    ) VALUES
        (
            v_company_id,
            'ESS 모니터링 시연 데이터 안내',
            42,
            '부산 ESS 그룹의 시연 데이터가 등록되었습니다.',
            DATE_SUB(NOW(), INTERVAL 5 DAY),
            'NOTICE'
        ),
        (
            v_company_id,
            '부산 ESS-01 장비 점검 문의',
            18,
            '부산 ESS-01 장비의 SOC 변동폭 확인 요청드립니다.',
            DATE_SUB(NOW(), INTERVAL 3 DAY),
            'QNA'
        ),
        (
            v_company_id,
            '대시보드 월간 통계 확인',
            25,
            '월간 발전량과 절감 금액 통계 확인용 게시글입니다.',
            DATE_SUB(NOW(), INTERVAL 1 DAY),
            'GENERAL'
        );

    INSERT INTO board_comment (
        board_no,
        member_id,
        comment_content,
        created_at
    )
    SELECT
        board_no,
        v_admin_id,
        '확인 후 점검 내용을 안내드리겠습니다.',
        DATE_SUB(NOW(), INTERVAL 2 DAY)
    FROM board
    WHERE board_title = '부산 ESS-01 장비 점검 문의'
    LIMIT 1;

END $$

DELIMITER ;

CALL seed_busan_demo_data();

/*
 * 실행 확인용
 */
SELECT 'ess_device' AS table_name, COUNT(*) AS row_count FROM ess_device
UNION ALL
SELECT 'monitoring', COUNT(*) FROM monitoring
UNION ALL
SELECT 'energy_log', COUNT(*) FROM energy_log
UNION ALL
SELECT 'weather_data', COUNT(*) FROM weather_data
UNION ALL
SELECT 'ess_alert', COUNT(*) FROM ess_alert
UNION ALL
SELECT 'board', COUNT(*) FROM board;