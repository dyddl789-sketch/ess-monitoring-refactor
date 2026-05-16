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
		    maintainAspectRatio: false,
		    scales: {
		        x: {
		            ticks: {
		                maxRotation: 0,
		                autoSkip: true,
		                maxTicksLimit: 10
		            }
		        }
		    }
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
		    maintainAspectRatio: false,
		    scales: {
		        x: {
		            ticks: {
		                maxRotation: 0,
		                autoSkip: true,
		                maxTicksLimit: 10
		            }
		        }
		    }
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
    
	if (Number(data.powerOutput || 0) < 1.0) {
    	$('#deviceStatus')
        	.removeClass()
        	.addClass('card-value status-error')
        	.text('장비 이상');
	} else {
    	$('#deviceStatus')
        .removeClass()
        .addClass('card-value status-normal')
        .text('정상');
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

    while (powerLabels.length > 10) {
        powerLabels.shift();
        powerData.shift();
    }

    while (socLabels.length > 10) {
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

    let operationCondition = '-';
    let batteryCondition = '-';
    let recommendAction = '-';

    /*
     * 현재 SOC 읽기
     */
    const socText =
        $('#soc')
            .text()
            .replace('%', '');

    const soc = Number(socText);

    /*
     * 발전 조건 판단
     */
    if (weather.rainType &&
        weather.rainType !== '없음') {

        operationCondition = '발전량 낮음';

    } else if (weather.skyStatus === '맑음') {

        operationCondition = '발전 양호';

    } else if (weather.skyStatus === '흐림') {

        operationCondition = '발전 보통';

    } else {

        operationCondition = '상태 확인 필요';
    }

    /*
     * 배터리 상태
     */
    if (!isNaN(soc)) {

        if (soc >= 80) {

            batteryCondition =
                '충전 상태 양호';

        } else if (soc >= 40) {

            batteryCondition =
                '배터리 상태 보통';

        } else if (soc >= 20) {

            batteryCondition =
                '충전 필요';

        } else {

            batteryCondition =
                '저전력 경고';
        }
    }

    /*
     * 권장 조치
     */
    if (soc < 20) {

        recommendAction =
            '절전 모드 권장';

    } else if (
        operationCondition === '발전량 낮음'
    ) {

        recommendAction =
            'ESS 충전 상태 확인 권장';

    } else if (
        operationCondition === '발전 양호'
    ) {

        recommendAction =
            '현재 상태 유지';

    } else {

        recommendAction =
            '상태 모니터링 필요';
    }

    /*
     * 화면 반영
     */
    $('#operationCondition')
        .text(operationCondition);

    $('#batteryCondition')
        .text(batteryCondition);

    $('#recommendAction')
        .text(recommendAction);
}
/*
 * 최근 알림 조회
 */
function loadAlerts() {

    const deviceId =
        $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({

        url:
            contextPath +
            '/monitoring/alerts',

        type: 'GET',

        data: {
            deviceId: deviceId
        },

        dataType: 'json',

        success: function(list) {

            let html = '';

            /*
             * 알림 없을 경우
             */
            if (!list || list.length === 0) {

                html +=
                    '<div class="alert-item">' +

                        '<span class="alert-badge info">' +
                            '정보' +
                        '</span>' +

                        '<span class="alert-message">' +
                            '최근 알림이 없습니다.' +
                        '</span>' +

                    '</div>';

                $('#alertList').html(html);

                return;
            }

            /*
             * 알림 목록 출력
             */
		list.forEach(function(alert) {
		
		    let levelClass = 'info';
		    let levelText = '정보';
		
		    if (alert.alertLevel === 'WARNING') {
		        levelClass = 'warning';
		        levelText = '경고';
		    }
		
		    if (alert.alertLevel === 'CRITICAL') {
		        levelClass = 'danger';
		        levelText = '위험';
		    }
		
		    const createdAt =
		        formatTimestamp(alert.createdAt);
		
		    html +=
		        '<div class="alert-item alert-click" ' +
		             'onclick="location.href=\'' + contextPath +
		             '/alert/detail?alertId=' + alert.alertId + '\'">' +
		
		            '<span class="alert-badge ' + levelClass + '">' +
		                levelText +
		            '</span>' +
		
		            '<div class="alert-content">' +
		                '<div class="alert-message">' +
		                    alert.message +
		                '</div>' +
		
		                '<div class="alert-time">' +
		                    createdAt +
		                '</div>' +
		            '</div>' +
		
		        '</div>';
		});

            $('#alertList').html(html);
        },

        error: function() {

            console.log('알림 조회 실패');
        }
    });
}
/*
 * 전체 실시간 데이터 조회
 */
function loadRealtimeData() {

    loadLatestMonitoring();

    loadWeather();

    loadAlerts();
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