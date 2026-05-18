package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.MonitoringSummaryDTO;

public interface EssMonitoringService {

    // 회원 기준 모니터링 목록 조회
    List<EssMonitoringDTO> getMonitoringListByMemberId(
            int memberId
    );

    // 특정 디바이스 최신 데이터
    EssMonitoringDTO getLatestMonitoring(
            int deviceId
    );

    // 전체 모니터링 데이터 수
    int getTotalCount();

    // 회원별 모니터링 데이터 수
    int getMemberCount(
            int memberId
    );

    // 시간별 모니터링 이력 조회
    List<EssMonitoringDTO> getMonitoringHistory(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    );

    // 오늘 누적 발전량 조회
    Double getTodayGeneration(
            int deviceId
    );

    // 그룹 목록
    List<EssGroupDTO> getGroups(
            Integer memberId
    );

    // 그룹별 장비 목록
    List<EssDeviceDTO> getDevices(
            Integer memberId,
            Integer groupId
    );

    // 상단 카드 요약
    MonitoringSummaryDTO getMonitoringSummary(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    );

    // 최근 7일 차트
    List<DashboardChartDTO> getWeeklyMonitoringChart(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    );

    // 최근 알림
    List<AlertDTO> getMonitoringAlerts(
            Integer deviceId
    );
    
 // 모니터링 데이터 저장
    void insertMonitoring(EssMonitoringDTO dto);
    
    MonitoringSummaryDTO getMonitoringSummaryFromEnergyLog(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    );
    
    List<DashboardChartDTO> getHistoryFromEnergyLog(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    );
}