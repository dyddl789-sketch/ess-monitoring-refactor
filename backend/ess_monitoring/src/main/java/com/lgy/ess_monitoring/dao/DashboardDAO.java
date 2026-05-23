package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface DashboardDAO {

    DashboardSummaryDTO getDashboardSummary(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    List<EssDeviceDTO> getDashboardDeviceStatusList(
            @Param("memberId") int memberId,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    List<EssGroupDTO> getGroups(
            @Param("memberId") int memberId
    );

    List<DashboardChartDTO> getMonthlyGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    List<DashboardChartDTO> getMonthlyCostChart(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    List<DashboardChartDTO> getTopDeviceGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );
}