<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<aside class="sidebar" id="sidebar">

    <div class="sidebar-header">

        <a href="${pageContext.request.contextPath}/dashboard/main"
           class="logo-link">

            <span class="logo">ESS</span>

        </a>

        <button type="button"
                class="sidebar-toggle"
                id="sidebarToggle">
            ☰
        </button>

    </div>

    <nav class="sidebar-menu">

        <!-- 메인 홈 -->
        <div class="menu-section">

            <a href="${pageContext.request.contextPath}/main"
               class="menu-item home-button">

                <span class="menu-text">메인 홈</span>

            </a>

        </div>
    <div class="menu-section">
      <div class="menu-title">운영</div>

      <a href="${pageContext.request.contextPath}/dashboard/main" class="menu-item">
        <span class="menu-text">대시보드</span>
      </a>

      <a href="${pageContext.request.contextPath}/monitoring/main" class="menu-item">
        <span class="menu-text">실시간 모니터링</span>
      </a>

      <a href="${pageContext.request.contextPath}/device/status" class="menu-item">
        <span class="menu-text">장비 상태</span>
      </a>

      <a href="${pageContext.request.contextPath}/alert/list" class="menu-item">
        <span class="menu-text">알림</span>
      </a>
    </div>

    <div class="menu-section">
      <div class="menu-title">분석</div>

      <a href="${pageContext.request.contextPath}/analysis/generation" class="menu-item">
        <span class="menu-text">발전량 분석</span>
      </a>

      <a href="${pageContext.request.contextPath}/analysis/energy" class="menu-item">
        <span class="menu-text">에너지 통계</span>
      </a>
    </div>

    <div class="menu-section">
      <div class="menu-title">관리</div>

      <a href="${pageContext.request.contextPath}/device/manage" class="menu-item">
        <span class="menu-text">장비 관리</span>
      </a>

      <c:if test="${userType eq 'COMPANY'}">
        <a href="${pageContext.request.contextPath}/group/manage" class="menu-item">
          <span class="menu-text">그룹 관리</span>
        </a>
      </c:if>

      <a href="${pageContext.request.contextPath}/board_list" class="menu-item">
        <span class="menu-text">문의 게시판</span>
      </a>

      <a href="${pageContext.request.contextPath}/member/info" class="menu-item">
        <span class="menu-text">내 정보</span>
      </a>
    </div>

  </nav>

</aside>