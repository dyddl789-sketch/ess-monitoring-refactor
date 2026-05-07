/*
 * =========================
 * 실시간 모니터링 JS
 * monitoring_main.js
 * =========================
 */

/* 출력 그래프 객체 */
let powerChart;

/* SOC 그래프 객체 */
let socChart;

/* 자동 갱신 타이머 */
let autoRefreshTimer = null;

/* 출력 그래프 데이터 */
const powerLabels = [];
const powerData = [];

/* SOC 그래프 데이터 */
const socLabels = [];
const socData = [];

/*
 * 숫자 포맷
 * null, undefined, 빈값 방지
 */
function formatNumber(value, digit) {

    if (value === null || value === undefined || value === '') {
        return '-';
    }

    const num = Number(value);

    if (isNaN(num)) {
        return '-';
    }

    return num.toFixed(digit);
}

/*
 * timestamp(ms) 또는 날짜 문자열 → HH:mm 변환
 * 그래프 X축 표시용
 */
function formatTimeLabel(recordTime) {

    if (!recordTime) {
        return '-';
    }

    let date;

    if (!isNaN(Number(recordTime))) {
        date = new Date(Number(recordTime));
    } else {
        date = new Date(recordTime);
    }

    if (isNaN(date.getTime())) {
        return '-';
    }

    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');

    return `${hour}:${minute}`;
}

/*
 * timestamp(ms) 또는 날짜 문자열 → yyyy-MM-dd HH:mm:ss 변환
 * 상세 측정 시간 표시용
 */
function formatTimestamp(recordTime) {

    if (!recordTime) {
        return '-';
    }

    let date;

    if (!isNaN(Number(recordTime))) {
        date = new Date(Number(recordTime));
    } else {
        date = new Date(recordTime);
    }

    if (isNaN(date.getTime())) {
        return '-';
    }

    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');
    const second = String(date.getSeconds()).padStart(2, '0');

    return `${year}-${month}-${day} ${hour}:${minute}:${second}`;
}

/*
 * 마지막 갱신 시간 표시
 */
function formatNow() {

    return new Date().toLocaleTimeString();
}

/*
 * 날씨 상태 아이콘 반환
 */
function getWeatherIcon(skyStatus, rainType) {

    if (rainType && rainType !== '없음') {

        if (rainType === '눈') {
            return '❄️';
        }

        if (rainType === '비/눈') {
            return '🌨️';
        }

        return '🌧️';
    }

    if (skyStatus === '맑음') {
        return '☀️';
    }

    if (skyStatus === '구름많음') {
        return '⛅';
    }

    if (skyStatus === '흐림') {
        return '☁️';
    }

    return '🌡️';
}

/*
 * Chart.js 초기화
 */
function initCharts() {

    const powerCtx = document.getElementById('powerChart').getContext('2d');
    const socCtx = document.getElementById('socChart').getContext('2d');

    powerChart = new Chart(powerCtx, {
        type: 'line',
        data: {
            labels: powerLabels,
            datasets: [{
                label: '출력(kW)',
                data: powerData,
                tension: 0.35,
                borderWidth: 3,
                pointRadius: 4
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
            labels: socLabels,
            datasets: [{
                label: 'SOC(%)',
                data: socData,
                tension: 0.35,
                borderWidth: 3,
                pointRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

/*
 * 최근 모니터링 이력 조회
 * 그래프 초기 데이터 생성
 */
function loadMonitoringHistory() {

    const deviceId = $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/history',
        type: 'GET',
        data: {
            deviceId: deviceId
        },
        dataType: 'json',

        success: function(list) {

            powerLabels.length = 0;
            powerData.length = 0;
            socLabels.length = 0;
            socData.length = 0;

            if (!list || list.length === 0) {
                powerChart.update();
                socChart.update();
                return;
            }

            list.reverse();

            list.forEach(function(item) {

                const label = formatTimeLabel(item.recordTime);

                powerLabels.push(label);
                powerData.push(Number(item.powerOutput || 0));

                socLabels.push(label);
                socData.push(Number(item.soc || 0));
            });

            powerChart.update();
            socChart.update();
        },

        error: function() {
            console.log('모니터링 이력 조회 실패');
        }
    });
}

/*
 * 최신 모니터링 데이터 화면 반영
 */
function updateMonitoring(data) {

    if (!data) {
        return;
    }

    $('#soc').text(formatNumber(data.soc, 1) + '%');

    $('#powerOutput').text(formatNumber(data.powerOutput, 1) + ' kW');

    $('#todayGeneration').text(
        formatNumber(data.solarGenerationKwh, 1) + ' kWh'
    );

    $('#voltage').text(formatNumber(data.voltage, 1) + ' V');

    $('#currentA').text(formatNumber(data.currentA, 1) + ' A');

    $('#powerOutputDetail').text(
        formatNumber(data.powerOutput, 1) + ' kW'
    );

    $('#recordTime').text(formatTimestamp(data.recordTime));

    addLatestChartData(data);
}

/*
 * 최신 데이터 그래프 추가
 */
function addLatestChartData(data) {

    if (!data) {
        return;
    }

    const label = formatTimeLabel(data.recordTime);

    if (
        powerLabels.length > 0 &&
        powerLabels[powerLabels.length - 1] === label
    ) {
        powerData[powerData.length - 1] = Number(data.powerOutput || 0);
        socData[socData.length - 1] = Number(data.soc || 0);
    } else {
        powerLabels.push(label);
        powerData.push(Number(data.powerOutput || 0));

        socLabels.push(label);
        socData.push(Number(data.soc || 0));
    }

    while (powerLabels.length > 20) {
        powerLabels.shift();
        powerData.shift();
    }

    while (socLabels.length > 20) {
        socLabels.shift();
        socData.shift();
    }

    powerChart.update();
    socChart.update();
}

/*
 * 최신 모니터링 데이터 조회
 */
function loadLatestMonitoring() {

    const deviceId = $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/latest',
        type: 'GET',
        data: {
            deviceId: deviceId
        },
        dataType: 'json',

        success: function(data) {
            updateMonitoring(data);
            $('#lastUpdateTime').text(formatNow());
        },

        error: function() {
            console.log('최신 모니터링 조회 실패');
        }
    });
}

/*
 * 현재 날씨 조회
 */
function loadWeather() {

    const deviceId = $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/weather/current',
        type: 'GET',
        data: {
            deviceId: deviceId
        },
        dataType: 'json',

        success: function(data) {

            if (!data) {
                return;
            }

            $('#weatherIcon').text(
                getWeatherIcon(data.skyStatus, data.rainType)
            );

            $('#temperature').text(
                formatNumber(data.temperature, 1) + '℃'
            );

            $('#skyStatus').text(data.skyStatus || '-');

            $('#rainProb').text((data.rainProb || '-') + '%');

            $('#humidity').text((data.humidity || '-') + '%');

            $('#windSpeed').text(
                formatNumber(data.windSpeed, 1) + ' m/s'
            );

            $('#solarRadiation').text(
                formatNumber(data.solarRadiation, 1)
            );

            $('#sunTime').text(
                (data.sunrise || '-') + ' / ' + (data.sunset || '-')
            );

            $('#essStatus').text(data.essStatus || '-');

            updateOperationSummary(data);
        },

        error: function() {
            console.log('날씨 조회 실패');
        }
    });
}

/*
 * 운영 판단 요약
 */
function updateOperationSummary(weather) {

    const operationCondition =
        weather && weather.essStatus
            ? weather.essStatus
            : '-';

    let batteryCondition = '-';
    let recommendAction = '-';

    const socText = $('#soc').text().replace('%', '');
    const soc = Number(socText);

    if (!isNaN(soc)) {

        if (soc >= 80) {
            batteryCondition = '충전 상태 양호';
        } else if (soc >= 40) {
            batteryCondition = '보통';
        } else {
            batteryCondition = '충전 필요';
        }
    }

    if (operationCondition === '발전 조건 양호') {
        recommendAction = '현재 조치 필요 없음';
    } else if (operationCondition === '야간 발전 없음') {
        recommendAction = 'ESS 방전/대기 모드 권장';
    } else if (operationCondition === '발전량 저하 예상') {
        recommendAction = '배터리 잔량 확인 권장';
    } else {
        recommendAction = '상태 모니터링 필요';
    }

    $('#operationCondition').text(operationCondition);
    $('#batteryCondition').text(batteryCondition);
    $('#recommendAction').text(recommendAction);
}

/*
 * 전체 실시간 데이터 조회
 */
function loadRealtimeData() {

    loadLatestMonitoring();
    loadWeather();
}

/*
 * 자동 갱신 시작
 */
function startAutoRefresh() {

    stopAutoRefresh();

    autoRefreshTimer = setInterval(loadRealtimeData, 10000);

    $('#autoRefreshBtn').text('자동갱신 OFF');
}

/*
 * 자동 갱신 중지
 */
function stopAutoRefresh() {

    if (autoRefreshTimer != null) {
        clearInterval(autoRefreshTimer);
        autoRefreshTimer = null;
    }

    $('#autoRefreshBtn').text('자동갱신 ON');
}

/*
 * 자동 갱신 토글
 */
function toggleAutoRefresh() {

    if (autoRefreshTimer) {
        stopAutoRefresh();
    } else {
        startAutoRefresh();
    }
}

/*
 * 페이지 초기 실행
 */
$(document).ready(function() {

    initCharts();

    if (selectedDeviceId) {
        $('#deviceSelect').val(selectedDeviceId);
    } else if ($('#deviceSelect option').length > 1) {
        $('#deviceSelect option:eq(1)').prop('selected', true);
    }

    loadMonitoringHistory();

    loadRealtimeData();

    startAutoRefresh();

    $('#refreshBtn').on('click', function() {
        loadRealtimeData();
    });

    $('#deviceSelect').on('change', function() {
        loadMonitoringHistory();
        loadRealtimeData();
    });

    $('#autoRefreshBtn').on('click', toggleAutoRefresh);

    const sidebar = document.getElementById('sidebar');
    const main = document.querySelector('.main');
    const toggleBtn = document.getElementById('sidebarToggle');

    if (sidebar && main && toggleBtn) {

        toggleBtn.addEventListener('click', function() {
            sidebar.classList.toggle('collapsed');
            main.classList.toggle('collapsed');
        });
    }
});