package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.MonitoringSummaryDTO;

public interface EssMonitoringDAO {

    // 회원 기준 모니터링 목록 조회
    List<EssMonitoringDTO> getMonitoringListByMemberId(
            @Param("memberId") int memberId
    );

    // 특정 디바이스 최신 데이터
    EssMonitoringDTO getLatestMonitoring(
            @Param("deviceId") int deviceId
    );

    // 모니터링 데이터 저장
    void insertMonitoring(
            EssMonitoringDTO dto
    );

    // 전체 모니터링 수
    int getTotalCount();

    // 회원별 모니터링 수
    int getMemberCount(
            @Param("memberId") int memberId
    );

    // 시간별 모니터링 이력 조회
    List<EssMonitoringDTO> getMonitoringHistory(
            @Param("memberId") Integer memberId,
            @Param("deviceId") Integer deviceId,
            @Param("selectedDate") String selectedDate
    );

    // 오늘 누적 발전량 조회
    Double getTodayGeneration(
            @Param("deviceId") int deviceId
    );

    // 그룹 목록
    List<EssGroupDTO> getGroups(
            @Param("memberId") Integer memberId
    );

    // 그룹별 장비 목록
    List<EssDeviceDTO> getDevices(
            @Param("memberId") Integer memberId,
            @Param("groupId") Integer groupId
    );

    // 상단 카드 요약
    MonitoringSummaryDTO getMonitoringSummary(
            @Param("memberId") Integer memberId,
            @Param("deviceId") Integer deviceId,
            @Param("selectedDate") String selectedDate
    );

    // 최근 7일 차트
    List<DashboardChartDTO> getWeeklyMonitoringChart(
            @Param("memberId") Integer memberId,
            @Param("deviceId") Integer deviceId,
            @Param("selectedDate") String selectedDate
    );

    // 최근 알림
    List<AlertDTO> getMonitoringAlerts(
            @Param("deviceId") Integer deviceId
    );
}