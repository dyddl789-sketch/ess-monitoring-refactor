/**
 * 대시보드 메인 JS
 * - selectedMonth 기준
 * - 요약 카드 / 장비 셀렉트 / 알림 처리
 */

function getSummaryParams() {

    const params = {};

    let selectedMonth = $('#selectedMonth').val();

    if (!selectedMonth) {
        const today = new Date();

        selectedMonth =
            today.getFullYear() +
            '-' +
            String(today.getMonth() + 1).padStart(2, '0');

        $('#selectedMonth').val(selectedMonth);
    }

    params.selectedMonth = selectedMonth;

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


// 요약 카드 조회
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

            const totalDeviceCount =
                Number(data.totalDeviceCount || 0);

            const operatingDeviceCount =
                Number(data.operatingDeviceCount || 0);

            const monthlyGeneration =
                Number(data.monthlyGenerationKwh || 0);

            const monthlySavedCost =
                Number(data.monthlySavedCost || 0);

            const averageEfficiency =
                Number(data.averageEfficiency || 0);
                
            const deletedDeviceCount =
   				 Number(data.deletedDeviceCount || 0);

            $('#monthlyGenerationKwh')
                .text(monthlyGeneration.toFixed(1) + ' kWh');

            $('#generationSubInfo')
                .text('선택 월 발전량 합계');

            $('#monthlySavedCost')
                .text(monthlySavedCost.toLocaleString() + '원');

            $('#savedCostSubInfo')
                .text('선택 월 절감 금액 합계');

            $('#averageEfficiency')
                .text(averageEfficiency.toFixed(1) + '%');

            $('#efficiencySubInfo')
                .text('선택 월 평균 효율');

            $('#operatingDeviceCount')
                .text(operatingDeviceCount + ' / ' + totalDeviceCount + '대');

			$('#deviceSubInfo')
			    .text(
			        '운영 종료 ' +
			        deletedDeviceCount +
			        '대 · 기록 포함'
			    );
        },

        error: function() {
            setEmptySummary();
            console.log('대시보드 요약 조회 실패');
        }
    });
}


// 요약 카드 초기화
function setEmptySummary() {

    $('#monthlyGenerationKwh').text('-');
    $('#generationSubInfo').text('발전량 데이터 없음');

    $('#monthlySavedCost').text('-');
    $('#savedCostSubInfo').text('절감 금액 데이터 없음');

    $('#averageEfficiency').text('-');
    $('#efficiencySubInfo').text('효율 데이터 없음');

    $('#operatingDeviceCount').text('-');
    $('#deviceSubInfo').text('장비 데이터 없음');
}


// 그룹 변경 시 장비 목록 갱신
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


// 대시보드 전체 갱신
function reloadDashboard() {

    loadSummary();
    loadDashboardAlerts();

    if (typeof loadDashboardCharts === 'function') {
        loadDashboardCharts();
    }
}


// HTML 이스케이프
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


// 알림 시간 표시
function formatDashboardAlertTime(value) {

    if (!value) {
        return '-';
    }

    const date = new Date(value);

    if (isNaN(date.getTime())) {
        return value;
    }

    const month =
        String(date.getMonth() + 1).padStart(2, '0');

    const day =
        String(date.getDate()).padStart(2, '0');

    const hour =
        String(date.getHours()).padStart(2, '0');

    const minute =
        String(date.getMinutes()).padStart(2, '0');

    return month + '-' + day + ' ' + hour + ':' + minute;
}


// 최근 알림 조회
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


// 초기 로딩
$(document).ready(function() {

    if ($('#selectedMonth').length > 0 && !$('#selectedMonth').val()) {

        const today = new Date();

        const selectedMonth =
            today.getFullYear() +
            '-' +
            String(today.getMonth() + 1).padStart(2, '0');

        $('#selectedMonth').val(selectedMonth);
    }

    reloadDashboard();

    $('#selectedMonth').on('change', function() {
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


// 알림 클릭
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