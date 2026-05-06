package com.lgy.ess_monitoring.dto;

import java.util.List;

import lombok.Data;

/**
 * 대시보드 발전량 차트 응답 DTO
 */
@Data
public class DashboardChartResponseDTO {

    /** 차트 제목 */
    private String chartTitle;

    /** 차트 구분: GROUP / DEVICE */
    private String chartType;

    /** 화면 표시 개수 제한 */
    private int limitCount;

    /** 전체 항목 수 */
    private int totalItemCount;

    /** 차트 데이터 */
    private List<DashboardChartDTO> chartList;
}