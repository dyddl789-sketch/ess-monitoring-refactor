<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원정보수정 | ESS-M.S</title>

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
                <span>MY PAGE</span>
                <h2>회원정보수정</h2>
                <p>회원님의 기본 정보를 수정할 수 있습니다.</p>
            </div>

            <c:if test="${not empty msg}">
                <div class="member-message">
                    ${msg}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/member/update"
                  method="post"
                  onsubmit="return memberInfoCheck();">

                <div class="form-group">
                    <label>아이디</label>
                    <input type="text"
                           value="${member.memberUserid}"
                           readonly>
                </div>

                <div class="form-group">
                    <label>회원유형</label>
                    <input type="text"
                           value="${member.userType}"
                           readonly>
                </div>

                <div class="form-group">
                    <label for="memberName">이름</label>
                    <input type="text"
                           id="memberName"
                           name="memberName"
                           value="${member.memberName}"
                           required>
                </div>

                <div class="form-group">
                    <label for="phone">연락처</label>
                    <input type="text"
                           id="phone"
                           name="phone"
                           value="${member.phone}"
                           placeholder="010-0000-0000">
                </div>

                <div class="form-group">
                    <label for="email">이메일</label>
                    <input type="email"
                           id="email"
                           name="email"
                           value="${member.email}"
                           placeholder="email@example.com">
                </div>

                <div class="form-group">
				    <label for="address">주소</label>
				
				    <div class="address-row">
				        <input type="text"
				               id="address"
				               name="address"
				               value="${member.address}"
				               placeholder="주소를 검색하세요"
				               readonly>
				
				        <button type="button"
				                class="btn-address"
				                onclick="searchAddress();">
				            주소검색
				        </button>
				    </div>
				</div>

                <div class="member-btn-area">
                    <button type="button"
                            class="btn btn-secondary"
                            onclick="location.href='${pageContext.request.contextPath}/main'">
                        취소
                    </button>

                    <button type="submit"
                            class="btn btn-primary">
                        수정하기
                    </button>
                </div>

            </form>
        </section>

    </div>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp" />

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
function searchAddress() {
    new daum.Postcode({
        oncomplete: function(data) {
            const address =
                data.roadAddress || data.jibunAddress;

            document.getElementById("address").value = address;
        }
    }).open();
}

function memberInfoCheck() {
    const memberName =
        document.getElementById("memberName").value.trim();

    if (memberName === "") {
        alert("이름을 입력해주세요.");
        document.getElementById("memberName").focus();
        return false;
    }

    return true;
}
</script>

</body>
</html>