<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>알림</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
</head>

<body>
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <div class="page-header">
            <div>
                <h2>알림</h2>
                <p>장비 이상 상태와 처리 이력을 확인합니다.</p>
            </div>
        </div>

        <div class="filter-box">
            <select id="levelFilter">
                <option value="">전체 등급</option>
                <option value="INFO">정보</option>
                <option value="WARNING">경고</option>
                <option value="CRITICAL">심각</option>
            </select>

            <select id="statusFilter">
                <option value="">전체 처리상태</option>
                <option value="OPEN">미처리</option>
                <option value="RESOLVED">처리완료</option>
            </select>

            <button type="button" id="searchBtn">조회</button>
        </div>

        <div class="card">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>발생 시간</th>
                        <th>장비명</th>
                        <th>등급</th>
                        <th>알림 유형</th>
                        <th>내용</th>
                        <th>자동 제어</th>
                        <th>처리 상태</th>
                        <th>장비 확인</th>
                        <th>상세</th>
                    </tr>
                </thead>

                <tbody>
                    <c:choose>

                        <c:when test="${empty alertList}">
                            <tr>
                                <td colspan="9">조회된 알림이 없습니다.</td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="alert" items="${alertList}">
                                <tr>
                                    <td>
                                        <fmt:formatDate value="${alert.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </td>

                                    <td>${alert.deviceName}</td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${alert.alertLevel eq 'CRITICAL'}">
                                                <span class="badge-danger">심각</span>
                                            </c:when>
                                            <c:when test="${alert.alertLevel eq 'WARNING'}">
                                                <span class="badge-warning">경고</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-info">정보</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>${alert.alertType}</td>

                                    <td>${alert.message}</td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${empty alert.controlAction}">
                                                -
                                            </c:when>
                                            <c:otherwise>
                                                ${alert.controlAction}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${alert.status eq 'OPEN'}">
                                                <span class="status-warning">미처리</span>
                                            </c:when>
                                            <c:when test="${alert.status eq 'RESOLVED'}">
                                                <span class="status-normal">처리완료</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-nodata">${alert.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <a class="btn-link"
                                           href="${pageContext.request.contextPath}/monitoring/main?deviceId=${alert.deviceId}">
                                            장비 확인
                                        </a>
                                    </td>

                                    <td>
                                        <a class="btn-link"
                                           href="${pageContext.request.contextPath}/alert/detail?alertId=${alert.alertId}">
                                            상세
                                        </a>
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