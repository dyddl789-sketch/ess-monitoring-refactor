<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${empty sessionScope.memberId}">
    <script>
        alert("로그인이 필요합니다.");
        location.href = "${pageContext.request.contextPath}/login_view";
    </script>
</c:if>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>문의하기 - ESS-M.S</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">

<style>
.container { width: 80%; margin: 0 auto; }
.notice-banner {
    background: #e8fcfd;
    padding: 15px 0;
    border-bottom: 1px solid #dddddd;
    text-align: center;
}
.write-section {
    padding: 70px 0;
}
.contact-form-container {
    max-width: 760px;
    margin: 0 auto;
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 14px;
    padding: 35px;
    box-shadow: 0 4px 14px rgba(0,0,0,0.06);
}
.form-group {
    margin-bottom: 20px;
}
.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: bold;
}
.form-group input,
.form-group textarea,
.form-group select {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 6px;
    box-sizing: border-box;
}
.form-group textarea {
    resize: vertical;
}
.btn {
    padding: 11px 18px;
    background:#007bff;
    color:white;
    border:none;
    border-radius:6px;
    cursor:pointer;
    text-decoration:none;
}
.btn-gray {
    background:#6c757d;
}
.button-area {
    display: flex;
    gap: 8px;
    margin-top: 20px;
}
.warning-box {
    max-width: 760px;
    margin: 0 auto 50px;
    background: #fff8f8;
    border: 1px solid #ffd6d6;
    border-radius: 8px;
    padding: 15px;
    text-align: center;
}
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
</head>

<body>

<%@ include file="/WEB-INF/views/header.jsp" %>

<div class="notice-banner">
    <div class="container">
        <p>
            <strong>[안내]</strong>
            설치문의, 장비 등록, 모니터링 이상, 알림 오류 등을 상세히 작성해주시면 답변에 도움이 됩니다.
        </p>
    </div>
</div>

<section class="container write-section">
    <h1>문의하기</h1>

    <div class="contact-form-container">
        <form action="${pageContext.request.contextPath}/board_write" method="post">

            <div class="form-group">
                <label>작성자</label>
                <input type="text" value="${sessionScope.memberName}" readonly>
            </div>

            <div class="form-group">
                <label>회원 유형</label>
                <input type="text" value="${sessionScope.userType}" readonly>
            </div>

            <div class="form-group">
                <label for="category">문의 유형</label>
                <select id="category">
                    <option value="장비문의">장비문의</option>
                    <option value="모니터링문의">모니터링문의</option>
                    <option value="알림문의">알림문의</option>
                    <option value="에너지분석문의">에너지분석문의</option>
                    <option value="계정문의">계정문의</option>
                    <option value="기타문의">기타문의</option>
                </select>
            </div>

            <div class="form-group">
                <label for="titleInput">제목</label>
                <input type="text" id="titleInput" placeholder="문의 제목을 입력하세요" required>
                <input type="hidden" id="boardTitle" name="boardTitle">
            </div>

            <div class="form-group">
                <label for="boardContent">문의 내용</label>
                <textarea id="boardContent"
                          name="boardContent"
                          rows="10"
                          placeholder="문의 내용을 상세히 입력해주세요."
                          required></textarea>
            </div>

            <div class="button-area">
                <button type="submit" class="btn">문의 등록</button>
                <a href="${pageContext.request.contextPath}/board_list" class="btn btn-gray">목록</a>
            </div>

        </form>
    </div>
</section>

<div class="warning-box">
    <p><strong>※ <span>주의</span> ※ 욕설, 비방, 허위 문의는 제한될 수 있습니다.</strong></p>
</div>

<%@ include file="/WEB-INF/views/footer.jsp" %>

<script>
document.querySelector("form").addEventListener("submit", function () {
    const category = document.getElementById("category").value;
    const title = document.getElementById("titleInput").value.trim();

    document.getElementById("boardTitle").value = "[" + category + "] " + title;
});
</script>

</body>
</html>