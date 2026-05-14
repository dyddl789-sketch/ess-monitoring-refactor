# ESS Monitoring System

Spring Legacy 기반 ESS 모니터링 프로젝트를  
개인적으로 리팩토링 및 유지보수하고 있는 프로젝트입니다.

## 프로젝트 소개

학원 팀 프로젝트로 진행했던 ESS Monitoring System을 기반으로,  
프로젝트 구조를 정리하고 유지보수성을 개선하는 방향으로 리팩토링을 진행하고 있습니다.

기존 기능 구현 중심 구조에서 벗어나  
디렉토리 구조 정리, SQL 분리, 문서화 등을 추가했습니다.

---

## 기술 스택

| Category | Stack |
|---|---|
| Backend | Spring Legacy, Java |
| Database | MySQL |
| ORM | MyBatis |
| Frontend | JSP, JavaScript, jQuery |
| Build Tool | Maven |
| Version Control | Git, GitHub |

---

## 프로젝트 구조

```txt
backend/
 └── ess_monitoring

publishing/

sql/

docs/
```

---

## 주요 기능

- ESS 상태 모니터링
- 사용자 마이페이지
- 데이터 조회 및 페이징 처리
- 설비 정보 조회

---

## 리팩토링 내용

- 루트 디렉토리 구조 정리
- SQL 파일 분리 및 정리
- 불필요한 파일 제거
- 문서 디렉토리 추가
- Git 브랜치 전략 적용

---

## 브랜치 전략

```txt
main
 └── develop
      ├── refactor/*
      ├── fix/*
      └── docs/*
```

기능 단위로 브랜치를 분리해서 작업 후  
develop 브랜치로 병합하는 방식으로 관리하고 있습니다.

---

## 실행 환경

- Spring Legacy 기반 프로젝트
- Tomcat 서버 연동 필요
- MySQL DB 사용
- Maven 프로젝트 import 후 실행

---

## 개선 예정

- 예외 처리 개선
- API 문서화
- 테스트 코드 추가
- SQL 정리 및 최적화

---

## Commit Convention

```txt
feat: 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
docs: 문서 수정
chore: 기타 작업
```