package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;
import com.lgy.ess_monitoring.dto.DashboardChartResponseDTO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;

public interface DashboardService {

    // ===============================
    // 대시보드 요약 정보 조회
    // ===============================
    DashboardSummaryDTO getDashboardSummary(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // ===============================
    // 대시보드 장비 상태 조회 (핵심)
    // ===============================
    List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // ===============================
    // 회원 기준 장비 그룹 목록 조회
    // ===============================
    List<EssDeviceGroupDTO> getGroups(int memberId);
    
 // 발전량 차트 조회
    DashboardChartResponseDTO getGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );
 // 시간별 발전량 / SOC 비교 차트
    List<DashboardChartDTO> getHourlyCompareChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );
 // 장비별 발전량 비교 차트
    List<DashboardChartDTO> getDeviceCompareChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );
}