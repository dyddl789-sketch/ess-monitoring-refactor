package com.lgy.ess_monitoring.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.lgy.ess_monitoring.dao.EssDeviceDAO;
import com.lgy.ess_monitoring.dto.CsvUploadResultDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.util.GridConverter;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EssDeviceServiceImpl implements EssDeviceService {

    @Autowired
    private SqlSession sqlSession;

    private EssDeviceDAO getDao() {
        return sqlSession.getMapper(EssDeviceDAO.class);
    }

    @Override
    public void insertDevice(EssDeviceDTO deviceDto) {
        if (deviceDto.getLatitude() != null && deviceDto.getLongitude() != null) {
            double latitude = deviceDto.getLatitude().doubleValue();
            double longitude = deviceDto.getLongitude().doubleValue();

            int[] grid = GridConverter.convertToGrid(latitude, longitude);

            deviceDto.setNx(grid[0]);
            deviceDto.setNy(grid[1]);

            log.info("@# latitude => " + latitude);
            log.info("@# longitude => " + longitude);
            log.info("@# nx => " + grid[0]);
            log.info("@# ny => " + grid[1]);
        } else {
            log.warn("@# 좌표 없음 → nx/ny 계산 안됨");
        }

        // status 한글값을 DB 허용값으로 변환
        if ("정상".equals(deviceDto.getStatus())) {
            deviceDto.setStatus("NORMAL");
        } else if ("주의".equals(deviceDto.getStatus())) {
            deviceDto.setStatus("WARNING");
        } else if ("오류".equals(deviceDto.getStatus())) {
            deviceDto.setStatus("ERROR");
        } else if ("오프라인".equals(deviceDto.getStatus())) {
            deviceDto.setStatus("OFFLINE");
        }

        // status가 비어 있으면 기본값 NORMAL
        if (deviceDto.getStatus() == null || deviceDto.getStatus().trim().equals("")) {
            deviceDto.setStatus("NORMAL");
        }

     // ESS 저장 용량 기본값 보정
        if (deviceDto.getEssCapacityKwh() <= 0) {
            deviceDto.setEssCapacityKwh(deviceDto.getCapacityKw());
        }

        // 현재 충전량 기본값 보정
        if (deviceDto.getCurrentChargeKwh() == null) {
            deviceDto.setCurrentChargeKwh(0.00);
        }

        // 충전 효율 기본값 보정
        if (deviceDto.getChargeEfficiency() <= 0) {
            deviceDto.setChargeEfficiency(90.00);
        }

        // 방전 효율 기본값 보정
        if (deviceDto.getDischargeEfficiency() <= 0) {
            deviceDto.setDischargeEfficiency(90.00);
        }

        // 전기요금 단가 기본값 보정
        if (deviceDto.getElectricityRate() <= 0) {
            deviceDto.setElectricityRate(150.00);
        }

        // 대표 디바이스 기본값 보정
        if (deviceDto.getIsMain() == null || deviceDto.getIsMain().trim().equals("")) {
            deviceDto.setIsMain("N");
        }

        log.info("@# insert 보정 후 deviceDto => " + deviceDto);

        getDao().insertDevice(deviceDto);
    }

    @Override
    public ArrayList<EssDeviceDTO> getDeviceList(int memberId) {
        return getDao().getDeviceList(memberId);
    }

    @Override
    public int getDeviceCount(int memberId) {
        return getDao().getDeviceCount(memberId);
    }

    @Override
    public int deleteDevice(int deviceId, int memberId) {
        return getDao().deleteDevice(deviceId, memberId);
    }

    @Override
    public EssDeviceDTO deviceDetail(int deviceId) {
        return getDao().deviceDetail(deviceId);
    }

    @Override
    public ArrayList<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        return getDao().getDashboardDeviceStatusList(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    @Override
    public EssDeviceDTO getMainDevice(int memberId) {
        log.info("@# getMainDevice()");
        log.info("@# memberId => " + memberId);

        EssDeviceDTO dto = getDao().getMainDevice(memberId);

        log.info("@# mainDevice dto => " + dto);

        return dto;
    }

   

@Override
public void setMainDevice(int memberId, int deviceId) {
    log.info("@# setMainDevice()");
    log.info("@# memberId => " + memberId);
    log.info("@# deviceId => " + deviceId);

    /*
     * 1단계
     * 해당 회원의 기존 대표 디바이스를 모두 해제한다.
     */
    getDao().clearMainDevice(memberId);

    /*
     * 2단계
     * 사용자가 선택한 기기만 대표 디바이스로 설정한다.
     */
    getDao().setMainDevice(memberId, deviceId);

    log.info("@# 대표 디바이스 설정 완료");
}

@Override
public List<EssDeviceDTO> getAllActiveDevices() {
    return getDao().getAllActiveDevices();
}

	/**
	 * CSV 파일을 읽어서 여러 ESS 기기를 한 번에 등록하는 메서드
	 *
	 * 처리 흐름:
	 * 1. CSV 파일 존재 여부 확인
	 * 2. CSV 첫 줄을 헤더로 인식
	 * 3. 한 행씩 읽으면서 EssDeviceDTO 생성
	 * 4. 기존 insertDevice() 메서드 재사용
	 * 5. 성공/실패 건수 저장
	 */
	@Override
	public CsvUploadResultDTO uploadDeviceCsv(MultipartFile file, int memberId) {
	
	    log.info("@# uploadDeviceCsv()");
	    log.info("@# memberId => " + memberId);
	
	    // 화면으로 반환할 결과 DTO 생성
	    CsvUploadResultDTO result = new CsvUploadResultDTO();
	
	    // 1. 파일이 없거나 비어 있으면 실패 처리
	    if (file == null || file.isEmpty()) {
	        result.addFail("CSV 파일이 비어 있습니다.");
	        return result;
	    }
	
	    /*
	     * try-with-resources
	     * reader, parser는 사용 후 자동으로 close 된다.
	     */
	    try (
	        // 업로드된 CSV 파일을 UTF-8로 읽기
	        BufferedReader reader = new BufferedReader(
	            new InputStreamReader(file.getInputStream(), "UTF-8")
	        );
	
	        /*
	         * CSVParser 설정
	         * withFirstRecordAsHeader()
	         * → 첫 번째 줄을 컬럼명으로 사용
	         *
	         * withTrim()
	         * → 각 값의 앞뒤 공백 제거
	         */
	        CSVParser parser = CSVFormat.DEFAULT
	            .withFirstRecordAsHeader()
	            .withTrim()
	            .parse(reader)
	    ) {
	
	        // 2. CSV 데이터를 한 줄씩 반복
	        for (CSVRecord record : parser) {
	
	            // 전체 처리 건수 증가
	            result.setTotalCount(result.getTotalCount() + 1);
	
	            /*
	             * record.getRecordNumber()
	             * → 데이터 행 번호
	             *
	             * CSV 첫 줄은 헤더이므로 실제 엑셀 기준 행 번호는 +1 처리
	             */
	            int rowNum = (int) record.getRecordNumber() + 1;
	
	            try {
	                /*
	                 * 3. CSV 컬럼 값 읽기
	                 *
	                 * CSV 헤더 이름과 정확히 일치해야 한다.
	                 * 예: deviceName, location, capacityKw
	                 */
	            	String groupName = getCsvValue(record, "groupName");
	                String deviceName = getCsvValue(record, "deviceName");
	                String location = getCsvValue(record, "location");
	                String capacityKwText = getCsvValue(record, "capacityKw");
	                String deviceType = getCsvValue(record, "deviceType");
	                log.info("@# CSV row groupName => " + groupName);
	                log.info("@# CSV row deviceName => " + deviceName);
	                // 4. 필수값 검증
	                if (isEmpty(deviceName)) {
	                    result.addFail(rowNum + "행: 장비명이 비어 있습니다.");
	                    continue;
	                }
	
	                if (isEmpty(location)) {
	                    result.addFail(rowNum + "행: 위치가 비어 있습니다.");
	                    continue;
	                }
	
	                if (isEmpty(capacityKwText)) {
	                    result.addFail(rowNum + "행: 설비 용량이 비어 있습니다.");
	                    continue;
	                }
	
	                if (isEmpty(deviceType)) {
	                    result.addFail(rowNum + "행: 장비 유형이 비어 있습니다.");
	                    continue;
	                }
	
	                // 설비 용량은 숫자여야 하므로 double로 변환
	                double capacityKw = Double.parseDouble(capacityKwText);
	
	                /*
	                 * 5. DTO 생성
	                 * 기존 단건 등록과 같은 EssDeviceDTO를 사용한다.
	                 */
	                EssDeviceDTO dto = new EssDeviceDTO();
	
	                // 로그인한 회원의 장비로 등록
	                dto.setMemberId(memberId);
	
	                //CSV 그룹 처리
	                if (!isEmpty(groupName)) {
	                    Integer groupId = getDao().getGroupIdByName(memberId, groupName);
	
	                    if (groupId == null) {
	                        result.addFail(rowNum + "행: 존재하지 않는 그룹명입니다. groupName=" + groupName);
	                        continue;
	                    }
	
	                    dto.setGroupId(groupId);
	                }
	
	                // CSV에서 읽은 기본 정보 세팅
	                dto.setDeviceName(deviceName);
	                dto.setLocation(location);
	                dto.setCapacityKw(capacityKw);
	                dto.setDeviceType(deviceType);
	
	                /*
	                 * 상태값이 비어 있으면 기본값 NORMAL로 처리
	                 * 예: NORMAL, WARNING, ERROR, OFFLINE 등
	                 */
	                String status = getCsvValue(record, "status");
	                dto.setStatus(isEmpty(status) ? "NORMAL" : status);
	
	                /*
	                 * 위도/경도
	                 * 값이 있으면 BigDecimal로 변환해서 저장
	                 * insertDevice() 내부에서 nx, ny 계산에 사용됨
	                 */
	                String latitude = getCsvValue(record, "latitude");
	                String longitude = getCsvValue(record, "longitude");
	
	                if (!isEmpty(latitude)) {
	                    dto.setLatitude(new BigDecimal(latitude));
	                }
	
	                if (!isEmpty(longitude)) {
	                    dto.setLongitude(new BigDecimal(longitude));
	                }
	
	                /*
	                 * ESS 스펙 정보
	                 * CSV에 값이 있으면 그 값을 사용하고,
	                 * 없으면 기본값을 사용한다.
	                 */
	                dto.setEssCapacityKwh(
	                    parseDoubleOrDefault(record, "essCapacityKwh", capacityKw * 2)
	                );
	
	                dto.setCurrentChargeKwh(
	                    parseDoubleOrDefault(record, "currentChargeKwh", 0)
	                );
	
	                dto.setChargeEfficiency(
	                    parseDoubleOrDefault(record, "chargeEfficiency", 95)
	                );
	
	                dto.setDischargeEfficiency(
	                    parseDoubleOrDefault(record, "dischargeEfficiency", 90)
	                );
	
	                dto.setElectricityRate(
	                    parseDoubleOrDefault(record, "electricityRate", 150)
	                );
	
	                /*
	                 * 6. 기존 단건 등록 메서드 재사용
	                 *
	                 * insertDevice(dto) 안에서:
	                 * - 위도/경도 → 기상청 nx/ny 변환
	                 * - DB insert
	                 * 를 처리하고 있으므로 중복 로직을 만들지 않는다.
	                 */
	                insertDevice(dto);
	
	                // 성공 건수 증가
	                result.addSuccess();
	
	            } catch (Exception e) {
	                /*
	                 * 한 행에서 오류가 나도 전체 업로드를 중단하지 않고
	                 * 해당 행만 실패 처리 후 다음 행 계속 진행
	                 */
	                log.error("@# CSV row insert error", e);
	                result.addFail(rowNum + "행: 등록 실패 - " + e.getMessage());
	            }
	        }
	
	    } catch (Exception e) {
	        /*
	         * CSV 파일 자체를 읽을 수 없는 경우
	         * 예: 인코딩 오류, 파일 형식 오류 등
	         */
	        log.error("@# CSV upload error", e);
	        result.addFail("CSV 파일 처리 실패: " + e.getMessage());
	    }
	
	    log.info("@# csv total => " + result.getTotalCount());
	    log.info("@# csv success => " + result.getSuccessCount());
	    log.info("@# csv fail => " + result.getFailCount());
	
	    return result;
	}

	
	private String getCsvValue(CSVRecord record, String columnName) {
	    try {
	        /*
	         * 1. 일반적인 헤더명으로 먼저 조회
	         *
	         * 예:
	         * groupName, deviceName, location
	         */
	        if (record.isMapped(columnName)) {
	            String value = record.get(columnName);
	            return value == null ? "" : value.trim();
	        }

	        /*
	         * 2. UTF-8 BOM 처리
	         *
	         * CSV 파일 첫 번째 컬럼 앞에 BOM이 붙으면
	         * groupName이 아니라 "\uFEFFgroupName"으로 인식될 수 있다.
	         */
	        String bomColumnName = "\uFEFF" + columnName;

	        if (record.isMapped(bomColumnName)) {
	            String value = record.get(bomColumnName);
	            return value == null ? "" : value.trim();
	        }

	        /*
	         * 3. 해당 컬럼이 없으면 빈 값 반환
	         */
	        return "";

	    } catch (Exception e) {
	        return "";
	    }
	}
	
	/**
	 * 문자열이 비어 있는지 확인하는 메서드
	 */
	private boolean isEmpty(String value) {
	    return value == null || value.trim().equals("");
	}
	
	/**
	 * CSV 값을 double로 변환하는 메서드
	 *
	 * 값이 없거나 숫자 변환 실패 시 기본값 사용
	 */
	private double parseDoubleOrDefault(CSVRecord record,
	                                    String columnName,
	                                    double defaultValue) {
	    try {
	        String value = getCsvValue(record, columnName);
	
	        if (isEmpty(value)) {
	            return defaultValue;
	        }
	
	        return Double.parseDouble(value);
	
	    } catch (Exception e) {
	        return defaultValue;
	    }
	}
}
