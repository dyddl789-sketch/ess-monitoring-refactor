SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS board_comment;
DROP TABLE IF EXISTS ess_control_log;
DROP TABLE IF EXISTS weather_data;
DROP TABLE IF EXISTS board;
DROP TABLE IF EXISTS ess_alert;
DROP TABLE IF EXISTS energy_log;
DROP TABLE IF EXISTS monitoring;
DROP TABLE IF EXISTS ess_device;
DROP TABLE IF EXISTS ess_device_group;
DROP TABLE IF EXISTS ess_member;

SET FOREIGN_KEY_CHECKS = 1;


CREATE TABLE ess_member (
  member_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '회원 고유 번호',

  member_name VARCHAR(30) NOT NULL COMMENT '회원 실명 또는 회사 담당자 이름',

  member_userid VARCHAR(30) NOT NULL UNIQUE COMMENT '로그인용 아이디',

  member_pw VARCHAR(100) NOT NULL COMMENT '암호화된 비밀번호',

  user_type VARCHAR(20) NULL COMMENT '회원 유형 (PERSONAL, COMPANY / 관리자는 NULL 가능)',

  role VARCHAR(20) NOT NULL DEFAULT 'USER' COMMENT '권한 역할 (USER, ADMIN)',

  phone VARCHAR(20) COMMENT '연락처',

  email VARCHAR(50) UNIQUE COMMENT '이메일',

  address VARCHAR(100) COMMENT '주소',

  join_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '회원 가입 시점',

  CONSTRAINT chk_user_type
    CHECK (user_type IN ('PERSONAL', 'COMPANY') OR user_type IS NULL),

  CONSTRAINT chk_member_role
    CHECK (role IN ('USER', 'ADMIN'))
) COMMENT='ESS 모니터링 웹서비스 회원 정보';


CREATE TABLE ess_device_group (
  group_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '장비 그룹 고유 ID',

  member_id INT NOT NULL COMMENT '그룹 생성 회원 ID',

  group_name VARCHAR(50) NOT NULL COMMENT '그룹 이름',

  description VARCHAR(200) COMMENT '그룹 설명',

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '그룹 생성 시간',

  CONSTRAINT fk_group_member
    FOREIGN KEY (member_id) REFERENCES ess_member(member_id)
    ON DELETE CASCADE,

  CONSTRAINT uq_group_member_name
    UNIQUE (member_id, group_name)
) COMMENT='기업용 ESS 장비 그룹';


CREATE TABLE ess_device (
  device_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '장비 고유 ID',

  member_id INT NOT NULL COMMENT '장비 소유 회원',

  group_id INT COMMENT '소속 그룹 ID',

  device_name VARCHAR(50) NOT NULL COMMENT '시스템 이름',

  location VARCHAR(100) COMMENT '설치 위치',

  capacity_kw DECIMAL(10,2) NOT NULL COMMENT '태양광 설비 용량(kW)',

  device_type VARCHAR(20) NOT NULL DEFAULT 'HYBRID' COMMENT '시스템 유형',

  status VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '현재 상태',

  install_date DATE COMMENT '설치 날짜',

  latitude DECIMAL(10,7) COMMENT '위도',

  longitude DECIMAL(10,7) COMMENT '경도',

  nx INT COMMENT '기상청 격자 X좌표',

  ny INT COMMENT '기상청 격자 Y좌표',

  is_main CHAR(1) DEFAULT 'N' COMMENT '대표 디바이스 여부',

  ess_capacity_kwh DECIMAL(10,2) NOT NULL COMMENT 'ESS 저장 용량(kWh)',

  current_charge_kwh DECIMAL(10,2) DEFAULT NULL COMMENT '현재 충전량(kWh, 미측정 시 NULL)',

  charge_efficiency DECIMAL(5,2) DEFAULT 90.00 COMMENT '충전 효율(%)',

  discharge_efficiency DECIMAL(5,2) DEFAULT 90.00 COMMENT '방전 효율(%)',

  electricity_rate DECIMAL(10,2) DEFAULT 150.00 COMMENT '전기요금 단가(원/kWh)',

  CONSTRAINT fk_device_member
    FOREIGN KEY (member_id) REFERENCES ess_member(member_id)
    ON DELETE CASCADE,

  CONSTRAINT fk_device_group
    FOREIGN KEY (group_id) REFERENCES ess_device_group(group_id)
    ON DELETE SET NULL,

  CONSTRAINT chk_is_main
    CHECK (is_main IN ('Y', 'N')),

  CONSTRAINT chk_device_status
    CHECK (status IN ('NORMAL', 'WARNING', 'ERROR', 'OFFLINE'))
) COMMENT='태양광+ESS 하이브리드 시스템 정보';


CREATE TABLE monitoring (
  monitor_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '모니터링 데이터 고유 ID',

  device_id INT NOT NULL COMMENT '데이터를 생성한 장비 ID',

  voltage DECIMAL(10,2) COMMENT '전압(V)',

  current_a DECIMAL(10,2) COMMENT '전류(A)',

  soc DECIMAL(5,2) NOT NULL COMMENT '배터리 충전 상태(%)',

  power_output DECIMAL(10,2) COMMENT '예상 출력/발전 전력(kW)',

  solar_generation_kwh DECIMAL(10,2) DEFAULT 0 COMMENT '예상 태양광 발전량(kWh)',

  charged_energy_kwh DECIMAL(10,2) DEFAULT 0 COMMENT 'ESS 충전량(kWh)',

  used_energy_kwh DECIMAL(10,2) DEFAULT 0 COMMENT '사용 전력량(kWh)',

  saved_cost DECIMAL(12,2) DEFAULT 0 COMMENT '예상 절감 금액(원)',

  record_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '데이터 측정 시각',

  CONSTRAINT fk_monitoring_device
    FOREIGN KEY (device_id) REFERENCES ess_device(device_id)
    ON DELETE CASCADE,

  CONSTRAINT chk_soc_range
    CHECK (soc BETWEEN 0 AND 100),

  INDEX idx_monitoring_device_time (device_id, record_time)
) COMMENT='ESS 시뮬레이션 모니터링 데이터';


CREATE TABLE energy_log (
  log_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '에너지 로그 ID',

  device_id INT NOT NULL COMMENT '해당 장비',

  daily_kwh DECIMAL(10,2) COMMENT '일일 발전/충전량(kWh)',

  monthly_kwh DECIMAL(10,2) COMMENT '월간 발전/충전량(kWh)',

  cost DECIMAL(12,2) COMMENT '절감 금액',

  efficiency DECIMAL(5,2) DEFAULT 80 COMMENT '운영 효율(%)',

  log_date DATE NOT NULL COMMENT '기록 날짜',

  CONSTRAINT fk_energylog_device
    FOREIGN KEY (device_id) REFERENCES ess_device(device_id)
    ON DELETE CASCADE,

  UNIQUE KEY uq_energy_log_device_date (device_id, log_date),

  INDEX idx_energylog_date (log_date)
) COMMENT='일/월 단위 에너지 통계 로그';


CREATE TABLE ess_alert (
  alert_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '알림 ID',

  device_id INT NOT NULL COMMENT '문제가 발생한 장비',

  alert_type VARCHAR(30) NOT NULL COMMENT '알림 유형',

  alert_level VARCHAR(20) NOT NULL COMMENT '위험 수준',

  message VARCHAR(200) NOT NULL COMMENT '사용자에게 보여줄 메시지',

  status VARCHAR(20) NOT NULL COMMENT '처리 상태',

  control_action VARCHAR(30) COMMENT '자동 제어 수행 내용',

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '알림 발생 시각',

  CONSTRAINT fk_alert_device
    FOREIGN KEY (device_id) REFERENCES ess_device(device_id)
    ON DELETE CASCADE,

  CONSTRAINT chk_alert_level
    CHECK (alert_level IN ('INFO', 'WARNING', 'CRITICAL'))
) COMMENT='알림 정보';


CREATE TABLE board (
  board_no INT PRIMARY KEY AUTO_INCREMENT COMMENT '게시글 번호',

  member_id INT NOT NULL COMMENT '작성자',

  board_title VARCHAR(100) NOT NULL COMMENT '게시글 제목',

  board_hit INT DEFAULT 0 COMMENT '조회수',

  board_content TEXT NOT NULL COMMENT '게시글 내용',

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '작성일',

  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',

  CONSTRAINT fk_board_member
    FOREIGN KEY (member_id) REFERENCES ess_member(member_id)
    ON DELETE CASCADE
) COMMENT='게시판';


CREATE TABLE weather_data (
  weather_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '날씨 데이터 ID',

  device_id INT NOT NULL COMMENT '해당 장비 위치 기준 날씨',

  base_date VARCHAR(8) COMMENT '발표 날짜',

  base_time VARCHAR(4) COMMENT '발표 시간',

  fcst_date VARCHAR(8) NOT NULL COMMENT '예보 날짜',

  fcst_time VARCHAR(4) NOT NULL COMMENT '예보 시간',

  sky_status VARCHAR(20) COMMENT '하늘 상태',

  rain_type VARCHAR(20) COMMENT '강수 형태',

  rain_prob INT COMMENT '강수 확률(%)',

  temperature DECIMAL(5,2) COMMENT '기온(℃)',

  humidity INT COMMENT '습도(%)',

  wind_speed DECIMAL(5,2) COMMENT '풍속(m/s)',

  solar_radiation DECIMAL(10,2) COMMENT '추정 일사량',

  sunrise VARCHAR(5) COMMENT '일출 시간',

  sunset VARCHAR(5) COMMENT '일몰 시간',

  ess_status VARCHAR(30) COMMENT '날씨 기반 ESS 상태 분석',

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '데이터 생성 시간',

  CONSTRAINT fk_weather_device
    FOREIGN KEY (device_id) REFERENCES ess_device(device_id)
    ON DELETE CASCADE,

  UNIQUE KEY uq_weather_data (
    device_id,
    base_date,
    base_time,
    fcst_date,
    fcst_time
  ),

  INDEX idx_weather_device_fcst (device_id, fcst_date, fcst_time)
) COMMENT='기상청 API 기반 날씨 데이터';


CREATE TABLE ess_control_log (
  control_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '제어 로그 ID',

  device_id INT NOT NULL COMMENT '제어 대상 장비',

  control_type VARCHAR(30) NOT NULL COMMENT '제어 종류',

  trigger_reason VARCHAR(100) COMMENT '제어 발생 이유',

  result_status VARCHAR(20) COMMENT '제어 결과',

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '제어 실행 시각',

  CONSTRAINT fk_control_device
    FOREIGN KEY (device_id) REFERENCES ess_device(device_id)
    ON DELETE CASCADE
) COMMENT='시뮬레이션 판단 로그';


CREATE TABLE board_comment (
  comment_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '댓글 번호',

  board_no INT NOT NULL COMMENT '게시글 번호',

  member_id INT NOT NULL COMMENT '댓글 작성자 회원 ID',

  comment_content TEXT NOT NULL COMMENT '댓글 내용',

  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '댓글 작성일',

  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '댓글 수정일',

  CONSTRAINT fk_comment_board
    FOREIGN KEY (board_no) REFERENCES board(board_no)
    ON DELETE CASCADE,

  CONSTRAINT fk_comment_member
    FOREIGN KEY (member_id) REFERENCES ess_member(member_id)
    ON DELETE CASCADE
) COMMENT='문의게시판 관리자 댓글';

ALTER TABLE ess_device
MODIFY install_date DATE DEFAULT (CURRENT_DATE);