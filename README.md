````md
# ESS Monitoring System Refactoring

Spring Legacy 기반 ESS 모니터링 프로젝트를 개인적으로 리팩토링 및 유지보수한 프로젝트입니다.

기존 학원 팀 프로젝트를 기반으로 단순 기능 구현 중심 구조를 개선하고, 실제 운영형 ESS 모니터링 시스템에 가깝도록 데이터 구조, 화면 구조, 시뮬레이션 로직, 대시보드 통계 기능을 재정리했습니다.

---

## 1. 프로젝트 소개

ESS Monitoring System은 태양광 발전 설비와 ESS 배터리 상태를 모니터링하는 웹 기반 시스템입니다.

기존 프로젝트는 장비 등록, 게시판, 모니터링 화면 중심으로 구성되어 있었으나, 개인 리팩토링 과정에서 다음과 같은 방향으로 개선했습니다.

- 실시간 모니터링 데이터 구조 개선
- 대시보드 통계 구조 재설계
- Scheduler 기반 데이터 자동 생성
- ESS 운영 흐름 기반 시뮬레이션 로직 추가
- SOC 기반 상태 판단 및 Alert 생성
- Chart.js 기반 시각화 개선
- 그룹 / 장비 / 날짜 / 월 기준 조회 구조 적용
- 논리 삭제 구조 추가
- 화면 디자인 통일
- 로그인 실패 알림 분기 처리
- SQL / 문서 / 프로젝트 디렉토리 구조 정리

---

## 2. 프로젝트 핵심 기술 스택 및 선택 이유

### Spring MVC 3 기반 아키텍처

- Controller / Service / DAO 계층을 분리하여 유지보수성과 역할 분리를 강화했습니다.
- XML 기반 Bean 관리 방식을 사용하여 레거시 환경 및 기존 SI 구조와의 호환성을 고려했습니다.
- 실제 현업에서 많이 사용하는 전통적인 Spring MVC 구조를 경험하기 위해 선택했습니다.

### MyBatis 기반 데이터 접근

- 복잡한 SQL을 직접 제어할 수 있도록 MyBatis를 사용했습니다.
- 모니터링 시스템 특성상 조회 쿼리와 통계성 SQL이 많아 ORM보다 SQL 제어가 유리하다고 판단했습니다.
- SQL 튜닝 및 쿼리 가독성을 고려해 Mapper 기반 구조로 설계했습니다.

### Java 11 환경 적용

- 최신 문법과 안정적인 LTS 버전을 사용하기 위해 Java 11을 적용했습니다.
- 기존 레거시 Spring 구조와 최신 JDK 환경을 함께 운영하며 호환성 문제도 직접 경험했습니다.

### Jackson 기반 외부 API 연동

- 기상청 Open API 데이터를 JSON 형태로 수집 / 파싱하기 위해 Jackson을 사용했습니다.
- 실시간 외부 데이터 연동 및 데이터 가공 경험을 쌓기 위해 적용했습니다.

### Commons FileUpload + CSV 처리

- CSV 업로드 기능을 구현하여 대량 데이터를 일괄 등록할 수 있도록 구성했습니다.
- 운영 효율성과 사용자 편의성을 고려한 기능입니다.

### Lombok 적용

- 반복적인 Getter / Setter 및 생성자 코드를 줄여 생산성을 높였습니다.
- 비즈니스 로직에 집중할 수 있도록 코드 간결성을 유지했습니다.

### WAR 기반 배포 구조

- Tomcat 환경 배포를 고려하여 WAR 패키징 방식을 사용했습니다.
- 실제 운영 서버 배포 구조와 유사한 환경으로 프로젝트를 구성했습니다.

---

## 3. 기술적으로 강조할 수 있는 부분

- 단순 CRUD 수준이 아니라  
  **외부 API 연동 / 파일 업로드 / 데이터 파싱 / 실시간 모니터링 구조**까지 직접 구현했습니다.

- Spring XML 설정, Bean 등록, MyBatis 연동 과정에서 발생하는  
  **의존성 충돌 및 빌드 문제를 직접 해결하며 레거시 유지보수 경험도 쌓았습니다.**

- 최신 기술만 사용하는 것이 아니라,  
  **실제 현업에서 많이 접하는 레거시 기반 Spring 구조를 이해하고 운영할 수 있다는 점**을 강점으로 생각합니다.

- 실시간 운영 데이터(`monitoring`)와 통계 데이터(`energy_log`)를 분리하여  
  화면 목적에 맞는 데이터 구조를 직접 설계했습니다.

- Scheduler 기반 데이터 자동 생성 구조를 구현하여  
  실제 센서 데이터가 없는 환경에서도 운영 흐름을 시뮬레이션할 수 있도록 구성했습니다.

- ESS 충전/방전 흐름과 SOC 변화를 연결하여  
  단순 랜덤 데이터가 아닌 운영 흐름 기반 시뮬레이션 구조를 구현했습니다.

- Chart.js 기반 실시간 차트 및 월별 통계 차트를 구현하여  
  운영 데이터 시각화 경험을 쌓았습니다.

- 그룹 / 장비 / 날짜 / 월 기준 필터링 구조를 적용하여  
  실제 운영 관제 시스템과 유사한 조회 흐름을 구성했습니다.

- 논리 삭제 구조를 적용하여  
  운영 데이터 이력 보존과 유지보수성을 고려했습니다.

---

## 4. 기술 스택

| Category | Stack |
|---|---|
| Backend | Java, Spring Legacy |
| Database | MySQL / MariaDB |
| ORM | MyBatis |
| Frontend | JSP, JSTL, JavaScript, jQuery |
| Chart | Chart.js |
| Build Tool | Maven |
| Server | Tomcat |
| Version Control | Git, GitHub |
| IDE | STS / Eclipse |

---

## 5. 프로젝트 구조

```txt
ess-monitoring-refactor/
│
├── backend/
│   └── ess_monitoring/
│       ├── src/main/java/
│       │   └── com/lgy/ess_monitoring/
│       │       ├── controller/
│       │       ├── service/
│       │       ├── dao/
│       │       ├── dto/
│       │       └── scheduler/
│       │
│       ├── src/main/resources/
│       │   └── mapper/
│       │
│       └── src/main/webapp/
│           ├── WEB-INF/views/
│           └── resources/
│               ├── css/
│               ├── js/
│               └── img/
│
├── sql/
├── docs/
└── publishing/
```

---

## 6. 핵심 개선 방향

기존 프로젝트는 화면 단위 기능 구현은 되어 있었지만, 실시간 데이터와 통계 데이터의 역할이 명확히 분리되어 있지 않았습니다.

이번 리팩토링에서는 다음과 같이 역할을 분리했습니다.

```txt
Dashboard Main
→ energy_log 기반 월별 / 일별 통계 화면

상세 Monitoring
→ monitoring 기반 실시간 운영 데이터 화면
```

이를 통해 대시보드는 장기 통계 중심으로, 상세 모니터링은 실시간 운영 상태 중심으로 구성했습니다.

---

## 7. 주요 기능

### 7.1 ESS 실시간 상세 모니터링

- 장비별 실시간 운영 상태 조회
- 실시간 출력(kW) 조회
- SOC(%) 조회
- 전압 / 전류 조회
- 금일 발전량 및 절감 금액 조회
- 시간별 출력 변화 그래프
- 시간별 SOC 변화 그래프
- 발전량 누적 그래프
- 최근 7일 발전량 차트
- 최근 7일 절감 금액 차트
- 최근 Alert 조회
- 운영 판단 요약 제공
- 오늘 날짜 기준 자동 갱신
- 과거 날짜 선택 시 이력 조회 모드 전환

---

### 7.2 Dashboard Main 통계 화면

- 선택 월 기준 발전량 합계 조회
- 선택 월 기준 절감 금액 합계 조회
- 월간 평균 효율 조회
- 운영 장비 수 조회
- 최근 6개월 발전량 차트
- 최근 6개월 절감 금액 차트
- 장비별 발전량 TOP 5 차트
- 최근 알림 조회
- 대표 지역 날씨 정보 조회
- 그룹 / 장비 / 월 기준 필터링

---

### 7.3 장비 등록 및 관리

- 사용자별 장비 등록
- 장비명, 설치 위치, 설비 용량, ESS 용량 입력
- 그룹 기준 장비 관리
- 대표 장비 설정
- 장비 상태 관리
- 논리 삭제 처리 적용

---

### 7.4 Scheduler 기반 실시간 데이터 자동 생성

```txt
Scheduler 실행
→ 활성 장비 목록 조회
→ 장비별 운영 데이터 생성
→ monitoring 저장
→ energy_log 누적
→ 장비 상태 갱신
→ Alert 발생 여부 판단
```

주요 처리 내용:

- monitoring 데이터 자동 생성
- energy_log 일별 통계 자동 누적
- 장비 현재 충전량 갱신
- SOC 기반 상태 변경
- WARNING / ERROR Alert 생성

---

## 8. ESS 운영 시뮬레이션 구조

### 8.1 에너지 흐름 구조

```txt
태양광 발전량 생성
→ 사용 전력량 차감
→ 남는 전력 ESS 충전
→ 현재 배터리 잔량 갱신
→ SOC 계산
→ 상태 판단
→ Alert 발생
```

```txt
발전량 > 사용량
→ 충전 증가 / SOC 상승

발전량 < 사용량
→ 방전 진행 / SOC 감소
```

---

### 8.2 DEMO_DAY_MODE

```txt
DEMO_DAY_MODE = true
→ 낮 시간 발전 상태 가정
→ 발전량 생성
→ 충전 / SOC 변화 확인 가능
```

---

### 8.3 DEMO_DRAIN_MODE

```txt
DEMO_DRAIN_MODE = true
→ 사용량 증가
→ 충전량 부족
→ SOC 감소
→ 상태 WARNING / ERROR 변경
→ Alert 발생
```

---

## 9. Alert 처리 구조

```txt
SOC <= 10
→ ERROR / CRITICAL Alert

SOC <= 25
→ WARNING Alert

주간 시간대 출력 저하
→ POWER_LOW Alert
```

중복 Alert 방지 로직:

```txt
최근 10분 내 동일 장비 / 동일 유형 / 미처리 Alert 존재
→ 신규 Alert 생성 방지
```

---

## 10. 데이터 구조 개선

### monitoring 테이블

실시간 운영 데이터 저장:

- 전압
- 전류
- SOC
- 출력
- 발전량
- 충전량
- 사용량
- 절감 금액
- 측정 시간

---

### energy_log 테이블

일별 / 월별 통계 데이터 저장:

- 일일 발전량
- 일일 절감 금액
- 일일 운영 효율
- 기록 날짜

---

### 역할 분리

```txt
monitoring
→ 실시간 운영 데이터

energy_log
→ 일별 / 월별 통계 데이터
```

---

## 11. UI / UX 개선

### 상세 모니터링 화면 개선

- 핵심 상태 카드 구성
- 실시간 출력 그래프 추가
- SOC 변화 그래프 추가
- 누적 발전량 그래프 추가
- 최근 7일 차트 추가
- 최근 알림 영역 추가
- 운영 판단 요약 추가
- 자동 갱신 기능 추가

---

### 대시보드 메인 화면 개선

- 월 기준 조회 필터 추가
- 월간 통계 카드 추가
- 최근 6개월 차트 추가
- 장비별 TOP5 차트 추가
- 최근 알림 영역 추가
- 대표 지역 날씨 정보 추가
- 화면 디자인 통일

---

## 12. 브랜치 전략

```txt
main
 └── develop
      ├── feature/*
      ├── refactor/*
      ├── fix/*
      └── docs/*
```

| Branch | Role |
|---|---|
| main | 안정 버전 관리 |
| develop | 작업 통합 브랜치 |
| feature/* | 신규 기능 작업 |
| refactor/* | 리팩토링 작업 |
| fix/* | 버그 수정 |
| docs/* | 문서 수정 |

---

## 13. 실행 환경

- Java 11
- Spring Legacy
- Maven
- Tomcat
- MySQL / MariaDB
- STS / Eclipse

---

## 14. 실행 방법

### 프로젝트 Import

```txt
STS 또는 Eclipse에서 Maven Project로 import
```

### DB 생성

```txt
sql 디렉토리의 DDL 파일 실행
```

### 서버 설정

```txt
Tomcat 서버 연결
```

### 프로젝트 실행

```txt
Run on Server 실행
```

---

## 15. Commit Convention

```txt
feat: 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
docs: 문서 수정
chore: 기타 작업
```

---

## 16. 개선 예정

- 예외 처리 공통화
- API 응답 구조 표준화
- 테스트 코드 추가
- SQL 성능 최적화
- Spring Boot 전환 검토
- 운영 로그 구조 개선
- Alert 처리 상태 관리 개선
- 관리자 화면 기능 확장
````
