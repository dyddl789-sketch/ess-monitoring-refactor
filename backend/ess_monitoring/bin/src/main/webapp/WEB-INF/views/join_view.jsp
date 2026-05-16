<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/join_view.css">
<meta charset="UTF-8">
<title>ESS 회원가입</title>
</head>

<body>
<div class="login-container">
    <div class="login-box">
		
		<h1 class="join-title">
		    ESS-M.S 회원가입
		</h1>

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
			
			    <div class="phone-row">
			        <input type="text"
			               id="phone1"
			               maxlength="3"
			               value="010">
			
			        <span class="input-separator">-</span>
			
			        <input type="text"
			               id="phone2"
			               maxlength="4"
			               placeholder="1234">
			
			        <span class="input-separator">-</span>
			
			        <input type="text"
			               id="phone3"
			               maxlength="4"
			               placeholder="5678">
			    </div>
			
			    <input type="hidden"
			           id="phone"
			           name="phone">
			
			    <small>ESS 이상 알림, 장애 대응 연락용으로 사용됩니다.</small>
			</div>

            <!-- email -->
			<div class="form-group">
			    <label>이메일</label>
			
			    <div class="email-row">
			        <input type="text"
			               id="emailId"
			               placeholder="email">
			
			        <span class="input-separator">@</span>
			
			        <input type="text"
			               id="emailDomain"
			               placeholder="domain.com">
			
			        <select id="emailDomainSelect">
			            <option value="">직접입력</option>
			            <option value="naver.com">naver.com</option>
			            <option value="gmail.com">gmail.com</option>
			            <option value="daum.net">daum.net</option>
			            <option value="kakao.com">kakao.com</option>
			            <option value="nate.com">nate.com</option>
			        </select>
			    </div>
			
			    <input type="hidden"
			           id="email"
			           name="email">
			
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