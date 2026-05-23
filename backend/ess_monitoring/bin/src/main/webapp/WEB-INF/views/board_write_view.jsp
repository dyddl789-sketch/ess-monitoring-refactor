<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="isNotice" value="${boardType eq 'NOTICE'}" />

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">

<c:choose>
    <c:when test="${isNotice}">
        <title>공지 작성 - ESS-M.S</title>
    </c:when>
    <c:otherwise>
        <title>문의 작성 - ESS-M.S</title>
    </c:otherwise>
</c:choose>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="board-page">

    <section class="board-hero">
        <c:choose>
            <c:when test="${isNotice}">
                <h1>공지 작성</h1>
                <p>ESS 운영 및 시스템 공지사항을 등록합니다.</p>
            </c:when>
            <c:otherwise>
                <h1>문의 작성</h1>
                <p>ESS 장비, 모니터링, 알림 관련 문의를 남겨주세요.</p>
            </c:otherwise>
        </c:choose>
    </section>

    <main class="board-container">

        <div class="form-card">

            <c:choose>
                <c:when test="${isNotice}">
                    <h2>공지사항 등록</h2>
                    <p>회원에게 안내할 운영 공지 내용을 입력하세요.</p>
                </c:when>
                <c:otherwise>
                    <h2>문의 등록</h2>
                    <p>문의 내용을 작성하면 관리자가 답변을 등록합니다.</p>
                </c:otherwise>
            </c:choose>

            <form action="${pageContext.request.contextPath}/board_write" method="post">

                <input type="hidden" name="boardType" value="${boardType}">

                <div class="form-group">
                    <label for="boardTitle">제목</label>
                    <input type="text"
                           id="boardTitle"
                           name="boardTitle"
                           class="board-input"
                           placeholder="제목을 입력하세요"
                           required>
                </div>

                <div class="form-group">
                    <label for="boardContent">
                        <c:choose>
                            <c:when test="${isNotice}">공지 내용</c:when>
                            <c:otherwise>문의 내용</c:otherwise>
                        </c:choose>
                    </label>

                    <textarea id="boardContent"
                              name="boardContent"
                              class="board-textarea"
                              rows="10"
                              placeholder="내용을 입력하세요"
                              required></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-primary">
                        <c:choose>
                            <c:when test="${isNotice}">공지 등록</c:when>
                            <c:otherwise>문의 등록</c:otherwise>
                        </c:choose>
                    </button>

                    <a href="${pageContext.request.contextPath}/${isNotice ? 'notice_list' : 'qna_list'}"
                       class="btn-secondary">
                        취소
                    </a>
                </div>

            </form>
        </div>

        <div class="notice-box">
            <c:choose>
                <c:when test="${isNotice}">
                    ※ 공지사항은 관리자만 작성할 수 있습니다.
                </c:when>
                <c:otherwise>
                    ※ 문의 내용은 관리자 답변과 함께 상세 화면에서 확인할 수 있습니다.
                </c:otherwise>
            </c:choose>
        </div>

    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>