package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssMonitoringDAO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EssMonitoringServiceImpl implements EssMonitoringService {

    @Autowired
    private SqlSession sqlSession;

    // DAO 가져오기
    private EssMonitoringDAO getDao() {
        return sqlSession.getMapper(EssMonitoringDAO.class);
    }

    // 회원 기준 모니터링 목록 조회
    @Override
    public List<EssMonitoringDTO> getMonitoringListByMemberId(int memberId) {

        log.info("getMonitoringListByMemberId() memberId={}", memberId);

        List<EssMonitoringDTO> list =
                getDao().getMonitoringListByMemberId(memberId);

        log.info("monitoring list size={}", list.size());

        return list;
    }

    // 최신 모니터링 데이터 조회
    @Override
    public EssMonitoringDTO getLatestMonitoring(int deviceId) {

        log.info("getLatestMonitoring() deviceId={}", deviceId);

        EssMonitoringDTO dto =
                getDao().getLatestMonitoring(deviceId);

        log.info("latest monitoring dto={}", dto);

        return dto;
    }

    // 전체 모니터링 데이터 수
    @Override
    public int getTotalCount() {

        log.info("getTotalCount()");

        return getDao().getTotalCount();
    }

    // 회원별 모니터링 데이터 수
    @Override
    public int getMemberCount(int memberId) {

        log.info("getMemberCount() memberId={}", memberId);

        return getDao().getMemberCount(memberId);
    }

    // 최근 모니터링 이력 조회
    @Override
    public List<EssMonitoringDTO> getMonitoringHistory(int deviceId) {

        log.info("getMonitoringHistory() deviceId={}", deviceId);

        return getDao().getMonitoringHistory(deviceId);
    }
    
 // 오늘 누적 발전량 조회
    @Override
    public Double getTodayGeneration(int deviceId) {
        log.info("getTodayGeneration() deviceId={}", deviceId);

        return getDao().getTodayGeneration(deviceId);
    }
}