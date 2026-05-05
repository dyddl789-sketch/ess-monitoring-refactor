<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대시보드</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/dashboard_main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
</head>

<body>
<div class="layout">

<%@ include file="/WEB-INF/views/sidebar.jsp" %>

  <main class="main">

    <div class="header">
      <h2>대시보드</h2>
      <div class="user-box">(주)에너지코리아 ▼</div>
    </div>

    <div class="filter-box">

      <select id="groupSelect">
        <option value="">전체 그룹</option>
        <c:forEach var="group" items="${groupList}">
          <option value="${group.groupId}">
            ${group.groupName}
          </option>
        </c:forEach>
      </select>

      <select id="deviceSelect">
        <option value="">전체 장비</option>
        <c:forEach var="device" items="${deviceList}">
          <option value="${device.deviceId}">
            ${device.deviceName}
          </option>
        </c:forEach>
      </select>

      <input type="date" id="selectedDate" value="${selectedDate}">
      <button type="button" id="refreshBtn">조회</button>

    </div>

    <section class="card-grid">

	<div class="card">
	  <div class="card-title">선택일 데이터 수집</div>
	  <div class="card-value" id="collectedDeviceCount">-</div>
	  <div class="card-sub" id="collectionSubInfo">-</div>
	</div>
	
	<div class="card">
	  <div class="card-title">선택일 예상 발전량</div>
	  <div class="card-value" id="todayGenerationKwh">-</div>
	  <div class="card-sub" id="generationSubInfo">선택일 수집 데이터 기준</div>
	</div>
	
	<div class="card">
	  <div class="card-title">선택일 평균 SOC</div>
	  <div class="card-value" id="averageSoc">-</div>
	  <div class="card-sub" id="socSubInfo">선택일 수집 데이터 기준</div>
	</div>
	
	<div class="card">
	  <div class="card-title">선택일 예상 절감 금액</div>
	  <div class="card-value" id="todaySavedCost">-</div>
	  <div class="card-sub" id="savedCostSubInfo">선택일 수집 데이터 기준</div>
	</div>
	
	<div class="dashboard-note">
  ※ 데이터 수집은 선택일에 측정 데이터가 존재한다는 뜻이며, 발전량이 0일 수도 있습니다.
	</div>	
    </section>

    <section class="content-grid">

		<div class="card">
		  <!-- 기업: 그룹별 / 개인: 장비별 / 필터 선택 시 제목은 JS에서 변경 -->
		  <div class="section-title" id="generationChartTitle">
		    선택일 발전량
		  </div>
		
		  <!-- 발전량 그래프 영역: JS에서 DB 조회 결과로 bar-item 생성 -->
		  <div class="bar-chart" id="generationChart">
		    <div class="empty-chart">데이터를 불러오는 중...</div>
		  </div>
		
		  <!-- 표시 기준 안내 -->
		  <div class="dashboard-note" id="generationChartNote">
		    선택한 날짜와 필터 기준으로 발전량을 표시합니다.
		  </div>
		</div>

		<div class="card">
		  <div class="section-title">장비 리스트</div>
		
		  <table>
		    <thead>
		      <tr>
		        <th>장비명</th>
		        <th>그룹</th>
		        <th>SOC</th>
		        <th>상태</th>
		        <th>상세</th>
		      </tr>
		    </thead>
		
		    <tbody id="deviceTableBody">
		      <tr>
		        <td colspan="5">데이터를 불러오는 중...</td>
		      </tr>
		    </tbody>
		  </table>
		
		  <!-- 상태 설명 -->
		  <div class="battery-status-guide">
		    <span class="status-normal">정상</span> : SOC 40% 이상
		    <span class="status-warning">경고</span> : SOC 20% 이상 40% 미만
		    <span class="status-danger">에러</span> : SOC 20% 미만
		    <span class="status-offline">오프라인</span> : SOC 0% 또는 미동작
		    <span class="status-nodata">데이터 없음</span> : 데이터 없음
		  </div>
		</div>

    </section>

    <section class="bottom-grid">

      <div class="card">
        <div class="section-title">최근 알림</div>

        <ul class="alert-list">
          <li><span class="badge">경고</span> 부산센터 ESS 2호기 SOC가 50% 미만입니다. <span style="float:right;">09:15</span></li>
          <li><span class="badge">정보</span> 서울공장 ESS 1호기 충전이 완료되었습니다. <span style="float:right;">08:45</span></li>
          <li><span class="badge">정보</span> 대구지점 ESS 1호기 일일 리포트가 생성되었습니다. <span style="float:right;">08:00</span></li>
          <li><span class="badge">경고</span> 전주사무소 ESS 1호기 통신 상태가 불안정합니다. <span style="float:right;">07:30</span></li>
        </ul>
      </div>

      <div class="card">
        <div class="section-title">오늘 날씨 (서울)</div>

        <div class="weather-main">
          <div class="weather-icon">☀️</div>

          <div>
            <div class="weather-temp">23.6℃</div>
            <div>맑음</div>
          </div>

          <div class="weather-detail">
            <div>강수확률 10%</div>
            <div>습도 42%</div>
            <div>풍속 2.1m/s</div>
            <div>일출 05:25 · 일몰 19:45</div>
          </div>
        </div>

        <div class="forecast">
          <div class="forecast-item">
            <div>내일</div>
            <div>☀️</div>
            <div>24℃ / 15℃</div>
            <div>맑음</div>
          </div>

          <div class="forecast-item">
            <div>모레</div>
            <div>🌤️</div>
            <div>22℃ / 14℃</div>
            <div>구름많음</div>
          </div>

          <div class="forecast-item">
            <div>05-23</div>
            <div>🌧️</div>
            <div>20℃ / 13℃</div>
            <div>비</div>
          </div>
        </div>

      </div>

    </section>

  </main>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
  const contextPath = '${pageContext.request.contextPath}';
</script>

<script src="${pageContext.request.contextPath}/resources/js/dashboard_main.js"></script>

</body>
</html>