<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/alert_detail.css">
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <div class="page-header">
            <h2>알림 상세</h2>
            <p>알림 발생 정보 및 처리 상태를 확인합니다.</p>
        </div>

        <div class="card">

            <table class="data-table">

                <tr>
                    <th>발생 시간</th>
                    <td>
                        <fmt:formatDate value="${alert.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                    </td>
                </tr>

                <tr>
                    <th>장비명</th>
                    <td>${alert.deviceName}</td>
                </tr>

                <tr>
                    <th>등급</th>
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
                </tr>

                <tr>
                    <th>알림 유형</th>
                    <td>${alert.alertType}</td>
                </tr>

                <tr>
                    <th>알림 내용</th>
                    <td>${alert.message}</td>
                </tr>

                <tr>
                    <th>자동 제어</th>
                    <td>
                        <c:choose>
                            <c:when test="${empty alert.controlAction}">
                                없음
                            </c:when>
                            <c:otherwise>
                                ${alert.controlAction}
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>

                <tr>
                    <th>처리 상태</th>
                    <td>
                        <c:choose>
                            <c:when test="${alert.status eq 'OPEN'}">
                                <span class="status-warning">미처리</span>
                            </c:when>
                            <c:when test="${alert.status eq 'RESOLVED'}">
                                <span class="status-normal">처리완료</span>
                            </c:when>
                            <c:otherwise>
                                ${alert.status}
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>

            </table>

            <!-- 버튼 영역 -->
            <div style="margin-top:20px; display:flex; gap:10px;">

                <!-- 장비 이동 -->
                <a class="btn-link"
                   href="${pageContext.request.contextPath}/monitoring/main?deviceId=${alert.deviceId}">
                    장비 실시간 보기
                </a>

                <!-- 처리 완료 -->
                <c:if test="${alert.status eq 'OPEN'}">
                    <a class="btn-link"
                       href="${pageContext.request.contextPath}/alert/resolve?alertId=${alert.alertId}">
                        처리 완료
                    </a>
                </c:if>

                <!-- 목록 -->
                <a class="btn-link"
                   href="${pageContext.request.contextPath}/alert/list">
                    목록으로
                </a>

            </div>

        </div>

    </main>

</div>