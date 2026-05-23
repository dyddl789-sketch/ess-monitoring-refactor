<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>발전량 분석</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">

<style>
.chart-placeholder {
    height: 280px;
    border-radius: 12px;
    background: #f8fafc;
    display: flex;
    align-items: end;
    gap: 18px;
    padding: 20px;
    border: 1px solid #e5e7eb;
}

.bar-item {
    flex: 1;
    text-align: center;
}

.bar-value {
    font-size: 13px;
    margin-bottom: 6px;
}

.bar {
    width: 38px;
    margin: 0 auto 8px;
    background: #2563eb;
    border-radius: 8px 8px 0 0;
}

.bar-label {
    font-size: 12px;
    color: #475569;
}
</style>
</head>

<body>
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <h2>발전량 분석</h2>
        <p>선택 기간의 발전량, 충전량, 사용량, 절감 금액을 분석합니다.</p>

        <form method="get" action="${pageContext.request.contextPath}/analysis/generation">
		    <div class="filter-box">
		        <input type="date" name="startDate" value="${startDate}">
		        <input type="date" name="endDate" value="${endDate}">
		
		        <!-- 장비 선택 필터 -->
		        <select name="deviceId">
		            <option value="">전체 장비</option>
		
		            <c:forEach var="device" items="${deviceSelectList}">
		                <option value="${device.deviceId}"
		                    <c:if test="${selectedDeviceId eq device.deviceId}">selected</c:if>>
		                    ${device.deviceName}
		                </option>
		            </c:forEach>
		        </select>
		
		        <button type="submit">조회</button>
		    </div>
		</form>

        <div class="card">
            <h3>일자별 발전량</h3>

            <div class="chart-placeholder">
                <c:choose>
                    <c:when test="${empty dailyList}">
                        <div>발전량 데이터가 없습니다.</div>
                    </c:when>

                    <c:otherwise>
                        <c:forEach var="item" items="${dailyList}">
                            <div class="bar-item">
                                <div class="bar-value">
                                    <fmt:formatNumber value="${item.generationKwh}" pattern="#,##0.0"/>
                                </div>

                                <div class="bar"
                                     style="height:${item.generationKwh * 2}px;"></div>

                                <div class="bar-label">${item.label}</div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <br>

        <div class="card">
            <h3>장비별 발전량</h3>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>장비명</th>
                        <th>발전량(kWh)</th>
                        <th>충전량(kWh)</th>
                        <th>사용량(kWh)</th>
                        <th>절감 금액(원)</th>
                    </tr>
                </thead>

                <tbody>
                    <c:choose>
                        <c:when test="${empty deviceList}">
                            <tr>
                                <td colspan="5">데이터가 없습니다.</td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="item" items="${deviceList}">
                                <tr>
                                    <td>${item.label}</td>
                                    <td>
                                        <fmt:formatNumber value="${item.generationKwh}" pattern="#,##0.0"/>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${item.chargedKwh}" pattern="#,##0.0"/>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${item.usedKwh}" pattern="#,##0.0"/>
                                    </td>
                                    <td>
                                        <fmt:formatNumber value="${item.savedCost}" pattern="#,##0"/>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

    </main>
</div>
</body>
</html>