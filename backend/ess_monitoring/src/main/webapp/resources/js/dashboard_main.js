/**
 * 현재 필터 상태(날짜, 그룹, 장비)를 서버에 전달할 파라미터 생성
 */
function getSummaryParams() {
    let selectedDate = $('#selectedDate').val();

    // 날짜 없으면 오늘
    if (!selectedDate) {
        selectedDate = new Date().toISOString().split('T')[0];
        $('#selectedDate').val(selectedDate);
    }

    const params = {
        selectedDate: selectedDate
    };

    const groupId = $('#groupSelect').val();
    const deviceId = $('#deviceSelect').val();

    // 값 있을 때만 전달
    if (groupId) params.groupId = groupId;
    if (deviceId) params.deviceId = deviceId;

    return params;
}


/**
 * 상단 카드 데이터 조회
 */
function loadSummary() {
    $.ajax({
        url: contextPath + '/dashboard/summary',
        type: 'GET',
        data: getSummaryParams(),
        dataType: 'json',

        success: function (data) {

            if (!data) {
                $('#collectedDeviceCount').text('-');
                $('#collectionSubInfo').text('-');
                return;
            }

            const total = data.totalDeviceCount || 0;
            const collected = data.collectedDeviceCount || 0;
            const uncollected = data.uncollectedDeviceCount || 0;
            const offline = data.offlineDeviceCount || 0;

            const generation = Number(data.todayGenerationKwh || 0);
            const averageSoc = Number(data.averageSoc || 0);
            const savedCost = Number(data.todaySavedCost || 0);

            $('#collectedDeviceCount').text(collected + ' / ' + total + '대');

            let collectionText = '미수집 ' + uncollected + '대 · 오프라인 ' + offline + '대';

            if (collected > 0 && generation === 0) {
                collectionText += ' · 발전량 없음';
            }

            $('#collectionSubInfo').text(collectionText);

            $('#todayGenerationKwh').text(generation.toFixed(1) + ' kWh');

            if (collected > 0 && generation === 0) {
                $('#generationSubInfo').text('발전 없음 (오프라인 또는 야간)');
            } else {
                $('#generationSubInfo').text('선택일 수집 데이터 기준');
            }

            $('#averageSoc').text(averageSoc.toFixed(1) + '%');

            if (collected > 0 && averageSoc === 0) {
                $('#socSubInfo').text('SOC 0% 장비 포함');
            } else {
                $('#socSubInfo').text('선택일 수집 데이터 기준');
            }

            $('#todaySavedCost').text(savedCost.toLocaleString() + '원');

            if (collected > 0 && savedCost === 0) {
                $('#savedCostSubInfo').text('발전량 0으로 절감 금액 없음');
            } else {
                $('#savedCostSubInfo').text('선택일 수집 데이터 기준');
            }
        },

        error: function () {
            alert('대시보드 요약 정보를 불러오지 못했습니다.');
        }
    });
}


/**
 * 그룹 선택 시 셀릭트박스 장비 목록 갱신
 */
function loadDeviceList(callback) {

    const params = getSummaryParams();
    delete params.deviceId; // 장비 셀렉트 목록은 특정 장비 필터 제외

    $.ajax({
        url: contextPath + '/dashboard/devices',
        type: 'GET',
        data: params,

        success: function (devices) {
            const $deviceSelect = $('#deviceSelect');

            $deviceSelect.empty();
            $deviceSelect.append('<option value="">전체 장비</option>');

            devices.forEach(function (device) {
                $deviceSelect.append(
                    '<option value="' + device.deviceId + '">' +
                    device.deviceName +
                    '</option>'
                );
            });

            if (callback) callback();
        }
    });
}

// 대쉬보드 장비 리스트 조회정보 불러오기
function loadDeviceTable() {
    $.ajax({
        url: contextPath + '/dashboard/devices',
        data: getSummaryParams(),

        success: function (devices) {
            const $tbody = $('#deviceTableBody');
            $tbody.empty();

            if (!devices || devices.length === 0) {
                $tbody.append('<tr><td colspan="4">조회된 장비가 없습니다.</td></tr>');
                return;
            }

            devices.forEach(function (device) {

                const groupName = device.groupName ? device.groupName : '-';
                const soc = device.soc == null ? '-' : Number(device.soc).toFixed(1) + '%';

                // 👉 여기 추가
                const statusMap = {
                    NORMAL: '<span class="status-normal" title="SOC 40% 이상">정상</span>',
                    WARNING: '<span class="status-warning" title="SOC 20% 이상 40% 미만">경고</span>',
                    ERROR: '<span class="status-danger" title="SOC 20% 미만">에러</span>',
                    OFFLINE: '<span class="status-offline" title="SOC 0% 상태">오프라인 (SOC 0%)</span>',
                    NO_DATA: '<span class="status-nodata" title="해당 날짜 측정 데이터 없음">데이터 없음</span>'
                };

                const status = statusMap[device.status] || '-';

                $tbody.append(
                    '<tr>' +
					'<td><a href="' + contextPath + '/monitoring/main?deviceId=' + device.deviceId + '">' +
					device.deviceName + '</a></td>' +
                    '<td>' + groupName + '</td>' +
                    '<td>' + soc + '</td>' +
                    '<td>' + status + '</td>' +
                    '<td>' +
           			 	'<a class="btn-link" href="' + contextPath + '/monitoring/main?deviceId=' + device.deviceId + '">' +
               				 '실시간 보기' +
           			 	'</a>' +
      				'</td>' +
                    '</tr>'
                );
            });
        }
    });
}

// 대시보드 전체 갱신
function reloadDashboard() {
    loadSummary();
    loadDeviceTable();
    loadGenerationChart();
}



// HTML 특수문자 방지
function escapeHtml(value) {
    if (value == null) return '-';

    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}


/**
 * 발전량 차트 조회
 * - 날짜 / 그룹 / 장비 필터 모두 반영
 */
function loadGenerationChart() {
    $.ajax({
        url: contextPath + '/dashboard/generationChart',
        type: 'GET',
        data: getSummaryParams(),
        dataType: 'json',

        success: function (data) {
            const $chart = $('#generationChart');
            const $title = $('#generationChartTitle');
            const $note = $('#generationChartNote');

            $chart.empty();

            if (!data || !data.chartList || data.chartList.length === 0) {
                $title.text('선택일 발전량');
                $chart.append('<div class="empty-chart">발전량 데이터가 없습니다.</div>');
                $note.text('선택한 조건에 해당하는 발전량 데이터가 없습니다.');
                return;
            }

            const list = data.chartList;
            const totalItemCount = data.totalItemCount || list.length;
            const limitCount = data.limitCount || list.length;

            $title.text(data.chartTitle || '선택일 발전량');

            if (totalItemCount > limitCount) {
                $note.text('발전량 상위 ' + limitCount + '개만 표시합니다. 전체 ' + totalItemCount + '개');
            } else {
                $note.text('선택한 날짜와 필터 기준으로 발전량을 표시합니다.');
            }

            let max = 0;

            list.forEach(function (item) {
                const value = Number(item.generation || 0);
                if (value > max) max = value;
            });

            if (max === 0) {
                max = 1;
            }

            list.forEach(function (item) {
                const label = escapeHtml(item.label);
                const value = Number(item.generation || 0);

                // 최대 높이 160px 기준 비율 계산
                let height = (value / max) * 160;

                // 값이 0이면 아주 낮게 표시
                if (value === 0) {
                    height = 4;
                }

                // 값이 있는데 너무 낮으면 최소 높이 보장
                if (value > 0 && height < 12) {
                    height = 12;
                }

                $chart.append(
                    '<div class="bar-item">' +
                        '<div class="bar-value">' + value.toFixed(1) + '</div>' +
                        '<div class="bar" style="height:' + height + 'px;"></div>' +
                        '<div class="bar-label" title="' + label + '">' + label + '</div>' +
                    '</div>'
                );
            });
        },

        error: function () {
            $('#generationChart').html(
                '<div class="empty-chart">발전량 차트를 불러오지 못했습니다.</div>'
            );
        }
    });
}

/**
 * 초기 로딩 + 이벤트
 */
$(document).ready(function () {

    // 날짜 초기화
    let date = $('#selectedDate').val();
    if (!date) {
        $('#selectedDate').val(new Date().toISOString().split('T')[0]);
    }

    // 최초 조회
    reloadDashboard();

    // 날짜 변경
    $('#selectedDate').on('change', reloadDashboard);

    // 그룹 변경
    $('#groupSelect').on('change', function () {
        loadDeviceList(function () {
            $('#deviceSelect').val('');
            reloadDashboard();
        });
    });

    // 장비 변경
    $('#deviceSelect').on('change', reloadDashboard);

    // 조회 버튼
    $('#refreshBtn').on('click', reloadDashboard);

});