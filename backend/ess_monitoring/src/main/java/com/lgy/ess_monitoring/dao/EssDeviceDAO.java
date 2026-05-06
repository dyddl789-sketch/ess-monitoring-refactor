package com.lgy.ess_monitoring.dao;

import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.EssDeviceDTO;

public interface EssDeviceDAO {

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

    // 대시보드용 장비 상태 리스트
    ArrayList<EssDeviceDTO> getDashboardDeviceStatusList(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );
    
    // 대표 디바이스 조회
    public EssDeviceDTO getMainDevice(int memberId);
    
    // 해당 회원의 기존 대표 디바이스 해제
    public void clearMainDevice(@Param("memberId") int memberId);

    // 선택한 디바이스를 대표 디바이스로 설정
    public void setMainDevice(@Param("memberId") int memberId,
                              @Param("deviceId") int deviceId);
    
    List<EssDeviceDTO> getAllActiveDevices();
}