<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="currentBoardType" value="${pageMaker.cri.boardType}" />

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의/공지게시판 - ESS-M.S</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="board-page">

    <section class="board-hero">
        <h1>문의/공지게시판</h1>
        <p>ESS-M.S 공지사항과 사용자 문의를 한 곳에서 확인하세요.</p>
    </section>

    <main class="board-container">

        <div class="board-card">

            <div class="board-tab-menu">
                <a href="${pageContext.request.contextPath}/board_list"
                   class="${empty currentBoardType ? 'active' : ''}">
                    전체
                </a>

                <a href="${pageContext.request.contextPath}/board_list?boardType=NOTICE"
                   class="${currentBoardType eq 'NOTICE' ? 'active' : ''}">
                    공지
                </a>

                <a href="${pageContext.request.contextPath}/board_list?boardType=QNA"
                   class="${currentBoardType eq 'QNA' ? 'active' : ''}">
                    문의
                </a>
            </div>

            <div class="board-toolbar">

                <div class="board-toolbar-left">
                    총 <strong>${pageMaker.total}</strong>개의 게시글이 있습니다.
                </div>

                <div class="board-toolbar-right">

                    <form action="${pageContext.request.contextPath}/board_list"
                          method="get"
                          style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">

                        <select name="type" class="board-select" style="width:120px;">
                            <option value="T" ${pageMaker.cri.type == 'T' ? 'selected' : ''}>제목</option>
                            <option value="C" ${pageMaker.cri.type == 'C' ? 'selected' : ''}>내용</option>
                            <option value="W" ${pageMaker.cri.type == 'W' ? 'selected' : ''}>작성자</option>
                            <option value="TC" ${pageMaker.cri.type == 'TC' ? 'selected' : ''}>제목+내용</option>
                            <option value="TW" ${pageMaker.cri.type == 'TW' ? 'selected' : ''}>제목+작성자</option>
                            <option value="TCW" ${pageMaker.cri.type == 'TCW' ? 'selected' : ''}>전체</option>
                        </select>

                        <input type="text"
                               name="keyword"
                               value="${pageMaker.cri.keyword}"
                               class="board-input"
                               style="width:220px;"
                               placeholder="검색어 입력">

                        <input type="hidden" name="pageNum" value="1">
                        <input type="hidden" name="amount" value="${pageMaker.cri.amount}">

                        <c:if test="${not empty currentBoardType}">
                            <input type="hidden" name="boardType" value="${currentBoardType}">
                        </c:if>

                        <button type="submit" class="btn-primary">검색</button>

                        <a href="${pageContext.request.contextPath}/board_list"
                           class="btn-secondary">
                            전체목록
                        </a>
                    </form>

                    <a href="${pageContext.request.contextPath}/board_write_view?boardType=QNA"
                       class="btn-primary">
                        문의하기
                    </a>

                    <c:if test="${sessionScope.role == 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/board_write_view?boardType=NOTICE"
                           class="btn-secondary">
                            공지 작성
                        </a>
                    </c:if>

                </div>
            </div>

            <div class="board-table-wrap">
                <table class="board-table">
                    <thead>
                        <tr>
                            <th style="width:80px;">번호</th>
                            <th style="width:90px;">구분</th>
                            <th>제목</th>
                            <th style="width:120px;">작성자</th>
                            <th style="width:150px;">작성일</th>
                            <th style="width:80px;">조회</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:choose>
                            <c:when test="${empty list}">
                                <tr>
                                    <td colspan="6" class="empty-row">
                                        등록된 게시글이 없습니다.
                                    </td>
                                </tr>
                            </c:when>

                            <c:otherwise>
                                <c:forEach var="board" items="${list}">
                                    <tr>
                                        <td>${board.boardNo}</td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${board.boardType eq 'NOTICE'}">
                                                    <span class="notice-badge">공지</span>
                                                </c:when>

                                                <c:otherwise>
                                                    <span class="qna-badge">문의</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td class="title-cell">
                                            <a href="${pageContext.request.contextPath}/board_content_view?boardNo=${board.boardNo}&pageNum=${pageMaker.cri.pageNum}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}&boardType=${currentBoardType}">
                                                ${board.boardTitle}
                                            </a>
                                        </td>

                                        <td>${board.memberName}</td>

                                        <td>
                                            <fmt:formatDate value="${board.createdAt}" pattern="yyyy-MM-dd"/>
                                        </td>

                                        <td>${board.boardHit}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <div class="board-pagination">

                <c:if test="${pageMaker.prev}">
                    <a href="${pageContext.request.contextPath}/board_list?pageNum=${pageMaker.startPage - 1}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}&boardType=${currentBoardType}">
                        이전
                    </a>
                </c:if>

                <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                    <c:choose>
                        <c:when test="${pageMaker.cri.pageNum == num}">
                            <span class="active">${num}</span>
                        </c:when>

                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/board_list?pageNum=${num}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}&boardType=${currentBoardType}">
                                ${num}
                            </a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <c:if test="${pageMaker.next}">
                    <a href="${pageContext.request.contextPath}/board_list?pageNum=${pageMaker.endPage + 1}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}&boardType=${currentBoardType}">
                        다음
                    </a>
                </c:if>
            </div>

        </div>
    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>