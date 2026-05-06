/*
 * =========================
 * 실시간 모니터링 JS
 * monitoring_main.js
 * =========================
 */

/*
 * 출력 그래프 객체
 */
let powerChart;

/*
 * SOC 그래프 객체
 */
let socChart;

/*
 * 자동 갱신 타이머
 */
let autoRefreshTimer = null;

/*
 * 출력 그래프 데이터
 */
const powerLabels = [];
const powerData = [];

/*
 * SOC 그래프 데이터
 */
const socLabels = [];
const socData = [];

/*
 * 숫자 포맷 함수
 * null/undefined 방지
 */
function formatNumber(value, digit) {

    if (value === null ||
        value === undefined ||
        value === '') {

        return '-';
    }

    const num = Number(value);

    if (isNaN(num)) {
        return '-';
    }

    return num.toFixed(digit);
}

/*
 * recordTime → HH:mm 변환
 * 예:
 * 2026-05-06 14:30:00
 * → 14:30
 */
function formatTimeLabel(recordTime) {

    if (!recordTime) {
        return '-';
    }

    const str = String(recordTime);

    if (str.length >= 16) {
        return str.substring(11, 16);
    }

    return str;
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

    /*
     * 강수 타입 우선 처리
     */
    if (rainType && rainType !== '없음') {

        if (rainType === '눈') {
            return '❄️';
        }

        if (rainType === '비/눈') {
            return '🌨️';
        }

        return '🌧️';
    }

    /*
     * 하늘 상태 처리
     */
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

    /*
     * 출력 그래프 canvas
     */
    const powerCtx =
        document.getElementById('powerChart')
            .getContext('2d');

    /*
     * SOC 그래프 canvas
     */
    const socCtx =
        document.getElementById('socChart')
            .getContext('2d');

    /*
     * 출력 그래프 생성
     */
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
            maintainAspectRatio: false
        }
    });

    /*
     * SOC 그래프 생성
     */
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
            maintainAspectRatio: false
        }
    });
}

/*
 * 최근 모니터링 이력 조회
 * 그래프 초기 데이터 생성용
 */
function loadMonitoringHistory() {

    /*
     * 선택 장비 ID
     */
    const deviceId =
        $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({

        /*
         * 최근 이력 조회 API
         */
        url: contextPath + '/monitoring/history',

        type: 'GET',

        data: {
            deviceId: deviceId
        },

        dataType: 'json',

        success: function(list) {

            /*
             * 기존 그래프 데이터 초기화
             */
            powerLabels.length = 0;
            powerData.length = 0;

            socLabels.length = 0;
            socData.length = 0;

            /*
             * 데이터 없으면 종료
             */
            if (!list || list.length === 0) {

                powerChart.update();
                socChart.update();

                return;
            }

            /*
             * 최신순 → 시간순 변경
             */
            list.reverse();

            /*
             * 그래프 데이터 추가
             */
            list.forEach(function(item) {

                const label =
                    formatTimeLabel(item.recordTime);

                /*
                 * 출력 그래프 데이터
                 */
                powerLabels.push(label);

                powerData.push(
                    Number(item.powerOutput || 0)
                );

                /*
                 * SOC 그래프 데이터
                 */
                socLabels.push(label);

                socData.push(
                    Number(item.soc || 0)
                );
            });

            /*
             * 그래프 갱신
             */
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

    /*
     * 상단 카드 데이터
     */
    $('#soc')
        .text(formatNumber(data.soc, 1) + '%');

    $('#powerOutput')
        .text(formatNumber(data.powerOutput, 1) + ' kW');

    $('#todayGeneration')
        .text(
            formatNumber(
                data.solarGenerationKwh,
                1
            ) + ' kWh'
        );

    /*
     * 상세 정보
     */
    $('#voltage')
        .text(formatNumber(data.voltage, 1) + ' V');

    $('#currentA')
        .text(formatNumber(data.currentA, 1) + ' A');

    $('#powerOutputDetail')
        .text(
            formatNumber(
                data.powerOutput,
                1
            ) + ' kW'
        );

    $('#recordTime')
        .text(data.recordTime || '-');

    /*
     * 최신 데이터 그래프 추가
     */
    addLatestChartData(data);
}

/*
 * 최신 데이터 그래프 추가
 */
function addLatestChartData(data) {

    if (!data) {
        return;
    }

    const label =
        formatTimeLabel(data.recordTime);

    /*
     * 같은 시간 데이터 중복 방지
     */
    if (
        powerLabels.length > 0 &&
        powerLabels[powerLabels.length - 1] === label
    ) {

        powerData[powerData.length - 1] =
            Number(data.powerOutput || 0);

        socData[socData.length - 1] =
            Number(data.soc || 0);

    } else {

        /*
         * 새 데이터 추가
         */
        powerLabels.push(label);

        powerData.push(
            Number(data.powerOutput || 0)
        );

        socLabels.push(label);

        socData.push(
            Number(data.soc || 0)
        );
    }

    /*
     * 최근 20개 유지
     */
    while (powerLabels.length > 20) {

        powerLabels.shift();
        powerData.shift();
    }

    while (socLabels.length > 20) {

        socLabels.shift();
        socData.shift();
    }

    /*
     * 그래프 갱신
     */
    powerChart.update();
    socChart.update();
}

/*
 * 최신 모니터링 데이터 조회
 */
function loadLatestMonitoring() {

    const deviceId =
        $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({

        /*
         * 최신 데이터 API
         */
        url: contextPath + '/monitoring/latest',

        type: 'GET',

        data: {
            deviceId: deviceId
        },

        dataType: 'json',

        success: function(data) {

            /*
             * 화면 데이터 반영
             */
            updateMonitoring(data);

            /*
             * 마지막 갱신 시간 표시
             */
            $('#lastUpdateTime')
                .text(formatNow());
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

    const deviceId =
        $('#deviceSelect').val();

    if (!deviceId) {
        return;
    }

    $.ajax({

        /*
         * 현재 날씨 API
         */
        url:
            contextPath +
            '/monitoring/weather/current',

        type: 'GET',

        data: {
            deviceId: deviceId
        },

        dataType: 'json',

        success: function(data) {

            if (!data) {
                return;
            }

            /*
             * 날씨 아이콘
             */
            $('#weatherIcon')
                .text(
                    getWeatherIcon(
                        data.skyStatus,
                        data.rainType
                    )
                );

            /*
             * 현재 온도
             */
            $('#temperature')
                .text(
                    formatNumber(
                        data.temperature,
                        1
                    ) + '℃'
                );

            /*
             * 하늘 상태
             */
            $('#skyStatus')
                .text(data.skyStatus || '-');

            /*
             * 강수 확률
             */
            $('#rainProb')
                .text(
                    (data.rainProb || '-') + '%'
                );

            /*
             * 습도
             */
            $('#humidity')
                .text(
                    (data.humidity || '-') + '%'
                );

            /*
             * 풍속
             */
            $('#windSpeed')
                .text(
                    formatNumber(
                        data.windSpeed,
                        1
                    ) + ' m/s'
                );

            /*
             * 일사량
             */
            $('#solarRadiation')
                .text(
                    formatNumber(
                        data.solarRadiation,
                        1
                    )
                );

            /*
             * 일출 / 일몰
             */
            $('#sunTime')
                .text(
                    (data.sunrise || '-') +
                    ' / ' +
                    (data.sunset || '-')
                );

            /*
             * ESS 상태
             */
            $('#essStatus')
                .text(data.essStatus || '-');

            /*
             * 운영 판단 업데이트
             */
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

    let operationCondition =
        weather &&
        weather.essStatus
            ? weather.essStatus
            : '-';

    let batteryCondition = '-';

    let recommendAction = '-';

    /*
     * 현재 SOC 값 읽기
     */
    const socText =
        $('#soc')
            .text()
            .replace('%', '');

    const soc = Number(socText);

    /*
     * 배터리 상태 계산
     */
    if (!isNaN(soc)) {

        if (soc >= 80) {

            batteryCondition =
                '충전 상태 양호';

        } else if (soc >= 40) {

            batteryCondition =
                '보통';

        } else {

            batteryCondition =
                '충전 필요';
        }
    }

    /*
     * 추천 조치 계산
     */
    if (operationCondition === '발전 조건 양호') {

        recommendAction =
            '현재 조치 필요 없음';

    } else if (
        operationCondition ===
        '야간 발전 없음'
    ) {

        recommendAction =
            'ESS 방전/대기 모드 권장';

    } else if (
        operationCondition ===
        '발전량 저하 예상'
    ) {

        recommendAction =
            '배터리 잔량 확인 권장';

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
 * 전체 실시간 데이터 조회
 */
function loadRealtimeData() {

    loadLatestMonitoring();

    loadWeather();
}

/*
 * 자동 갱신 시작
 * 10초 주기
 */
function startAutoRefresh() {

    stopAutoRefresh();

    autoRefreshTimer =
        setInterval(
            loadRealtimeData,
            10000
        );

    $('#autoRefreshBtn')
        .text('자동갱신 OFF');
}

/*
 * 자동 갱신 중지
 */
function stopAutoRefresh() {

    if (autoRefreshTimer != null) {

        clearInterval(autoRefreshTimer);

        autoRefreshTimer = null;
    }

    $('#autoRefreshBtn')
        .text('자동갱신 ON');
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

    /*
     * 차트 생성
     */
    initCharts();

    /*
     * 첫 번째 장비 자동 선택
     */
	if (selectedDeviceId) {
	    $('#deviceSelect').val(selectedDeviceId);
	} else if ($('#deviceSelect option').length > 1) {
	    $('#deviceSelect option:eq(1)').prop('selected', true);
	}

    /*
     * 최근 이력 그래프 로딩
     */
    loadMonitoringHistory();

    /*
     * 최신 데이터 조회
     */
    loadRealtimeData();

    /*
     * 자동 갱신 시작
     */
    startAutoRefresh();

    /*
     * 수동 새로고침
     */
    $('#refreshBtn').on(
        'click',
        function() {

            loadRealtimeData();
        }
    );

    /*
     * 장비 변경 시
     */
    $('#deviceSelect').on(
        'change',
        function() {

            loadMonitoringHistory();

            loadRealtimeData();
        }
    );

    /*
     * 자동 갱신 버튼
     */
    $('#autoRefreshBtn').on(
        'click',
        toggleAutoRefresh
    );

    /*
     * 사이드바 토글
     */
    const sidebar =
        document.getElementById('sidebar');

    const main =
        document.querySelector('.main');

    const toggleBtn =
        document.getElementById(
            'sidebarToggle'
        );

    if (
        sidebar &&
        main &&
        toggleBtn
    ) {

        toggleBtn.addEventListener(
            'click',
            function() {

                sidebar.classList.toggle(
                    'collapsed'
                );

                main.classList.toggle(
                    'collapsed'
                );
            }
        );
    }
});