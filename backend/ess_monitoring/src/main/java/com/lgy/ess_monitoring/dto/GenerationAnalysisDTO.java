package com.lgy.ess_monitoring.dto;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class GenerationAnalysisDTO {

    private String label;              // 날짜 또는 장비명
    private BigDecimal generationKwh;  // 발전량
    private BigDecimal chargedKwh;     // 충전량
    private BigDecimal usedKwh;        // 사용량
    private BigDecimal savedCost;      // 절감 금액
}