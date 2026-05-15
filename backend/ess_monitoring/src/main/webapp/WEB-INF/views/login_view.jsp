<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<html>

<head>

<meta charset="UTF-8">

<title>ESS 로그인</title>

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/resources/css/login_view.css">

</head>

<body>

<div class="login-container">

    <div class="login-box">

        <h1 class="logo login-logo">ESS-M.S</h1>

        <h2 class="login-title">로그인</h2>

        <div class="login-type-tabs">

            <button type="button"
                    class="tab-btn active"
                    onclick="selectType('PERSONAL')">

                개인용

            </button>

            <button type="button"
                    class="tab-btn"
                    onclick="selectType('COMPANY')">

                기업용

            </button>

        </div>

        <c:if test="${not empty msg}">

            <p class="error-message">
                ${msg}
            </p>

        </c:if>
		<c:if test="${not empty successMsg}">

		    <p class="success-message">
		        ${successMsg}
		    </p>
		
		</c:if>
        <form action="${pageContext.request.contextPath}/login"
              method="post">

            <input type="hidden"
                   id="userType"
                   name="userType"
                   value="PERSONAL">

            <div class="form-group">

                <label>아이디</label>

                <input type="text"
                       name="memberUserid"
                       placeholder="아이디를 입력하세요"
                       required>

            </div>

            <div class="form-group">

                <label>비밀번호</label>

                <input type="password"
                       name="memberPw"
                       placeholder="비밀번호를 입력하세요"
                       required>

            </div>

            <div class="login-options">

                <label>
                    <input type="checkbox">
                    아이디 저장
                </label>

                <a href="#"
                   class="find-pw">

                    비밀번호 찾기

                </a>

            </div>

            <button type="submit"
                    class="btn login-submit">

                로그인

            </button>

        </form>

        <div class="login-footer">

            <p>
                아직 계정이 없으신가요?

                <a href="${pageContext.request.contextPath}/join_view">
                    회원가입
                </a>
            </p>

        </div>

    </div>

</div>

<script src="${pageContext.request.contextPath}/resources/js/login_view.js"></script>

</body>

</html>