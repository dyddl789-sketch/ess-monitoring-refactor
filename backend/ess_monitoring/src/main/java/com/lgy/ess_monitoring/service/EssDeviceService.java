package com.lgy.ess_monitoring.service;

import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.EssDeviceDTO;

public interface EssDeviceService {

    // 기기 등록
    void insertDevice(EssDeviceDTO deviceDto);

    // 로그인한 회원의 기기 목록 조회
    ArrayList<EssDeviceDTO> getDeviceList(int memberId);

    // 로그인한 회원의 기기 수 조회
    int getDeviceCount(int memberId);

    // 기기 삭제
    int deleteDevice(@Param("deviceId") int deviceId,
                     @Param("memberId") int memberId);

    // 상세 보기
    EssDeviceDTO deviceDetail(int deviceId);

    // 대시보드 기기 상태 목록 조회
    ArrayList<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // 스케줄러용 전체 장비 조회
    List<EssDeviceDTO> getAllActiveDevices();

    // 선택한 디바이스를 대표 디바이스로 설정
    void setMainDevice(int memberId, int deviceId);

    // 회원의 대표 디바이스 조회
    EssDeviceDTO getMainDevice(int memberId);
}