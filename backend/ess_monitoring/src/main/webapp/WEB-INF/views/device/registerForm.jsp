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

</section>