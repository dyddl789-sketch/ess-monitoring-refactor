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

  <!-- 필터 -->
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

    <input type="month" id="selectedMonth" value="${selectedMonth}">
    <button type="button" id="refreshBtn">조회</button>

  </div>

  <!-- 요약 카드 -->
  <section class="dashboard-summary-grid">

    <div class="summary-card">
      <div class="summary-title">선택 월 발전량</div>
      <div class="summary-value" id="monthlyGenerationKwh">-</div>
      <div class="summary-sub" id="generationSubInfo">월간 발전량 합계</div>
    </div>

    <div class="summary-card">
      <div class="summary-title">선택 월 절감 금액</div>
      <div class="summary-value" id="monthlySavedCost">-</div>
      <div class="summary-sub" id="savedCostSubInfo">월간 절감 금액 합계</div>
    </div>

    <div class="summary-card">
      <div class="summary-title">평균 효율</div>
      <div class="summary-value" id="averageEfficiency">-</div>
      <div class="summary-sub" id="efficiencySubInfo">월간 평균 효율</div>
    </div>

    <div class="summary-card">
      <div class="summary-title">운영 장비 수</div>
      <div class="summary-value" id="operatingDeviceCount">-</div>
      <div class="summary-sub" id="deviceSubInfo">운영 장비 / 전체 장비</div>
    </div>

  </section>

  <!-- 메인 차트 -->
  <section class="dashboard-main-grid">

    <div class="card chart-card">
      <div class="section-title">최근 6개월 발전량</div>
      <div class="section-subtitle">월별 발전량 합계</div>

      <div class="chart-box-large">
        <canvas id="monthlyGenerationChart"></canvas>
      </div>
    </div>

    <div class="card chart-card">
      <div class="section-title">장비별 발전량 TOP 5</div>
      <div class="section-subtitle">선택 월 기준 장비별 발전량</div>

      <div class="chart-box-large">
        <canvas id="deviceTopChart"></canvas>
      </div>
    </div>

  </section>

  <!-- 하단 -->
  <section class="dashboard-bottom-grid">

    <div class="card chart-card">
      <div class="section-title">최근 6개월 절감 금액</div>
      <div class="section-subtitle">월별 절감 금액 합계</div>

      <div class="chart-box">
        <canvas id="monthlyCostChart"></canvas>
      </div>
    </div>

    <div class="card">
      <div class="section-title">최근 알림</div>

      <div id="dashboardAlertList">
        <div class="dashboard-alert-item">
          <span class="dashboard-alert-badge info">정보</span>
          <span class="dashboard-alert-message">최근 알림이 없습니다.</span>
        </div>
      </div>
    </div>

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

  <div class="dashboard-note">
    ※ 대시보드는 energy_log에 저장된 일별 통계 데이터를 월 단위로 집계하여 표시합니다.
  </div>

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
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/dashboard_chart.js"></script>

</body>
</html>

