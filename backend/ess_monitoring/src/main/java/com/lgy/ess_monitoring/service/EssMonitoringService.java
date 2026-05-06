package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.EssMonitoringDTO;

public interface EssMonitoringService {

    // 회원 기준 모니터링 목록 조회
    List<EssMonitoringDTO> getMonitoringListByMemberId(int memberId);

    // 특정 디바이스 최신 데이터
    EssMonitoringDTO getLatestMonitoring(int deviceId);

    // 전체 모니터링 데이터 수
    int getTotalCount();

    // 회원별 모니터링 데이터 수
    int getMemberCount(int memberId);
}