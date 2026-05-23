<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>장비 관리</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
</head>

<body>
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <div class="page-header">
            <div>
                <h2>장비 관리</h2>
                <p>등록된 ESS 장비를 조회하고 관리합니다.</p>
            </div>
        </div>

        <div class="filter-box">
            <input type="text" id="keyword" placeholder="장비명 또는 위치 검색">

            <select id="statusFilter">
                <option value="">전체 상태</option>
                <option value="NORMAL">정상</option>
                <option value="WARNING">경고</option>
                <option value="ERROR">오류</option>
                <option value="OFFLINE">오프라인</option>
            </select>

            <button type="button" id="searchBtn">조회</button>

			<button type="button"
			        onclick="location.href='${pageContext.request.contextPath}/main?view=register'">
			    장비 등록
			</button>
			
			<button type="button"
			        onclick="location.href='${pageContext.request.contextPath}/main?view=register&mode=csv'">
			    CSV 일괄 등록
			</button>
        </div>

        <div class="card">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>장비명</th>
                        <th>그룹</th>
                        <th>설치 위치</th>
                        <th>설비 용량(kW)</th>
                        <th>ESS 용량(kWh)</th>
                        <th>상태</th>
                        <th>대표</th>
                        <th>설치일</th>
                        <th>관리</th>
                    </tr>
                </thead>

                <tbody id="deviceManageTableBody">
                    <tr>
                        <td colspan="9">데이터를 불러오는 중...</td>
                    </tr>
                </tbody>
            </table>
        </div>

    </main>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script>
    const contextPath = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/resources/js/device_manage.js"></script>

</body>
</html>