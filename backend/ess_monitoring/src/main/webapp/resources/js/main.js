const ctx = document.body.dataset.contextPath || "";
const isLogin = document.body.dataset.login === "true";
const memberName = document.body.dataset.memberName || "";
const userType = document.body.dataset.userType || "";

function goLogin() {
    location.href = ctx + "/login_view";
}

function goJoin() {
    location.href = ctx + "/join_view";
}

function checkLogin(callback) {
    if (!isLogin) {
        alert("로그인이 필요합니다.");
        location.href = ctx + "/login_view";
        return;
    }

    callback();
}

function scrollContent() {
    const contentArea = $("#contentArea")[0];

    if (contentArea) {
        contentArea.scrollIntoView({ behavior: "smooth" });
    }
}

function renderTemp(title, html) {
    $("#contentArea").html(
        "<div class='panel-title'><h3>" + title + "</h3></div>" + html
    );

    scrollContent();
}

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

function loadRegister() {
    ajaxLoad(
        "/device/registerForm",
        "🔧 ESS 기기 등록",
        "<p>기기 등록 화면을 불러오는 중 오류가 발생했습니다.</p>"
    );
}

function openDeviceAddressSearch() {
    new daum.Postcode({
        oncomplete: function(data) {
            let address = data.roadAddress || data.jibunAddress;

            $("#location").val(address);

            console.log("@# 선택 주소 =>", address);
            console.log("@# postcode data =>", data);

            searchDeviceAddress();
        }
    }).open({
        popupName: "devicePostcodePopup"
    });
}

function searchDeviceAddress() {
    const address = $("#location").val().trim();

    if (address === "") {
        alert("설치 위치를 입력하세요.");
        $("#location").focus();
        return;
    }

    if (typeof kakao === "undefined" || !kakao.maps || !kakao.maps.services) {
        alert("카카오 지도 API가 로드되지 않았습니다.");
        return;
    }

    const geocoder = new kakao.maps.services.Geocoder();

    geocoder.addressSearch(address, function(result, status) {
        if (status === kakao.maps.services.Status.OK) {
            const latitude = result[0].y;
            const longitude = result[0].x;
            const roadAddress = result[0].road_address
                ? result[0].road_address.address_name
                : "";
            const jibunAddress = result[0].address
                ? result[0].address.address_name
                : address;

            $("#latitude").val(latitude);
            $("#longitude").val(longitude);

            $("#location").val(roadAddress !== "" ? roadAddress : jibunAddress);

            $("#addressResult").html(
                "주소 확인 완료<br>" +
                "위도: " + latitude + "<br>" +
                "경도: " + longitude
            );
        } else {
            $("#latitude").val("");
            $("#longitude").val("");
            $("#addressResult").html(
                "<span style='color:#dc2626;'>주소를 찾을 수 없습니다. 더 정확한 주소를 입력하세요.</span>"
            );
        }
    });
}

function fn_device_register() {
    console.log("@# fn_device_register() 실행");

    const deviceName = $("#deviceName").val().trim();
    const location = $("#location").val().trim();
    const capacityKw = $("#capacityKw").val().trim();
    const deviceType = $("#deviceType").val();
    const latitude = $("#latitude").val();
    const longitude = $("#longitude").val();

    if (deviceName === "") {
        alert("기기 이름을 입력하세요.");
        $("#deviceName").focus();
        return;
    }

    if (location === "") {
        alert("설치 위치를 입력하세요.");
        $("#location").focus();
        return;
    }

    if (latitude === "" || longitude === "") {
        alert("주소 검색 버튼을 눌러 설치 위치를 확인하세요.");
        $("#location").focus();
        return;
    }

    if (capacityKw === "") {
        alert("장비 용량을 입력하세요.");
        $("#capacityKw").focus();
        return;
    }

    if (deviceType === "") {
        alert("장비 종류를 선택하세요.");
        $("#deviceType").focus();
        return;
    }

    const baseAddress = $("#location").val().trim();
    const detailAddress = $("#detailAddress").val().trim();

    if (detailAddress !== "") {
        $("#location").val(baseAddress + " " + detailAddress);
    }

    const formData = $("#deviceForm").serialize();

    console.log("@# formData =>", formData);

    $.ajax({
        type: "post",
        url: ctx + "/device/register",
        data: formData,
        success: function(result) {
            console.log("@# result =>", result);

            if (result === "success") {
                alert("기기 등록이 완료되었습니다.");

                $("#deviceForm")[0].reset();
                $("#addressResult").html("");

                let countText = $("#deviceCount").text();
                let count = parseInt(countText.replace("대", "").trim(), 10);

                if (isNaN(count)) {
                    count = 0;
                }

                $("#deviceCount").text((count + 1) + "대");

                loadDeviceList();

            } else if (result === "login_required" || result === "login_view") {
                alert("로그인이 필요합니다.");
                location.href = ctx + "/login_view";

            } else {
                alert("기기 등록에 실패했습니다.");
            }
        },
        error: function(xhr, status, error) {
            console.log("@# xhr =>", xhr);
            console.log("@# status =>", status);
            console.log("@# error =>", error);
            alert("서버 오류가 발생했습니다.");
        }
    });
}

function loadDeviceList() {
    location.href = ctx + "/dashboard/main";
}

function goDeviceDetail(deviceId) {
    location.href = ctx + "/device/detail?deviceId=" + deviceId;
}

function deleteDevice(deviceId) {
    console.log("@# deleteDevice() 실행");
    console.log("@# deviceId =>", deviceId);

    if (!confirm("해당 기기를 삭제하시겠습니까?")) {
        return;
    }

    $.ajax({
        url: ctx + "/device/delete",
        type: "post",
        data: {
            deviceId: deviceId
        },
        success: function(result) {
            console.log("@# delete result =>", result);

            if (result === "success") {
                alert("기기가 삭제되었습니다.");

                let countText = $("#deviceCount").text();
                let count = parseInt(countText.replace("대", "").trim(), 10);

                if (isNaN(count)) {
                    count = 0;
                }

                if (count > 0) {
                    $("#deviceCount").text((count - 1) + "대");
                } else {
                    $("#deviceCount").text("0대");
                }

                loadDeviceList();

            } else if (result === "login_required") {
                alert("로그인이 필요합니다.");
                location.href = ctx + "/login_view";

            } else {
                alert("삭제에 실패했습니다.");
            }
        },
        error: function(xhr, status, error) {
            console.log("@# xhr.status =>", xhr.status);
            console.log("@# xhr.responseText =>", xhr.responseText);
            console.log("@# status =>", status);
            console.log("@# error =>", error);

            alert("삭제 중 서버 오류가 발생했습니다.");
        }
    });
}

function loadMonitor() {
    ajaxLoad(
        "/monitoring/list",
        "📊 실시간 모니터링",
        "<p>아직 <strong>/monitoring/list</strong> 화면이 없어서 임시 화면을 표시합니다.</p>" +
        "<div class='summary-grid'>" +
        "<div class='summary-card'><h4>SOC</h4><strong>--%</strong></div>" +
        "<div class='summary-card'><h4>전압</h4><strong>-- V</strong></div>" +
        "<div class='summary-card'><h4>전류</h4><strong>-- A</strong></div>" +
        "<div class='summary-card'><h4>온도</h4><strong>-- ℃</strong></div>" +
        "</div>"
    );
}

function loadAlert() {
    renderTemp(
        "🚨 알림/이상 이력",
        "<p>온도 이상, 전압 이상, 통신 장애 등의 이력을 확인하는 영역입니다.</p>" +
        "<table class='fake-table'>" +
        "<tr><th>발생일시</th><th>기기</th><th>알림유형</th><th>상태</th></tr>" +
        "<tr><td>-</td><td>-</td><td>미확인 알림 없음</td><td><span class='badge green'>정상</span></td></tr>" +
        "</table>"
    );
}

function loadEnergy() {
    renderTemp(
        "⚡ 에너지 분석",
        "<p>충전량, 방전량, 전력 사용 패턴을 분석하는 영역입니다.</p>" +
        "<div class='summary-grid'>" +
        "<div class='summary-card'><h4>오늘 충전량</h4><strong>-- kWh</strong></div>" +
        "<div class='summary-card'><h4>오늘 방전량</h4><strong>-- kWh</strong></div>" +
        "<div class='summary-card'><h4>피크 사용량</h4><strong>-- kW</strong></div>" +
        "<div class='summary-card'><h4>절감 추정</h4><strong>-- 원</strong></div>" +
        "</div>"
    );
}

function loadBoard() {
    location.href = ctx + "/board_list";
}

function loadMyPage() {
    renderTemp(
        "👤 마이페이지",
        "<p>회원 정보와 등록된 ESS 장비를 관리하는 영역입니다.</p>" +
        "<table class='fake-table'>" +
        "<tr><th>항목</th><th>내용</th></tr>" +
        "<tr><td>회원명</td><td>" + memberName + "</td></tr>" +
        "<tr><td>회원유형</td><td>" + userType + "</td></tr>" +
        "</table>"
    );
}

function loadGuide() {
    renderTemp(
        "📘 이용 가이드",
        "<ol>" +
        "<li>회원가입 후 로그인합니다.</li>" +
        "<li>기기 등록 메뉴에서 ESS 장비를 등록합니다.</li>" +
        "<li>모니터링 메뉴에서 실시간 데이터를 확인합니다.</li>" +
        "<li>알림 메뉴에서 이상 상태를 확인합니다.</li>" +
        "</ol>"
    );
}

function showServiceIntro() {
    $("#contentArea").html(
        "<div class='panel-title'><h3>서비스 소개</h3></div>" +
        "<p>ESS-M.S는 ESS 장비 등록, 실시간 모니터링, 이상 알림, 에너지 분석을 제공하는 통합 관리 시스템입니다.</p>" +
        "<table class='fake-table'>" +
        "<tr><th>기능</th><th>설명</th></tr>" +
        "<tr><td>기기 등록</td><td>회원 계정 기준으로 ESS 장비를 등록하고 관리합니다.</td></tr>" +
        "<tr><td>실시간 모니터링</td><td>전압, 전류, 온도, SOC 데이터를 확인합니다.</td></tr>" +
        "<tr><td>알림 관리</td><td>이상 상태와 장애 이력을 확인합니다.</td></tr>" +
        "<tr><td>에너지 분석</td><td>충전량, 방전량, 사용량 데이터를 분석합니다.</td></tr>" +
        "</table>"
    );

    scrollContent();
}

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

window.addEventListener("popstate", function() {
    const params = new URLSearchParams(location.search);
    const view = params.get("view");

    if (view) {
        loadViewByName(view);
    } else {
        location.href = ctx + "/main";
    }
});

$(function() {
    const params = new URLSearchParams(location.search);
    const view = params.get("view");

    if (view) {
        loadViewByName(view);
    }
});

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