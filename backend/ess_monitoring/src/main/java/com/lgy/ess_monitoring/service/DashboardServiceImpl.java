package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.DashboardDAO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class DashboardServiceImpl implements DashboardService {

    @Autowired
    private SqlSession sqlSession;

    private DashboardDAO getDao() {
        return sqlSession.getMapper(DashboardDAO.class);
    }

    @Override
    public DashboardSummaryDTO getDashboardSummary(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getDashboardSummary() memberId={}, selectedMonth={}", memberId, selectedMonth);

        return getDao().getDashboardSummary(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    @Override
    public List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getDashboardDeviceStatusList() memberId={}", memberId);

        return getDao().getDashboardDeviceStatusList(
                memberId,
                groupId,
                deviceId
        );
    }

    @Override
    public List<EssGroupDTO> getGroups(int memberId) {
        log.info("getGroups() memberId={}", memberId);

        return getDao().getGroups(memberId);
    }

    @Override
    public List<DashboardChartDTO> getMonthlyGenerationChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getMonthlyGenerationChart() selectedMonth={}", selectedMonth);

        return getDao().getMonthlyGenerationChart(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    @Override
    public List<DashboardChartDTO> getMonthlyCostChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getMonthlyCostChart() selectedMonth={}", selectedMonth);

        return getDao().getMonthlyCostChart(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    @Override
    public List<DashboardChartDTO> getTopDeviceGenerationChart(
            int memberId,
            String selectedMonth,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getTopDeviceGenerationChart() selectedMonth={}", selectedMonth);

        return getDao().getTopDeviceGenerationChart(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }
}