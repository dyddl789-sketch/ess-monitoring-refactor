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

    // ===============================
    // 기본 정보
    // ===============================
    private int monitorId;
    private int deviceId;

    // ===============================
    // 전기 데이터
    // ===============================
    private BigDecimal voltage;           // 전압(V)
    private BigDecimal currentA;          // 전류(A)

    private BigDecimal soc;               // SOC(%)

    private BigDecimal powerOutput;       // 출력 전력(kW)

    // ===============================
    // 발전 / 충전 / 사용
    // ===============================
    private BigDecimal solarGenerationKwh; // 태양광 발전량
    private BigDecimal chargedEnergyKwh;   // 충전량
    private BigDecimal usedEnergyKwh;      // 사용량

    // ===============================
    // 절감 금액
    // ===============================
    private BigDecimal savedCost;

    // ===============================
    // 시간
    // ===============================
    private Timestamp recordTime;

    // ===============================
    // JOIN용
    // ===============================
    private String deviceName;
    private String location;
    private String groupName;

    // ===============================
    // 날씨 정보 JOIN용
    // ===============================
    private String skyStatus;
    private String rainType;
    private BigDecimal temperature;

    // ===============================
    // 상태 표시용
    // ===============================
    private String deviceStatus;
    private String alertStatus;
}