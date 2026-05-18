let powerChart;
let socChart;
let generationChart;
let weeklyGenerationChart;
let weeklyCostChart;

function createGradient(ctx, color) {
    const gradient = ctx.createLinearGradient(0, 0, 0, 280);

    if (color === 'blue') {
        gradient.addColorStop(0, 'rgba(37, 99, 235, 0.35)');
        gradient.addColorStop(1, 'rgba(37, 99, 235, 0.02)');
    }

    if (color === 'green') {
        gradient.addColorStop(0, 'rgba(22, 163, 74, 0.35)');
        gradient.addColorStop(1, 'rgba(22, 163, 74, 0.02)');
    }

    if (color === 'purple') {
        gradient.addColorStop(0, 'rgba(124, 58, 237, 0.35)');
        gradient.addColorStop(1, 'rgba(124, 58, 237, 0.02)');
    }

    return gradient;
}

function commonLineOptions() {
    return {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
            duration: 350
        },
        interaction: {
            intersect: false,
            mode: 'index'
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

function commonBarOptions() {
    return {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
            duration: 350
        },
        plugins: {
            legend: {
                display: false
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

function initPowerChart() {
    const canvas = document.getElementById('powerChart');

    if (!canvas) {
        return;
    }

    const ctx = canvas.getContext('2d');

    powerChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: '출력(kW)',
                data: [],
                borderColor: '#2563eb',
                backgroundColor: createGradient(ctx, 'blue'),
                fill: true,
                tension: 0.35,
                borderWidth: 2.5,
                pointRadius: 2,
                pointHoverRadius: 5
            }]
        },
        options: commonLineOptions()
    });
}

function initSocChart() {
    const canvas = document.getElementById('socChart');

    if (!canvas) {
        return;
    }

    const ctx = canvas.getContext('2d');

    socChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'SOC(%)',
                data: [],
                borderColor: '#16a34a',
                backgroundColor: createGradient(ctx, 'green'),
                fill: true,
                tension: 0.35,
                borderWidth: 2.5,
                pointRadius: 2,
                pointHoverRadius: 5
            }]
        },
        options: commonLineOptions()
    });
}

function initGenerationChart() {
    const canvas = document.getElementById('generationChart');

    if (!canvas) {
        return;
    }

    const ctx = canvas.getContext('2d');

    generationChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: '누적 발전량(kWh)',
                data: [],
                borderColor: '#7c3aed',
                backgroundColor: createGradient(ctx, 'purple'),
                fill: true,
                tension: 0.35,
                borderWidth: 2.5,
                pointRadius: 2,
                pointHoverRadius: 5
            }]
        },
        options: commonLineOptions()
    });
}

function initWeeklyGenerationChart() {
    const canvas = document.getElementById('weeklyGenerationChart');

    if (!canvas) {
        return;
    }

    const ctx = canvas.getContext('2d');

    weeklyGenerationChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [],
            datasets: [{
                label: '발전량(kWh)',
                data: [],
                backgroundColor: 'rgba(124, 58, 237, 0.65)',
                borderRadius: 6,
                barThickness: 34
            }]
        },
        options: commonBarOptions()
    });
}

function initWeeklyCostChart() {
    const canvas = document.getElementById('weeklyCostChart');

    if (!canvas) {
        return;
    }

    const ctx = canvas.getContext('2d');

    weeklyCostChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [],
            datasets: [{
                label: '절감 금액(원)',
                data: [],
                backgroundColor: 'rgba(22, 163, 74, 0.65)',
                borderRadius: 6,
                barThickness: 34
            }]
        },
        options: commonBarOptions()
    });
}

function initMonitoringCharts() {
    initPowerChart();
    initSocChart();
    initGenerationChart();
    initWeeklyGenerationChart();
    initWeeklyCostChart();
}

function updateLineChart(chart, labels, values) {

    if (!chart) {
        return;
    }

    chart.data.labels = labels || [];
    chart.data.datasets[0].data = values || [];
    chart.update();
}

function updatePowerChart(labels, values) {
    updateLineChart(powerChart, labels, values);
}

function updateSocChart(labels, values) {
    updateLineChart(socChart, labels, values);
}

function updateGenerationChart(labels, values) {
    updateLineChart(generationChart, labels, values);
}

function updateWeeklyGenerationChart(labels, values) {
    updateLineChart(weeklyGenerationChart, labels, values);
}

function updateWeeklyCostChart(labels, values) {
    updateLineChart(weeklyCostChart, labels, values);
}

// 이력/실시간 제목 변경
function updateMonitoringModeTitle() {

    if (isHistoryMode()) {

        $('.power-chart-title')
            .text('선택일 운영 이력');

        $('.soc-chart-title')
            .text('일별 통계 기준');

        return;
    }

    $('.power-chart-title')
        .text('실시간 출력 그래프');

    $('.soc-chart-title')
        .text('SOC 변화 그래프');
}