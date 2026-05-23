<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS 상세 모니터링</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">

<style>
.device-detail {
    padding: 50px 0;
}

.detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
}

.detail-header h2 {
    margin-bottom: 8px;
}

.detail-summary-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
    margin-bottom: 25px;
}

.summary-card {
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 14px;
    padding: 18px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.06);
}

.summary-card h4 {
    margin: 0 0 10px;
    color: #555;
}

.summary-card strong {
    font-size: 1.5rem;
}

.status-normal {
    color: #16a34a;
}

.status-warning {
    color: #f59e0b;
}

.status-danger {
    color: #dc2626;
}

.detail-layout {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 25px;
}

.detail-panel {
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 14px;
    padding: 22px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.05);
}

.monitor-table {
    width: 100%;
    border-collapse: collapse;
}

.monitor-table th,
.monitor-table td {
    border-bottom: 1px solid #eee;
    padding: 12px;
    text-align: left;
}

.monitor-table th {
    color: #555;
    width: 35%;
}

.chart-panel {
    margin-bottom: 25px;
}

.chart-placeholder {
    height: 260px;
    border: 2px dashed #ccc;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #777;
    background: #f8fafc;
}

.btn-gray {
    display: inline-block;
    padding: 10px 16px;
    border-radius: 8px;
    background: #334155;
    color: white;
    text-decoration: none;
}

.status-badge {
    padding: 5px 9px;
    border-radius: 10px;
    font-size: 13px;
}

.status-badge.normal {
    background: #dcfce7;
    color: #166534;
}

.status-badge.warning {
    background: #fef3c7;
    color: #92400e;
}

.status-badge.danger {
    background: #fee2e2;
    color: #991b1b;
}

@media (max-width: 900px) {
    .detail-summary-grid,
    .detail-layout {
        grid-template-columns: 1fr;
    }
}
</style>
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<section class="container device-detail">

    <div class="detail-header">
        <div>
            <h2>${device.device_name} 상세 모니터링</h2>
            <p>${device.location}</p>
        </div>

        <a href="${pageContext.request.contextPath}/main" class="btn-gray">목록으로</a>
    </div>

    <div class="detail-summary-grid">

        <div class="summary-card">
            <h4>장비 상태</h4>

            <c:choose>
                <c:when test="${device.status eq '정상'}">
                    <strong class="status-normal">${device.status}</strong>
                </c:when>
                <c:when test="${device.status eq '점검'}">
                    <strong class="status-warning">${device.status}</strong>
                </c:when>
                <c:otherwise>
                    <strong class="status-danger">${device.status}</strong>
                </c:otherwise>
            </c:choose>

            <p>최근 수신 데이터 기준</p>
        </div>

        <div class="summary-card">
            <h4>현재 SOC</h4>
            <strong>
                <c:choose>
                    <c:when test="${empty monitor}">
                        --%
                    </c:when>
                    <c:otherwise>
                        ${monitor.soc}%
                    </c:otherwise>
                </c:choose>
            </strong>
            <p>배터리 충전 상태</p>
        </div>

        <div class="summary-card">
            <h4>현재 날씨</h4>
            <strong>
                <c:choose>
                    <c:when test="${empty weather}">
                        -- / --℃
                    </c:when>
                    <c:otherwise>
                        ${weather.skyStatus} / ${weather.temperature}℃
                    </c:otherwise>
                </c:choose>
            </strong>
            <p>기기 설치 위치 기준</p>
        </div>

        <div class="summary-card">
            <h4>예상 영향</h4>
            
				<c:choose>
				    <c:when test="${empty weather}">
				        <strong>--</strong>
				    </c:when>
				
				    <c:when test="${weather.essStatus eq '발전 조건 양호'}">
				        <strong class="status-normal">${weather.essStatus}</strong>
				    </c:when>
				
				    <c:when test="${weather.essStatus eq '발전량 저하 예상'}">
				        <strong class="status-danger">${weather.essStatus}</strong>
				    </c:when>
				
				    <c:when test="${weather.essStatus eq '야간 발전 없음'}">
				        <strong class="status-warning">${weather.essStatus}</strong>
				    </c:when>
				
				    <c:otherwise>
				        <strong class="status-warning">${weather.essStatus}</strong>
				    </c:otherwise>
				</c:choose>
		
		    <p>날씨 기반 ESS 분석 결과</p>
        </div>

    </div>

    <div class="detail-layout">

        <div class="detail-panel">
            <h3>실시간 모니터링</h3>

            <table class="monitor-table">
                <tr>
                    <th>전압</th>
                    <td>
                        <c:choose>
                            <c:when test="${empty monitor}">--V</c:when>
                            <c:otherwise>${monitor.voltage}V</c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <tr>
                    <th>전류</th>
                    <td>
                        <c:choose>
                            <c:when test="${empty monitor}">--A</c:when>
                            <c:otherwise>${monitor.current_a}A</c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <tr>
                    <th>출력 전력</th>
                    <td>
                        <c:choose>
                            <c:when test="${empty monitor}">--kW</c:when>
                            <c:otherwise>${monitor.power_output}kW</c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <tr>
                    <th>측정 시간</th>
                    <td>
                        <c:choose>
                            <c:when test="${empty monitor}">데이터 없음</c:when>
                            <c:otherwise>${monitor.record_time}</c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </table>
        </div>

	<div class="detail-panel">
	    <h3>날씨 정보</h3>
	
	    <table class="monitor-table">
	        <tr>
	            <th>하늘 상태</th>
	            <td>${empty weather ? '--' : weather.skyStatus}</td>
	        </tr>
	
	        <tr>
	            <th>기온</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather or empty weather.temperature}">
	                        --℃
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.temperature}℃
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	
	        <tr>
	            <th>강수 형태</th>
	            <td>${empty weather ? '--' : weather.rainType}</td>
	        </tr>
	
	        <tr>
	            <th>강수 확률</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather}">
	                        --%
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.rainProb}%
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	
	        <tr>
	            <th>습도</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather}">
	                        --%
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.humidity}%
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	
	        <tr>
	            <th>풍속</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather or empty weather.windSpeed}">
	                        --m/s
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.windSpeed}m/s
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	
	        <tr>
	            <th>일사량</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather or empty weather.solarRadiation}">
	                        --W/m²
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.solarRadiation}W/m²
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	
	        <tr>
	            <th>일출</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather or empty weather.sunrise}">
	                        --
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.sunrise}
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	
	        <tr>
	            <th>일몰</th>
	            <td>
	                <c:choose>
	                    <c:when test="${empty weather or empty weather.sunset}">
	                        --
	                    </c:when>
	                    <c:otherwise>
	                        ${weather.sunset}
	                    </c:otherwise>
	                </c:choose>
	            </td>
	        </tr>
	    </table>
	</div>

    </div>
	<div class="detail-panel" style="margin-bottom:25px;">
	    <h3>시간별 날씨 예보</h3>
	
	    <table class="monitor-table">
	        <tr>
	            <th>예보 시간</th>
	            <th>하늘</th>
	            <th>기온</th>
	            <th>강수</th>
	            <th>강수확률</th>
	            <th>습도</th>
	            <th>풍속</th>
	        </tr>
	
	        <c:choose>
	            <c:when test="${empty weatherList}">
	                <tr>
	                    <td colspan="7">조회된 시간별 날씨 데이터가 없습니다.</td>
	                </tr>
	            </c:when>
	
	            <c:otherwise>
	                <c:forEach var="w" items="${weatherList}">
	                    <tr>
	                        <td>${w.displayTime}</td>
	                        <td>${w.skyStatus}</td>
	                        <td>${w.temperature}℃</td>
	                        <td>${w.rainType}</td>
	                        <td>${w.rainProb}%</td>
	                        <td>${w.humidity}%</td>
	                        <td>${w.windSpeed}m/s</td>
	                    </tr>
	                </c:forEach>
	            </c:otherwise>
	        </c:choose>
	    </table>
	</div>
    <div class="detail-panel chart-panel">
        <h3>에너지 분석</h3>
        <div class="chart-placeholder">
            발전량 / 충전량 / 방전량 그래프 영역
        </div>
    </div>

    <div class="detail-panel">
        <h3>최근 알림</h3>

        <table class="monitor-table">
            <tr>
                <th>시간</th>
                <th>알림 내용</th>
                <th>상태</th>
            </tr>

            <c:choose>
                <c:when test="${empty alertList}">
                    <tr>
                        <td colspan="3">최근 알림이 없습니다.</td>
                    </tr>
                </c:when>

                <c:otherwise>
                    <c:forEach var="alert" items="${alertList}">
                        <tr>
                            <td>${alert.created_at}</td>
                            <td>${alert.alert_content}</td>
                            <td>
                                <span class="status-badge normal">${alert.alert_status}</span>
                            </td>
                        </tr>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </table>
    </div>

</section>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>