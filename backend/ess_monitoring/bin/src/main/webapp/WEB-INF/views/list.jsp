<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<div class="top-box">
    <h2>ESS 모니터링 현황</h2>
    <form action="logout" method="post">
        <button type="submit" class="btn">로그아웃</button>
    </form>
</div>

<c:choose>
    <c:when test="${not empty list}">
        <table width="1000" border="1">
            <tr>
                <th>번호</th>
                <th>장비명</th>
                <th>전압(V)</th>
                <th>전류(A)</th>
                <th>SOC(%)</th>
                <th>상태</th>
                <th>측정시간</th>
            </tr>

            <c:forEach var="dto" items="${list}">
                <tr>
                    <td>${dto.ess_id}</td>
                    <td>${dto.device_name}</td>
                    <td>${dto.voltage}</td>
                    <td>${dto.current_val}</td>
                    <td>${dto.soc}</td>
                    <td>
                        <c:choose>
                            <c:when test="${dto.status eq 'NORMAL'}">
                                <span class="normal">NORMAL</span>
                            </c:when>
                            <c:when test="${dto.status eq 'CHARGING'}">
                                <span class="charging">CHARGING</span>
                            </c:when>
                            <c:when test="${dto.status eq 'DISCHARGING'}">
                                <span class="discharging">DISCHARGING</span>
                            </c:when>
                            <c:when test="${dto.status eq 'WARNING'}">
                                <span class="warning">WARNING</span>
                            </c:when>
                            <c:otherwise>
                                <span class="error">${dto.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>${dto.measured_at}</td>
                </tr>
            </c:forEach>
        </table>
    </c:when>

    <c:otherwise>
        <p class="empty-msg">등록된 모니터링 데이터가 없습니다.</p>
    </c:otherwise>
</c:choose>
</body>
</html>