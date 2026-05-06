package com.lgy.ess_monitoring.dto;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class EssDeviceDTO {

    // ===== ess_device 기본 =====
    private int deviceId;
    private int memberId;
    private Integer groupId;

    private String deviceName;
    private String location;
    private double capacityKw;

    private String deviceType;
    private String status;
    private String installDate;

    private BigDecimal latitude;
    private BigDecimal longitude;
    private Integer nx;
    private Integer ny;

    private String isMain;

    // ===== ESS 스펙 =====
    private double essCapacityKwh;
    private Double currentChargeKwh;
    private double chargeEfficiency;
    private double dischargeEfficiency;
    private double electricityRate;

    // ===== JOIN =====
    private String groupName;
    private Double soc;
    private String recordTime;
}