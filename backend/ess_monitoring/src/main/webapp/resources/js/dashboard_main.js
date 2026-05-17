function getSummaryParams() {

    const params = {};

    let selectedDate = $('#selectedDate').val();

    if (!selectedDate) {
        selectedDate = new Date().toISOString().split('T')[0];
        $('#selectedDate').val(selectedDate);
    }

    params.selectedDate = selectedDate;

    const groupId = $('#groupSelect').val();
    const deviceId = $('#deviceSelect').val();

    if (groupId) {
        params.groupId = groupId;
    }

    if (deviceId) {
        params.deviceId = deviceId;
    }

    return params;
}

function loadSummary() {

    $.ajax({
        url: contextPath + '/dashboard/summary',
        type: 'GET',
        data: getSummaryParams(),
        dataType: 'json',

        success: function(data) {

            if (!data) {
                setEmptySummary();
                return;
            }

            const totalDeviceCount = Number(data.totalDeviceCount || 0);
            const activeDeviceCount = Number(data.activeDeviceCount || data.collectedDeviceCount || 0);

            const todayGeneration = Number(data.todayGenerationKwh || 0);
            const monthlyGeneration = Number(data.monthlyGenerationKwh || 0);
            const monthlySavedCost = Number(data.monthlySavedCost || data.todaySavedCost || 0);
            const averageEfficiency = Number(data.averageEfficiency || data.averageSoc || 0);

            $('#collectedDeviceCount')
                .text(activeDeviceCount + ' / ' + totalDeviceCount + '대');

            $('#collectionSubInfo')
                .text('운영 장비 / 전체 등록 장비');

            $('#todayGenerationKwh')
                .text(todayGeneration.toFixed(1) + ' kWh');

            $('#generationSubInfo')
                .text('선택일 발전량');

            $('#averageSoc')
                .text(averageEfficiency.toFixed(1) + '%');

            $('#socSubInfo')
                .text('energy_log 평균 효율');

            $('#todaySavedCost')
                .text(monthlySavedCost.toLocaleString() + '원');

            $('#savedCostSubInfo')
                .text('선택월 절감 금액');

            if ($('#monthlyGenerationKwh').length > 0) {
                $('#monthlyGenerationKwh')
                    .text(monthlyGeneration.toFixed(1) + ' kWh');
            }
        },

        error: function() {
            setEmptySummary();
            console.log('대시보드 요약 정보 조회 실패');
        }
    });
}

function setEmptySummary() {

    $('#collectedDeviceCount').text('-');
    $('#collectionSubInfo').text('장비 데이터 없음');

    $('#todayGenerationKwh').text('-');
    $('#generationSubInfo').text('발전량 데이터 없음');

    $('#averageSoc').text('-');
    $('#socSubInfo').text('효율 데이터 없음');

    $('#todaySavedCost').text('-');
    $('#savedCostSubInfo').text('절감 금액 데이터 없음');
}

function loadDeviceList(callback) {

    const params = getSummaryParams();
    delete params.deviceId;

    $.ajax({
        url: contextPath + '/dashboard/devices',
        type: 'GET',
        data: params,
        dataType: 'json',

        success: function(devices) {

            const $deviceSelect = $('#deviceSelect');

            $deviceSelect.empty();
            $deviceSelect.append('<option value="">전체 장비</option>');

            if (devices && devices.length > 0) {
                devices.forEach(function(device) {
                    $deviceSelect.append(
                        '<option value="' + device.deviceId + '">' +
                            escapeHtml(device.deviceName) +
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

function reloadDashboard() {

    loadSummary();
    loadDashboardAlerts();

    if (typeof loadDashboardCharts === 'function') {
        loadDashboardCharts();
    }
}

function escapeHtml(value) {

    if (value == null) {
        return '-';
    }

    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function formatDashboardAlertTime(value) {

    if (!value) {
        return '-';
    }

    const date = new Date(value);

    if (isNaN(date.getTime())) {
        return value;
    }

    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');

    return hour + ':' + minute;
}

function loadDashboardAlerts() {

    $.ajax({
        url: contextPath + '/dashboard/alerts',
        type: 'GET',
        data: getSummaryParams(),
        dataType: 'json',

        success: function(list) {

            let html = '';

            if (!list || list.length === 0) {

                html +=
                    '<div class="dashboard-alert-item">' +
                        '<span class="dashboard-alert-badge info">정보</span>' +
                        '<div class="dashboard-alert-content">' +
                            '<div class="dashboard-alert-message">최근 알림이 없습니다.</div>' +
                        '</div>' +
                    '</div>';

                $('#dashboardAlertList').html(html);
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
                    '<div class="dashboard-alert-item" data-alert-id="' + alert.alertId + '">' +
                        '<span class="dashboard-alert-badge ' + levelClass + '">' +
                            levelText +
                        '</span>' +
                        '<div class="dashboard-alert-content">' +
                            '<div class="dashboard-alert-message">' +
                                escapeHtml(alert.deviceName) + ' ' + escapeHtml(alert.message) +
                            '</div>' +
                            '<div class="dashboard-alert-time">' +
                                formatDashboardAlertTime(alert.createdAt) +
                            '</div>' +
                        '</div>' +
                    '</div>';
            });

            $('#dashboardAlertList').html(html);
        },

        error: function() {
            console.log('대시보드 알림 조회 실패');
        }
    });
}

$(document).ready(function() {

    if ($('#selectedDate').length > 0 && !$('#selectedDate').val()) {
        $('#selectedDate').val(
            new Date().toISOString().split('T')[0]
        );
    }

    reloadDashboard();

    $('#selectedDate').on('change', function() {
        reloadDashboard();
    });

    $('#groupSelect').on('change', function() {

        loadDeviceList(function() {
            $('#deviceSelect').val('');
            reloadDashboard();
        });
    });

    $('#deviceSelect').on('change', function() {
        reloadDashboard();
    });

    $('#refreshBtn').on('click', function() {
        reloadDashboard();
    });
});

$(document).on('click', '.dashboard-alert-item', function() {

    const alertId = $(this).data('alert-id');

    if (!alertId) {
        return;
    }

    location.href =
        contextPath +
        '/alert/detail?alertId=' +
        alertId;
});