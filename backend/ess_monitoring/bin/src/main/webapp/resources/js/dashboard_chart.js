/*
 * 대시보드 차트 JS
 * - 최근 6개월 발전량
 * - 최근 6개월 절감 금액
 * - 장비별 발전량 TOP5
 * - 상대 축 범위 적용
 */

let monthlyGenerationChart;
let monthlyCostChart;
let deviceTopChart;


// 차트 요청 파라미터
function getDashboardChartParams() {

    if (typeof getDashboardParams === 'function') {
        return getDashboardParams();
    }

    return {};
}


// 공통 옵션
function commonDashboardChartOptions(unit) {

    return {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
            duration: 350
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
                beginAtZero: false,
                grid: {
                    color: '#e5e7eb'
                },
                ticks: {
                    color: '#64748b',
                    stepSize: unit
                }
            }
        }
    };
}


// 상대 y축 범위 적용
function applyRelativeYAxis(chart, values, unit) {

    if (!chart || !values || values.length === 0) {
        return;
    }

    const nums = values
        .map(function(value) {
            return Number(value || 0);
        })
        .filter(function(value) {
            return !isNaN(value);
        });

    if (nums.length === 0) {
        return;
    }

    const maxValue = Math.max.apply(null, nums);
    const minValue = Math.min.apply(null, nums);

    if (maxValue === 0 && minValue === 0) {
        chart.options.scales.y.min = 0;
        chart.options.scales.y.max = unit;
        chart.options.scales.y.ticks.stepSize = unit;
        return;
    }

    const upperPadding = maxValue * 0.12;
    const lowerPadding = maxValue * 0.05;

    const rawMin = Math.max(0, minValue - lowerPadding);
    const rawMax = maxValue + upperPadding;

    chart.options.scales.y.min =
        Math.floor(rawMin / unit) * unit;

    chart.options.scales.y.max =
        Math.ceil(rawMax / unit) * unit;

    chart.options.scales.y.ticks.stepSize = unit;
}


// 월별 발전량 차트 생성
function initMonthlyGenerationChart() {

    const canvas =
        document.getElementById('monthlyGenerationChart');

    if (!canvas) {
        return;
    }

    monthlyGenerationChart =
        new Chart(canvas.getContext('2d'), {
            type: 'bar',
            data: {
                labels: [],
                datasets: [{
                    label: '월별 발전량(kWh)',
                    data: [],
                    backgroundColor: 'rgba(37, 99, 235, 0.75)',
                    borderRadius: 6,
                    barThickness: 28
                }]
            },
            options: commonDashboardChartOptions(200)
        });
}


// 월별 절감 금액 차트 생성
function initMonthlyCostChart() {

    const canvas =
        document.getElementById('monthlyCostChart');

    if (!canvas) {
        return;
    }

    monthlyCostChart =
        new Chart(canvas.getContext('2d'), {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: '월별 절감 금액(원)',
                    data: [],
                    borderColor: '#16a34a',
                    backgroundColor: 'rgba(22, 163, 74, 0.10)',
                    borderWidth: 2,
                    pointRadius: 3,
                    pointHoverRadius: 5,
                    tension: 0.3,
                    fill: true
                }]
            },
            options: commonDashboardChartOptions(20000)
        });
}


// 장비별 TOP5 차트 생성
function initDeviceTopChart() {

    const canvas =
        document.getElementById('deviceTopChart');

    if (!canvas) {
        return;
    }

    deviceTopChart =
        new Chart(canvas.getContext('2d'), {
            type: 'bar',
            data: {
                labels: [],
                datasets: [{
                    label: '장비별 발전량(kWh)',
                    data: [],
                    backgroundColor: 'rgba(124, 58, 237, 0.75)',
                    borderRadius: 6,
                    barThickness: 28
                }]
            },
            options: commonDashboardChartOptions(100)
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

            applyRelativeYAxis(monthlyGenerationChart, values, 200);

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

            applyRelativeYAxis(monthlyCostChart, values, 20000);

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

            applyRelativeYAxis(deviceTopChart, values, 100);

            deviceTopChart.update();
        },

        error: function() {
            console.log('장비별 TOP5 차트 조회 실패');
        }
    });
}


// 전체 차트 조회
function loadDashboardCharts() {

    loadMonthlyGenerationChart();
    loadMonthlyCostChart();
    loadDeviceTopChart();
}


// 초기 실행
$(document).ready(function() {

    initMonthlyGenerationChart();
    initMonthlyCostChart();
    initDeviceTopChart();

    loadDashboardCharts();
});