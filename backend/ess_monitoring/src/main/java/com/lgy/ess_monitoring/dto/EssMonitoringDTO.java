package com.lgy.ess_monitoring.dto;

import java.math.BigDecimal;
import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EssMonitoringDTO {

    private int monitorId;        // PK
    private int deviceId;         // 장비 ID (FK)

    private BigDecimal voltage;   // 전압 (V)
    private BigDecimal currentA;  // 전류 (A)
    private BigDecimal soc;       // 충전율 (%)
    private BigDecimal powerOutput; // 출력 전력 (kW)

    private Timestamp recordTime; // 측정 시간
    
}