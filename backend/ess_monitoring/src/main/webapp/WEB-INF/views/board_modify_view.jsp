<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의 수정 - ESS-M.S</title>

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
    게시판 수정 전체 영역

    board-page:
    - 게시판 목록/상세/글쓰기/수정 화면의 배경을 통일하기 위한 wrapper
--%>
<div class="board-page">

    <%--
        상단 소개 영역

        board-hero:
        - 현재 페이지가 문의 수정 화면임을 보여주는 영역
    --%>
    <section class="board-hero">
        <h1>문의 수정</h1>
        <p>작성한 문의 내용을 수정할 수 있습니다.</p>
    </section>

    <%--
        수정 폼 영역

        board-container:
        - 본문 최대 너비와 여백 조정
    --%>
    <main class="board-container">

        <%--
            수정 폼 카드

            form-card:
            - 글쓰기 화면과 동일한 카드 디자인 사용
        --%>
        <div class="form-card">

            <h2>문의 내용 수정</h2>
            <p>수정 후 저장 버튼을 누르면 게시글 내용이 변경됩니다.</p>

            <%--
                게시글 수정 form

                action="/modify":
                - BoardController의 @RequestMapping("/modify") 메서드로 전송된다.

                method="post":
                - 수정 작업이므로 POST 방식 사용
            --%>
            <form action="${pageContext.request.contextPath}/modify" method="post">

                <%--
                    boardNo:
                    - 어떤 게시글을 수정할지 구분하는 게시글 번호
                    - Controller에서 params.get("boardNo")로 사용한다.
                --%>
                <input type="hidden" name="boardNo" value="${content_view.boardNo}">

                <%--
                    목록 복귀용 페이징/검색 조건

                    수정 완료 후 /board_list로 돌아갈 때
                    기존 페이지 번호와 검색 조건을 유지하기 위한 값
                --%>
                <input type="hidden" name="pageNum" value="${empty cri.pageNum ? 1 : cri.pageNum}">
                <input type="hidden" name="amount" value="${empty cri.amount ? 10 : cri.amount}">
                <input type="hidden" name="type" value="${cri.type}">
                <input type="hidden" name="keyword" value="${cri.keyword}">

                <%--
                    제목

                    name="boardTitle":
                    - BoardDTO / Mapper에서 사용하는 필드명과 맞춘다.
                    - 현재 board_list.jsp에서 boardTitle을 사용하고 있으므로 camelCase 기준으로 작성
                --%>
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

                <%--
                    내용

                    name="boardContent":
                    - BoardDTO / Mapper에서 사용하는 필드명과 맞춘다.
                --%>
                <div class="form-group">
                    <label for="boardContent">문의 내용</label>
                    <textarea id="boardContent"
                              name="boardContent"
                              class="board-textarea"
                              rows="10"
                              placeholder="문의 내용을 입력하세요"
                              required>${content_view.boardContent}</textarea>
                </div>

                <%--
                    버튼 영역

                    수정 완료:
                    - /modify로 form 전송

                    취소:
                    - 기존 상세 페이지로 돌아감
                --%>
                <div class="form-actions">
                    <button type="submit" class="btn-primary">
                        수정 완료
                    </button>

                    <a href="${pageContext.request.contextPath}/board_content_view?boardNo=${content_view.boardNo}&pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}"
                       class="btn-secondary">
                        취소
                    </a>

                    <a href="${pageContext.request.contextPath}/board_list?pageNum=${empty cri.pageNum ? 1 : cri.pageNum}&amount=${empty cri.amount ? 10 : cri.amount}&type=${cri.type}&keyword=${cri.keyword}"
                       class="btn-secondary">
                        목록
                    </a>
                </div>

            </form>
        </div>

        <%--
            안내 박스

            글 수정 시 주의사항 표시
        --%>
        <div class="notice-box">
            ※ 문의 내용 수정 후에는 관리자 답변 내용과 차이가 생길 수 있습니다.
        </div>

    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

</body>
</html>