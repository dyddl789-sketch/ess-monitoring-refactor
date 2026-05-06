<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>에너지 통계</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">

<style>
.stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-bottom: 20px;
}

.stats-card {
    background: #fff;
    border: 1px solid #e5e7eb;
    border-radius: 14px;
    padding: 20px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.04);
}

.stats-card h4 {
    margin: 0 0 10px;
    color: #64748b;
    font-size: 14px;
}

.stats-card strong {
    font-size: 24px;
}

.chart-placeholder {
    min-height: 260px;
    border-radius: 12px;
    background: #f8fafc;
    border: 1px solid #e5e7eb;
    padding: 20px;
}
</style>
</head>

<body>
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <h2>에너지 통계</h2>
        <p>기간별 에너지 생산량, 절감 금액, 운영 효율을 확인합니다.</p>

        <form method="get" action="${pageContext.request.contextPath}/analysis/energy">
            <div class="filter-box">
                <input type="date" name="startDate" value="${startDate}">
                <input type="date" name="endDate" value="${endDate}">
                <button type="submit">조회</button>
            </div>
        </form>

        <div class="stats-grid">
            <c:set var="totalDailyKwh" value="0"/>
            <c:set var="totalCost" value="0"/>
            <c:set var="totalEfficiency" value="0"/>
            <c:set var="count" value="0"/>

            <c:forEach var="item" items="${dailyList}">
                <c:set var="totalDailyKwh" value="${totalDailyKwh + item.dailyKwh}"/>
                <c:set var="totalCost" value="${totalCost + item.cost}"/>
                <c:set var="totalEfficiency" value="${totalEfficiency + item.efficiency}"/>
                <c:set var="count" value="${count + 1}"/>
            </c:forEach>

            <div class="stats-card">
                <h4>총 에너지량</h4>
                <strong>
                    <fmt:formatNumber value="${totalDailyKwh}" pattern="#,##0.0"/> kWh
                </strong>
            </div>

            <div class="stats-card">
                <h4>총 절감 금액</h4>
                <strong>
                    <fmt:formatNumber value="${totalCost}" pattern="#,##0"/> 원
                </strong>
            </div>

            <div class="stats-card">
                <h4>평균 효율</h4>
                <strong>
                    <c:choose>
                        <c:when test="${count == 0}">
                            0.0%
                        </c:when>
                        <c:otherwise>
                            <fmt:formatNumber value="${totalEfficiency / count}" pattern="#,##0.0"/>%
                        </c:otherwise>
                    </c:choose>
                </strong>
            </div>

            <div class="stats-card">
                <h4>조회 기간</h4>
                <strong>${startDate} ~ ${endDate}</strong>
            </div>
        </div>

        <div class="card">
            <h3>일자별 에너지 통계</h3>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>날짜</th>
                        <th>일일 에너지(kWh)</th>
                        <th>월간 에너지(kWh)</th>
                        <th>절감 금액(원)</th>
                        <th>운영 효율(%)</th>
                    </tr>
                </thead>

                <tbody>
                    <c:choose>
                        <c:when test="${empty dailyList}">
                            <tr>
                                <td colspan="5">데이터가 없습니다.</td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="item" items="${dailyList}">
                                <tr>
                                    <td>${item.label}</td>
                                    <td><fmt:formatNumber value="${item.dailyKwh}" pattern="#,##0.0"/></td>
                                    <td><fmt:formatNumber value="${item.monthlyKwh}" pattern="#,##0.0"/></td>
                                    <td><fmt:formatNumber value="${item.cost}" pattern="#,##0"/></td>
                                    <td><fmt:formatNumber value="${item.efficiency}" pattern="#,##0.0"/></td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <br>

        <div class="card">
            <h3>장비별 에너지 통계</h3>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>장비명</th>
                        <th>에너지량(kWh)</th>
                        <th>월간 에너지(kWh)</th>
                        <th>절감 금액(원)</th>
                        <th>평균 효율(%)</th>
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
                                    <td><fmt:formatNumber value="${item.dailyKwh}" pattern="#,##0.0"/></td>
                                    <td><fmt:formatNumber value="${item.monthlyKwh}" pattern="#,##0.0"/></td>
                                    <td><fmt:formatNumber value="${item.cost}" pattern="#,##0"/></td>
                                    <td><fmt:formatNumber value="${item.efficiency}" pattern="#,##0.0"/></td>
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