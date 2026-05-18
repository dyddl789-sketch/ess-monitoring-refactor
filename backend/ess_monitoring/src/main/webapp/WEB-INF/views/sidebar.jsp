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

        <div class="menu-section">
            <div class="menu-title">운영 관리</div>

            <a href="${pageContext.request.contextPath}/dashboard/main"
               class="menu-item">
                <span class="menu-text">메인 대시보드</span>
            </a>

            <a href="${pageContext.request.contextPath}/monitoring/main"
               class="menu-item">
                <span class="menu-text">상세 모니터링</span>
            </a>

            <a href="${pageContext.request.contextPath}/alert/list"
               class="menu-item">
                <span class="menu-text">알림 관리</span>
            </a>

            <a href="${pageContext.request.contextPath}/device/manage"
               class="menu-item">
                <span class="menu-text">장비 관리</span>
            </a>
        </div>

    </nav>

</aside>