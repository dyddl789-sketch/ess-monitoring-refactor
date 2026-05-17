package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardChartResponseDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface DashboardService {

    DashboardSummaryDTO getDashboardSummary(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    List<EssGroupDTO> getGroups(int memberId);

    DashboardChartResponseDTO getGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    List<DashboardChartDTO> getHourlyCompareChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    List<DashboardChartDTO> getDeviceCompareChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // energy_log 기반 최근 7일 발전량
    List<DashboardChartDTO> getWeeklyGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // energy_log 기반 최근 6개월 월별 발전량
    List<DashboardChartDTO> getMonthlyGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // energy_log 기반 장비별 발전량 TOP5
    List<DashboardChartDTO> getTopDeviceGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId
    );
}