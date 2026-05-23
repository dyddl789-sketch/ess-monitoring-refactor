package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface DashboardService {

    DashboardSummaryDTO getDashboardSummary(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );

    List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            Integer groupId,
            Integer deviceId
    );

    List<EssGroupDTO> getGroups(int memberId);

    List<DashboardChartDTO> getMonthlyGenerationChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );

    List<DashboardChartDTO> getMonthlyCostChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );

    List<DashboardChartDTO> getTopDeviceGenerationChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );
}