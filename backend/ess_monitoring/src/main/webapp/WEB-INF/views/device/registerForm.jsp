<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<section class="device-register-box">

    <form id="deviceForm" class="device-form">

        <input type="hidden" name="latitude" id="latitude">
        <input type="hidden" name="longitude" id="longitude">

        <table class="device-form-table">
            <tr>
                <th>기기 이름</th>
                <td>
                    <input type="text" name="deviceName" id="deviceName"
                           class="form-input"
                           placeholder="예: SOLAR_BUSAN_ESS_01">
                </td>
            </tr>

            <tr>
                <th>설치 위치</th>
                <td>
                    <div class="address-row">
                        <input type="text" name="location" id="location"
                               class="form-input"
                               readonly
                               placeholder="주소 검색 버튼을 눌러주세요">

                        <button type="button" class="btn-sub"
                                onclick="openDeviceAddressSearch()">
                            주소 검색
                        </button>
                    </div>

                    <input type="text" id="detailAddress"
                           class="form-input detail-address"
                           placeholder="상세주소 (선택)">

                    <div id="addressResult" class="address-result"></div>
                </td>
            </tr>

            <tr>
                <th>장비 용량</th>
                <td>
                    <input type="text" name="capacityKw" id="capacityKw"
                           class="form-input short"
                           placeholder="예: 100"> kW
                </td>
            </tr>

            <tr>
                <th>장비 종류</th>
                <td>
                    <select name="deviceType" id="deviceType" class="form-input">
                        <option value="">선택</option>
                        <option value="태양광ESS">태양광ESS</option>
                        <option value="배터리">배터리</option>
                        <option value="인버터">인버터</option>
                        <option value="PCS">PCS</option>
                        <option value="BMS">BMS</option>
                    </select>
                </td>
            </tr>

            <tr>
                <th>현재 상태</th>
                <td>
                    <select name="status" id="status" class="form-input">
                        <option value="정상">정상</option>
                        <option value="점검">점검</option>
                        <option value="오류">오류</option>
                    </select>
                </td>
            </tr>

            <tr>
                <th>설치 날짜</th>
                <td>
                    <input type="date" name="installDate" id="installDate"
                           class="form-input short">
                </td>
            </tr>
        </table>

        <div class="form-button-area">
            <button type="button" class="btn-primary" onclick="fn_device_register()">등록</button>
            <button type="button" class="btn-gray-form"
                    onclick="$('#deviceForm')[0].reset(); $('#addressResult').html('');">
                초기화
            </button>
        </div>

    </form>
	
<!-- ===============================
     기기 일괄 등록 영역
     =============================== -->
<div class="excel-register-box">

    <div class="excel-register-header">
        <h3>기기 일괄 등록</h3>
        <p>
            양식 파일을 다운로드한 뒤 기기 정보를 입력하고
            파일을 업로드하면 여러 장비를 한 번에 등록할 수 있습니다.
        </p>
    </div>

    <div class="excel-guide-box">
        <strong>등록 방법</strong>
        <span>1. 양식 다운로드 → 2. 기기 정보 입력 → 3. 파일 업로드</span>
    </div>

    <div class="excel-upload-row">

        <button type="button"
                class="btn-excel-download"
                onclick="location.href='${pageContext.request.contextPath}/device/csv/template'">
            양식 다운로드
        </button>

        <input type="file"
               id="csvFile"
               name="csvFile"
               accept=".csv,.txt"
               class="excel-file-input">

        <button type="button"
                class="btn-excel-upload"
                onclick="uploadDeviceCsv()">
            일괄 등록
        </button>

    </div>

    <p class="excel-help-text">
        ※ 다운로드한 양식 파일의 첫 줄은 수정하거나 삭제하지 말고 그대로 업로드해주세요.
    </p>

    <div id="csvResultBox" class="csv-result-box"></div>

</div>

    <!-- CSV 업로드 결과 출력 영역 -->
    <div id="csvResultBox" class="csv-result-box"></div>

</div>

    <script>
	    function uploadDeviceCsv() {
	        console.log("@# uploadDeviceCsv()");
	
	        var fileInput = $("#csvFile")[0];
	
	        if (fileInput.files.length === 0) {
	            alert("업로드할 양식 파일을 선택하세요.");
	            return;
	        }
	
	        var formData = new FormData();
	        formData.append("csvFile", fileInput.files[0]);
	
	        $.ajax({
	            type: "post",
	            url: "${pageContext.request.contextPath}/device/csv/upload",
	            data: formData,
	            processData: false,
	            contentType: false,
	
	            success: function(result) {
	                console.log("@# csv upload result =>", result);
	
	                var html = "";
	                html += "<div class='csv-result'>";
	
	                if (result.failCount === 0) {
	                    html += "<p>일괄 등록 완료: "
	                         + result.successCount
	                         + "개 장비가 등록되었습니다.</p>";
	                } else {
	                    html += "<p>일괄 등록 완료</p>";
	                    html += "<p>성공: "
	                         + result.successCount
	                         + "건 / 실패: "
	                         + result.failCount
	                         + "건</p>";
	                }
	
	                if (result.errorList && result.errorList.length > 0) {
	                    html += "<ul>";
	
	                    for (var i = 0; i < result.errorList.length; i++) {
	                        html += "<li>" + result.errorList[i] + "</li>";
	                    }
	
	                    html += "</ul>";
	                }
	
	                html += "</div>";
	
	                $("#csvResultBox").html(html);
	
	                if (result.successCount > 0) {
	                    alert("기기 일괄 등록이 완료되었습니다.");
	                }
	            },
	
	            error: function(xhr) {
	                console.log("@# csv upload error");
	                console.log(xhr.responseText);
	
	                alert("파일 업로드 중 오류가 발생했습니다.");
	            }
	        });
	    }
	</script>


</section>