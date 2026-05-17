<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<section class="device-register-page">

    <div class="register-header">
        <div>
            <h2>장비 등록</h2>
            <p>ESS 장비 정보와 설치 위치를 등록합니다.</p>
        </div>
    </div>

    <!-- ===============================
         등록 방식 선택 버튼
         =============================== -->
    <div class="register-mode-tabs">
        <button type="button"
                class="mode-btn active"
                onclick="showRegisterMode('single')">
            기기 직접 등록
        </button>

        <button type="button"
                class="mode-btn"
                onclick="showRegisterMode('csv')">
            CSV 등록
        </button>
    </div>

    <!-- ===============================
         기기 직접 등록 영역
         =============================== -->
    <div id="singleRegisterSection">

        <form id="deviceForm" class="device-form">

            <!-- 주소/지도 검색으로 세팅되는 값 -->
            <input type="hidden" name="latitude" id="latitude">
            <input type="hidden" name="longitude" id="longitude">

            <!--
            기상청 격자 좌표: 주소 검색 후 JS에서 세팅 권장
            <input type="hidden" name="nx" id="nx">
            <input type="hidden" name="ny" id="ny">
            -->

            <div class="form-card">

                <div class="form-section-title">기본 정보</div>

                <div class="form-grid">

                    <div class="form-group">
                        <label>장비명 <span>*</span></label>
                        <input type="text" name="deviceName" id="deviceName"
                               class="form-input"
                               placeholder="예: ESS-부산-01">
                    </div>

                    <div class="form-group">
                        <label>그룹</label>
                        <select name="groupId" id="groupId" class="form-input">
                            <option value="0">그룹 없음</option>
                            <c:forEach var="group" items="${groupList}">
                                <option value="${group.groupId}">
                                    ${group.groupName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>시스템 유형</label>
                        <select name="deviceType" id="deviceType" class="form-input">
                            <option value="HYBRID">태양광 + ESS</option>
                            <option value="SOLAR">태양광</option>
                            <option value="ESS">ESS</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>설치 날짜</label>
                        <input type="date" name="installDate" id="installDate"
                               class="form-input">
                    </div>

                    <div class="form-group">
                        <label>대표 장비</label>
                        <select name="isMain" id="isMain" class="form-input">
                            <option value="N">아니오</option>
                            <option value="Y">예</option>
                        </select>
                    </div>

                </div>
            </div>

            <div class="form-card">

                <div class="form-section-title">설치 위치</div>

                <div class="form-group full">
                    <label>주소 <span>*</span></label>

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

                    <div id="addressResult" class="address-result">
                        주소를 검색하면 위도/경도와 기상청 좌표가 자동으로 입력됩니다.
                    </div>
                </div>

            </div>

            <div class="form-card">

                <div class="form-section-title">설비 / ESS 스펙</div>

                <div class="form-grid">

                    <div class="form-group">
                        <label>태양광 설비 용량(kW) <span>*</span></label>
                        <input type="number" step="0.01" name="capacityKw" id="capacityKw"
                               class="form-input"
                               placeholder="예: 50">
                    </div>

                    <div class="form-group">
                        <label>ESS 저장 용량(kWh) <span>*</span></label>
                        <input type="number" step="0.01" name="essCapacityKwh" id="essCapacityKwh"
                               class="form-input"
                               placeholder="예: 100">
                    </div>

                    <div class="form-group">
                        <label>현재 충전량(kWh)</label>
                        <input type="number" step="0.01" name="currentChargeKwh" id="currentChargeKwh"
                               class="form-input"
                               placeholder="미입력 가능">
                    </div>

                    <div class="form-group">
                        <label>전기요금 단가(원/kWh)</label>
                        <input type="number" step="0.01" name="electricityRate" id="electricityRate"
                               class="form-input"
                               value="150.00">
                    </div>

                </div>
            </div>

            <div class="form-button-area">
                <button type="button" class="btn-primary" onclick="fn_device_register()">
                    장비 등록
                </button>

                <button type="button" class="btn-gray-form"
                        onclick="resetDeviceForm()">
                    초기화
                </button>

                <button type="button" class="btn-gray-form"
                        onclick="location.href='${pageContext.request.contextPath}/device/manage'">
                    목록으로
                </button>
            </div>

        </form>

    </div>

    <!-- ===============================
         CSV 등록 영역
         =============================== -->
    <div id="csvRegisterSection" style="display:none;">

        <div class="csv-register-box">

            <div class="csv-register-header">
                <h3>CSV 등록</h3>
                <p>
                    CSV 양식 파일을 다운로드한 뒤 기기 정보를 입력하고,
                    파일을 업로드하면 여러 장비를 한 번에 등록할 수 있습니다.
                </p>
            </div>

            <div class="csv-guide-box">
                <strong>등록 방법</strong>
                <span>1. CSV 양식 다운로드 → 2. 기기 정보 입력 → 3. CSV 업로드</span>
            </div>

            <div class="csv-upload-row">

                <button type="button"
                        class="btn-csv-download"
                        onclick="location.href='${pageContext.request.contextPath}/device/csv/template'">
                    CSV 양식 다운로드
                </button>

			<div class="csv-file-label">
			
			    <input type="file"
			           id="csvFile"
			           name="csvFile"
			           accept=".csv,.txt"
			           hidden>
			
			    <button type="button"
			            id="csvSelectBtn"
			            class="btn-csv-select">
			        파일 선택
			    </button>
			
			    <span id="csvFileName">
			        선택된 파일 없음
			    </span>
			
			</div>

                <button type="button"
                        class="btn-csv-upload"
                        onclick="uploadDeviceCsv()">
                    CSV 등록
                </button>

            </div>

            <p class="csv-help-text">
                ※ groupName은 미리 생성된 그룹명과 정확히 일치해야 합니다.<br>
    			※ CSV 등록 전 그룹 관리에서 그룹을 먼저 생성해주세요.<br>
    			※ 첫 번째 헤더 행은 수정하지 마세요.
            </p>

            <div id="csvResultBox" class="csv-result-box"></div>

        </div>

    </div>

    <script>
        /*
         * 등록 방식 전환
         *
         * single:
         * - 기기 직접 등록 폼 표시
         *
         * csv:
         * - CSV 등록 영역 표시
         */
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

        /*
         * CSV 파일 선택 시 파일명 표시
         */
        document.addEventListener("DOMContentLoaded", function () {

            const csvFile = document.getElementById("csvFile");
            const csvFileName = document.getElementById("csvFileName");

            if (csvFile && csvFileName) {

                csvFile.addEventListener("change", function () {

                    if (this.files.length > 0) {
                        csvFileName.textContent = this.files[0].name;
                    } else {
                        csvFileName.textContent = "선택된 파일 없음";
                    }

                });

            }

        });

        /*
         * CSV 등록 처리
         *
         * 요청 URL:
         * POST /device/csv/upload
         */
        function uploadDeviceCsv() {
            console.log("@# uploadDeviceCsv()");

            var fileInput = $("#csvFile")[0];

            if (fileInput.files.length === 0) {
                alert("업로드할 CSV 파일을 선택하세요.");
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

                        for (var i = 0; i < result.errorList.length; i++) {
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

                error: function(xhr) {
                    console.log("@# csv upload error");
                    console.log(xhr.responseText);

                    alert("CSV 파일 업로드 중 오류가 발생했습니다.");
                }
            });
        }
        /*
         * 파일 선택 버튼 클릭
         */
        document.getElementById("csvSelectBtn")
            .addEventListener("click", function () {

                document.getElementById("csvFile").click();

            });
    </script>

</section>