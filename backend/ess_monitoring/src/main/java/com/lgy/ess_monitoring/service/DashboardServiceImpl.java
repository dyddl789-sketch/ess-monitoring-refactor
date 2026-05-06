package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.DashboardDAO;
import com.lgy.ess_monitoring.dto.DashboardChartResponseDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class DashboardServiceImpl implements DashboardService {

    @Autowired
    private SqlSession sqlSession;

    // DAO 가져오기
    private DashboardDAO getDao() {
        return sqlSession.getMapper(DashboardDAO.class);
    }

    // 대시보드 요약 정보 조회
    @Override
    public DashboardSummaryDTO getDashboardSummary(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getDashboardSummary() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getDashboardSummary(memberId, selectedDate, groupId, deviceId);
    }

    // 대시보드 장비 상태 목록 조회
    @Override
    public List<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("getDashboardDeviceStatusList() memberId={}, selectedDate={}", memberId, selectedDate);

        return getDao().getDashboardDeviceStatusList(memberId, selectedDate, groupId, deviceId);
    }

    // 회원 기준 장비 그룹 목록 조회
    @Override
    public List<EssDeviceGroupDTO> getGroups(int memberId) {
        log.info("getGroups() memberId={}", memberId);

        return getDao().getGroups(memberId);
    }

    // 발전량 차트 조회
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

        // 장비를 직접 선택한 경우: 선택 장비 1개 기준
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

        // 그룹을 선택한 경우: 해당 그룹 안의 장비별 발전량
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

        // 기업 사용자: 그룹별 발전량
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

        // 개인 사용자: 장비별 발전량
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
}