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
    <div class="hero-inner">

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

        <c:choose>
            <c:when test="${empty weatherList}">
                <div class="hero-weather-card clear">
                    <div class="hero-weather-empty">
                        날씨 정보를 불러오지 못했습니다.
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <c:set var="currentWeather" value="${weatherList[0]}" />

                <div class="hero-weather-card ${currentWeather.weatherTheme}">
                    <div class="hero-weather-overlay">

                        <div class="hero-weather-top">
                            <div>
                                <h3>${currentWeather.city}</h3>
                            </div>

                            <span class="hero-weather-badge">
                                대표 ESS 위치 기준
                            </span>
                                <c:if test="${not empty mainDevice}">
							        <div class="hero-main-device">
							            대표 장비 :
							            <strong>${mainDevice.deviceName}</strong>
							        </div>
							    </c:if>
                        </div>

                        <div class="hero-weather-main">
							<div class="hero-weather-icon">
							    <img
							        src="${pageContext.request.contextPath}/resources/img/weather-icon/${currentWeather.weatherIcon}.svg"
							        alt="weather icon">
							</div>

                            <div>
                                <strong>${currentWeather.temperature}</strong>
                                <p>${currentWeather.skyStatus}</p>
                            </div>
                        </div>

                        <div class="hero-weather-info">
                            <span>강수확률 ${currentWeather.rainProb}</span>
                            <span>일출 ${currentWeather.sunrise}</span>
                            <span>일몰 ${currentWeather.sunset}</span>
                        </div>

						<div class="hero-weather-forecast">
						    <c:forEach var="weather" items="${weatherList}" varStatus="status">
						        <c:if test="${status.index lt 5}">
						            <div class="hero-forecast-item">
						                <span>${weather.fcstTime}</span>
						
						                <div class="hero-forecast-icon">
						                    <img
						                        src="${pageContext.request.contextPath}/resources/img/weather-icon/${weather.weatherIcon}.svg"
						                        alt="weather icon">
						                </div>
						
						                <p>${weather.skyStatus}</p>
						                <strong>${weather.temperature}</strong>
						            </div>
						        </c:if>
						    </c:forEach>
						</div>

                    </div>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</section>

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
                
			<c:if test="${sessionScope.userType eq 'COMPANY'}">
			    <div class="main-guide-card"
			         onclick="checkLogin(function(){ moveView('groupList', loadGroupList); })">
			
			        <div class="main-guide-icon">◎</div>
			
			        <h4>그룹 관리</h4>
			
			        <p>
			            기업 회원은 ESS 장비를 그룹 단위로 생성하고 관리할 수 있습니다.
			        </p>
			    </div>
			</c:if>
			
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
<script src="${pageContext.request.contextPath}/resources/js/group_manage.js"></script>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>