<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>실시간 모니터링</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sidebar.css">

<style>
body {
    margin: 0;
    background: #f5f7fb;
    color: #0f172a;
    font-family: Arial, sans-serif;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.filter-box {
    display: flex;
    gap: 12px;
    margin-bottom: 24px;
}

.filter-box select,
.filter-box button {
    height: 42px;
    padding: 0 14px;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    background: white;
}

.filter-box button {
    background: #111827;
    color: white;
    cursor: pointer;
}

.card-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-bottom: 24px;
}

.card {
    background: #fff;
    border-radius: 14px;
    border: 1px solid #e5e7eb;
    padding: 22px;
    box-shadow: 0 3px 10px rgba(0,0,0,0.04);
}

.card-title {
    font-size: 14px;
    color: #64748b;
    margin-bottom: 12px;
}

.card-value {
    font-size: 28px;
    font-weight: bold;
}

.card-sub {
    margin-top: 10px;
    font-size: 13px;
    color: #64748b;
}

.status-normal { color: #16a34a; font-weight: bold; }
.status-warning { color: #f59e0b; font-weight: bold; }
.status-error { color: #dc2626; font-weight: bold; }
.status-offline { color: #64748b; font-weight: bold; }

.content-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 18px;
    margin-bottom: 24px;
}

.section-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 18px;
}

.chart-box {
    height: 280px;
}

.info-table {
    width: 100%;
    border-collapse: collapse;
}

.info-table th,
.info-table td {
    padding: 12px 8px;
    border-bottom: 1px solid #e5e7eb;
    text-align: left;
}

.info-table th {
    color: #64748b;
    width: 35%;
}

.bottom-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px;
}

.weather-main {
    display: flex;
    align-items: center;
    gap: 20px;
}

.weather-icon {
    font-size: 46px;
}

.weather-temp {
    font-size: 30px;
    font-weight: bold;
}

.alert-list {
    list-style: none;
    padding: 0;
    margin: 0;
}

.alert-list li {
    padding: 12px 0;
    border-bottom: 1px solid #e5e7eb;
}

.badge {
    display: inline-block;
    padding: 4px 8px;
    border-radius: 999px;
    background: #fee2e2;
    color: #dc2626;
    font-size: 12px;
    margin-right: 8px;
}
</style>
</head>

<body>

<div class="layout">
<%@ include file="/WEB-INF/views/sidebar.jsp" %>

<main class="main">

    <div class="page-header">
        <div>
            <h2>실시간 모니터링</h2>
            <p>선택한 장비의 현재 상태와 발전 환경을 확인합니다.</p>
        </div>

        <div>
            마지막 업데이트: <span id="lastUpdateTime">-</span>
        </div>
    </div>

    <div class="filter-box">
        <select id="deviceSelect">
            <option value="">장비 선택</option>

            <c:forEach var="device" items="${deviceList}">
                <option value="${device.deviceId}">
                    ${device.deviceName}
                </option>
            </c:forEach>
        </select>

        <button type="button" id="refreshBtn">새로고침</button>
        <button type="button" id="autoRefreshBtn">자동갱신 ON</button>
    </div>

    <!-- 핵심 상태 카드 -->
    <section class="card-grid">

        <div class="card">
            <div class="card-title">장비 상태</div>
            <div class="card-value status-normal" id="deviceStatus">정상</div>
            <div class="card-sub">최근 수신 데이터 기준</div>
        </div>

        <div class="card">
            <div class="card-title">현재 SOC</div>
            <div class="card-value" id="soc">- %</div>
            <div class="card-sub">배터리 충전 상태</div>
        </div>

        <div class="card">
            <div class="card-title">현재 출력</div>
            <div class="card-value" id="powerOutput">- kW</div>
            <div class="card-sub">실시간 발전 출력</div>
        </div>

        <div class="card">
            <div class="card-title">오늘 발전량</div>
            <div class="card-value" id="todayGeneration">- kWh</div>
            <div class="card-sub">금일 누적 기준</div>
        </div>

    </section>

    <!-- 그래프 + 상세값 -->
    <section class="content-grid">

        <div class="card">
            <div class="section-title">실시간 출력 그래프</div>

            <div class="chart-box">
                <canvas id="powerChart"></canvas>
            </div>
        </div>

        <div class="card">
            <div class="section-title">실시간 계측 정보</div>

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
                    <th>출력 전력</th>
                    <td id="powerOutputDetail">- kW</td>
                </tr>

                <tr>
                    <th>측정 시간</th>
                    <td id="recordTime">-</td>
                </tr>
            </table>
        </div>

    </section>

    <section class="content-grid">

        <div class="card">
            <div class="section-title">SOC 변화 그래프</div>

            <div class="chart-box">
                <canvas id="socChart"></canvas>
            </div>
        </div>

        <div class="card">
            <div class="section-title">현재 발전 환경</div>

            <div class="weather-main">

                <div class="weather-icon" id="weatherIcon">☀️</div>

                <div>
                    <div class="weather-temp" id="temperature">- ℃</div>
                    <div id="skyStatus">-</div>
                </div>

            </div>

            <table class="info-table" style="margin-top: 18px;">

                <tr>
                    <th>강수확률</th>
                    <td id="rainProb">- %</td>
                </tr>

                <tr>
                    <th>습도</th>
                    <td id="humidity">- %</td>
                </tr>

                <tr>
                    <th>풍속</th>
                    <td id="windSpeed">- m/s</td>
                </tr>

                <tr>
                    <th>일사량</th>
                    <td id="solarRadiation">-</td>
                </tr>

                <tr>
                    <th>일출/일몰</th>
                    <td id="sunTime">-</td>
                </tr>

                <tr>
                    <th>ESS 분석</th>
                    <td id="essStatus">-</td>
                </tr>

            </table>
        </div>

    </section>

    <!-- 최근 알림 -->
    <section class="bottom-grid">

        <div class="card">
            <div class="section-title">최근 알림</div>

            <ul class="alert-list" id="alertList">
                <li><span class="badge">정보</span> 최근 알림이 없습니다.</li>
            </ul>
        </div>

        <div class="card">
            <div class="section-title">운영 판단 요약</div>

            <table class="info-table">

                <tr>
                    <th>발전 조건</th>
                    <td id="operationCondition">-</td>
                </tr>

                <tr>
                    <th>배터리 상태</th>
                    <td id="batteryCondition">-</td>
                </tr>

                <tr>
                    <th>권장 조치</th>
                    <td id="recommendAction">-</td>
                </tr>

            </table>
        </div>

    </section>

</main>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
const contextPath = '${pageContext.request.contextPath}';

let powerChart;
let socChart;
let autoRefreshTimer = null;

function initCharts() {

    const powerCtx =
        document.getElementById('powerChart').getContext('2d');

    const socCtx =
        document.getElementById('socChart').getContext('2d');

    powerChart = new Chart(powerCtx, {
        type: 'line',
        data: {
            labels: ['10:00', '10:10', '10:20', '10:30', '10:40'],
            datasets: [{
                label: '출력(kW)',
                data: [3.1, 3.5, 3.2, 3.8, 4.1],
                tension: 0.35
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });

    socChart = new Chart(socCtx, {
        type: 'line',
        data: {
            labels: ['10:00', '10:10', '10:20', '10:30', '10:40'],
            datasets: [{
                label: 'SOC(%)',
                data: [72, 73, 74, 74, 75],
                tension: 0.35
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

function loadRealtimeData() {

    const deviceId = $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $('#deviceStatus')
        .text('정상')
        .attr('class', 'card-value status-normal');

    $('#soc').text('75.0%');
    $('#powerOutput').text('4.1 kW');
    $('#todayGeneration').text('28.6 kWh');

    $('#voltage').text('380 V');
    $('#currentA').text('12.4 A');
    $('#powerOutputDetail').text('4.1 kW');
    $('#recordTime').text('2026-05-01 14:30');

    $('#temperature').text('23.6℃');
    $('#skyStatus').text('맑음');

    $('#rainProb').text('10%');
    $('#humidity').text('42%');
    $('#windSpeed').text('2.1 m/s');

    $('#solarRadiation').text('620.5');

    $('#sunTime').text('05:25 / 19:45');

    $('#essStatus').text('발전 조건 양호');

    $('#operationCondition').text('양호');
    $('#batteryCondition').text('정상');

    $('#recommendAction').text('현재 조치 필요 없음');

    $('#lastUpdateTime')
        .text(new Date().toLocaleTimeString());
}

function toggleAutoRefresh() {

    if (autoRefreshTimer) {

        clearInterval(autoRefreshTimer);

        autoRefreshTimer = null;

        $('#autoRefreshBtn').text('자동갱신 ON');

    } else {

        autoRefreshTimer =
            setInterval(loadRealtimeData, 30000);

        $('#autoRefreshBtn').text('자동갱신 OFF');
    }
}

$(document).ready(function () {

    initCharts();

    $('#refreshBtn').on('click', loadRealtimeData);

    $('#deviceSelect').on('change', loadRealtimeData);

    $('#autoRefreshBtn').on('click', toggleAutoRefresh);

    const sidebar =
        document.getElementById('sidebar');

    const main =
        document.querySelector('.main');

    const toggleBtn =
        document.getElementById('sidebarToggle');

    if (sidebar && main && toggleBtn) {

        toggleBtn.addEventListener('click', function () {

            sidebar.classList.toggle('collapsed');

            main.classList.toggle('collapsed');
        });
    }
});
</script>

</body>
</html>