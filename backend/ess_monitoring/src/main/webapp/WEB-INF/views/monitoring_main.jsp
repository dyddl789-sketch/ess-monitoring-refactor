<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>

<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">

<title>상세 모니터링</title>

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/resources/css/sidebar.css">

<link rel="stylesheet"
      href="${pageContext.request.contextPath}/resources/css/monitoring_main.css">

</head>

<body>

<div class="layout">

    <%@ include file="/WEB-INF/views/sidebar.jsp" %>

    <main class="main">

        <!-- =========================
             페이지 헤더
        ========================== -->

        <div class="page-header">

            <div>

                <h2>상세 모니터링</h2>

                <p>
                    선택한 장비의 실시간 상태 및 이력 데이터를 확인합니다.
                </p>

            </div>

            <div class="last-update-box">

                마지막 업데이트 :
                <span id="lastUpdateTime">-</span>

            </div>

        </div>


        <!-- =========================
             필터 영역
        ========================== -->

        <div class="filter-box">

            <!-- 그룹 -->
            <select id="groupSelect">

                <option value="">
                    전체 그룹
                </option>

                <c:forEach var="group" items="${groupList}">

                    <option value="${group.groupId}">
                        ${group.groupName}
                    </option>

                </c:forEach>

            </select>

            <!-- 장비 -->
            <select id="deviceSelect">

                <option value="">
                    장비 선택
                </option>

                <c:forEach var="device" items="${deviceList}">

                    <option value="${device.deviceId}">
                        ${device.deviceName}
                    </option>

                </c:forEach>

            </select>

            <!-- 날짜 -->
            <input type="date"
                   id="selectedDate"
                   value="${selectedDate}">

            <!-- 버튼 -->
            <button type="button" id="searchBtn">
                조회
            </button>

            <button type="button" id="refreshBtn">
                새로고침
            </button>

            <button type="button" id="autoRefreshBtn">
                자동갱신 ON
            </button>

        </div>


        <!-- =========================
             상태 카드
        ========================== -->

        <section class="card-grid card-grid-five">

            <!-- 장비 상태 -->
            <div class="card">

                <div class="card-title">
                    장비 상태
                </div>

                <div class="card-value status-normal"
                     id="deviceStatus">

                    정상

                </div>

                <div class="card-sub">
                    최근 수신 데이터 기준
                </div>

            </div>

            <!-- SOC -->
            <div class="card">

                <div class="card-title">
                    현재 SOC
                </div>

                <div class="card-value"
                     id="soc">

                    - %

                </div>

                <div class="card-sub">
                    배터리 충전 상태
                </div>

            </div>

            <!-- 출력 -->
            <div class="card">

                <div class="card-title">
                    현재 출력
                </div>

                <div class="card-value"
                     id="powerOutput">

                    - kW

                </div>

                <div class="card-sub">
                    실시간 발전 출력
                </div>

            </div>

            <!-- 발전량 -->
            <div class="card">

                <div class="card-title">
                    선택일 발전량
                </div>

                <div class="card-value"
                     id="todayGeneration">

                    - kWh

                </div>

                <div class="card-sub"
                     id="generationCompareText">

                    7일 평균 대비 -

                </div>

            </div>

            <!-- 절감 금액 -->
            <div class="card">

                <div class="card-title">
                    선택일 절감 금액
                </div>

                <div class="card-value"
                     id="todaySavedCost">

                    - 원

                </div>

                <div class="card-sub"
                     id="costCompareText">

                    7일 평균 대비 -

                </div>

            </div>

        </section>


        <!-- =========================
             출력 그래프 + 계측 정보
        ========================== -->

        <section class="content-grid">

            <!-- 출력 그래프 -->
            <div class="card">

                <div class="section-title">
                    실시간 출력 그래프
                </div>

                <div class="chart-box">

                    <canvas id="powerChart"></canvas>

                </div>

            </div>

            <!-- 계측 정보 -->
            <div class="card">

                <div class="section-title">
                    실시간 계측 정보
                </div>

                <table class="info-table">

                    <tr>
                        <th>전압</th>
                        <td id="voltage">- V</td>
                    </tr>

                    <tr>
                        <th>전류</th>
                        <td id="currentA">- A</td>
                    </tr>

                    <tr>
                        <th>출력</th>
                        <td id="powerOutputDetail">- kW</td>
                    </tr>

                    <tr>
                        <th>SOC</th>
                        <td id="socDetail">- %</td>
                    </tr>

                    <tr>
                        <th>측정 시간</th>
                        <td id="recordTime">-</td>
                    </tr>

                </table>

            </div>

        </section>


        <!-- =========================
             SOC / 발전량 그래프
        ========================== -->

        <section class="content-grid-half">

            <!-- SOC -->
            <div class="card">

                <div class="section-title">
                    SOC 변화 그래프
                </div>

                <div class="chart-box">

                    <canvas id="socChart"></canvas>

                </div>

            </div>

            <!-- 발전량 -->
            <div class="card">

                <div class="section-title">
                    발전량 누적 그래프
                </div>

                <div class="chart-box">

                    <canvas id="generationChart"></canvas>

                </div>

            </div>

        </section>


        <!-- =========================
             최근 7일 변화
        ========================== -->

        <section class="content-grid-half">

            <!-- 발전량 -->
            <div class="card">

                <div class="section-title">
                    최근 7일 발전량 변화
                </div>

                <div class="section-subtitle">
                    일별 발전량 흐름
                </div>

                <div class="chart-box">

                    <canvas id="weeklyGenerationChart"></canvas>

                </div>

            </div>

            <!-- 절감 금액 -->
            <div class="card">

                <div class="section-title">
                    최근 7일 절감 금액 변화
                </div>

                <div class="section-subtitle">
                    일별 절감 금액 흐름
                </div>

                <div class="chart-box">

                    <canvas id="weeklyCostChart"></canvas>

                </div>

            </div>

        </section>


        <!-- =========================
             최근 알림 / 운영 판단
        ========================== -->

        <section class="bottom-grid">

            <!-- 최근 알림 -->
            <div class="card">

                <div class="section-title">
                    최근 알림
                </div>

                <div id="alertList">

                    <div class="alert-item">

                        <span class="alert-badge info">
                            정보
                        </span>

                        <div class="alert-content">

                            <div class="alert-message">
                                최근 알림이 없습니다.
                            </div>

                        </div>

                    </div>

                </div>

            </div>

            <!-- 운영 판단 -->
            <div class="card">

                <div class="section-title">
                    운영 판단 요약
                </div>

                <ul class="operation-list">

                    <li id="operationCondition">
                        발전 상태 분석 준비 중
                    </li>

                    <li id="batteryCondition">
                        배터리 상태 분석 준비 중
                    </li>

                    <li id="recommendAction">
                        운영 권장 조치 분석 준비 중
                    </li>

                </ul>

            </div>

        </section>


        <!-- =========================
             안내 문구
        ========================== -->

        <div class="monitoring-note">

            ※ 오늘 날짜 선택 시 실시간 자동 갱신이 활성화되며,
            이전 날짜 선택 시 이력 조회 모드로 동작합니다.

        </div>

    </main>

</div>


<!-- =========================
     Script
========================= -->

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>

    const contextPath =
        '${pageContext.request.contextPath}';

    const selectedDeviceId =
        '${deviceId}';

</script>
<script src="${pageContext.request.contextPath}/resources/js/monitoring_chart.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/monitoring_main.js"></script>

</body>
</html>