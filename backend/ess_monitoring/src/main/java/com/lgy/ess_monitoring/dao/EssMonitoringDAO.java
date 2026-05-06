package com.lgy.ess_monitoring.dao;

import java.util.List;

import com.lgy.ess_monitoring.dto.EssMonitoringDTO;

public interface EssMonitoringDAO {

    // 회원 기준 모니터링 목록 조회
    List<EssMonitoringDTO> getMonitoringListByMemberId(int memberId);

    // 특정 디바이스 최신 데이터
    EssMonitoringDTO getLatestMonitoring(int deviceId);

    // (필요 시 유지)
    int getTotalCount();
    int getMemberCount(int memberId);
}