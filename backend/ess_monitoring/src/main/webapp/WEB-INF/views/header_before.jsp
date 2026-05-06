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
                <a href="javascript:void(0);" onclick="loadBoard()">문의게시판</a>

                <c:choose>
                    <c:when test="${empty sessionScope.member_id}">
                        <a href="${pageContext.request.contextPath}/login_view">로그인</a>
                    </c:when>
                    <c:otherwise>
                        <span>${sessionScope.member_name}님</span>
                        <a href="${pageContext.request.contextPath}/logout">로그아웃</a>
                    </c:otherwise>
                </c:choose>

                <button type="button" class="mobile-menu-btn" onclick="toggleHeaderMenu()">☰</button>
            </div>
        </div>
    </div>

    <nav class="header-nav" id="headerNav">
        <div class="header-wrap">
            <ul class="gnb">
                <li class="has-sub">
                    <a href="javascript:void(0);">서비스</a>
                    <ul class="sub-menu">
                        <li><a href="javascript:void(0);" onclick="showNotice()">공지사항</a></li>
                        <li><a href="javascript:void(0);" onclick="loadBoard()">자료실</a></li>
                        <li><a href="javascript:void(0);" onclick="loadBoard()">문의게시판</a></li>
                    </ul>
                </li>

                <li>
                    <a href="javascript:void(0);" onclick="checkLogin(function(){ moveView('register', loadRegister); })">
                        ESS 등록
                    </a>
                </li>

                <li>
                    <a href="javascript:void(0);" onclick="checkLogin(function(){ moveView('deviceList', loadDeviceList); })">
                        ESS 관리
                    </a>
                </li>

                <li>
                    <a href="javascript:void(0);" onclick="checkLogin(loadEnergy)">
                        에너지 분석
                    </a>
                </li>

                <li>
                    <a href="javascript:void(0);" onclick="checkLogin(loadAlert)">
                        알림 이력
                    </a>
                </li>

                <li>
                    <a href="javascript:void(0);" onclick="checkLogin(loadMyPage)">
                        회원정보
                    </a>
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