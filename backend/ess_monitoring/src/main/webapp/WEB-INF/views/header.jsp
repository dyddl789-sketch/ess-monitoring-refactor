<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header class="site-header">
    <div class="header-top">
        <div class="header-wrap">
            <h1 class="logo">
                <a href="${pageContext.request.contextPath}/main">
                    <span class="logo-mark">ESS</span>
                    <span>ESS-M.S</span>
                </a>
            </h1>

		<div class="header-util">
		    <c:choose>
		        <c:when test="${not empty sessionScope.memberId}">
		            <span>${sessionScope.memberName}님</span>
		            <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
		        </c:when>
		        <c:otherwise>
		            <a href="${pageContext.request.contextPath}/login_view">로그인</a>
		            <a href="${pageContext.request.contextPath}/join_view">회원가입</a>
		        </c:otherwise>
		    </c:choose>
		</div>
        </div>
    </div>

    <nav class="header-nav">
        <div class="header-wrap">
            <ul class="gnb">

                <li class="has-sub">
                    <a href="#">서비스</a>
                    <ul class="sub-menu">
                        <li><a href="${pageContext.request.contextPath}/board_list">공지사항</a></li>
                        <li><a href="#">자료실</a></li>
                        <li>
                        	<a href="${pageContext.request.contextPath}/board_list">
                        		문의게시판
                        	</a>
                        </li>
                    </ul>
                </li>

                <li class="has-sub">
                    <a href="#">사용자 메뉴</a>
                    <ul class="sub-menu">
                        <li>
                            <a href="#" onclick="checkLogin(function(){ moveView('monitor', loadMonitor); }); return false;">
                                통합관리 대시보드
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="checkLogin(function(){ moveView('register', loadRegister); }); return false;">
                                ESS 기기 등록
                            </a>
                        </li>
                        <li>
                            <a href="#" onclick="checkLogin(function(){ moveView('deviceList', loadDeviceList); }); return false;">
                                ESS 관리
                            </a>
                        </li>
                    </ul>
                </li>

                <li class="has-sub">
                    <a href="#">메시지</a>
                    <ul class="sub-menu">
                        <li>
                            <a href="#" onclick="checkLogin(function(){ moveView('alert', loadAlert); }); return false;">
                                알람
                            </a>
                        </li>
                        <li>
                            <a href="#">메시지함</a>
                        </li>
                    </ul>
                </li>

                <li class="has-sub">
                    <a href="#">회원정보</a>
                    <ul class="sub-menu">
                        <li>
                            <a href="#" onclick="checkLogin(function(){ moveView('myPage', loadMyPage); }); return false;">
                                회원정보수정
                            </a>
                        </li>
                        <li>
                            <a href="#">비밀번호 변경</a>
                        </li>
                    </ul>
                </li>

            </ul>
        </div>
    </nav>
</header>

<script>
function toggleHeaderMenu() {
    document.getElementById("headerNav").classList.toggle("active");
}

function showNotice() {
    const contentArea = document.getElementById("contentArea");

    if (!contentArea) return;

    contentArea.innerHTML = `
        <section class="content-section">
            <div class="section-title">
                <span>NOTICE</span>
                <h3>공지사항</h3>
                <p>ESS-M.S 서비스 공지사항을 확인할 수 있습니다.</p>
            </div>

            <div class="empty-box">
                등록된 공지사항이 없습니다.
            </div>
        </section>
    `;
}
</script>