package com.lgy.ess_monitoring.dto;

import lombok.Data;

/**
 * 대시보드 차트 DTO
 *
 * 역할:
 * - 메인 대시보드에서 사용하는 월간 통계 차트 데이터 전달
 * - energy_log 기반 집계 결과를 화면으로 전달
 *
 * 사용 위치:
 * - 최근 6개월 발전량 차트
 * - 최근 6개월 절감 금액 차트
 * - 장비별 월간 발전량 TOP5 차트
 */
@Data
public class DashboardChartDTO {

    /**
     * 차트 라벨
     * 예)
     * - 2026-01
     * - 2026-02
     * - 서울공장 ESS
     */
    private String label;

    /**
     * 월간 발전량
     * energy_log.daily_kwh를 월 단위로 SUM한 값
     */
    private Double monthlyKwh;

    /**
     * 월간 절감 금액
     * energy_log.cost를 월 단위로 SUM한 값
     */
    private Double savedCost;

    /**
     * 평균 효율
     * energy_log.efficiency를 월 단위로 AVG한 값
     */
    private Double efficiency;

    /**
     * 장비명
     * 장비별 TOP5 차트에서 사용
     */
    private String deviceName;

    /**
     * 그룹명
     * 장비별 TOP5 차트에서 보조 정보로 사용 가능
     */
    private String groupName;

    /**
     * 범용 차트 값
     * Chart.js에서 공통적으로 사용하기 위한 값
     */
    private Double value;
}