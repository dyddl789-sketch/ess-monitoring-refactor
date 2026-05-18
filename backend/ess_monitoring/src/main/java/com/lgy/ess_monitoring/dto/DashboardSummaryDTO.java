package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 요약 DTO
 *
 * 역할:
 * - 메인 대시보드 상단 요약 카드 데이터 전달
 * - selectedMonth 기준 월간 통계 표시
 *
 * 기준 테이블:
 * - ess_device
 * - energy_log
 */
@Data
public class DashboardSummaryDTO {

    /**
     * 전체 등록 장비 수
     */
    private int totalDeviceCount;

    /**
     * 운영 장비 수
     * status가 OFFLINE이 아닌 장비 수
     */
    private int operatingDeviceCount;

    /**
     * 오프라인 장비 수
     */
    private int offlineDeviceCount;

    /**
     * 선택 월에 energy_log 데이터가 존재하는 장비 수
     */
    private int loggedDeviceCount;

    /**
     * 선택 월 발전량 합계
     * energy_log.daily_kwh 월 단위 SUM
     */
    private Double monthlyGenerationKwh;

    /**
     * 선택 월 절감 금액 합계
     * energy_log.cost 월 단위 SUM
     */
    private Double monthlySavedCost;

    /**
     * 선택 월 평균 효율
     * energy_log.efficiency 월 단위 AVG
     */
    private Double averageEfficiency;
    
    private int deletedDeviceCount;
}