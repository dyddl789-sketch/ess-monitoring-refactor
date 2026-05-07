let generationCompareChart;
let socCompareChart;
let deviceGenerationChart;

function getDashboardChartParams() {
    const params = {
        selectedDate: $('#selectedDate').val()
    };

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

function emptyChartMessage(ctx, message) {
    return;
}

function initGenerationCompareChart() {
    const ctx = document.getElementById('generationCompareChart').getContext('2d');

    generationCompareChart = new Chart(ctx, {
        data: {
            labels: [],
            datasets: [
                {
                    type: 'bar',
                    label: '선택일 발전량',
                    data: [],
                    backgroundColor: 'rgba(37, 99, 235, 0.75)',
                    borderRadius: 8,
                    yAxisID: 'y'
                },
                {
                    type: 'bar',
                    label: '이전일 발전량',
                    data: [],
                    backgroundColor: 'rgba(203, 213, 225, 0.9)',
                    borderRadius: 8,
                    yAxisID: 'y'
                },
                {
                    type: 'line',
                    label: '발전량 차이',
                    data: [],
                    borderColor: '#22c55e',
                    backgroundColor: '#22c55e',
                    tension: 0.35,
                    borderWidth: 3,
                    pointRadius: 4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false
            },
            plugins: {
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'kWh'
                    }
                },
                y1: {
                    position: 'right',
                    grid: {
                        drawOnChartArea: false
                    },
                    title: {
                        display: true,
                        text: '차이'
                    }
                }
            }
        }
    });
}

function initSocCompareChart() {
    const ctx = document.getElementById('socCompareChart').getContext('2d');

    socCompareChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [
                {
                    label: '선택일 SOC',
                    data: [],
                    borderColor: '#2563eb',
                    backgroundColor: '#2563eb',
                    tension: 0.35,
                    borderWidth: 3,
                    pointRadius: 4
                },
                {
                    label: '이전일 SOC',
                    data: [],
                    borderColor: '#cbd5e1',
                    backgroundColor: '#cbd5e1',
                    tension: 0.35,
                    borderWidth: 3,
                    pointRadius: 4
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

function initDeviceGenerationChart() {
    const ctx = document.getElementById('deviceGenerationChart').getContext('2d');

    deviceGenerationChart = new Chart(ctx, {
        data: {
            labels: [],
            datasets: [
                {
                    type: 'bar',
                    label: '선택일 발전량',
                    data: [],
                    backgroundColor: 'rgba(37, 99, 235, 0.75)',
                    borderRadius: 8,
                    yAxisID: 'y'
                },
                {
                    type: 'bar',
                    label: '이전일 발전량',
                    data: [],
                    backgroundColor: 'rgba(203, 213, 225, 0.9)',
                    borderRadius: 8,
                    yAxisID: 'y'
                },
                {
                    type: 'line',
                    label: '차이',
                    data: [],
                    borderColor: '#22c55e',
                    backgroundColor: '#22c55e',
                    tension: 0.35,
                    borderWidth: 3,
                    pointRadius: 4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false
            },
            plugins: {
                legend: {
                    position: 'top'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    position: 'left',
                    title: {
                        display: true,
                        text: 'kWh'
                    }
                },
                y1: {
                    position: 'right',
                    grid: {
                        drawOnChartArea: false
                    },
                    title: {
                        display: true,
                        text: '차이'
                    }
                }
            }
        }
    });
}

function loadHourlyChart() {
    $.ajax({
        url: contextPath + '/dashboard/chart/hourly',
        type: 'GET',
        data: getDashboardChartParams(),
        dataType: 'json',
        success: function(list) {
            if (!list) {
                list = [];
            }

            const labels = [];
            const selectedGeneration = [];
            const previousGeneration = [];
            const generationDiff = [];
            const selectedSoc = [];
            const previousSoc = [];

            list.forEach(function(row) {
                labels.push(row.label);
                selectedGeneration.push(Number(row.selectedGeneration || 0));
                previousGeneration.push(Number(row.previousGeneration || 0));
                generationDiff.push(Number(row.generationDiff || 0));
                selectedSoc.push(Number(row.selectedSoc || 0));
                previousSoc.push(Number(row.previousSoc || 0));
            });

            generationCompareChart.data.labels = labels;
            generationCompareChart.data.datasets[0].data = selectedGeneration;
            generationCompareChart.data.datasets[1].data = previousGeneration;
            generationCompareChart.data.datasets[2].data = generationDiff;
            generationCompareChart.update();

            socCompareChart.data.labels = labels;
            socCompareChart.data.datasets[0].data = selectedSoc;
            socCompareChart.data.datasets[1].data = previousSoc;
            socCompareChart.update();
        },
        error: function() {
            console.log('시간별 차트 데이터 조회 실패');
        }
    });
}

function loadDeviceChart() {
    $.ajax({
        url: contextPath + '/dashboard/chart/device',
        type: 'GET',
        data: getDashboardChartParams(),
        dataType: 'json',
        success: function(list) {
            if (!list) {
                list = [];
            }

            const labels = [];
            const selectedGeneration = [];
            const previousGeneration = [];
            const generationDiff = [];

            list.forEach(function(row) {
                labels.push(row.label);
                selectedGeneration.push(Number(row.selectedGeneration || 0));
                previousGeneration.push(Number(row.previousGeneration || 0));
                generationDiff.push(Number(row.generationDiff || 0));
            });

            deviceGenerationChart.data.labels = labels;
            deviceGenerationChart.data.datasets[0].data = selectedGeneration;
            deviceGenerationChart.data.datasets[1].data = previousGeneration;
            deviceGenerationChart.data.datasets[2].data = generationDiff;
            deviceGenerationChart.update();
        },
        error: function() {
            console.log('장비별 차트 데이터 조회 실패');
        }
    });
}

function loadDashboardCharts() {
    loadHourlyChart();
    loadDeviceChart();
}

$(document).ready(function() {
    initGenerationCompareChart();
    initSocCompareChart();
    initDeviceGenerationChart();

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

    $('.chart-tab').on('click', function() {
        $('.chart-tab').removeClass('active');
        $(this).addClass('active');
    });
});