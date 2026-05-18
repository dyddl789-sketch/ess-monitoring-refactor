/**
 * 대시보드 차트 JS
 * - selectedMonth 기준
 * - 월별 발전량 / 월별 절감 금액 / 장비별 TOP5
 */

let monthlyGenerationChart;
let monthlyCostChart;
let deviceTopChart;


// 차트 요청 파라미터
function getDashboardChartParams() {

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


// 공통 차트 옵션
function commonChartOptions() {

    return {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
            duration: 400
        },
        plugins: {
            legend: {
                position: 'bottom',
                labels: {
                    boxWidth: 12,
                    padding: 16,
                    color: '#475569'
                }
            },
            tooltip: {
                backgroundColor: '#0f172a',
                padding: 12
            }
        },
        scales: {
            x: {
                grid: {
                    display: false
                },
                ticks: {
                    color: '#64748b'
                }
            },
            y: {
                beginAtZero: true,
                grid: {
                    color: '#e5e7eb'
                },
                ticks: {
                    color: '#64748b'
                }
            }
        }
    };
}


// 최근 6개월 발전량
function initMonthlyGenerationChart() {

    const ctx = document.getElementById('monthlyGenerationChart');

    if (!ctx) {
        return;
    }

    monthlyGenerationChart = new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: [],
            datasets: [
                {
                    label: '월별 발전량',
                    data: [],
                    backgroundColor: 'rgba(37, 99, 235, 0.75)',
                    borderRadius: 4,
                    barThickness: 28
                }
            ]
        },
        options: commonChartOptions()
    });
}


// 최근 6개월 절감 금액
function initMonthlyCostChart() {

    const ctx = document.getElementById('monthlyCostChart');

    if (!ctx) {
        return;
    }

    monthlyCostChart = new Chart(ctx.getContext('2d'), {
        type: 'line',
        data: {
            labels: [],
            datasets: [
                {
                    label: '월별 절감 금액',
                    data: [],
                    borderColor: '#16a34a',
                    backgroundColor: 'rgba(22, 163, 74, 0.10)',
                    borderWidth: 2,
                    pointRadius: 3,
                    pointHoverRadius: 5,
                    tension: 0.3,
                    fill: true
                }
            ]
        },
        options: commonChartOptions()
    });
}


// 장비별 TOP5
function initDeviceTopChart() {

    const ctx = document.getElementById('deviceTopChart');

    if (!ctx) {
        return;
    }

    deviceTopChart = new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: [],
            datasets: [
                {
                    label: '장비별 발전량',
                    data: [],
                    backgroundColor: 'rgba(37, 99, 235, 0.75)',
                    borderRadius: 4,
                    barThickness: 22
                }
            ]
        },
        options: Object.assign(
            {},
            commonChartOptions(),
            {
                indexAxis: 'y'
            }
        )
    });
}


// 월별 발전량 조회
function loadMonthlyGenerationChart() {

    if (!monthlyGenerationChart) {
        return;
    }

    $.ajax({
        url: contextPath + '/dashboard/chart/monthly-generation',
        type: 'GET',
        data: getDashboardChartParams(),
        dataType: 'json',

        success: function(list) {

            list = list || [];

            const labels = [];
            const values = [];

            list.forEach(function(row) {
                labels.push(row.label);
                values.push(Number(row.monthlyKwh || row.value || 0));
            });

            monthlyGenerationChart.data.labels = labels;
            monthlyGenerationChart.data.datasets[0].data = values;
            monthlyGenerationChart.update();
        },

        error: function() {
            console.log('월별 발전량 차트 조회 실패');
        }
    });
}


// 월별 절감 금액 조회
function loadMonthlyCostChart() {

    if (!monthlyCostChart) {
        return;
    }

    $.ajax({
        url: contextPath + '/dashboard/chart/monthly-cost',
        type: 'GET',
        data: getDashboardChartParams(),
        dataType: 'json',

        success: function(list) {

            list = list || [];

            const labels = [];
            const values = [];

            list.forEach(function(row) {
                labels.push(row.label);
                values.push(Number(row.savedCost || row.value || 0));
            });

            monthlyCostChart.data.labels = labels;
            monthlyCostChart.data.datasets[0].data = values;
            monthlyCostChart.update();
        },

        error: function() {
            console.log('월별 절감 금액 차트 조회 실패');
        }
    });
}


// 장비별 TOP5 조회
function loadDeviceTopChart() {

    if (!deviceTopChart) {
        return;
    }

    $.ajax({
        url: contextPath + '/dashboard/chart/device-top',
        type: 'GET',
        data: getDashboardChartParams(),
        dataType: 'json',

        success: function(list) {

            list = list || [];

            const labels = [];
            const values = [];

            list.forEach(function(row) {
                labels.push(row.deviceName || row.label);
                values.push(Number(row.monthlyKwh || row.value || 0));
            });

            deviceTopChart.data.labels = labels;
            deviceTopChart.data.datasets[0].data = values;
            deviceTopChart.update();
        },

        error: function() {
            console.log('장비별 TOP5 차트 조회 실패');
        }
    });
}


// 전체 차트 갱신
function loadDashboardCharts() {

    loadMonthlyGenerationChart();
    loadMonthlyCostChart();
    loadDeviceTopChart();
}


// 초기 로딩
$(document).ready(function() {

    initMonthlyGenerationChart();
    initMonthlyCostChart();
    initDeviceTopChart();

    loadDashboardCharts();
});