package com.lgy.ess_monitoring.service;

import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssDeviceDAO;
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
}