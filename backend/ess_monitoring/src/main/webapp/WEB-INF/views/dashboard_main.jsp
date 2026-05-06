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
		        <th>대표</th>
		      </tr>
		    </thead>
		
		    <tbody id="deviceTableBody">
		      <tr>
		        <td colspan="6">데이터를 불러오는 중...</td>
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

  <!-- ============================= -->
  <!-- 대표 디바이스 기준 날씨 카드 -->
  <!-- ============================= -->
  <div class="card">
    <div class="dashboard-weather-box">

      <div class="dashboard-weather-header">
        <div>
          <div class="section-title">대표 지역 날씨</div>
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

          <!-- 현재 대표 날씨 -->
          <div class="dashboard-weather-current">
            <div class="dashboard-weather-icon">
              ${weatherList[0].weatherIcon}
            </div>

            <div>
              <div class="dashboard-weather-temp">
                ${weatherList[0].temperature}
              </div>
              <div class="dashboard-weather-status">
                ${weatherList[0].skyStatus}
              </div>
            </div>

            <div class="dashboard-weather-detail">
              <div>예보시간 ${weatherList[0].fcstTime}</div>
              <div>강수확률 ${weatherList[0].rainProb}</div>

              <c:if test="${not empty mainDevice}">
                <div>대표기기 ${mainDevice.deviceName}</div>
              </c:if>
            </div>
          </div>

          <!-- 시간대별 예보 -->
          <div class="dashboard-weather-list">
            <c:forEach var="weather" items="${weatherList}" varStatus="status">
              <c:if test="${status.index lt 4}">
                <div class="dashboard-weather-item">
                  <div class="weather-time">${weather.fcstTime}</div>
                  <div class="weather-icon">${weather.weatherIcon}</div>
                  <div class="weather-temp">${weather.temperature}</div>
                  <div class="weather-status">${weather.skyStatus}</div>
                </div>
              </c:if>
            </c:forEach>
          </div>

        </c:otherwise>
      </c:choose>

    </div>
  </div>

</section>

  </main>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>



<script>
  const contextPath = '${pageContext.request.contextPath}';

  function setMainDevice(deviceId) {
      if (!confirm("이 장비를 대표 디바이스로 설정하시겠습니까?")) {
          return;
      }

      $.ajax({
          type: "post",
          url: contextPath + "/device/main/set",
          data: {
              deviceId: deviceId
          },
          success: function(result) {
              console.log("@# setMainDevice result =>", result);

              if (result === "success") {
                  alert("대표 디바이스로 설정되었습니다.");
					
                  location.reload();
                  
                  if (typeof loadDashboardData === "function") {
                      loadDashboardData();
                  } else {
                      location.reload();
                  }

              } else if (result === "login_required") {
                  alert("로그인이 필요합니다.");
                  location.href = contextPath + "/login_view";

              } else {
                  alert("대표 디바이스 설정에 실패했습니다.");
              }
          },
          error: function(xhr) {
              console.log("@# xhr.status =>", xhr.status);
              console.log("@# xhr.responseText =>", xhr.responseText);

              alert("서버 오류가 발생했습니다.");
          }
      });
  }
</script>

<script src="${pageContext.request.contextPath}/resources/js/dashboard_main.js"></script>

</body>
</html>

