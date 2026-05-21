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

    <nav class="header-nav" id="headerNav">
        <div class="header-wrap">
            <ul class="gnb">

                <li class="has-sub">
                    <a href="#">서비스</a>

                    <ul class="sub-menu">
                        <li>
                            <a href="${pageContext.request.contextPath}/board_list">
                                문의/공지게시판
                            </a>
                        </li>
                    </ul>
                </li>

				<li class="has-sub">
				    <a href="#">사용자 메뉴</a>
				
				    <ul class="sub-menu">
				        <li>
				            <a href="${pageContext.request.contextPath}/dashboard/main">
				                통합관리 대시보드
				            </a>
				        </li>
				
				        <li>
							<a href="${pageContext.request.contextPath}/main?view=register">
							    ESS 기기 등록
							</a>
				        </li>
				
				        <li>
				            <a href="${pageContext.request.contextPath}/device/manage">
				                ESS 관리
				            </a>
				        </li>
				    </ul>
				</li>
				
				<li class="has-sub">
				    <a href="#">메시지</a>
				
				    <ul class="sub-menu">
				        <li>
				            <a href="${pageContext.request.contextPath}/alert/list">
				                알림
				            </a>
				        </li>
				    </ul>
				</li>

                <li class="has-sub">
                    <a href="#">회원정보</a>

                    <ul class="sub-menu">
                        <li>
                            <a href="${pageContext.request.contextPath}/member/info">
                                회원정보수정
                            </a>
                        </li>

                        <li>
                            <a href="${pageContext.request.contextPath}/member/password">
                                비밀번호 변경
                            </a>
                        </li>
                    </ul>
                </li>

            </ul>
        </div>
    </nav>
</header>

<script>
function toggleHeaderMenu() {
    const headerNav = document.getElementById("headerNav");

    if (headerNav) {
        headerNav.classList.toggle("active");
    }
}
</script>