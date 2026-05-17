package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.DashboardDAO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardChartResponseDTO;
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
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getDashboardSummary() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getDashboardSummary(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    @Override
    public List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getDashboardDeviceStatusList() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getDashboardDeviceStatusList(
                memberId,
                selectedDate,
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
    public DashboardChartResponseDTO getGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getGenerationChart() memberId={}, selectedDate={}", memberId, selectedDate);

        DashboardDAO dao = getDao();

        int limit = 6;
        String userType = dao.getUserType(memberId);

        DashboardChartResponseDTO response = new DashboardChartResponseDTO();
        response.setLimitCount(limit);

        if (deviceId != null) {
            response.setChartType("DEVICE");
            response.setChartTitle("선택 장비 발전량");
            response.setTotalItemCount(
                    dao.getDeviceGenerationChartCount(memberId, selectedDate, groupId, deviceId)
            );
            response.setChartList(
                    dao.getDeviceGenerationChart(memberId, selectedDate, groupId, deviceId, limit)
            );
            return response;
        }

        if (groupId != null) {
            response.setChartType("DEVICE");
            response.setChartTitle("선택 그룹 내 장비별 발전량");
            response.setTotalItemCount(
                    dao.getDeviceGenerationChartCount(memberId, selectedDate, groupId, null)
            );
            response.setChartList(
                    dao.getDeviceGenerationChart(memberId, selectedDate, groupId, null, limit)
            );
            return response;
        }

        if ("COMPANY".equals(userType)) {
            response.setChartType("GROUP");
            response.setChartTitle("그룹별 선택일 발전량");
            response.setTotalItemCount(
                    dao.getGroupGenerationChartCount(memberId, selectedDate, null)
            );
            response.setChartList(
                    dao.getGroupGenerationChart(memberId, selectedDate, null, limit)
            );
            return response;
        }

        response.setChartType("DEVICE");
        response.setChartTitle("장비별 선택일 발전량");
        response.setTotalItemCount(
                dao.getDeviceGenerationChartCount(memberId, selectedDate, null, null)
        );
        response.setChartList(
                dao.getDeviceGenerationChart(memberId, selectedDate, null, null, limit)
        );

        return response;
    }

    @Override
    public List<DashboardChartDTO> getHourlyCompareChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        return getDao().getHourlyCompareChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    @Override
    public List<DashboardChartDTO> getDeviceCompareChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        return getDao().getDeviceCompareChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    @Override
    public List<DashboardChartDTO> getWeeklyGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getWeeklyGenerationChart() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getWeeklyGenerationChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    @Override
    public List<DashboardChartDTO> getMonthlyGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getMonthlyGenerationChart() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getMonthlyGenerationChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    @Override
    public List<DashboardChartDTO> getTopDeviceGenerationChart(
            int memberId,
            String selectedDate,
            Integer groupId
    ) {
        log.info("getTopDeviceGenerationChart() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getTopDeviceGenerationChart(
                memberId,
                selectedDate,
                groupId
        );
    }
}