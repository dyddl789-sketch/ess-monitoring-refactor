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

    const soc = Number(data.soc || 0);
    const powerOutput = Number(data.powerOutput || 0);
    const dailyKwh = Number(data.dailyKwh || 0);
    const avgKwh = Number(data.generationSevenDayAvg || 0);

    let operationCondition = '발전 상태 분석 준비 중';
    let batteryCondition = '배터리 상태 분석 준비 중';
    let recommendAction = '운영 권장 조치 분석 준비 중';

    if (powerOutput <= 0) {
        operationCondition = '현재 출력이 낮아 발전 상태 확인이 필요합니다.';
    } else {
        operationCondition = '현재 발전 출력이 정상적으로 수신되고 있습니다.';
    }

    if (soc >= 80) {
        batteryCondition = '배터리 SOC가 충분한 상태입니다.';
    } else if (soc >= 40) {
        batteryCondition = '배터리 SOC가 적정 범위에 있습니다.';
    } else if (soc >= 20) {
        batteryCondition = '배터리 충전 상태가 낮아 주의가 필요합니다.';
    } else {
        batteryCondition = '배터리 저전력 상태입니다.';
    }

    if (avgKwh > 0 && dailyKwh >= avgKwh) {
        recommendAction = '선택일 발전량이 7일 평균 이상으로 양호합니다.';
    } else if (avgKwh > 0) {
        recommendAction = '선택일 발전량이 7일 평균보다 낮아 원인 확인이 필요합니다.';
    } else {
        recommendAction = '데이터가 누적되면 발전량 비교 분석이 가능합니다.';
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