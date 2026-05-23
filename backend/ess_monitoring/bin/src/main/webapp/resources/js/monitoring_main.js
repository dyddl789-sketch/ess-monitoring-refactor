/*
 * =========================
 * 상세 모니터링 메인 JS
 * monitoring_main.js
 * =========================
 */

let autoRefreshTimer = null;
let autoRefreshEnabled = true;

/* =========================
   공통 유틸
========================= */

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

function formatComma(value) {

    if (value === null || value === undefined || value === '') {
        return '-';
    }

    const num = Number(value);

    if (isNaN(num)) {
        return '-';
    }

    return num.toLocaleString();
}

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

    return hour + ':' + minute;
}

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

    return year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
}

function getTodayString() {

    const today = new Date();

    return today.getFullYear() +
        '-' +
        String(today.getMonth() + 1).padStart(2, '0') +
        '-' +
        String(today.getDate()).padStart(2, '0');
}

function isTodaySelected() {

    return $('#selectedDate').val() === getTodayString();
}

function formatNow() {

    return new Date().toLocaleTimeString();
}

function getMonitoringParams() {

    return {
        groupId: $('#groupSelect').val(),
        deviceId: $('#deviceSelect').val(),
        selectedDate: $('#selectedDate').val()
    };
}

/* =========================
   화면 상태 처리
========================= */

function setDeviceStatus(status) {

    const $status = $('#deviceStatus');

    $status.removeClass()
           .addClass('card-value');

    if (status === 'WARNING') {
        $status.addClass('status-warning').text('주의');
        return;
    }

    if (status === 'ERROR') {
        $status.addClass('status-error').text('이상');
        return;
    }

    if (status === 'OFFLINE') {
        $status.addClass('status-offline').text('오프라인');
        return;
    }

    $status.addClass('status-normal').text('정상');
}

function updateAutoRefreshMode() {

    if (isTodaySelected()) {
        $('#autoRefreshBtn').prop('disabled', false);

        if (autoRefreshEnabled) {
            startAutoRefresh();
        }

        return;
    }

    stopAutoRefresh();
    $('#autoRefreshBtn').prop('disabled', true).text('이력 조회 모드');
}

function setCompareText(selector, value, average, unit) {

    const $target = $(selector);

    if (!average || average <= 0) {
        $target.removeClass().addClass('card-sub').text('7일 평균 대비 -');
        return;
    }

    const diffRate = ((value - average) / average) * 100;
    const absRate = Math.abs(diffRate).toFixed(1);

    $target.removeClass().addClass('card-sub');

    if (diffRate > 0) {
        $target.addClass('compare-up')
               .text('7일 평균 대비 ▲ ' + absRate + '%');
        return;
    }

    if (diffRate < 0) {
        $target.addClass('compare-down')
               .text('7일 평균 대비 ▼ ' + absRate + '%');
        return;
    }

    $target.addClass('compare-normal')
           .text('7일 평균과 동일');
}

function updateMonitoringAlertBanner(data) {

    const $banner = $('#monitoringAlertBanner');
    const $icon = $('#monitoringAlertIcon');
    const $title = $('#monitoringAlertTitle');
    const $message = $('#monitoringAlertMessage');
    const $btn = $('#monitoringAlertMoveBtn');

    const status = data.deviceStatus || 'NORMAL';
    const soc = Number(data.soc || 0);
    const powerOutput = Number(data.powerOutput || 0);

    $banner.removeClass('normal warning danger offline');

    if (status === 'ERROR') {
        $banner.addClass('danger');
        $icon.text('!');
        $title.text('위험 상태 감지');
        $message.text('장비 이상 상태가 감지되었습니다. 즉시 점검이 필요합니다.');
        return;
    }

    if (status === 'WARNING') {
        $banner.addClass('warning');
        $icon.text('!');
        $title.text('주의 상태 감지');
        $message.text('장비 상태가 주의 단계입니다. 최근 알림과 운영 상태를 확인하세요.');
        return;
    }

    if (status === 'OFFLINE') {
        $banner.addClass('offline');
        $icon.text('-');
        $title.text('장비 오프라인');
        $message.text('장비 데이터 수신이 중단되었습니다. 통신 상태를 확인하세요.');
        return;
    }

    if (soc <= 20) {
        $banner.addClass('danger');
        $icon.text('!');
        $title.text('배터리 저전력 위험');
        $message.text('SOC가 20% 이하입니다. 충전 상태 확인이 필요합니다.');
        return;
    }

    if (soc <= 40) {
        $banner.addClass('warning');
        $icon.text('!');
        $title.text('배터리 잔량 주의');
        $message.text('SOC가 낮은 편입니다. 발전량과 사용량을 확인하세요.');
        return;
    }

    if (powerOutput <= 0 && isTodaySelected()) {
        $banner.addClass('warning');
        $icon.text('!');
        $title.text('현재 출력 낮음');
        $message.text('현재 발전 출력이 낮습니다. 날씨 또는 일몰 시간 영향일 수 있습니다.');
        return;
    }

    $banner.addClass('normal');
    $icon.text('●');
    $title.text('정상 운영 중');
    $message.text('현재 장비에서 확인된 주요 경고가 없습니다.');
}

/* =========================
   그룹 / 장비
========================= */

function loadDeviceList(callback) {

    const groupId = $('#groupSelect').val();

    $.ajax({
        url: contextPath + '/monitoring/devices',
        type: 'GET',
        data: {
            groupId: groupId
        },
        dataType: 'json',

        success: function(list) {

            const $deviceSelect = $('#deviceSelect');

            $deviceSelect.empty();
            $deviceSelect.append('<option value="">장비 선택</option>');

            if (list && list.length > 0) {
                list.forEach(function(device) {
                    $deviceSelect.append(
                        '<option value="' + device.deviceId + '">' +
                            device.deviceName +
                        '</option>'
                    );
                });
            }

            if (callback) {
                callback();
            }
        },

        error: function() {
            console.log('장비 목록 조회 실패');
        }
    });
}

/* =========================
   최신 / 일일 요약
========================= */

function loadMonitoringSummary() {

    const params = getMonitoringParams();

    if (!params.deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/summary',
        type: 'GET',
        data: params,
        dataType: 'json',

        success: function(data) {

            if (!data) {
                return;
            }

            setDeviceStatus(data.deviceStatus || 'NORMAL');
			updateMonitoringAlertBanner(data);
			
            $('#soc').text(formatNumber(data.soc, 1) + ' %');
            $('#powerOutput').text(formatNumber(data.powerOutput, 1) + ' kW');
            $('#todayGeneration').text(formatNumber(data.dailyKwh, 1) + ' kWh');
            $('#todaySavedCost').text(formatComma(data.savedCost) + ' 원');

            $('#voltage').text(formatNumber(data.voltage, 1) + ' V');
            $('#currentA').text(formatNumber(data.currentA, 1) + ' A');
            $('#powerOutputDetail').text(formatNumber(data.powerOutput, 1) + ' kW');
            $('#socDetail').text(formatNumber(data.soc, 1) + ' %');
            $('#recordTime').text(formatTimestamp(data.recordTime));

            if (data.generationSevenDayAvg !== undefined) {
                setCompareText(
                    '#generationCompareText',
                    Number(data.dailyKwh || 0),
                    Number(data.generationSevenDayAvg || 0),
                    'kWh'
                );
            }

            if (data.costSevenDayAvg !== undefined) {
                setCompareText(
                    '#costCompareText',
                    Number(data.savedCost || 0),
                    Number(data.costSevenDayAvg || 0),
                    '원'
                );
            }

            $('#lastUpdateTime').text(formatNow());

            updateOperationSummary(data);
            
            if (isHistoryMode()) {
			    applyHistoryModeView();
			}
        },

        error: function() {
            console.log('모니터링 요약 조회 실패');
        }
    });
}

/* =========================
   시간별 차트
========================= */

function loadDailyCharts() {

    const params = getMonitoringParams();

    if (!params.deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/history',
        type: 'GET',
        data: params,
        dataType: 'json',

        success: function(list) {

            list = list || [];

            const labels = [];
            const powerValues = [];
            const socValues = [];
            const generationValues = [];

            list.forEach(function(row) {

                labels.push(formatTimeLabel(row.recordTime));

                powerValues.push(Number(row.powerOutput || 0));
                socValues.push(Number(row.soc || 0));
                generationValues.push(Number(row.solarGenerationKwh || 0));
            });

            updatePowerChart(labels, powerValues);
            updateSocChart(labels, socValues);
            updateGenerationChart(labels, generationValues);
        },

        error: function() {
            console.log('모니터링 이력 차트 조회 실패');
        }
    });
}

/* =========================
   최근 7일 차트
========================= */

function loadWeeklyCharts() {

    const params = getMonitoringParams();

    if (!params.deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/weekly',
        type: 'GET',
        data: params,
        dataType: 'json',

        success: function(list) {

            list = list || [];

            const labels = [];
            const generationValues = [];
            const costValues = [];

            list.forEach(function(row) {
                labels.push(row.label || row.logDate);
                generationValues.push(Number(row.dailyKwh || row.value || 0));
                costValues.push(Number(row.cost || row.savedCost || 0));
            });

            updateWeeklyGenerationChart(labels, generationValues);
            updateWeeklyCostChart(labels, costValues);
        },

        error: function() {
            console.log('최근 7일 차트 조회 실패');
        }
    });
}

/* =========================
   최근 알림
========================= */

function loadAlerts() {

    const params = getMonitoringParams();

    if (!params.deviceId) {
        return;
    }

    $.ajax({
        url: contextPath + '/monitoring/alerts',
        type: 'GET',
        data: params,
        dataType: 'json',

        success: function(list) {

            let html = '';

            if (!list || list.length === 0) {

                html +=
                    '<div class="alert-item">' +
                        '<span class="alert-badge info">정보</span>' +
                        '<div class="alert-content">' +
                            '<div class="alert-message">최근 알림이 없습니다.</div>' +
                        '</div>' +
                    '</div>';

                $('#alertList').html(html);
                return;
            }

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

                html +=
                    '<div class="alert-item alert-click" ' +
                         'onclick="location.href=\'' + contextPath +
                         '/alert/detail?alertId=' + alert.alertId + '\'">' +

                        '<span class="alert-badge ' + levelClass + '">' +
                            levelText +
                        '</span>' +

                        '<div class="alert-content">' +
                            '<div class="alert-message">' +
                                (alert.message || '-') +
                            '</div>' +
                            '<div class="alert-time">' +
                                formatTimestamp(alert.createdAt) +
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

/* =========================
   운영 판단 요약
========================= */

function updateOperationSummary(data) {

    if (isHistoryMode()) {
        $('#operationCondition').text('선택한 날짜의 이력 데이터를 조회 중입니다.');
        $('#batteryCondition').text('실시간 배터리 상태는 오늘 날짜에서만 판단합니다.');
        $('#recommendAction').text('이전 날짜는 energy_log 기준 통계 확인용으로 활용하세요.');
        return;
    }

    const status = data.deviceStatus || 'NORMAL';
    const soc = Number(data.soc || 0);
    const powerOutput = Number(data.powerOutput || 0);
    const dailyKwh = Number(data.dailyKwh || 0);
    const avgKwh = Number(data.generationSevenDayAvg || 0);

    let operationCondition = '';
    let batteryCondition = '';
    let recommendAction = '';

    if (status === 'ERROR') {
        operationCondition = '장비 이상 상태가 감지되었습니다.';
        recommendAction = '즉시 장비 점검 및 최근 알림 확인이 필요합니다.';
    } else if (status === 'WARNING') {
        operationCondition = '장비가 주의 상태로 운영 중입니다.';
        recommendAction = '최근 알림과 발전량 저하 여부를 확인하세요.';
    } else if (status === 'OFFLINE') {
        operationCondition = '장비 데이터 수신이 중단되었습니다.';
        recommendAction = '통신 상태 또는 장비 전원 상태를 확인하세요.';
    } else if (powerOutput <= 0) {
        operationCondition = '현재 발전 출력이 낮거나 수신되지 않고 있습니다.';
        recommendAction = '날씨, 일몰 시간, 장비 상태를 함께 확인하세요.';
    } else {
        operationCondition = '현재 발전 출력이 정상적으로 수신되고 있습니다.';
        recommendAction = '현재 운영 상태는 양호합니다.';
    }

    if (soc >= 80) {
        batteryCondition = '배터리 SOC가 충분한 상태입니다.';
    } else if (soc >= 40) {
        batteryCondition = '배터리 SOC가 적정 범위에 있습니다.';
    } else if (soc >= 20) {
        batteryCondition = '배터리 SOC가 낮아 주의가 필요합니다.';
    } else {
        batteryCondition = '배터리 저전력 위험 상태입니다.';
        recommendAction = '충전 상태를 우선 확인하고 방전 운전을 제한하세요.';
    }

    if (avgKwh > 0) {
        if (dailyKwh < avgKwh * 0.7) {
            recommendAction = '선택일 발전량이 7일 평균보다 크게 낮습니다. 날씨 또는 장비 이상 여부를 확인하세요.';
        } else if (dailyKwh >= avgKwh * 1.1) {
            recommendAction = '선택일 발전량이 7일 평균보다 높아 운영 상태가 양호합니다.';
        }
    }

    $('#operationCondition').text(operationCondition);
    $('#batteryCondition').text(batteryCondition);
    $('#recommendAction').text(recommendAction);
}

/* =========================
   전체 조회
========================= */

function reloadMonitoring() {

    loadMonitoringSummary();
    loadDailyCharts();
    loadWeeklyCharts();
    loadAlerts();
    updateAutoRefreshMode();

}

/* =========================
   자동 갱신
========================= */

function startAutoRefresh() {

    stopAutoRefresh();

    autoRefreshEnabled = true;

    autoRefreshTimer = setInterval(function() {

        if (isTodaySelected()) {
            loadMonitoringSummary();
            loadDailyCharts();
            loadAlerts();
        }

    }, 10000);

    $('#autoRefreshBtn').text('자동갱신 OFF');
}

function stopAutoRefresh() {

    if (autoRefreshTimer !== null) {
        clearInterval(autoRefreshTimer);
        autoRefreshTimer = null;
    }

    $('#autoRefreshBtn').text('자동갱신 ON');
}

function toggleAutoRefresh() {

    if (!isTodaySelected()) {
        return;
    }

    if (autoRefreshTimer) {
        autoRefreshEnabled = false;
        stopAutoRefresh();
    } else {
        autoRefreshEnabled = true;
        startAutoRefresh();
    }
}

/* =========================
   초기 실행
========================= */

$(document).ready(function() {

    initMonitoringCharts();

    if (selectedDeviceId) {
        $('#deviceSelect').val(selectedDeviceId);
    } else if ($('#deviceSelect option').length > 1) {
        $('#deviceSelect option:eq(1)').prop('selected', true);
    }

    if (!$('#selectedDate').val()) {
        $('#selectedDate').val(getTodayString());
    }

    reloadMonitoring();

    $('#searchBtn').on('click', function() {
        reloadMonitoring();
    });

    $('#refreshBtn').on('click', function() {
        reloadMonitoring();
    });

    $('#groupSelect').on('change', function() {

        loadDeviceList(function() {

            if ($('#deviceSelect option').length > 1) {
                $('#deviceSelect option:eq(1)').prop('selected', true);
            }

            reloadMonitoring();
        });
    });

    $('#deviceSelect').on('change', function() {
        reloadMonitoring();
    });

    $('#selectedDate').on('change', function() {
        reloadMonitoring();
    });

    $('#autoRefreshBtn').on('click', function() {
        toggleAutoRefresh();
    });
    
	$('#monitoringAlertMoveBtn').on('click', function() {
	    $('html, body').animate({
	        scrollTop: $('#alertList').offset().top - 120
	    }, 300);
	});
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

// 현재 날짜 여부
function isHistoryMode() {

    return $('#selectedDate').val() !== getTodayString();
}


// 이력 조회 모드 표시
function applyHistoryModeView() {

    if (!isHistoryMode()) {

        $('.power-chart-title')
            .text('실시간 출력 그래프');

        $('.soc-chart-title')
            .text('SOC 변화 그래프');

        return;
    }

    setDeviceStatus('NORMAL');

    $('#soc').text('이력');
    $('#powerOutput').text('조회');

    $('#voltage').text('이력 데이터');
    $('#currentA').text('일별 통계');
    $('#powerOutputDetail').text('실시간 데이터 없음');
    $('#socDetail').text('energy_log 기준');
    $('#recordTime').text($('#selectedDate').val());

    $('#autoRefreshBtn')
        .prop('disabled', true)
        .text('이력 조회 모드');

    $('.power-chart-title')
        .text('선택일 출력 이력 그래프');

    $('.soc-chart-title')
        .text('선택일 SOC 변화');

    $('#monitoringAlertTitle')
        .text('이력 조회 모드');

    $('#monitoringAlertMessage')
        .text('선택한 날짜 기준 저장된 이력 데이터를 조회 중입니다.');
}
