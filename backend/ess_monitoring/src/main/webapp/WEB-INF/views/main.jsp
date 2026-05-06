<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS Main</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/device_register.css">

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=4c85272f51538d1512f6a5f19d0c8e2a&libraries=services"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>

<body
    data-context-path="${pageContext.request.contextPath}"
    data-login="${not empty sessionScope.memberId}"
    data-member-name="${sessionScope.memberName}"
    data-user-type="${sessionScope.userType}">

<%@ include file="/WEB-INF/views/header.jsp" %>

<section class="hero">
    <div class="hero-content">
        <div class="hero-badge">Solar ESS Monitoring Platform</div>

        <h2>
            실시간 ESS 모니터링을<br>
            더 직관적이고 안정적으로
        </h2>

        <p>
            태양광 ESS 장비의 상태, 전압, 전류, SOC, 알림 이력을<br>
            한눈에 확인하고 빠르게 관리할 수 있는 통합 대시보드입니다.
        </p>

        <div class="hero-buttons">
            <button type="button" class="hero-btn"
                onclick="checkLogin(function(){ moveView('register', loadRegister); })">
                ESS 기기 등록
            </button>

            <button type="button" class="hero-btn secondary"
                onclick="checkLogin(function(){ location.href='${pageContext.request.contextPath}/dashboard/main'; })">
                통합 대시보드 이동
            </button>
        </div>
    </div>
</section>

<section class="container summary-overlap">
    <div class="summary-panel">
        <div class="summary-panel-head">
            <div class="summary-panel-title">운영 현황 요약</div>
            <div class="summary-panel-sub">회원 대표 기기 기준</div>
        </div>

        <div class="summary-grid">
            <div class="summary-card">
                <h4>등록 기기</h4>
                <strong id="deviceCount">
                    <c:choose>
                        <c:when test="${empty deviceCount}">
                            0대
                        </c:when>
                        <c:otherwise>
                            ${deviceCount}대
                        </c:otherwise>
                    </c:choose>
                </strong>
                <p>ESS 장비 등록 후 표시</p>
            </div>

            <div class="summary-card">
                <h4>운영상태</h4>
                <strong class="status-normal">정상</strong>
                <p>최근 알림 기준</p>
            </div>

            <div class="summary-card">
                <h4>평균 SOC</h4>
                <strong>--%</strong>
                <p>모니터링 연동 후 표시</p>
            </div>

            <div class="summary-card">
                <h4>미확인 알림</h4>
                <strong class="status-warning">0건</strong>
                <p>알림 이력 연동 후 표시</p>
            </div>
        </div>
    </div>
</section>

<section class="container welcome-area">
    <c:if test="${empty sessionScope.memberId}">
        <div class="login-card">
            <h3>👋 방문을 환영합니다</h3>
            <p>로그인하면 기기 등록, 모니터링, 알림 관리 기능을 사용할 수 있습니다.</p>
            <br>
            <button type="button" onclick="goLogin()">로그인</button>
            <button type="button" onclick="goJoin()">회원가입</button>
        </div>
    </c:if>

    <c:if test="${not empty sessionScope.memberId}">
        <h3>${sessionScope.memberName}님 환영합니다</h3>
        <p>현재 회원 유형: ${sessionScope.userType}</p>
    </c:if>
</section>

<section class="container dashboard-main-grid">

    <div class="dashboard-card weather-dashboard-card">
        <div class="dashboard-card-head">
            <div class="dashboard-card-title">
                ☀
                <c:choose>
                    <c:when test="${empty weatherList}">
                        내 지역 날씨 예보
                    </c:when>
                    <c:otherwise>
                        ${weatherList[0].city} 날씨 예보
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="dashboard-card-sub">
                회원 대표지역 기준 · 단기예보 API 연동
            </div>
        </div>

        <div class="weather-dashboard-layout">
            <div class="weather-dashboard-main">
                <c:choose>
                    <c:when test="${empty weatherList}">
                        <div>
                            <div class="weather-dashboard-city">내 지역</div>
                            <div class="weather-dashboard-condition">날씨 데이터 없음</div>
                            <div class="weather-dashboard-big">--℃</div>
                        </div>

                        <div class="weather-dashboard-info">
                            날씨 데이터가 조회되지 않았습니다.<br>
                            API 응답 또는 회원 대표지역을 확인하세요.
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div>
                            <div class="weather-dashboard-city">${weatherList[0].city}</div>
                            <div class="weather-dashboard-condition">
                                ${weatherList[0].weatherIcon}
                                ${weatherList[0].skyStatus}
                            </div>
                            <div class="weather-dashboard-big">${weatherList[0].temperature}</div>
                        </div>

                        <div class="weather-dashboard-info">
                            현재 시간 이후 예보를 기준으로<br>
                            ESS 운전환경을 함께 확인합니다.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="weather-dashboard-grid">
                <c:choose>
                    <c:when test="${empty weatherList}">
                        <div class="weather-dashboard-empty">
                            날씨 데이터가 없습니다.
                        </div>
                    </c:when>

                    <c:otherwise>
                        <c:forEach var="weather" items="${weatherList}">
                            <div class="weather-dashboard-item">
                                <div class="weather-dashboard-time">${weather.fcstTime}</div>
                                <div class="weather-dashboard-icon">${weather.weatherIcon}</div>
                                <div class="weather-dashboard-status">${weather.skyStatus}</div>
                                <div class="weather-dashboard-temp">${weather.temperature}</div>
                                <div class="weather-dashboard-prob">${weather.rainProb}</div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="dashboard-card quick-dashboard-card">
        <div class="dashboard-card-head">
            <div class="dashboard-card-title">빠른 실행</div>
            <div class="dashboard-card-sub">자주 사용하는 메뉴</div>
        </div>

        <div class="force-quick-grid">
            <div class="force-quick-card" id="btnDeviceList">
                <div class="force-quick-icon">🗂</div>
                <div class="force-quick-title">기기 목록</div>
                <div class="force-quick-desc">등록된 장비 목록과 상세 정보를 확인합니다.</div>
            </div>

            <div class="force-quick-card" id="btnMonitor">
                <div class="force-quick-icon">📊</div>
                <div class="force-quick-title">실시간 모니터링</div>
                <div class="force-quick-desc">SOC, 전압, 전류, 온도 데이터를 확인합니다.</div>
            </div>

            <div class="force-quick-card" id="btnAlert">
                <div class="force-quick-icon">🚨</div>
                <div class="force-quick-title">알림/이상 이력</div>
                <div class="force-quick-desc">이상 경고와 장애 발생 이력을 확인합니다.</div>
            </div>

            <div class="force-quick-card" id="btnMyPage">
                <div class="force-quick-icon">👤</div>
                <div class="force-quick-title">마이페이지</div>
                <div class="force-quick-desc">회원 정보와 등록 장비를 관리합니다.</div>
            </div>
        </div>
    </div>

</section>

<div class="container">
    <div id="contentArea">

        <section class="content-section">
            <div class="main-guide-head">
                <span>ESS-M.S SERVICE</span>
                <h3>ESS 통합 관리 서비스</h3>
                <p>
                    ESS 장비 등록부터 실시간 모니터링, 알림 확인까지
                    필요한 기능을 빠르게 이용할 수 있습니다.
                </p>
            </div>

            <div class="main-guide-grid">
                <div class="main-guide-card" onclick="checkLogin(function(){ moveView('register', loadRegister); })">
                    <div class="main-guide-icon">＋</div>
                    <h4>ESS 등록</h4>
                    <p>설치 위치와 장비 정보를 입력해 새로운 ESS를 등록합니다.</p>
                </div>

                <div class="main-guide-card" onclick="checkLogin(function(){ moveView('deviceList', loadDeviceList); })">
                    <div class="main-guide-icon">▣</div>
                    <h4>ESS 관리</h4>
                    <p>등록된 ESS 목록을 확인하고 상세 모니터링으로 이동합니다.</p>
                </div>

                <div class="main-guide-card"
                     onclick="checkLogin(function(){ location.href='${pageContext.request.contextPath}/dashboard/main'; })">
                    <div class="main-guide-icon">●</div>
                    <h4>통합 대시보드</h4>
                    <p>SOC, 전압, 전류, 발전량, 알림 현황을 한눈에 확인합니다.</p>
                </div>
            </div>
        </section>

        <section class="content-section notice-section">
            <div class="section-title">
                <span>NOTICE</span>
                <h3>공지사항</h3>
                <p>ESS-M.S의 주요 안내와 업데이트 소식을 확인하세요.</p>
            </div>

            <table class="fake-table">
                <tr>
                    <th>번호</th>
                    <th>제목</th>
                    <th>작성일</th>
                </tr>
                <tr>
                    <td>1</td>
                    <td><a href="#" onclick="loadBoard(); return false;">ESS-M.S 시스템 오픈 안내</a></td>
                    <td>2025-01-01</td>
                </tr>
                <tr>
                    <td>2</td>
                    <td><a href="#" onclick="loadBoard(); return false;">실시간 모니터링 기능 업데이트 안내</a></td>
                    <td>2025-01-10</td>
                </tr>
                <tr>
                    <td>3</td>
                    <td><a href="#" onclick="loadBoard(); return false;">정기 점검 안내</a></td>
                    <td>2025-01-15</td>
                </tr>
            </table>
        </section>

    </div>
</div>

<script>
    const contextPath = '${pageContext.request.contextPath}';
</script>

<script src="${pageContext.request.contextPath}/resources/js/main.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/device_register.js"></script>

<%@ include file="/WEB-INF/views/footer.jsp" %>
</body>
</html>