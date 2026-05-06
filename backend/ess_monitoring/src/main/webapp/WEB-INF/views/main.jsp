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

<!-- ============================= -->
<!-- 날씨 예보 영역 시작 -->
<!-- ============================= -->
<section class="weather-section">
    <div class="weather-header">
        <div>
            <h3>대표 지역 날씨 예보</h3>
            <p>${weatherBaseText}</p>
        </div>

        <c:if test="${not empty weatherList}">
            <span>${weatherList[0].city}</span>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${empty weatherList}">
            <div class="weather-empty">
                날씨 정보를 불러오지 못했습니다.
            </div>
        </c:when>

        <c:otherwise>
            <div class="weather-list">
                <c:forEach var="weather" items="${weatherList}" varStatus="status">
                    <c:if test="${status.index lt 5}">
                        <div class="weather-card">

                            <div class="weather-time">
                                ${weather.fcstTime}
                            </div>

                            <div class="weather-icon">
                                ${weather.weatherIcon}
                            </div>

                            <div class="weather-status">
                                ${weather.skyStatus}
                            </div>

                            <div class="weather-temp">
                                ${weather.temperature}
                            </div>

                            <div class="weather-rain">
                                강수확률 ${weather.rainProb}
                            </div>

                        </div>
                    </c:if>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</section>
<!-- ============================= -->
<!-- 날씨 예보 영역 끝 -->
<!-- ============================= -->

<div class="main-content-wrap">
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

                <div class="main-guide-card"
                     onclick="checkLogin(function(){ moveView('register', loadRegister); })">

                    <div class="main-guide-icon">＋</div>

                    <h4>ESS 등록</h4>

                    <p>
                        설치 위치와 장비 정보를 입력해 새로운 ESS를 등록합니다.
                    </p>
                </div>

                <div class="main-guide-card"
                     onclick="checkLogin(function(){ moveView('deviceList', loadDeviceList); })">

                    <div class="main-guide-icon">▣</div>

                    <h4>ESS 관리</h4>

                    <p>
                        등록된 ESS 목록을 확인하고 상세 모니터링으로 이동합니다.
                    </p>
                </div>

                <div class="main-guide-card"
                     onclick="checkLogin(function(){ location.href='${pageContext.request.contextPath}/dashboard/main'; })">

                    <div class="main-guide-icon">●</div>

                    <h4>통합 대시보드</h4>

                    <p>
                        SOC, 전압, 전류, 발전량, 알림 현황을 한눈에 확인합니다.
                    </p>
                </div>

            </div>
        </section>

        <section class="content-section notice-section">

            <div class="section-title">
                <span>NOTICE</span>

                <h3>공지사항</h3>

                <p>
                    ESS-M.S의 주요 안내와 업데이트 소식을 확인하세요.
                </p>
            </div>

            <table class="fake-table">

                <tr>
                    <th>번호</th>
                    <th>제목</th>
                    <th>작성일</th>
                </tr>

                <tr>
                    <td>1</td>
                    <td>
                        <a href="#" onclick="loadBoard(); return false;">
                            ESS-M.S 시스템 오픈 안내
                        </a>
                    </td>
                    <td>2025-01-01</td>
                </tr>

                <tr>
                    <td>2</td>
                    <td>
                        <a href="#" onclick="loadBoard(); return false;">
                            실시간 모니터링 기능 업데이트 안내
                        </a>
                    </td>
                    <td>2025-01-10</td>
                </tr>

                <tr>
                    <td>3</td>
                    <td>
                        <a href="#" onclick="loadBoard(); return false;">
                            정기 점검 안내
                        </a>
                    </td>
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