function loadDeviceManageList() {
    $.ajax({
        url: contextPath + '/device/listAjax',
        type: 'GET',
        dataType: 'json',

        success: function (list) {
            renderDeviceManageTable(list);
        },

        error: function () {
            alert('장비 목록을 불러오지 못했습니다.');
        }
    });
}

function renderDeviceManageTable(list) {
    const $tbody = $('#deviceManageTableBody');
    const keyword = $('#keyword').val();
    const statusFilter = $('#statusFilter').val();

    $tbody.empty();

    if (!list || list.length === 0) {
        $tbody.append('<tr><td colspan="9">등록된 장비가 없습니다.</td></tr>');
        return;
    }

    const filteredList = list.filter(function (device) {
        let matchKeyword = true;
        let matchStatus = true;

        if (keyword) {
            const target =
                (device.deviceName || '') + ' ' +
                (device.location || '') + ' ' +
                (device.groupName || '');

            matchKeyword =
                target.toLowerCase().indexOf(keyword.toLowerCase()) > -1;
        }

        if (statusFilter) {
            matchStatus = device.status === statusFilter;
        }

        return matchKeyword && matchStatus;
    });

    if (filteredList.length === 0) {
        $tbody.append('<tr><td colspan="9">조회된 장비가 없습니다.</td></tr>');
        return;
    }

    filteredList.forEach(function (device) {
        const statusInfo = getDeviceStatusInfo(device.status);

	const mainBadge =
	    device.isMain === 'Y'
	
	        ? '<span class="main-device-badge">대표 ESS</span>'
	
	        : '<button type="button" ' +
	              'class="btn-main-set" ' +
	              'onclick="setMainDevice(' + device.deviceId + ')">' +
	                '대표 설정' +
	          '</button>';

        const row =
            '<tr>' +

				'<td>' +
				
				    '<a class="device-name-link" ' +
				       'href="' + contextPath +
				       '/monitoring/main?deviceId=' + device.deviceId + '">' +
				
				        escapeHtml(device.deviceName) +
				
				    '</a>' +
				
				    (
				        device.isMain === 'Y'
				        ? '<span class="main-device-badge">대표 ESS</span>'
				        : ''
				    ) +
				
				'</td>' +

                '<td>' +
				    '<span class="group-badge">' +
				        escapeHtml(device.groupName || '미지정 그룹') +
				    '</span>' +
				'</td>' +

                '<td>' + escapeHtml(device.location || '-') + '</td>' +

                '<td>' + formatNumber(device.capacityKw) + ' kW</td>' +

                '<td>' + formatNumber(device.essCapacityKwh) + ' kWh</td>' +

                '<td>' +
                    '<span class="' + statusInfo.className + '">' +
                        statusInfo.text +
                    '</span>' +
                '</td>' +

                '<td>' + mainBadge + '</td>' +

                '<td>' + formatDate(device.installDate) + '</td>' +

                '<td>' +
                    '<div class="device-action-group">' +

                        '<a class="table-btn-primary" ' +
                           'href="' + contextPath + '/monitoring/main?deviceId=' + device.deviceId + '">' +
                            '실시간' +
                        '</a>' +

                        '<button type="button" ' +
                                'class="table-btn-danger" ' +
                                'onclick="deleteDevice(' + device.deviceId + ')">' +
                            '삭제' +
                        '</button>' +

                    '</div>' +
                '</td>' +

            '</tr>';

        $tbody.append(row);
    });
}

function deleteDevice(deviceId) {

    if (!confirm('이 장비를 운영 종료 처리하시겠습니까?\n기존 모니터링/통계 기록은 보존되며, 장비 목록에서는 숨겨집니다.')) {
        return;
    }

    $.ajax({
        url: contextPath + '/device/delete',
        type: 'POST',
        data: {
            deviceId: deviceId
        },

        success: function(result) {

            if (result === 'success') {
                alert('장비가 운영 종료 처리되었습니다.');

                if (typeof loadDeviceList === 'function') {
                    loadDeviceList();
                }

                return;
            }

            if (result === 'login_required') {
                alert('로그인이 필요합니다.');
                location.href = contextPath + '/login_view';
                return;
            }

            alert('장비 운영 종료 처리에 실패했습니다.');
        },

        error: function() {
            alert('장비 운영 종료 처리 중 오류가 발생했습니다.');
        }
    });
}

function getDeviceStatusInfo(status) {
    if (status === 'NORMAL') {
        return {
            text: '정상',
            className: 'status-normal'
        };
    }

    if (status === 'WARNING') {
        return {
            text: '경고',
            className: 'status-warning'
        };
    }

    if (status === 'ERROR') {
        return {
            text: '오류',
            className: 'status-danger'
        };
    }

    if (status === 'OFFLINE') {
        return {
            text: '오프라인',
            className: 'status-offline'
        };
    }

    return {
        text: '데이터 없음',
        className: 'status-nodata'
    };
}

function formatNumber(value) {
    if (value == null || value === '') {
        return '-';
    }

    const num = Number(value);

    if (isNaN(num)) {
        return '-';
    }

    return num.toLocaleString();
}

function formatDate(value) {
    if (!value) {
        return '-';
    }

    return String(value).substring(0, 10);
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
function setMainDevice(deviceId) {

    if (!confirm('이 장비를 대표 ESS로 설정하시겠습니까?')) {
        return;
    }

    $.ajax({

        url: contextPath + '/device/main/set',

        type: 'POST',

        data: {
            deviceId: deviceId
        },

        success: function(result) {

            if (result === 'success') {

                alert('대표 ESS가 변경되었습니다.');

                loadDeviceManageList();

                return;
            }

            if (result === 'login_required') {

                alert('로그인이 필요합니다.');

                location.href =
                    contextPath + '/login_view';

                return;
            }

            alert('대표 ESS 설정에 실패했습니다.');
        },

        error: function() {
            alert('대표 ESS 설정 중 오류가 발생했습니다.');
        }
    });
}
$(document).ready(function () {
    loadDeviceManageList();

    $('#searchBtn').on('click', function () {
        loadDeviceManageList();
    });

    $('#keyword').on('keyup', function (e) {
        if (e.keyCode === 13) {
            loadDeviceManageList();
        }
    });

    $('#statusFilter').on('change', function () {
        loadDeviceManageList();
    });

    const sidebar = document.getElementById('sidebar');
    const main = document.querySelector('.main');
    const toggleBtn = document.getElementById('sidebarToggle');

    if (sidebar && main && toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            sidebar.classList.toggle('collapsed');
            main.classList.toggle('collapsed');
        });
    }
});