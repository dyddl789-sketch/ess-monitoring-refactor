// ===============================
// 장비 등록 전용 JS
// ===============================

// contextPath 통일
function getContextPath() {
    if (typeof contextPath !== "undefined") {
        return contextPath;
    }

    if (typeof ctx !== "undefined") {
        return ctx;
    }

    return "";
}

// ===============================
// 등록 방식 전환
// ===============================
function showRegisterMode(mode) {
    const singleSection = document.getElementById("singleRegisterSection");
    const csvSection = document.getElementById("csvRegisterSection");
    const buttons = document.querySelectorAll(".mode-btn");

    if (!singleSection || !csvSection) {
        console.log("@# register section not found");
        return;
    }

    buttons.forEach(function (btn) {
        btn.classList.remove("active");
    });

    if (mode === "single") {
        singleSection.style.display = "block";
        csvSection.style.display = "none";

        if (buttons.length > 0) {
            buttons[0].classList.add("active");
        }
    } else {
        singleSection.style.display = "none";
        csvSection.style.display = "block";

        if (buttons.length > 1) {
            buttons[1].classList.add("active");
        }
    }
}

// ===============================
// 장비 등록
// ===============================
function fn_device_register() {
    console.log("@# fn_device_register() 실행");

    if (!validateDeviceForm()) {
        return;
    }

    applyDetailAddress();

    const formData = $("#deviceForm").serialize();

    console.log("@# formData =>", formData);

    $.ajax({
        type: "POST",
        url: getContextPath() + "/device/register",
        data: formData,

        success: function (result) {
            console.log("@# result =>", result);

            if (result === "success") {
                alert("장비 등록이 완료되었습니다.");

                updateDeviceCount();
                resetDeviceForm();

                if (confirm("장비 관리 화면으로 이동하시겠습니까?")) {
                    location.href = getContextPath() + "/device/manage";
                }

            } else if (result === "login_required" || result === "login_view") {
                alert("로그인이 필요합니다.");
                location.href = getContextPath() + "/login_view";

            } else {
                alert("장비 등록에 실패했습니다.");
            }
        },

        error: function (xhr, status, error) {
            console.log("@# xhr =>", xhr);
            console.log("@# status =>", status);
            console.log("@# error =>", error);

            alert("서버 오류가 발생했습니다.");
        }
    });
}

// ===============================
// 유효성 검사
// ===============================
function validateDeviceForm() {
    const deviceName = $("#deviceName").val().trim();
    const location = $("#location").val().trim();
    const capacityKw = $("#capacityKw").val();
    const essCapacityKwh = $("#essCapacityKwh").val();
    const deviceType = $("#deviceType").val();

    const latitude = $("#latitude").val();
    const longitude = $("#longitude").val();

    if (deviceName === "") {
        alert("장비명을 입력해주세요.");
        $("#deviceName").focus();
        return false;
    }

    if (location === "") {
        alert("주소 검색 버튼을 눌러 설치 위치를 입력해주세요.");
        $("#location").focus();
        return false;
    }

    if (latitude === "" || longitude === "") {
        alert("주소 검색을 통해 위도/경도를 입력해주세요.");
        return false;
    }

    if (capacityKw === "" || Number(capacityKw) <= 0) {
        alert("태양광 설비 용량을 올바르게 입력해주세요.");
        $("#capacityKw").focus();
        return false;
    }

    if (essCapacityKwh === "" || Number(essCapacityKwh) <= 0) {
        alert("ESS 저장 용량을 올바르게 입력해주세요.");
        $("#essCapacityKwh").focus();
        return false;
    }

    if (deviceType === "") {
        alert("시스템 유형을 선택해주세요.");
        $("#deviceType").focus();
        return false;
    }

    return true;
}

// ===============================
// 상세주소 합치기
// ===============================
function applyDetailAddress() {
    const baseAddress = $("#location").val().trim();
    const detailAddress = $("#detailAddress").val().trim();

    if (detailAddress !== "" && baseAddress.indexOf(detailAddress) === -1) {
        $("#location").val(baseAddress + " " + detailAddress);
    }
}

// ===============================
// 폼 초기화
// ===============================
function resetDeviceForm() {
    if ($("#deviceForm").length === 0) {
        return;
    }

    $("#deviceForm")[0].reset();

    $("#latitude").val("");
    $("#longitude").val("");

    $("#addressResult").html(
        "주소를 검색하면 위도/경도와 기상청 좌표가 자동으로 입력됩니다."
    );
}

// ===============================
// 장비 수 갱신
// ===============================
function updateDeviceCount() {
    if ($("#deviceCount").length === 0) {
        return;
    }

    let countText = $("#deviceCount").text();
    let count = parseInt(countText.replace("대", "").trim(), 10);

    if (isNaN(count)) {
        count = 0;
    }

    $("#deviceCount").text((count + 1) + "대");
}

// ===============================
// 주소 정보 세팅
// ===============================
function setDeviceAddressInfo(roadAddress, latitude, longitude) {
    $("#location").val(roadAddress);
    $("#latitude").val(latitude);
    $("#longitude").val(longitude);

    $("#addressResult").html(
        "주소 확인 완료<br>" +
        "위도: " + latitude + "<br>" +
        "경도: " + longitude + "<br>" +
        "기상청 좌표는 서버에서 자동 계산됩니다."
    );
}

// ===============================
// 주소 검색
// ===============================
function openDeviceAddressSearch() {
    new daum.Postcode({
        oncomplete: function (data) {
            const address = data.roadAddress || data.jibunAddress;

            if (!address) {
                alert("주소를 선택할 수 없습니다.");
                return;
            }

            searchDeviceAddress(address);
        }
    }).open({
        popupName: "devicePostcodePopup"
    });
}

// ===============================
// 주소 → 위도/경도 변환
// ===============================
function searchDeviceAddress(address) {
    if (typeof kakao === "undefined" || !kakao.maps || !kakao.maps.services) {
        alert("카카오 지도 API가 로드되지 않았습니다.");
        return;
    }

    const geocoder = new kakao.maps.services.Geocoder();

    geocoder.addressSearch(address, function (result, status) {
        if (status === kakao.maps.services.Status.OK) {
            const latitude = result[0].y;
            const longitude = result[0].x;

            const roadAddress = result[0].road_address
                ? result[0].road_address.address_name
                : "";

            const jibunAddress = result[0].address
                ? result[0].address.address_name
                : address;

            setDeviceAddressInfo(
                roadAddress !== "" ? roadAddress : jibunAddress,
                latitude,
                longitude
            );

        } else {
            $("#latitude").val("");
            $("#longitude").val("");

            $("#addressResult").html(
                "<span style='color:#dc2626;'>주소를 찾을 수 없습니다. 더 정확한 주소를 선택해주세요.</span>"
            );
        }
    });
}

// ===============================
// CSV 등록
// ===============================
function uploadDeviceCsv() {
    console.log("@# uploadDeviceCsv()");

    const fileInput = $("#csvFile")[0];

    if (!fileInput || fileInput.files.length === 0) {
        alert("업로드할 CSV 파일을 선택하세요.");
        return;
    }

    const formData = new FormData();
    formData.append("csvFile", fileInput.files[0]);

    $.ajax({
        type: "POST",
        url: getContextPath() + "/device/csv/upload",
        data: formData,
        processData: false,
        contentType: false,

        success: function (result) {
            console.log("@# csv upload result =>", result);

            let html = "";
            html += "<div class='csv-result'>";

            if (result.failCount === 0) {
                html += "<p>CSV 등록 완료: "
                    + result.successCount
                    + "개 장비가 등록되었습니다.</p>";
            } else {
                html += "<p>CSV 등록 완료</p>";
                html += "<p>성공: "
                    + result.successCount
                    + "건 / 실패: "
                    + result.failCount
                    + "건</p>";
            }

            if (result.errorList && result.errorList.length > 0) {
                html += "<ul>";

                for (let i = 0; i < result.errorList.length; i++) {
                    html += "<li>" + result.errorList[i] + "</li>";
                }

                html += "</ul>";
            }

            html += "</div>";

            $("#csvResultBox").html(html);

            if (result.successCount > 0) {
                alert("CSV 등록이 완료되었습니다.");
            }
        },

        error: function (xhr) {
            console.log("@# csv upload error");
            console.log(xhr.responseText);

            alert("CSV 파일 업로드 중 오류가 발생했습니다.");
        }
    });
}

// ===============================
// CSV 파일 선택 시 파일명 표시
// ===============================
$(document).on("change", "#csvFile", function () {

    const fileName = this.files.length > 0
        ? this.files[0].name
        : "선택된 파일 없음";

    $("#csvFileName").text(fileName);

});