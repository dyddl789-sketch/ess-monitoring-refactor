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

<main class="member-page dark-member-page">
    <div class="member-container wide">

        <section class="member-card dark-member-card">
            <div class="member-title dark-member-title">
                <span>MY PAGE</span>
                <h2>회원정보 수정</h2>
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
                    <label>연락처</label>

                    <div class="phone-row">
                        <select id="phone1">
                            <option value="010">010</option>
                            <option value="011">011</option>
                            <option value="016">016</option>
                            <option value="017">017</option>
                            <option value="018">018</option>
                            <option value="019">019</option>
                        </select>

                        <span>-</span>

                        <input type="text"
                               id="phone2"
                               maxlength="4"
                               placeholder="0000">

                        <span>-</span>

                        <input type="text"
                               id="phone3"
                               maxlength="4"
                               placeholder="0000">
                    </div>

                    <small>* 연락처는 숫자만 입력해주세요.</small>

                    <input type="hidden"
                           id="phone"
                           name="phone"
                           value="${member.phone}">
                </div>

                <div class="form-group">
                    <label>이메일</label>

                    <div class="email-row">
                        <input type="text"
                               id="emailId"
                               placeholder="이메일 아이디">

                        <span>@</span>

                        <input type="text"
                               id="emailDomain"
                               placeholder="도메인">

                        <select id="emailSelect" onchange="selectEmailDomain();">
                            <option value="">직접입력</option>
                            <option value="naver.com">naver.com</option>
                            <option value="gmail.com">gmail.com</option>
                            <option value="daum.net">daum.net</option>
                            <option value="kakao.com">kakao.com</option>
                        </select>
                    </div>

                    <small>* 이메일 주소를 정확하게 입력해주세요.</small>

                    <input type="hidden"
                           id="email"
                           name="email"
                           value="${member.email}">
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
window.onload = function () {
    splitPhone();
    splitEmail();
};

function splitPhone() {
    const phone = document.getElementById("phone").value;

    if (phone) {
        const phoneParts = phone.split("-");

        if (phoneParts.length === 3) {
            document.getElementById("phone1").value = phoneParts[0];
            document.getElementById("phone2").value = phoneParts[1];
            document.getElementById("phone3").value = phoneParts[2];
        }
    }
}

function splitEmail() {
    const email = document.getElementById("email").value;

    if (email && email.includes("@")) {
        const emailParts = email.split("@");

        document.getElementById("emailId").value = emailParts[0];
        document.getElementById("emailDomain").value = emailParts[1];

        const emailSelect = document.getElementById("emailSelect");

        for (let i = 0; i < emailSelect.options.length; i++) {
            if (emailSelect.options[i].value === emailParts[1]) {
                emailSelect.value = emailParts[1];
                document.getElementById("emailDomain").readOnly = true;
                break;
            }
        }
    }
}

function selectEmailDomain() {
    const selectedDomain = document.getElementById("emailSelect").value;
    const emailDomain = document.getElementById("emailDomain");

    emailDomain.value = selectedDomain;

    if (selectedDomain === "") {
        emailDomain.readOnly = false;
        emailDomain.focus();
    } else {
        emailDomain.readOnly = true;
    }
}

function searchAddress() {
    new daum.Postcode({
        oncomplete: function(data) {
            const address = data.roadAddress || data.jibunAddress;
            document.getElementById("address").value = address;
        }
    }).open();
}

function memberInfoCheck() {
    const memberName = document.getElementById("memberName").value.trim();

    const phone1 = document.getElementById("phone1").value.trim();
    const phone2 = document.getElementById("phone2").value.trim();
    const phone3 = document.getElementById("phone3").value.trim();

    const emailId = document.getElementById("emailId").value.trim();
    const emailDomain = document.getElementById("emailDomain").value.trim();

    if (memberName === "") {
        alert("이름을 입력해주세요.");
        document.getElementById("memberName").focus();
        return false;
    }

    if (phone2 !== "" || phone3 !== "") {
        if (!/^[0-9]{3,4}$/.test(phone2)) {
            alert("연락처 가운데 자리를 올바르게 입력해주세요.");
            document.getElementById("phone2").focus();
            return false;
        }

        if (!/^[0-9]{4}$/.test(phone3)) {
            alert("연락처 마지막 자리를 올바르게 입력해주세요.");
            document.getElementById("phone3").focus();
            return false;
        }

        document.getElementById("phone").value =
            phone1 + "-" + phone2 + "-" + phone3;
    }

    if (emailId !== "" || emailDomain !== "") {
        if (emailId === "") {
            alert("이메일 아이디를 입력해주세요.");
            document.getElementById("emailId").focus();
            return false;
        }

        if (emailDomain === "") {
            alert("이메일 도메인을 입력해주세요.");
            document.getElementById("emailDomain").focus();
            return false;
        }

        document.getElementById("email").value =
            emailId + "@" + emailDomain;
    }

    return true;
}
</script>

</body>
</html>