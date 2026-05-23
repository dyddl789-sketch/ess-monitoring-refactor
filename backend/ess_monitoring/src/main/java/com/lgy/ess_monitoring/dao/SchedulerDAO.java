package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.WeatherDataDTO;

public interface SchedulerDAO {

    // 스케줄러 대상 장비 조회
    List<EssDeviceDTO> getActiveDeviceList();

    // 모니터링 데이터 저장
    void insertMonitoring(EssMonitoringDTO dto);

    // 일일 에너지 로그 누적 저장
    void upsertEnergyLog(
            @Param("deviceId") int deviceId,
            @Param("dailyKwh") double dailyKwh,
            @Param("cost") double cost,
            @Param("efficiency") double efficiency
    );

    // 장비 현재 충전량 / 상태 갱신
    void updateDeviceRuntimeState(
            @Param("deviceId") int deviceId,
            @Param("currentChargeKwh") double currentChargeKwh,
            @Param("status") String status
    );

    // 중복 방지 알림 생성
    void insertAlertIfNotExists(
            @Param("deviceId") int deviceId,
            @Param("alertType") String alertType,
            @Param("alertLevel") String alertLevel,
            @Param("message") String message,
            @Param("status") String status
    );
    
 // 현재 시간 기준 가장 가까운 날씨 예보 조회
    WeatherDataDTO getLatestWeatherForScheduler(
            @Param("deviceId") int deviceId,
            @Param("fcstDate") String fcstDate,
            @Param("fcstTime") String fcstTime
    );
}