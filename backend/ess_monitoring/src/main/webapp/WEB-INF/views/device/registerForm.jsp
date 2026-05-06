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

    <form id="deviceForm" class="device-form">

        <!-- 주소/지도 검색으로 세팅되는 값 -->
        <input type="hidden" name="latitude" id="latitude">
        <input type="hidden" name="longitude" id="longitude">

<!--         기상청 격자 좌표: 주소 검색 후 JS에서 세팅 권장
        <input type="hidden" name="nx" id="nx">
        <input type="hidden" name="ny" id="ny"> -->

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
                    <label>현재 상태</label>
                    <select name="status" id="status" class="form-input">
                        <option value="NORMAL">정상</option>
                        <option value="WARNING">경고</option>
                        <option value="ERROR">오류</option>
                        <option value="OFFLINE">오프라인</option>
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
                           placeholder="예: 10.5">
                </div>

                <div class="form-group">
                    <label>ESS 저장 용량(kWh) <span>*</span></label>
                    <input type="number" step="0.01" name="essCapacityKwh" id="essCapacityKwh"
                           class="form-input"
                           placeholder="예: 50">
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

                <div class="form-group">
                    <label>충전 효율(%)</label>
                    <input type="number" step="0.01" name="chargeEfficiency" id="chargeEfficiency"
                           class="form-input"
                           value="90.00">
                </div>

                <div class="form-group">
                    <label>방전 효율(%)</label>
                    <input type="number" step="0.01" name="dischargeEfficiency" id="dischargeEfficiency"
                           class="form-input"
                           value="90.00">
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

</section>