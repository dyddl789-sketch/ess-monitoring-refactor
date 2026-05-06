<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>내 정보</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common.css">
</head>

<body>
<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <h2>내 정보</h2>
        <p>회원 정보를 확인하고 수정할 수 있습니다.</p>

        <div class="card">
            <form action="${pageContext.request.contextPath}/member/update" method="post">

                <table class="data-table">
                    <tr>
                        <th>이름</th>
                        <td>
                            <input type="text" name="memberName" value="${member.memberName}">
                        </td>
                    </tr>

                    <tr>
                        <th>아이디</th>
                        <td>${member.memberUserid}</td>
                    </tr>

                    <tr>
                        <th>회원 유형</th>
                        <td>${member.userType}</td>
                    </tr>

                    <tr>
                        <th>연락처</th>
                        <td>
                            <input type="text" name="phone" value="${member.phone}">
                        </td>
                    </tr>

                    <tr>
                        <th>이메일</th>
                        <td>
                            <input type="text" name="email" value="${member.email}">
                        </td>
                    </tr>

                    <tr>
                        <th>주소</th>
                        <td>
                            <input type="text" name="address" value="${member.address}">
                        </td>
                    </tr>

                    <tr>
                        <th>가입일</th>
                        <td>${member.joinDate}</td>
                    </tr>
                </table>

                <div style="margin-top:20px;">
                    <button type="submit">정보 수정</button>
                </div>

            </form>
        </div>

    </main>
</div>
</body>
</html>