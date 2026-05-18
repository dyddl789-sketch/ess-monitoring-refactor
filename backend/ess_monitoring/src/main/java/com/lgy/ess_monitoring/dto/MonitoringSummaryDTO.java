package com.lgy.ess_monitoring.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class MonitoringSummaryDTO {

    // 장비 상태
    private String deviceStatus;

    // 최신 SOC
    private Double soc;

    // 최신 출력
    private Double powerOutput;

    // 최신 전압
    private Double voltage;

    // 최신 전류
    private Double currentA;

    // 선택일 발전량
    private Double dailyKwh;

    // 선택일 절감 금액
    private Double savedCost;

    // 최신 측정 시간
    private LocalDateTime recordTime;

    // 최근 7일 발전량 평균
    private Double generationSevenDayAvg;

    // 최근 7일 절감 금액 평균
    private Double costSevenDayAvg;
}
