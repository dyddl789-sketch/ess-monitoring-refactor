<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login_view.css">
<meta charset="UTF-8">
<title>Insert title here</title>
 <style>
        /* 새 창 전용 추가 스타일 (1.main.css와 별개로 이 페이지에만 적용) */
        body { 
            background-color: #f4f7f9; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0;
        }
        .login-container { width: 100%; padding: 20px; }
    </style>
</head>
<body>
 <div class="login-container">
        <div class="login-box">
            <h1 class="logo" style="text-align:center; margin-bottom:20px; font-size:1.8rem;">ESS-M.S</h1>
            <h2 style="text-align:center; margin-bottom:25px;">로그인</h2>
            
            <div class="login-type-tabs">
                <button type="button" class="tab-btn active" onclick="selectType('user')">개인용</button>
                <button type="button" class="tab-btn" onclick="selectType('business')">기업용</button>
            </div>
			<c:if test="${not empty msg}">
   				 <p style="color:red; text-align:center; margin-bottom:10px;">
       				 ${msg}
    			</p>
			</c:if>
            <form action="${pageContext.request.contextPath}/login" method="post">
			    <div class="form-group">
			        <label>아이디</label>
			        <input type="text" name="memberUserid" placeholder="아이디를 입력하세요" required>
			    </div>
			
			    <div class="form-group">
			        <label>비밀번호</label>
			        <input type="password" name="memberPw" placeholder="비밀번호를 입력하세요" required>
			    </div>
                
                <div class="login-options">
                    <label><input type="checkbox"> 아이디 저장</label>
                    <a href="#" class="find-pw">비밀번호 찾기</a>
                </div>

                <button type="submit" class="btn login-submit">로그인</button>
            </form>

            <div class="login-footer">
                <p>아직 계정이 없으신가요? <a href="${pageContext.request.contextPath}/join_view">회원가입</a></p>
            </div>
        </div>
    </div>

    <script>
        // 탭 전환 기능
        function selectType(type) {
            const tabs = document.querySelectorAll('.tab-btn');
            tabs.forEach(tab => tab.classList.remove('active'));
            
            if(type === 'user') {
                tabs[0].classList.add('active');
                console.log("개인용 로그인 모드");
            } else {
                tabs[1].classList.add('active');
                console.log("기업용 로그인 모드");
            }
        }
    </script>
</body>
</html>