package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.dto.EnergyStatsDTO;

public interface AlertDAO {

    // 알림 목록 조회
    List<AlertDTO> getAlertList(@Param("memberId") int memberId);

    // 알림 상세 조회
    AlertDTO getAlertDetail(
            @Param("alertId") int alertId,
            @Param("memberId") int memberId
    );

    // 알림 처리 상태 변경
    int updateAlertStatus(
            @Param("alertId") int alertId,
            @Param("memberId") int memberId,
            @Param("status") String status
    );

    // 열린 알림 중복 확인
    int existsOpenAlert(
            @Param("deviceId") int deviceId,
            @Param("alertType") String alertType
    );

    // 알림 자동 생성
    int insertAlert(AlertDTO alert);

    // 일별 에너지 통계 조회
    List<EnergyStatsDTO> getDailyEnergyStats(
            @Param("memberId") int memberId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate,
            @Param("deviceId") Integer deviceId
    );

    // 기기별 에너지 통계 조회
    List<EnergyStatsDTO> getDeviceEnergyStats(
            @Param("memberId") int memberId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );
    
 // 특정 장비 최근 알림 조회
    List<AlertDTO> getRecentAlertsByDeviceId(@Param("deviceId") int deviceId);
    
 // 대시보드 필터 기준 최근 알림 조회
    List<AlertDTO> getDashboardAlerts(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );
}