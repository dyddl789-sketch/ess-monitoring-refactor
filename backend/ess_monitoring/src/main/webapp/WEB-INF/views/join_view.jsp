<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login_view.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/join_view.css">
<meta charset="UTF-8">
<title>ESS 회원가입</title>
</head>

<body>
<div class="login-container">
    <div class="login-box">

        <h1 class="logo join-logo">ESS-M.S</h1>
		<h2 class="join-title">회원가입</h2>

        <div class="guide-box">
            ESS 모니터링 서비스는 회원 유형에 따라 장비 등록, 데이터 조회, 이상 알림 기능이 다르게 제공됩니다.
        </div>

        <c:if test="${not empty msg}">
			<p class="error-message">
			    ${msg}
			</p>
        </c:if>

        <form action="${pageContext.request.contextPath}/join" method="post" onsubmit="return joinCheck();">

            <!-- user_type -->
            <div class="login-type-tabs">
                <button type="button" class="tab-btn active" onclick="selectType('PERSONAL')">개인용</button>
                <button type="button" class="tab-btn" onclick="selectType('COMPANY')">기업용</button>
            </div>

            <input type="hidden" id="userType" name="userType" value="PERSONAL">

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

                <input type="text" id="roadAddress" class="address-input" placeholder="기본주소" readonly>
                <input type="text" id="detailAddress" placeholder="상세주소를 입력하세요">

                <!-- DB의 address 컬럼에 실제 저장되는 값 -->
                <input type="hidden" id="address" name="address">

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
<script src="${pageContext.request.contextPath}/resources/js/join_view.js"></script>
</body>
</html>