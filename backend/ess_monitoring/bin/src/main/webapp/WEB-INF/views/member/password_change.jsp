<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비밀번호 변경 | ESS-M.S</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/member.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/header.css">
</head>

<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<main class="member-page">
    <div class="member-container">

        <section class="member-card">
            <div class="member-title">
                <span>SECURITY</span>
                <h2>비밀번호 변경</h2>
                <p>안전한 계정 보호를 위해 비밀번호를 주기적으로 변경해주세요.</p>
            </div>

            <c:if test="${not empty msg}">
                <div class="member-message error">
                    ${msg}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/member/password/update"
                  method="post"
                  onsubmit="return passwordCheck();">

                <div class="form-group">
                    <label for="currentPw">현재 비밀번호</label>
                    <input type="password"
                           id="currentPw"
                           name="currentPw"
                           required>
                </div>

                <div class="form-group">
                    <label for="newPw">새 비밀번호</label>
                    <input type="password"
                           id="newPw"
                           name="newPw"
                           required>
                    <small>8자 이상 입력해주세요.</small>
                </div>

                <div class="form-group">
                    <label for="newPwCheck">새 비밀번호 확인</label>
                    <input type="password"
                           id="newPwCheck"
                           name="newPwCheck"
                           required>
                </div>

                <div class="member-btn-area">
                    <button type="button"
                            class="btn btn-secondary"
                            onclick="location.href='${pageContext.request.contextPath}/main'">
                        취소
                    </button>

                    <button type="submit" class="btn btn-primary">
                        변경하기
                    </button>
                </div>

            </form>
        </section>

    </div>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp" />

<script>
function passwordCheck() {
    const currentPw = document.getElementById("currentPw").value.trim();
    const newPw = document.getElementById("newPw").value.trim();
    const newPwCheck = document.getElementById("newPwCheck").value.trim();

    if (currentPw === "") {
        alert("현재 비밀번호를 입력해주세요.");
        document.getElementById("currentPw").focus();
        return false;
    }

    if (newPw.length < 8) {
        alert("새 비밀번호는 8자 이상 입력해주세요.");
        document.getElementById("newPw").focus();
        return false;
    }

    if (newPw !== newPwCheck) {
        alert("새 비밀번호가 일치하지 않습니다.");
        document.getElementById("newPwCheck").focus();
        return false;
    }

    if (currentPw === newPw) {
        alert("현재 비밀번호와 새 비밀번호가 같습니다.");
        document.getElementById("newPw").focus();
        return false;
    }

    return true;
}
</script>

</body>
</html>