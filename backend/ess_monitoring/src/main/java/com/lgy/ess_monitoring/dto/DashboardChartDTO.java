package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 비교 차트 DTO
 */
@Data
public class DashboardChartDTO {

    // 시간 또는 장비명
    private String label;

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