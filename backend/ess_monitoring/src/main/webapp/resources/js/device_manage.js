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

    let filteredList = list.filter(function (device) {
        let matchKeyword = true;
        let matchStatus = true;

        if (keyword) {
            const target =
                (device.deviceName || '') + ' ' +
                (device.location || '') + ' ' +
                (device.groupName || '');

            matchKeyword = target.indexOf(keyword) > -1;
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

        const row =
            '<tr>' +
                '<td>' + escapeHtml(device.deviceName) + '</td>' +
                '<td>' + escapeHtml(device.groupName || '-') + '</td>' +
                '<td>' + escapeHtml(device.location || '-') + '</td>' +
                '<td>' + formatNumber(device.capacityKw) + '</td>' +
                '<td>' + formatNumber(device.essCapacityKwh) + '</td>' +
                '<td><span class="' + statusInfo.className + '">' + statusInfo.text + '</span></td>' +
                '<td>' + (device.isMain === 'Y' ? '대표' : '-') + '</td>' +
                '<td>' + escapeHtml(device.installDate || '-') + '</td>' +
                '<td>' +
                    '<a class="btn-link" href="' + contextPath + '/monitoring/main?deviceId=' + device.deviceId + '">실시간 보기</a> ' +
                    '<button type="button" class="btn-danger-small" onclick="deleteDevice(' + device.deviceId + ')">삭제</button>' +
                '</td>' +
            '</tr>';

        $tbody.append(row);
    });
}

function deleteDevice(deviceId) {
    if (!confirm('해당 장비를 삭제하시겠습니까? 관련 모니터링 데이터도 함께 삭제됩니다.')) {
        return;
    }

    $.ajax({
        url: contextPath + '/device/delete',
        type: 'POST',
        data: {
            deviceId: deviceId
        },

        success: function (result) {
            if (result === 'success') {
                alert('삭제되었습니다.');
                loadDeviceManageList();
            } else if (result === 'login_required') {
                alert('로그인이 필요합니다.');
                location.href = contextPath + '/login_view';
            } else {
                alert('삭제에 실패했습니다.');
            }
        },

        error: function () {
            alert('삭제 중 오류가 발생했습니다.');
        }
    });
}

function getDeviceStatusInfo(status) {
    if (status === 'NORMAL') {
        return { text: '정상', className: 'status-normal' };
    }

    if (status === 'WARNING') {
        return { text: '경고', className: 'status-warning' };
    }

    if (status === 'ERROR') {
        return { text: '오류', className: 'status-danger' };
    }

    if (status === 'OFFLINE') {
        return { text: '오프라인', className: 'status-offline' };
    }

    return { text: '-', className: 'status-nodata' };
}

function formatNumber(value) {
    if (value == null || value === '') {
        return '-';
    }

    return Number(value).toLocaleString();
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