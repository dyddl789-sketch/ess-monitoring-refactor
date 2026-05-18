package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface DashboardService {

    // 요약 카드
    DashboardSummaryDTO getDashboardSummary(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );

    // 장비 목록
    List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            Integer groupId,
            Integer deviceId
    );

    // 그룹 목록
    List<EssGroupDTO> getGroups(int memberId);

    // 월별 발전량
    List<DashboardChartDTO> getMonthlyGenerationChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );

    // 월별 절감 금액
    List<DashboardChartDTO> getMonthlyCostChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );

    // 장비별 TOP5
    List<DashboardChartDTO> getTopDeviceGenerationChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    );
}