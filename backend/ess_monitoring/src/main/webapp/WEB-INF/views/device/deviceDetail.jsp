<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>ESS 장비 상세</title>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/main.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
.dashboard-layout {
    display: flex;
    min-height: 100vh;
    background: #f1f5f9;
}

.sidebar-area {
    width: 240px;
    flex-shrink: 0;
}

.content-area {
    flex: 1;
    padding: 32px;
    overflow-x: hidden;
}

.detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.detail-header h2 {
    margin: 0 0 6px;
    font-size: 28px;
    color: #0f172a;
}

.detail-header p {
    margin: 0;
    color: #64748b;
}

.btn-back {
    display: inline-block;
    padding: 10px 16px;
    border-radius: 8px;
    background: #334155;
    color: #fff;
    text-decoration: none;
}

.summary-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-bottom: 24px;
}

.summary-card,
.detail-panel,
.recommend-panel {
    background: #fff;
    border-radius: 14px;
    padding: 20px;
    border: 1px solid #e5e7eb;
    box-shadow: 0 3px 10px rgba(0,0,0,0.05);
}

.summary-card h4,
.detail-panel h3,
.recommend-panel h3 {
    margin: 0 0 12px;
    color: #334155;
}

.summary-card h4 {
    color: #64748b;
    font-size: 15px;
}

.summary-card strong {
    display: block;
    font-size: 1.55rem;
    margin-bottom: 8px;
    color: #0f172a;
}

.summary-card p {
    margin: 0;
    color: #94a3b8;
    font-size: 13px;
}

.recommend-panel {
    margin-bottom: 24px;
    border-left: 5px solid #2563eb;
}

.recommend-message {
    margin: 0;
    color: #1e293b;
    line-height: 1.7;
}

.chart-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 24px;
}

.chart-panel canvas {
    width: 100% !important;
    height: 260px !important;
}

.detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 24px;
}

.monitor-table {
    width: 100%;
    border-collapse: collapse;
}

.monitor-table th,
.monitor-table td {
    padding: 12px;
    border-bottom: 1px solid #e5e7eb;
    text-align: left;
    vertical-align: middle;
}

.monitor-table th {
    width: 35%;
    color: #64748b;
    font-weight: 600;
}

.full-panel {
    margin-bottom: 24px;
}

.status-normal { color: #16a34a !important; }
.status-warning { color: #f59e0b !important; }
.status-danger { color: #dc2626 !important; }
.status-offline { color: #64748b !important; }

.status-badge {
    display: inline-block;
    padding: 5px 9px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
}

.status-badge.normal {
    background: #dcfce7;
    color: #166534;
}

.status-badge.warning {
    background: #fef3c7;
    color: #92400e;
}

.status-badge.danger {
    background: #fee2e2;
    color: #991b1b;
}

.status-badge.offline {
    background: #e2e8f0;
    color: #475569;
}

.battery-bar {
    width: 100%;
    height: 12px;
    background: #e2e8f0;
    border-radius: 999px;
    overflow: hidden;
    margin-top: 8px;
}

.battery-fill {
    height: 100%;
    background: #2563eb;
    border-radius: 999px;
}

.empty-text {
    color: #94a3b8;
    text-align: center;
}

@media (max-width: 1100px) {
    .summary-grid,
    .chart-grid,
    .detail-grid {
        grid-template-columns: 1fr 1fr;
    }
}

@media (max-width: 800px) {
    .dashboard-layout {
        flex-direction: column;
    }

    .sidebar-area {
        width: 100%;
    }

    .content-area {
        padding: 20px;
    }

    .summary-grid,
    .chart-grid,
    .detail-grid {
        grid-template-columns: 1fr;
    }

    .detail-header {
        align-items: flex-start;
        gap: 12px;
        flex-direction: column;
    }
}
</style>
</head>

<body>

<div class="dashboard-layout">

    <aside class="sidebar-area">
        <%@ include file="/WEB-INF/views/sidebar.jsp" %>
    </aside>

    <main class="content-area">

        <div class="detail-header">
            <div>
                <h2>${device.deviceName} 상세 모니터링</h2>
                <p>${device.location}</p>
            </div>

            <a href="${pageContext.request.contextPath}/main" class="btn-back">대시보드로</a>
        </div>

        <!-- 요약 카드 -->
        <div class="summary-grid">

            <div class="summary-card">
                <h4>장비 상태</h4>
                <c:choose>
                    <c:when test="${device.status eq 'NORMAL'}">
                        <strong class="status-normal">정상</strong>
                    </c:when>
                    <c:when test="${device.status eq 'WARNING'}">
                        <strong class="status-warning">위험</strong>
                    </c:when>
                    <c:when test="${device.status eq 'ERROR'}">
                        <strong class="status-danger">에러</strong>
                    </c:when>
                    <c:when test="${device.status eq 'OFFLINE'}">
                        <strong class="status-offline">오프라인</strong>
                    </c:when>
                    <c:otherwise>
                        <strong class="status-danger">알 수 없음</strong>
                    </c:otherwise>
                </c:choose>
                <p>최근 수신 데이터 기준</p>
            </div>

            <div class="summary-card">
                <h4>현재 SOC</h4>
                <strong>
                    <c:choose>
                        <c:when test="${empty monitor}">--%</c:when>
                        <c:otherwise>${monitor.soc}%</c:otherwise>
                    </c:choose>
                </strong>
                <p>배터리 충전 상태</p>
            </div>

            <div class="summary-card">
                <h4>현재 출력</h4>
                <strong>
                    <c:choose>
                        <c:when test="${empty monitor}">-- kW</c:when>
                        <c:otherwise>${monitor.powerOutput} kW</c:otherwise>
                    </c:choose>
                </strong>
                <p>예상 출력 전력</p>
            </div>

            <div class="summary-card">
                <h4>예상 절감금액</h4>
                <strong>
                    <c:choose>
                        <c:when test="${empty monitor}">-- 원</c:when>
                        <c:otherwise><fmt:formatNumber value="${monitor.savedCost}" pattern="#,#00"/> 원</c:otherwise>
                    </c:choose>
                </strong>
                <p>최신 모니터링 기준</p>
            </div>

        </div>

        <!-- 운영 권장 메시지 -->
        <section class="recommend-panel">
            <h3>운영 권장 메시지</h3>
            <p class="recommend-message">
                <c:choose>
                    <c:when test="${device.status eq 'OFFLINE'}">
                        장비가 오프라인 상태입니다. 통신 상태와 전원 연결을 우선 점검하세요.
                    </c:when>
                    <c:when test="${device.status eq 'ERROR'}">
                        장비 에러가 감지되었습니다. 최근 알림과 제어 로그를 확인하고 현장 점검을 진행하세요.
                    </c:when>
                    <c:when test="${not empty monitor and monitor.soc lt 30}">
                        현재 SOC가 낮습니다. 야간 사용 또는 비상 운전을 대비해 충전 계획을 확인하세요.
                    </c:when>
                    <c:when test="${not empty weather and weather.essStatus eq '발전량 저하 예상'}">
                        날씨 영향으로 발전량 저하가 예상됩니다. ESS 방전 계획과 사용 전력량을 함께 확인하세요.
                    </c:when>
                    <c:otherwise>
                        현재 장비 상태는 안정적입니다. SOC 변화와 발전량 추이를 계속 모니터링하세요.
                    </c:otherwise>
                </c:choose>
            </p>
        </section>

        <!-- 그래프 영역 -->
        <div class="chart-grid">
            <section class="detail-panel chart-panel">
                <h3>SOC 변화</h3>
                <canvas id="socChart"></canvas>
            </section>

            <section class="detail-panel chart-panel">
                <h3>발전량 / 출력 변화</h3>
                <canvas id="generationChart"></canvas>
            </section>

            <section class="detail-panel chart-panel">
                <h3>일별 에너지 로그</h3>
                <canvas id="energyLogChart"></canvas>
            </section>

            <section class="detail-panel chart-panel">
                <h3>절감금액 / 효율</h3>
                <canvas id="costEfficiencyChart"></canvas>
            </section>
        </div>

        <!-- 상세 정보 1 -->
        <div class="detail-grid">

            <section class="detail-panel">
                <h3>실시간 모니터링</h3>
                <table class="monitor-table">
                    <tr>
                        <th>전압</th>
                        <td><c:choose><c:when test="${empty monitor}">-- V</c:when><c:otherwise>${monitor.voltage} V</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>전류</th>
                        <td><c:choose><c:when test="${empty monitor}">-- A</c:when><c:otherwise>${monitor.currentA} A</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>발전량</th>
                        <td><c:choose><c:when test="${empty monitor}">-- kWh</c:when><c:otherwise>${monitor.solarGenerationKwh} kWh</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>충전량</th>
                        <td><c:choose><c:when test="${empty monitor}">-- kWh</c:when><c:otherwise>${monitor.chargedEnergyKwh} kWh</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>사용 전력량</th>
                        <td><c:choose><c:when test="${empty monitor}">-- kWh</c:when><c:otherwise>${monitor.usedEnergyKwh} kWh</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>측정 시간</th>
                        <td><c:choose><c:when test="${empty monitor}">데이터 없음</c:when><c:otherwise>${monitor.recordTime}</c:otherwise></c:choose></td>
                    </tr>
                </table>
            </section>

            <section class="detail-panel">
                <h3>현재 날씨 정보</h3>
                <table class="monitor-table">
                    <tr>
                        <th>하늘 상태</th>
                        <td>${empty weather ? '--' : weather.skyStatus}</td>
                    </tr>
                    <tr>
                        <th>기온</th>
                        <td><c:choose><c:when test="${empty weather}">-- ℃</c:when><c:otherwise>${weather.temperature} ℃</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>강수 형태</th>
                        <td>${empty weather ? '--' : weather.rainType}</td>
                    </tr>
                    <tr>
                        <th>강수 확률</th>
                        <td><c:choose><c:when test="${empty weather}">-- %</c:when><c:otherwise>${weather.rainProb}%</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>습도</th>
                        <td><c:choose><c:when test="${empty weather}">-- %</c:when><c:otherwise>${weather.humidity}%</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>풍속</th>
                        <td><c:choose><c:when test="${empty weather}">-- m/s</c:when><c:otherwise>${weather.windSpeed} m/s</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>일사량</th>
                        <td><c:choose><c:when test="${empty weather}">-- W/m²</c:when><c:otherwise>${weather.solarRadiation} W/m²</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>ESS 분석</th>
                        <td>${empty weather ? '--' : weather.essStatus}</td>
                    </tr>
                </table>
            </section>

        </div>

        <!-- 상세 정보 2 -->
        <div class="detail-grid">

            <section class="detail-panel">
                <h3>장비 기본 스펙</h3>
                <table class="monitor-table">
                    <tr>
                        <th>태양광 설비 용량</th>
                        <td>${device.capacityKw} kW</td>
                    </tr>
                    <tr>
                        <th>ESS 저장 용량</th>
                        <td>${device.essCapacityKwh} kWh</td>
                    </tr>
                    <tr>
                        <th>현재 충전량</th>
                        <td>
                            <c:choose>
                                <c:when test="${empty device.currentChargeKwh}">미측정</c:when>
                                <c:otherwise>
                                    ${device.currentChargeKwh} / ${device.essCapacityKwh} kWh
                                    <div class="battery-bar">
                                        <div class="battery-fill" style="width:${device.currentChargeKwh / device.essCapacityKwh * 100}%"></div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>충전 효율</th>
                        <td>${device.chargeEfficiency}%</td>
                    </tr>
                    <tr>
                        <th>방전 효율</th>
                        <td>${device.dischargeEfficiency}%</td>
                    </tr>
                    <tr>
                        <th>전기요금 단가</th>
                        <td><fmt:formatNumber value="${device.electricityRate}" pattern="#,#00"/> 원/kWh</td>
                    </tr>
                    <tr>
                        <th>설치일</th>
                        <td>${device.installDate}</td>
                    </tr>
                </table>
            </section>

            <section class="detail-panel">
                <h3>데이터 수신 상태</h3>
                <table class="monitor-table">
                    <tr>
                        <th>마지막 수신 시간</th>
                        <td><c:choose><c:when test="${empty monitor}">데이터 없음</c:when><c:otherwise>${monitor.recordTime}</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>수신 상태</th>
                        <td>
                            <c:choose>
                                <c:when test="${device.status eq 'OFFLINE'}"><span class="status-badge offline">오프라인</span></c:when>
                                <c:when test="${device.status eq 'ERROR'}"><span class="status-badge danger">에러</span></c:when>
                                <c:when test="${device.status eq 'WARNING'}"><span class="status-badge warning">주의</span></c:when>
                                <c:otherwise><span class="status-badge normal">정상 수신</span></c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>장비 유형</th>
                        <td>${device.deviceType}</td>
                    </tr>
                    <tr>
                        <th>대표 장비 여부</th>
                        <td><c:choose><c:when test="${device.isMain eq 'Y'}">대표 장비</c:when><c:otherwise>일반 장비</c:otherwise></c:choose></td>
                    </tr>
                    <tr>
                        <th>기상청 격자</th>
                        <td>NX ${device.nx} / NY ${device.ny}</td>
                    </tr>
                </table>
            </section>

        </div>

        <!-- 최근 알림 -->
        <section class="detail-panel full-panel">
            <h3>최근 알림</h3>
            <table class="monitor-table">
                <tr>
                    <th>시간</th>
                    <th>유형</th>
                    <th>위험도</th>
                    <th>알림 내용</th>
                    <th>처리 상태</th>
                    <th>제어 내용</th>
                </tr>
                <c:choose>
                    <c:when test="${empty alertList}">
                        <tr><td colspan="6" class="empty-text">최근 알림이 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="alert" items="${alertList}">
                            <tr>
                                <td>${alert.createdAt}</td>
                                <td>${alert.alertType}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${alert.alertLevel eq 'INFO'}"><span class="status-badge normal">INFO</span></c:when>
                                        <c:when test="${alert.alertLevel eq 'WARNING'}"><span class="status-badge warning">WARNING</span></c:when>
                                        <c:otherwise><span class="status-badge danger">CRITICAL</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${alert.message}</td>
                                <td>${alert.status}</td>
                                <td>${empty alert.controlAction ? '-' : alert.controlAction}</td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </table>
        </section>

        <!-- 최근 제어 로그 -->
        <section class="detail-panel full-panel">
            <h3>최근 제어 로그</h3>
            <table class="monitor-table">
                <tr>
                    <th>시간</th>
                    <th>제어 종류</th>
                    <th>발생 이유</th>
                    <th>결과</th>
                </tr>
                <c:choose>
                    <c:when test="${empty controlLogList}">
                        <tr><td colspan="4" class="empty-text">최근 제어 로그가 없습니다.</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="log" items="${controlLogList}">
                            <tr>
                                <td>${log.createdAt}</td>
                                <td>${log.controlType}</td>
                                <td>${log.triggerReason}</td>
                                <td>${log.resultStatus}</td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </table>
        </section>

    </main>
</div>

<script>
// Controller에서 JSON 문자열로 내려주는 값을 가정
// model.addAttribute("monitorChartJson", monitorChartJson);
// model.addAttribute("energyLogChartJson", energyLogChartJson);
var monitorChartData = ${empty monitorChartJson ? '[]' : monitorChartJson};
var energyLogChartData = ${empty energyLogChartJson ? '[]' : energyLogChartJson};

var monitorLabels = monitorChartData.map(function(row) { return row.recordTime; });
var socValues = monitorChartData.map(function(row) { return row.soc; });
var generationValues = monitorChartData.map(function(row) { return row.solarGenerationKwh; });
var powerValues = monitorChartData.map(function(row) { return row.powerOutput; });

var energyLabels = energyLogChartData.map(function(row) { return row.logDate; });
var dailyKwhValues = energyLogChartData.map(function(row) { return row.dailyKwh; });
var costValues = energyLogChartData.map(function(row) { return row.cost; });
var efficiencyValues = energyLogChartData.map(function(row) { return row.efficiency; });

function createLineChart(canvasId, labels, datasets) {
    var ctx = document.getElementById(canvasId);
    if (!ctx) return;

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: datasets
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
}

createLineChart('socChart', monitorLabels, [
    {
        label: 'SOC (%)',
        data: socValues,
        tension: 0.35
    }
]);

createLineChart('generationChart', monitorLabels, [
    {
        label: '발전량 (kWh)',
        data: generationValues,
        tension: 0.35
    },
    {
        label: '출력 (kW)',
        data: powerValues,
        tension: 0.35
    }
]);

createLineChart('energyLogChart', energyLabels, [
    {
        label: '일별 에너지 (kWh)',
        data: dailyKwhValues,
        tension: 0.35
    }
]);

createLineChart('costEfficiencyChart', energyLabels, [
    {
        label: '절감금액 (원)',
        data: costValues,
        tension: 0.35,
        yAxisID: 'y'
    },
    {
        label: '효율 (%)',
        data: efficiencyValues,
        tension: 0.35,
        yAxisID: 'y1'
    }
]);
</script>

</body>
</html>
