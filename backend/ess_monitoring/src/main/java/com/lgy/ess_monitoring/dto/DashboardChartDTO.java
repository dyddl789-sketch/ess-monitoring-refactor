package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 발전량 차트 항목 DTO
 */
@Data
public class DashboardChartDTO {

    /** 그룹명 또는 장비명 */
    private String label;

    /** 선택일 발전량 합계 */
    private Double generation;
}