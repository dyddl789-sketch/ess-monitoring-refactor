// ===============================
// 메인 공통 정보
// ===============================
const ctx = document.body.dataset.contextPath || "";
const isLogin = document.body.dataset.login === "true";
const memberName = document.body.dataset.memberName || "";
const userType = document.body.dataset.userType || "";


// ===============================
// 기본 이동
// ===============================
function goLogin() {
    location.href = ctx + "/login_view";
}

function goJoin() {
    location.href = ctx + "/join_view";
}


// ===============================
// 로그인 체크
// ===============================
function checkLogin(callback) {
    if (!isLogin) {
        alert("로그인이 필요합니다.");
        location.href = ctx + "/login_view";
        return;
    }

    callback();
}


// ===============================
// 콘텐츠 영역 이동
// ===============================
function scrollContent() {
    const contentArea = $("#contentArea")[0];

    if (contentArea) {
        contentArea.scrollIntoView({ behavior: "smooth" });
    }
}


// ===============================
// 임시 콘텐츠 출력
// ===============================
function renderTemp(title, html) {
    $("#contentArea").html(
        "<div class='panel-title'><h3>" + title + "</h3></div>" + html
    );

    scrollContent();
}


// ===============================
// Ajax 화면 로드
// ===============================
function ajaxLoad(url, fallbackTitle, fallbackHtml) {
    $.ajax({
        url: ctx + url,
        type: "get",
        success: function(data) {
            $("#contentArea").html(data);
            scrollContent();
        },
        error: function() {
            renderTemp(fallbackTitle, fallbackHtml);
        }
    });
}


// ===============================
// 장비 등록 폼 로드
// ===============================
function loadRegister() {
    ajaxLoad(
        "/device/registerForm",
        "ESS 장비 등록",
        "<p>장비 등록 화면을 불러오는 중 오류가 발생했습니다.</p>"
    );
}


// ===============================
// 장비 목록 조회
// ===============================
function loadDeviceList() {
    $.ajax({
        url: ctx + "/device/listAjax",
        type: "get",
        dataType: "json",
        success: function(list) {
            let html = "";

            html += "<section class='device-main'>";
            html += "<div class='section-title'>";
            html += "<h2>나의 ESS 장비</h2>";
            html += "<p>등록된 ESS 장비의 상태를 확인합니다.</p>";
            html += "</div>";

            html += "<div class='device-card-grid'>";

            if (list == null || list.length === 0) {
                html += "<p>등록된 장비가 없습니다.</p>";
            } else {
                for (let i = 0; i < list.length; i++) {
                    const device = list[i];

                    const statusInfo = getDeviceStatusInfo(device.status);

                    html += "<div class='device-card' onclick='goMonitoring(" + device.deviceId + ")'>";

                    html += "<div class='device-card-header'>";
                    html += "<h3>" + escapeHtml(device.deviceName) + "</h3>";
                    html += "<span class='status-badge " + statusInfo.className + "'>" + statusInfo.text + "</span>";
                    html += "</div>";

                    html += "<p class='device-location'>" + escapeHtml(device.location || "-") + "</p>";

                    html += "<div class='device-info-grid'>";
                    html += "<div><span>설비 용량</span><strong>" + formatNumber(device.capacityKw) + " kW</strong></div>";
                    html += "<div><span>ESS 용량</span><strong>" + formatNumber(device.essCapacityKwh) + " kWh</strong></div>";
                    html += "<div><span>시스템</span><strong>" + escapeHtml(device.deviceType || "-") + "</strong></div>";
                    html += "<div><span>대표</span><strong>" + (device.isMain === "Y" ? "Y" : "N") + "</strong></div>";
                    html += "</div>";

                    html += "<p class='device-message'>클릭하면 실시간 모니터링으로 이동합니다.</p>";
                    html += "</div>";
                }
            }

            html += "</div>";
            html += "</section>";

            renderTemp("장비 목록", html);
        },
        error: function() {
            renderTemp("장비 목록", "<p>장비 목록을 불러오는 중 오류가 발생했습니다.</p>");
        }
    });
}


// ===============================
// 상태 표시 변환
// ===============================
function getDeviceStatusInfo(status) {
    if (status === "NORMAL") {
        return { text: "정상", className: "normal" };
    }

    if (status === "WARNING") {
        return { text: "경고", className: "warning" };
    }

    if (status === "ERROR") {
        return { text: "오류", className: "danger" };
    }

    if (status === "OFFLINE") {
        return { text: "오프라인", className: "offline" };
    }

    return { text: "-", className: "offline" };
}


// ===============================
// 실시간 모니터링 이동
// ===============================
function goMonitoring(deviceId) {
    location.href = ctx + "/monitoring/main?deviceId=" + deviceId;
}


// ===============================
// 장비 삭제
// ===============================
function deleteDevice(deviceId) {
    if (!confirm("해당 장비를 삭제하시겠습니까?")) {
        return;
    }

    $.ajax({
        url: ctx + "/device/delete",
        type: "post",
        data: {
            deviceId: deviceId
        },
        success: function(result) {
            if (result === "success") {
                alert("장비가 삭제되었습니다.");
                updateDeviceCount(-1);
                loadDeviceList();

            } else if (result === "login_required") {
                alert("로그인이 필요합니다.");
                location.href = ctx + "/login_view";

            } else {
                alert("삭제에 실패했습니다.");
            }
        },
        error: function() {
            alert("삭제 중 서버 오류가 발생했습니다.");
        }
    });
}


// ===============================
// 장비 수 갱신
// ===============================
function updateDeviceCount(amount) {
    if ($("#deviceCount").length === 0) {
        return;
    }

    let countText = $("#deviceCount").text();
    let count = parseInt(countText.replace("대", "").trim(), 10);

    if (isNaN(count)) {
        count = 0;
    }

    count += amount;

    if (count < 0) {
        count = 0;
    }

    $("#deviceCount").text(count + "대");
}


// ===============================
// 다른 메뉴 이동
// ===============================
function loadMonitor() {
    location.href = ctx + "/monitoring/main";
}

function loadAlert() {
    location.href = ctx + "/alert/list";
}

function loadEnergy() {
    location.href = ctx + "/analysis/energy";
}

function loadBoard() {
    location.href = ctx + "/board_list";
}

function loadMyPage() {
    location.href = ctx + "/member/info";
}

function loadGuide() {
    renderTemp(
        "이용 가이드",
        "<ol>" +
        "<li>회원가입 후 로그인합니다.</li>" +
        "<li>장비 등록 메뉴에서 ESS 장비를 등록합니다.</li>" +
        "<li>모니터링 메뉴에서 실시간 데이터를 확인합니다.</li>" +
        "<li>알림 메뉴에서 이상 상태를 확인합니다.</li>" +
        "</ol>"
    );
}

function showServiceIntro() {
    renderTemp(
        "서비스 소개",
        "<p>ESS-M.S는 ESS 장비 등록, 실시간 모니터링, 이상 알림, 에너지 분석을 제공하는 통합 관리 시스템입니다.</p>"
    );
}


// ===============================
// 주소 기반 View 처리
// ===============================
function moveView(viewName, loader) {
    history.pushState({ view: viewName }, "", ctx + "/main?view=" + viewName);
    loader();
}

function loadViewByName(viewName) {
    if (viewName === "register") {
        loadRegister();
    } else if (viewName === "deviceList") {
        loadDeviceList();
    } else if (viewName === "monitor") {
        loadMonitor();
    } else if (viewName === "alert") {
        loadAlert();
    } else if (viewName === "energy") {
        loadEnergy();
    } else if (viewName === "myPage") {
        loadMyPage();
    } else {
        location.href = ctx + "/main";
    }
}


// ===============================
// 유틸
// ===============================
function formatNumber(value) {
    if (value == null || value === "") {
        return "-";
    }

    return Number(value).toLocaleString();
}

function escapeHtml(value) {
    if (value == null) {
        return "-";
    }

    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}


// ===============================
// 브라우저 뒤로가기 처리
// ===============================
window.addEventListener("popstate", function() {
    const params = new URLSearchParams(location.search);
    const view = params.get("view");

    if (view) {
        loadViewByName(view);
    } else {
        location.href = ctx + "/main";
    }
});


// ===============================
// 초기 로딩
// ===============================
$(function() {
    const params = new URLSearchParams(location.search);
    const view = params.get("view");

    if (view) {
        loadViewByName(view);
    }
});


// ===============================
// 버튼 이벤트
// ===============================
$(document).on("click", "#btnRegister", function() {
    checkLogin(function() {
        moveView("register", loadRegister);
    });
});

$(document).on("click", "#btnDeviceList", function() {
    checkLogin(function() {
        moveView("deviceList", loadDeviceList);
    });
});

$(document).on("click", "#btnMonitor", function() {
    checkLogin(function() {
        moveView("monitor", loadMonitor);
    });
});

$(document).on("click", "#btnAlert", function() {
    checkLogin(function() {
        moveView("alert", loadAlert);
    });
});

$(document).on("click", "#btnEnergy", function() {
    checkLogin(function() {
        moveView("energy", loadEnergy);
    });
});

$(document).on("click", "#btnBoard", function() {
    loadBoard();
});

$(document).on("click", "#btnMyPage", function() {
    checkLogin(function() {
        moveView("myPage", loadMyPage);
    });
});

$(document).on("click", "#btnGuide", function() {
    loadGuide();
});