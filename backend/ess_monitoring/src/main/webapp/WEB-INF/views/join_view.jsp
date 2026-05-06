<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login_view.css">
<meta charset="UTF-8">
<title>ESS 회원가입</title>

<style>
    body {
        background-color: #f4f7f9;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        margin: 0;
    }

    .login-container {
        width: 100%;
        padding: 20px;
    }

    .login-box {
        max-width: 480px;
        margin: 0 auto;
    }

    .guide-box {
        background: #eef6ff;
        border: 1px solid #cfe5ff;
        padding: 12px;
        border-radius: 8px;
        font-size: 0.9rem;
        margin-bottom: 18px;
        color: #24527a;
    }

    .form-group {
        margin-bottom: 14px;
    }

    .form-group small {
        display: block;
        margin-top: 4px;
        color: #777;
        font-size: 0.8rem;
    }

    .address-row {
        display: flex;
        gap: 6px;
        margin-bottom: 6px;
    }

    .address-row input {
        flex: 1;
    }

    .address-btn {
        width: 120px !important;
        margin-top: 0 !important;
    }

    .agree-box {
        margin: 15px 0;
        font-size: 0.9rem;
    }

    .agree-box label {
        display: block;
        margin-bottom: 6px;
    }
</style>
</head>

<body>
<div class="login-container">
    <div class="login-box">

        <h1 class="logo" style="text-align:center; margin-bottom:20px; font-size:1.8rem;">ESS-M.S</h1>
        <h2 style="text-align:center; margin-bottom:20px;">회원가입</h2>

        <div class="guide-box">
            ESS 모니터링 서비스는 회원 유형에 따라 장비 등록, 데이터 조회, 이상 알림 기능이 다르게 제공됩니다.
        </div>

        <c:if test="${not empty msg}">
            <p style="color:red; text-align:center; margin-bottom:10px;">
                ${msg}
            </p>
        </c:if>

        <form action="${pageContext.request.contextPath}/join" method="post" onsubmit="return joinCheck();">

            <!-- user_type -->
            <div class="login-type-tabs">
                <button type="button" class="tab-btn active" onclick="selectType('개인')">개인용</button>
                <button type="button" class="tab-btn" onclick="selectType('기업')">기업용</button>
            </div>

            <input type="hidden" id="userType" name="userType" value="개인">

            <!-- member_name -->
            <div class="form-group">
                <label>이름</label>
                <input type="text" id="memberName" name="memberName" placeholder="이름을 입력하세요" required>
            </div>

            <!-- member_userid -->
            <div class="form-group">
                <label>아이디</label>
                <input type="text" id="memberUserid" name="memberUserid" placeholder="로그인에 사용할 아이디" required>
                <small>영문, 숫자 조합을 권장합니다.</small>
            </div>

            <!-- member_pw -->
            <div class="form-group">
                <label>비밀번호</label>
                <input type="password" id="memberPw" name="memberPw" placeholder="비밀번호를 입력하세요" required>
                <small>장비 및 에너지 데이터 보호를 위해 8자 이상을 권장합니다.</small>
            </div>

            <!-- DB 저장 안 함: 화면 검증용 -->
            <div class="form-group">
                <label>비밀번호 확인</label>
                <input type="password" id="memberPwCheck" placeholder="비밀번호를 다시 입력하세요" required>
            </div>

            <!-- phone -->
            <div class="form-group">
                <label>연락처</label>
                <input type="text" id="phone" name="phone" placeholder="010-0000-0000">
                <small>ESS 이상 알림, 장애 대응 연락용으로 사용됩니다.</small>
            </div>

            <!-- email -->
            <div class="form-group">
                <label>이메일</label>
                <input type="email" id="email" name="email" placeholder="email@example.com">
                <small>리포트, 알림, 계정 안내 수신에 사용됩니다.</small>
            </div>

            <!-- address -->
            <div class="form-group">
                <label>주소</label>

                <div class="address-row">
                    <input type="text" id="postcode" placeholder="우편번호" readonly>
                    <button type="button" class="btn address-btn" onclick="execDaumPostcode()">주소검색</button>
                </div>

                <input type="text" id="roadAddress" placeholder="기본주소" readonly style="margin-bottom:6px;">
                <input type="text" id="detailAddress" placeholder="상세주소를 입력하세요">

                <!-- DB의 address 컬럼에 실제 저장되는 값 -->
                <input type="hidden" id="address" name="address">

                <small>ESS 설치지 또는 관리 주소를 입력해주세요.</small>
            </div>

            <!-- DB 저장 안 함: 화면 검증용 -->
            <div class="agree-box">
                <label>
                    <input type="checkbox" id="agree_required">
                    서비스 이용약관 및 개인정보 처리방침에 동의합니다. <strong>(필수)</strong>
                </label>

                <label>
                    <input type="checkbox" id="agree_monitoring">
                    ESS 모니터링 데이터 수집 및 분석 목적을 확인했습니다. <strong>(필수)</strong>
                </label>

                <label>
                    <input type="checkbox" id="agree_alert">
                    이상 상태 발생 시 연락처 또는 이메일로 알림을 받을 수 있음을 확인했습니다.
                </label>
            </div>

            <button type="submit" class="btn login-submit">회원가입</button>
        </form>

        <div class="login-footer">
            <p>이미 계정이 있으신가요?
                <a href="${pageContext.request.contextPath}/login_view">로그인</a>
            </p>
        </div>

    </div>
</div>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    function selectType(type) {
        const tabs = document.querySelectorAll('.tab-btn');
        tabs.forEach(tab => tab.classList.remove('active'));

        if (type === 'PERSONAL') {
            tabs[0].classList.add('active');
        } else {
            tabs[1].classList.add('active');
        }

        document.getElementById('userType').value = type;
    }

    function execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                var roadAddr = data.roadAddress;
                var jibunAddr = data.jibunAddress;

                document.getElementById('postcode').value = data.zonecode;

                if (roadAddr !== '') {
                    document.getElementById('roadAddress').value = roadAddr;
                } else {
                    document.getElementById('roadAddress').value = jibunAddr;
                }

                document.getElementById('detailAddress').focus();
            }
        }).open();
    }

    function makeFullAddress() {
        var postcode = document.getElementById('postcode').value;
        var roadAddress = document.getElementById('roadAddress').value;
        var detailAddress = document.getElementById('detailAddress').value;

        var fullAddress = "";

        if (postcode !== "") {
            fullAddress += "(" + postcode + ") ";
        }

        fullAddress += roadAddress;

        if (detailAddress !== "") {
            fullAddress += " " + detailAddress;
        }

        document.getElementById('address').value = fullAddress;
    }

    function joinCheck() {
        const memberPw = document.getElementById('memberPw').value;
        const memberPwCheck = document.getElementById('memberPwCheck').value;

        // HTML id와 동일하게 수정
        const agreeRequired = document.getElementById('agree_required').checked;
        const agreeMonitoring = document.getElementById('agree_monitoring').checked;

        if (memberPw.length < 8) {
            alert("비밀번호는 8자 이상 입력해주세요.");
            document.getElementById('memberPw').focus();
            return false;
        }

        if (memberPw !== memberPwCheck) {
            alert("비밀번호가 일치하지 않습니다.");
            document.getElementById('memberPwCheck').focus();
            return false;
        }

        if (!agreeRequired) {
            alert("서비스 이용약관 및 개인정보 처리방침에 동의해주세요.");
            return false;
        }

        if (!agreeMonitoring) {
            alert("ESS 모니터링 데이터 수집 및 분석 목적 확인이 필요합니다.");
            return false;
        }

        makeFullAddress();

        return true;
    }
</script>

</body>
</html>