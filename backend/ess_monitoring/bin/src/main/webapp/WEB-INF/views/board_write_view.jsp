<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의하기 - ESS-M.S</title>

<%-- 공통 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">

<%-- 게시판 전용 CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">
</head>

<body>

<%-- 
    로그인 체크

    member_id가 없으면 로그인하지 않은 상태로 판단한다.
    기존 코드의 memberId가 아니라 프로젝트에서 사용 중인 sessionScope.member_id 기준으로 맞춘다.
--%>
<c:if test="${empty sessionScope.memberId and empty sessionScope.member_id}">
    <script>
        alert("로그인이 필요합니다.");
        location.href = "${pageContext.request.contextPath}/login_view";
    </script>
</c:if>

<%-- 공통 헤더 --%>
<%@ include file="/WEB-INF/views/header.jsp" %>

<%--
    게시판 글쓰기 전체 영역

    board-page:
    - 게시판 목록, 상세, 글쓰기 화면의 배경을 통일하기 위한 wrapper
--%>
<div class="board-page">

    <%--
        상단 소개 영역

        board-hero:
        - 글쓰기 페이지의 제목과 설명을 표시
    --%>
    <section class="board-hero">
        <h1>문의하기</h1>
        <p>설치문의, 장비 등록, 모니터링 이상, 알림 오류 등을 상세히 작성해주세요.</p>
    </section>

    <%--
        글쓰기 본문 영역

        board-container:
        - 본문 최대 너비와 상하 여백 조정
    --%>
    <main class="board-container">

        <%--
            글쓰기 폼 카드

            form-card:
            - 흰색 카드 형태의 입력 폼
            - 다크 배경과 대비를 주어 입력 영역을 명확하게 보여준다.
        --%>
        <div class="form-card">

            <h2>문의 등록</h2>
            <p>입력하신 문의는 관리자 확인 후 답변이 등록됩니다.</p>

            <%--
                문의 등록 form

                요청 주소:
                POST /board_write

                boardTitle:
                - 사용자가 입력한 제목 앞에 문의 유형을 붙여 hidden input으로 전송
                - 예: [장비문의] 배터리 충전량 문의
            --%>
            <form id="boardWriteForm"
                  action="${pageContext.request.contextPath}/board_write"
                  method="post">

                <%--
                    작성자 / 회원 유형

                    readonly:
                    - 사용자가 수정하지 못하게 표시용으로만 사용
                    - 실제 작성자 member_id는 Controller에서 session으로 처리하는 것이 안전함
                --%>
                <div class="form-row">
                    <div class="form-group">
                        <label>작성자</label>
                        <input type="text"
                               class="board-input"
							   value="${not empty sessionScope.memberName ? sessionScope.memberName : sessionScope.member_name}"                               
                               readonly>
                    </div>

                    <div class="form-group">
                        <label>회원 유형</label>
                        <input type="text"
                               class="board-input"
							   value="${not empty sessionScope.userType ? sessionScope.userType : sessionScope.user_type}"                          
                               readonly>
                    </div>
                </div>

                <%--
                    문의 유형

                    이 값은 직접 DB 컬럼으로 보내지 않고,
                    JavaScript에서 제목 앞에 붙여 boardTitle로 전송한다.
                --%>
                <div class="form-group">
                    <label for="category">문의 유형</label>
                    <select id="category" class="board-select">
                        <option value="장비문의">장비문의</option>
                        <option value="모니터링문의">모니터링문의</option>
                        <option value="알림문의">알림문의</option>
                        <option value="에너지분석문의">에너지분석문의</option>
                        <option value="계정문의">계정문의</option>
                        <option value="기타문의">기타문의</option>
                    </select>
                </div>

                <%--
                    제목 입력

                    titleInput:
                    - 화면에서 사용자가 입력하는 제목

                    boardTitle:
                    - 실제 Controller로 전송되는 제목
                    - submit 직전에 [문의유형] + 제목 형태로 값 세팅
                --%>
                <div class="form-group">
                    <label for="titleInput">제목</label>
                    <input type="text"
                           id="titleInput"
                           class="board-input"
                           placeholder="문의 제목을 입력하세요"
                           required>

                    <input type="hidden" id="boardTitle" name="boardTitle">
                </div>

                <%--
                    문의 내용

                    name="boardContent":
                    - Controller/DTO 필드명과 맞춰야 한다.
                --%>
                <div class="form-group">
                    <label for="boardContent">문의 내용</label>
                    <textarea id="boardContent"
                              name="boardContent"
                              class="board-textarea"
                              rows="10"
                              placeholder="문의 내용을 상세히 입력해주세요."
                              required></textarea>
                </div>

                <%-- 버튼 영역 --%>
                <div class="form-actions">
                    <button type="submit" class="btn-primary">문의 등록</button>

                    <a href="${pageContext.request.contextPath}/board_list"
                       class="btn-secondary">
                        목록
                    </a>
                </div>

            </form>
        </div>

        <%--
            주의 안내 박스

            notice-box:
            - 기존 분홍색 경고 박스를 다크 테마에 맞는 차분한 안내 박스로 변경
        --%>
        <div class="notice-box">
            ※ 욕설, 비방, 허위 문의는 제한될 수 있습니다.
        </div>

    </main>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
/*
    문의 등록 전 제목 가공

    사용자가 입력한 제목:
    예) 배터리 충전량 문의

    문의 유형:
    예) 장비문의

    실제 전송 제목:
    예) [장비문의] 배터리 충전량 문의
*/
document.getElementById("boardWriteForm").addEventListener("submit", function () {
    const category = document.getElementById("category").value;
    const title = document.getElementById("titleInput").value.trim();

    document.getElementById("boardTitle").value = "[" + category + "] " + title;
});
</script>

</body>
</html>