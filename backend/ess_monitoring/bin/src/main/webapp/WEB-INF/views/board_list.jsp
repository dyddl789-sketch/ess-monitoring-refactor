<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의게시판 - ESS-M.S</title>

<%-- 공통 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">

<%-- 게시판 전용 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">
</head>

<body>

<%-- 공통 헤더 --%>
<%@ include file="/WEB-INF/views/header.jsp" %>

<%--
    게시판 전체 페이지 영역

    board-page:
    - 게시판 목록, 상세, 글쓰기 화면 전체에 적용할 공통 배경 영역
    - 메인페이지와 같은 다크 네이비 톤을 유지하기 위한 wrapper
--%>
<div class="board-page">

    <%--
        게시판 상단 소개 영역

        board-hero:
        - 게시판 제목과 설명을 보여주는 상단 배너
        - 기존 sub-hero 대신 게시판 전용 디자인 사용
    --%>
    <section class="board-hero">
        <h1>문의게시판</h1>
        <p>ESS 장비, 모니터링, 알림, 유지보수 관련 문의를 남겨주세요.</p>
    </section>

    <%--
        게시판 본문 영역

        board-container:
        - 게시판 컨텐츠의 최대 너비를 잡아주는 영역
    --%>
    <main class="board-container">

        <%--
            게시판 카드 영역

            board-card:
            - 목록 상단 툴바, 검색 영역, 테이블, 페이지 번호를 하나의 카드로 묶음
            - 화면이 흩어져 보이지 않도록 정리
        --%>
        <div class="board-card">

            <%--
                게시판 상단 툴바

                왼쪽:
                - 총 문의 개수 표시

                오른쪽:
                - 검색 폼
                - 문의하기 버튼
            --%>
            <div class="board-toolbar">

                <div class="board-toolbar-left">
                    총 <strong>${pageMaker.total}</strong>개의 문의가 있습니다.
                </div>

                <div class="board-toolbar-right">

                    <%--
                        검색 폼

                        pageNum은 검색 시 항상 1페이지부터 보이도록 1로 고정
                        amount는 현재 페이지당 게시글 수 유지
                    --%>
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

                        <button type="submit" class="btn-primary">검색</button>

                        <a href="${pageContext.request.contextPath}/board_list"
                           class="btn-secondary">
                            목록
                        </a>
                    </form>

                    <%-- 문의 작성 화면으로 이동 --%>
                    <a href="${pageContext.request.contextPath}/board_write_view"
                       class="btn-primary">
                        문의하기
                    </a>
                </div>
            </div>

            <%--
                게시판 목록 테이블

                board-table-wrap:
                - 화면이 좁아졌을 때 가로 스크롤을 허용

                board-table:
                - 게시판 목록 테이블 전용 디자인
            --%>
            <div class="board-table-wrap">
                <table class="board-table">
                    <thead>
                        <tr>
                            <th style="width:80px;">번호</th>
                            <th>제목</th>
                            <th style="width:120px;">작성자</th>
                            <th style="width:150px;">작성일</th>
                            <th style="width:80px;">조회</th>
                        </tr>
                    </thead>

                    <tbody>
                        <%-- 게시글이 없을 때 --%>
                        <c:choose>
                            <c:when test="${empty list}">
                                <tr>
                                    <td colspan="5" class="empty-row">
                                        등록된 문의가 없습니다.
                                    </td>
                                </tr>
                            </c:when>

                            <%-- 게시글 목록 출력 --%>
                            <c:otherwise>
                                <c:forEach var="board" items="${list}">
                                    <tr>
                                        <%-- 게시글 번호 --%>
                                        <td>${board.boardNo}</td>

                                        <%--
                                            게시글 제목

                                            pageNum, amount, type, keyword를 같이 넘기는 이유:
                                            상세 페이지에서 목록으로 돌아올 때
                                            기존 페이지/검색 조건을 유지하기 위해서
                                        --%>
                                        <td class="title-cell">
                                            <a href="${pageContext.request.contextPath}/board_content_view?boardNo=${board.boardNo}&pageNum=${pageMaker.cri.pageNum}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">
                                                ${board.boardTitle}
                                            </a>
                                        </td>

                                        <%-- 작성자 --%>
                                        <td>${board.memberName}</td>

                                        <%-- 작성일 --%>
                                        <td>
                                            <fmt:formatDate value="${board.createdAt}" pattern="yyyy-MM-dd"/>
                                        </td>

                                        <%-- 조회수 --%>
                                        <td>${board.boardHit}</td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%--
                페이지네이션

                board-pagination:
                - 게시판 전용 페이지 번호 디자인
            --%>
            <div class="board-pagination">

                <%-- 이전 페이지 그룹 --%>
                <c:if test="${pageMaker.prev}">
                    <a href="${pageContext.request.contextPath}/board_list?pageNum=${pageMaker.startPage - 1}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">
                        이전
                    </a>
                </c:if>

                <%-- 페이지 번호 --%>
                <c:forEach var="num" begin="${pageMaker.startPage}" end="${pageMaker.endPage}">
                    <c:choose>
                        <%-- 현재 페이지 --%>
                        <c:when test="${pageMaker.cri.pageNum == num}">
                            <span class="active">${num}</span>
                        </c:when>

                        <%-- 다른 페이지 --%>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/board_list?pageNum=${num}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">
                                ${num}
                            </a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <%-- 다음 페이지 그룹 --%>
                <c:if test="${pageMaker.next}">
                    <a href="${pageContext.request.contextPath}/board_list?pageNum=${pageMaker.endPage + 1}&amount=${pageMaker.cri.amount}&type=${pageMaker.cri.type}&keyword=${pageMaker.cri.keyword}">
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