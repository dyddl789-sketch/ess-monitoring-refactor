<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의게시판 - ESS-M.S</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">

<style>
.container { width: 80%; margin: 0 auto; }
.sub-hero {
    background-color: #2c3e50;
    color: white;
    padding: 60px 0;
    text-align: center;
}
.board { padding: 50px 0; min-height: 500px; }
.board-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}
.board-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}
.board-table th {
    border-top: 2px solid #333;
    border-bottom: 1px solid #ddd;
    padding: 15px;
    background: #f9f9f9;
}
.board-table td {
    border-bottom: 1px solid #ddd;
    padding: 15px;
}
.board-table a {
    text-decoration: none;
    color: #333;
    font-weight: bold;
}
.board-table a:hover { color: #007bff; }
.search-box {
    display: flex;
    gap: 5px;
}
.search-box select,
.search-box input {
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 4px;
}
.btn {
    padding: 8px 15px;
    background:#007bff;
    color:white;
    border:none;
    border-radius:4px;
    cursor:pointer;
    text-decoration: none;
}
.btn-gray {
    background:#6c757d;
}
.pagination {
    text-align: center;
    margin-top: 30px;
}
.pagination a {
    display: inline-block;
    padding: 8px 13px;
    border: 1px solid #ddd;
    color: #333;
    text-decoration: none;
    border-radius: 4px;
    margin: 0 2px;
}
.pagination a.active {
    background-color: #007bff;
    color: white;
    border-color: #007bff;
}
.empty-row {
    text-align: center;
    color: #777;
}
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<section class="sub-hero">
    <div class="container">
        <h2>문의게시판</h2>
        <p>ESS 장비, 모니터링, 알림, 유지보수 관련 문의를 남겨주세요.</p>
    </div>
</section>

<main class="container board">

    <div class="board-header">
        <p>총 <strong>${pageMaker.total}</strong>개의 문의가 있습니다.</p>

        <form action="${pageContext.request.contextPath}/board_list" method="get" class="search-box">
            <select name="type">
                <option value="T" ${pageMaker.cri.type == 'T' ? 'selected' : ''}>제목</option>
                <option value="C" ${pageMaker.cri.type == 'C' ? 'selected' : ''}>내용</option>
                <option value="W" ${pageMaker.cri.type == 'W' ? 'selected' : ''}>작성자</option>
                <option value="TC" ${pageMaker.cri.type == 'TC' ? 'selected' : ''}>제목+내용</option>
                <option value="TW" ${pageMaker.cri.type == 'TW' ? 'selected' : ''}>제목+작성자</option>
                <option value="TCW" ${pageMaker.cri.type == 'TCW' ? 'selected' : ''}>전체</option>
            </select>

            <input type="text" name="keyword" value="${pageMaker.cri.keyword}" placeholder="검색어 입력">
            <input type="hidden" name="pageNum" value="1">
            <input type="hidden" name="amount" value="${pageMaker.cri.amount}">
            <button type="submit" class="btn">검색</button>
            <a href="${pageContext.request.contextPath}/board_list" class="btn btn-gray">목록</a>
        </form>
    </div>

    <div style="text-align:right; margin-bottom:10px;">
        <a href="${pageContext.request.contextPath}/board_write_view" class="btn">문의하기</a>
    </div>

    <table class="board-table">
        <thead>
            <tr>
                <th style="width:80px; text-align:center;">번호</th>
                <th>제목</th>
                <th style="width:120px; text-align:center;">작성자</th>
                <th style="width:150px; text-align:center;">작성일</th>
                <th style="width:80px; text-align:center;">조회</th>
            </tr>
        </thead>

		<tbody>
		    <c:choose>
		        <c:when test="${empty list}">
		            <tr>
		                <td colspan="5" class="empty-row">등록된 문의가 없습니다.</td>
		            </tr>
		        </c:when>
		
		        <c:otherwise>
		            <c:forEach var="board" items="${list}">
		                <tr>
		                    <td style="text-align:center;">${board.boardNo}</td>
		                    <td>
		                        <a href="${pageContext.request.contextPath}/board_content_view?boardNo=${board.boardNo}&pageNum=${pageMaker.cri.pageNum}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">
		                            ${board.boardTitle}
		                        </a>
		                    </td>
		                    <td style="text-align:center;">${board.memberName}</td>
		                    <td style="text-align:center;">
		                        <fmt:formatDate value="${board.createdAt}" pattern="yyyy-MM-dd"/>
		                    </td>
		                    <td style="text-align:center;">${board.boardHit}</td>
		                </tr>
		            </c:forEach>
		        </c:otherwise>
		    </c:choose>
		</tbody>
    </table>

    <div class="pagination">
        <c:if test="${pageMaker.prev}">
            <a href="${pageContext.request.contextPath}/board_list?pageNum=${pageMaker.startPage - 1}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">이전</a>
        </c:if>

        <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
            <a class="${pageMaker.cri.pageNum == num ? 'active' : ''}"
               href="${pageContext.request.contextPath}/board_list?pageNum=${num}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">
                ${num}
            </a>
        </c:forEach>

        <c:if test="${pageMaker.next}">
            <a href="${pageContext.request.contextPath}/board_list?pageNum=${pageMaker.endPage + 1}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">다음</a>
        </c:if>
    </div>
</main>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>