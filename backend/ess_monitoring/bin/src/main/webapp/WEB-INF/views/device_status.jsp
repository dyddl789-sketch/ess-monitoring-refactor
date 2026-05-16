<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>장비 상태</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">

</head>

<body>

<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <h2>장비 상태</h2>
        <p>전체 장비의 현재 상태를 확인합니다.</p>

        <div class="filter-box">
            <select id="statusFilter">
                <option value="">전체 상태</option>
                <option value="NORMAL">정상</option>
                <option value="WARNING">경고</option>
                <option value="ERROR">오류</option>
                <option value="OFFLINE">오프라인</option>
            </select>

            <input type="text" id="keyword" placeholder="장비명 검색">
            <button type="button" id="searchBtn">조회</button>
        </div>

        <div class="card">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>장비명</th>
                        <th>그룹</th>
                        <th>설치 위치</th>
                        <th>SOC</th>
                        <th>현재 출력</th>
                        <th>상태</th>
                        <th>상세</th>
                    </tr>
                </thead>

                <tbody>
                    <tr>
                        <td>ESS-부산-01</td>
                        <td>부산센터</td>
                        <td>부산광역시</td>
                        <td><span class="status-normal">82%</span></td>
                        <td>9.2kW</td>
                        <td><span class="status-normal">정상</span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/monitoring/main?deviceId=1">
                                실시간 보기
                            </a>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

    </main>

</div>

</body>
</html>