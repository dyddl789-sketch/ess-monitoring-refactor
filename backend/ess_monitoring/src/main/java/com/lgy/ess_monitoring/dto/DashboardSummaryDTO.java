package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 요약 정보 DTO
 */
@Data
public class DashboardSummaryDTO {

    // 전체 장비 수
    private int totalDeviceCount;

    // 운영 장비 수
    private int activeDeviceCount;

    // 오프라인 장비 수
    private int offlineDeviceCount;

    // 데이터 수집 장비 수
    private int collectedDeviceCount;

    // =========================
    // energy_log 기준 통계
    // =========================

    // 선택일 발전량
    private Double todayGenerationKwh;

    // 월간 발전량
    private Double monthlyGenerationKwh;

    // 평균 효율
    private Double averageEfficiency;

    // 평균 SOC (기존 호환)
    private Double averageSoc;

    // 절감 금액
    private Double todaySavedCost;

    // 월간 절감 금액
    private Double monthlySavedCost;
}