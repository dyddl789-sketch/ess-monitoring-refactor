package com.lgy.ess_monitoring.dao;

import java.util.List;

import com.lgy.ess_monitoring.dto.EssMonitoringDTO;

public interface EssMonitoringDAO {

    // 회원 기준 모니터링 목록 조회
    List<EssMonitoringDTO> getMonitoringListByMemberId(int memberId);

    // 특정 디바이스 최신 데이터
    EssMonitoringDTO getLatestMonitoring(int deviceId);

    // 모니터링 데이터 저장
    void insertMonitoring(EssMonitoringDTO dto);

    // 전체 모니터링 수
    int getTotalCount();

    // 회원별 모니터링 수
    int getMemberCount(int memberId);
    
    // 최근 모니터링 이력 조회
    List<EssMonitoringDTO> getMonitoringHistory(int deviceId);
    
 // 오늘 누적 발전량 조회
    Double getTodayGeneration(int deviceId);
}