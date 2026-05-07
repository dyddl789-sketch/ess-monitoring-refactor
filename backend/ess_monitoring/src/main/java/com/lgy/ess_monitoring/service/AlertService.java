package com.lgy.ess_monitoring.service;

import java.math.BigDecimal;
import java.util.List;

import com.lgy.ess_monitoring.dto.AlertDTO;

public interface AlertService {

    // 알림 목록 조회
    List<AlertDTO> getAlertList(int memberId);

    // 알림 상세 조회
    AlertDTO getAlertDetail(int alertId, int memberId);

    // 알림 상태 변경
    int updateAlertStatus(
            int alertId,
            int memberId,
            String status
    );

    // 특정 장비 최근 알림 조회
    List<AlertDTO> getRecentAlertsByDeviceId(int deviceId);

    // 알림 자동 생성
    void createAlertIfNeeded(
            int deviceId,
            BigDecimal soc,
            BigDecimal voltage,
            BigDecimal solarGenerationKwh,
            BigDecimal powerOutput
    );
    
 // 대시보드 필터 기준 최근 알림 조회
    List<AlertDTO> getDashboardAlerts(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );
}