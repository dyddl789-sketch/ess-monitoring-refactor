let weeklyGenerationChart;
let monthlyGenerationChart;
let deviceTopChart;

function getDashboardChartParams() {

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

function initWeeklyGenerationChart() {

    const ctx = document.getElementById('generationCompareChart');

    if (!ctx) {
        return;
    }

    weeklyGenerationChart = new Chart(ctx.getContext('2d'), {
        type: 'line',
        data: {
            labels: [],
            datasets: [
                {
                    label: '최근 7일 발전량',
                    data: [],
                    borderColor: '#2563eb',
                    backgroundColor: 'rgba(37, 99, 235, 0.10)',
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

function initDeviceTopChart() {

    const ctx = document.getElementById('deviceGenerationChart');

    if (!ctx) {
        return;
    }

    deviceTopChart = new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: [],
            datasets: [
                {
                    label: '장비별 월간 발전량',
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

function initMonthlyGenerationChart() {

    const ctx = document.getElementById('socCompareChart');

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

function loadWeeklyGenerationChart() {

    if (!weeklyGenerationChart) {
        return;
    }

    $.ajax({
        url: contextPath + '/dashboard/chart/weekly',
        type: 'GET',
        data: getDashboardChartParams(),
        dataType: 'json',

        success: function(list) {

            list = list || [];

            const labels = [];
            const values = [];

            list.forEach(function(row) {
                labels.push(row.label);
                values.push(Number(row.dailyKwh || row.value || 0));
            });

            weeklyGenerationChart.data.labels = labels;
            weeklyGenerationChart.data.datasets[0].data = values;
            weeklyGenerationChart.update();
        },

        error: function() {
            console.log('최근 7일 발전량 차트 조회 실패');
        }
    });
}

function loadMonthlyGenerationChart() {

    if (!monthlyGenerationChart) {
        return;
    }

    $.ajax({
        url: contextPath + '/dashboard/chart/monthly',
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

function loadDashboardCharts() {

    loadWeeklyGenerationChart();
    loadMonthlyGenerationChart();
    loadDeviceTopChart();
}

$(document).ready(function() {

    initWeeklyGenerationChart();
    initMonthlyGenerationChart();
    initDeviceTopChart();

    loadDashboardCharts();

    $('#refreshBtn').on('click', function() {
        loadDashboardCharts();
    });

    $('#groupSelect').on('change', function() {
        loadDashboardCharts();
    });

    $('#deviceSelect').on('change', function() {
        loadDashboardCharts();
    });

    $('#selectedDate').on('change', function() {
        loadDashboardCharts();
    });
});