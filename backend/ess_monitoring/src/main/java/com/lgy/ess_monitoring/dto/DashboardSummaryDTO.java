package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 요약 정보 DTO
 * - 선택 날짜 기준 통계
 */
@Data
public class DashboardSummaryDTO {

    /** 전체 장비 수 */
    private int totalDeviceCount;

    /** 선택일 데이터 수집 장비 수 */
    private int collectedDeviceCount;

    /** 선택일 미수집 장비 수 */
    private int uncollectedDeviceCount;

    /** 선택일 오프라인 장비 수 (SOC = 0) */
    private int offlineDeviceCount;

    /** 선택일 예상 발전량 합계 (kWh) */
    private Double todayGenerationKwh;

    /** 선택일 평균 SOC (%) */
    private Double averageSoc;

    /** 선택일 예상 절감 금액 (원) */
    private Double todaySavedCost;
}