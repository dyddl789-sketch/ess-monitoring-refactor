<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>그룹 관리</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
</head>

<body>
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <div class="page-header">
            <div>
                <h2>그룹 관리</h2>
                <p>기업 사용자의 장비 그룹을 생성하고 관리합니다.</p>
            </div>
        </div>

        <div class="card">
            <h3>그룹 등록</h3>

            <form action="${pageContext.request.contextPath}/group/insert" method="post">
                <div class="filter-box">
                    <input type="text" name="groupName" placeholder="그룹명" required>
                    <input type="text" name="description" placeholder="그룹 설명">
                    <button type="submit">등록</button>
                </div>
            </form>
        </div>

        <br>

        <div class="card">
            <h3>그룹 목록</h3>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>그룹명</th>
                        <th>설명</th>
                        <th>장비 수</th>
                        <th>생성일</th>
                        <th>관리</th>
                    </tr>
                </thead>

                <tbody>
                    <c:choose>
                        <c:when test="${empty groupList}">
                            <tr>
                                <td colspan="5">등록된 그룹이 없습니다.</td>
                            </tr>
                        </c:when>

                        <c:otherwise>
                            <c:forEach var="group" items="${groupList}">
                                <tr>
                                    <form action="${pageContext.request.contextPath}/group/update" method="post">
                                        <input type="hidden" name="groupId" value="${group.groupId}">

                                        <td>
                                            <input type="text" name="groupName" value="${group.groupName}" required>
                                        </td>

                                        <td>
                                            <input type="text" name="description" value="${group.description}">
                                        </td>

                                        <td>
                                            ${group.deviceCount}대
                                        </td>

                                        <td>
                                            <fmt:formatDate value="${group.createdAt}" pattern="yyyy-MM-dd"/>
                                        </td>

                                        <td>
                                            <button type="submit">수정</button>

                                            <a class="btn-danger-small"
                                               href="${pageContext.request.contextPath}/group/delete?groupId=${group.groupId}"
                                               onclick="return confirm('이 그룹을 삭제하시겠습니까? 그룹에 속한 장비는 그룹 없음 상태가 됩니다.');">
                                                삭제
                                            </a>
                                        </td>
                                    </form>
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