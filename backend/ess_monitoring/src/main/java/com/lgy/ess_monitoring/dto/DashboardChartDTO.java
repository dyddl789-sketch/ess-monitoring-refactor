package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 통계 차트 DTO
 */
@Data
public class DashboardChartDTO {

    // 공통 라벨
    // ex) 날짜, 월, 장비명
    private String label;

    // 일일 발전량
    private Double dailyKwh;

    // 월간 발전량
    private Double monthlyKwh;

    // 절감 금액
    private Double savedCost;

    // 평균 효율
    private Double efficiency;

    // 장비명
    private String deviceName;

    // 그룹명
    private String groupName;

    // 값 범용 처리용
    private Double value;

    // =========================
    // 기존 비교 차트 호환용
    // =========================

    // 선택일 발전량
    private Double selectedGeneration;

    // 이전일 발전량
    private Double previousGeneration;

    // 발전량 차이
    private Double generationDiff;

    // 선택일 SOC
    private Double selectedSoc;

    // 이전일 SOC
    private Double previousSoc;
}