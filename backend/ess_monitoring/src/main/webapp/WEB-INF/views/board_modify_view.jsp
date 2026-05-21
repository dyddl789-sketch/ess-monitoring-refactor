<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="isNotice" value="${content_view.boardType eq 'NOTICE'}" />

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">

<c:choose>
    <c:when test="${isNotice}">
        <title>공지 수정 - ESS-M.S</title>
    </c:when>
    <c:otherwise>
        <title>문의 수정 - ESS-M.S</title>
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
                <h1>공지 수정</h1>
                <p>등록된 공지사항 내용을 수정합니다.</p>
            </c:when>
            <c:otherwise>
                <h1>문의 수정</h1>
                <p>작성한 문의 내용을 수정할 수 있습니다.</p>
            </c:otherwise>
        </c:choose>
    </section>

    <main class="board-container">

        <div class="form-card">

            <c:choose>
                <c:when test="${isNotice}">
                    <h2>공지사항 수정</h2>
                    <p>공지 내용 수정 후 저장 버튼을 누르면 내용이 변경됩니다.</p>
                </c:when>
                <c:otherwise>
                    <h2>문의 내용 수정</h2>
                    <p>수정 후 저장 버튼을 누르면 게시글 내용이 변경됩니다.</p>
                </c:otherwise>
            </c:choose>

            <form action="${pageContext.request.contextPath}/modify" method="post">

                <input type="hidden" name="boardNo" value="${content_view.boardNo}">
                <input type="hidden" name="boardType" value="${content_view.boardType}">

                <input type="hidden" name="pageNum" value="${empty cri.pageNum ? 1 : cri.pageNum}">
                <input type="hidden" name="amount" value="${empty cri.amount ? 10 : cri.amount}">
                <input type="hidden" name="type" value="${cri.type}">
                <input type="hidden" name="keyword" value="${cri.keyword}">

                <div class="form-group">
                    <label for="boardTitle">제목</label>
                    <input type="text"
                           id="boardTitle"
                           name="boardTitle"
                           class="board-input"
                           value="${content_view.boardTitle}"
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
                              required>${content_view.boardContent}</textarea>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn-primary">
                        수정 완료
                    </button>

                    <a href="${pageContext.request.contextPath}/board_content_view?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                       class="btn-secondary">
                        취소
                    </a>

                    <a href="${pageContext.request.contextPath}/${isNotice ? 'notice_list' : 'qna_list'}?pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}&boardType=${content_view.boardType}"
                       class="btn-secondary">
                        목록
                    </a>
                </div>

            </form>
        </div>

        <div class="notice-box">
            <c:choose>
                <c:when test="${isNotice}">
                    ※ 공지사항 수정은 관리자 권한으로만 가능합니다.
                </c:when>
                <c:otherwise>
                    ※ 문의 내용 수정 후에는 관리자 답변 내용과 차이가 생길 수 있습니다.
                </c:otherwise>
            </c:choose>
        </div>

    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>