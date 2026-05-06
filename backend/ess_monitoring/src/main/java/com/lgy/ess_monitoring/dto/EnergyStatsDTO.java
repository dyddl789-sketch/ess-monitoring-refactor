package com.lgy.ess_monitoring.dto;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class EnergyStatsDTO {

    private String label;

    private BigDecimal dailyKwh;
    private BigDecimal monthlyKwh;
    private BigDecimal cost;
    private BigDecimal efficiency;
}
