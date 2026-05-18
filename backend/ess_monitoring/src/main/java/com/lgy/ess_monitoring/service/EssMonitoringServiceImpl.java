package com.lgy.ess_monitoring.service;

import java.util.List;
import java.time.LocalDate;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssMonitoringDAO;
import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.MonitoringSummaryDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EssMonitoringServiceImpl
        implements EssMonitoringService {

    @Autowired
    private SqlSession sqlSession;
    
    @Autowired
    private EnergyLogService energyLogService;

    // DAO 가져오기
    private EssMonitoringDAO getDao() {
        return sqlSession.getMapper(
                EssMonitoringDAO.class
        );
    }

    // 회원 기준 모니터링 목록 조회
    @Override
    public List<EssMonitoringDTO>
        getMonitoringListByMemberId(
                int memberId
    ) {

        log.info(
            "getMonitoringListByMemberId() memberId={}",
            memberId
        );

        return getDao()
            .getMonitoringListByMemberId(memberId);
    }

    // 특정 장비 최신 데이터
    @Override
    public EssMonitoringDTO getLatestMonitoring(
            int deviceId
    ) {

        log.info(
            "getLatestMonitoring() deviceId={}",
            deviceId
        );

        return getDao()
            .getLatestMonitoring(deviceId);
    }

    // 전체 데이터 수
    @Override
    public int getTotalCount() {

        log.info("getTotalCount()");

        return getDao().getTotalCount();
    }

    // 회원별 데이터 수
    @Override
    public int getMemberCount(int memberId) {

        log.info(
            "getMemberCount() memberId={}",
            memberId
        );

        return getDao().getMemberCount(memberId);
    }

    // 시간별 모니터링 이력
    @Override
    public List<EssMonitoringDTO>
        getMonitoringHistory(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    ) {

        log.info(
            "getMonitoringHistory() deviceId={}",
            deviceId
        );

        return getDao().getMonitoringHistory(
                memberId,
                deviceId,
                selectedDate
        );
    }

    // 오늘 누적 발전량
    @Override
    public Double getTodayGeneration(
            int deviceId
    ) {

        log.info(
            "getTodayGeneration() deviceId={}",
            deviceId
        );

        return getDao()
            .getTodayGeneration(deviceId);
    }

    // 그룹 목록
    @Override
    public List<EssGroupDTO> getGroups(
            Integer memberId
    ) {

        log.info(
            "getGroups() memberId={}",
            memberId
        );

        return getDao().getGroups(memberId);
    }

    // 그룹별 장비 목록
    @Override
    public List<EssDeviceDTO> getDevices(
            Integer memberId,
            Integer groupId
    ) {

        log.info(
            "getDevices() memberId={}, groupId={}",
            memberId,
            groupId
        );

        return getDao().getDevices(
                memberId,
                groupId
        );
    }

    // 상단 카드 요약
    @Override
    public MonitoringSummaryDTO
        getMonitoringSummary(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    ) {

        log.info(
            "getMonitoringSummary() deviceId={}",
            deviceId
        );

        return getDao().getMonitoringSummary(
                memberId,
                deviceId,
                selectedDate
        );
    }

    // 최근 7일 차트
    @Override
    public List<DashboardChartDTO>
        getWeeklyMonitoringChart(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    ) {

        log.info(
            "getWeeklyMonitoringChart() deviceId={}",
            deviceId
        );

        return getDao()
            .getWeeklyMonitoringChart(
                memberId,
                deviceId,
                selectedDate
        );
    }

    // 최근 알림
    @Override
    public List<AlertDTO>
        getMonitoringAlerts(
            Integer deviceId
    ) {

        log.info(
            "getMonitoringAlerts() deviceId={}",
            deviceId
        );

        return getDao()
            .getMonitoringAlerts(deviceId);
    }
    
    @Override
    public void insertMonitoring(EssMonitoringDTO dto) {

        log.info("insertMonitoring() deviceId={}", dto.getDeviceId());

        getDao().insertMonitoring(dto);

        energyLogService.aggregateDailyEnergyLog(
                dto.getDeviceId(),
                LocalDate.now().toString()
        );
    }
    
    @Override
    public MonitoringSummaryDTO getMonitoringSummaryFromEnergyLog(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    ) {
        log.info("getMonitoringSummaryFromEnergyLog() deviceId={}, selectedDate={}",
                deviceId,
                selectedDate
        );

        return getDao().getMonitoringSummaryFromEnergyLog(
                memberId,
                deviceId,
                selectedDate
        );
    }
    
    @Override
    public List<DashboardChartDTO> getHistoryFromEnergyLog(
            Integer memberId,
            Integer deviceId,
            String selectedDate
    ) {

        log.info("getHistoryFromEnergyLog() deviceId={}, selectedDate={}",
                deviceId,
                selectedDate
        );

        return getDao().getHistoryFromEnergyLog(
                memberId,
                deviceId,
                selectedDate
        );
    }
}