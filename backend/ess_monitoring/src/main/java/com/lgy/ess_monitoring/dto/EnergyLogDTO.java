package com.lgy.ess_monitoring.dto;

import java.sql.Date;

import lombok.Data;

@Data
public class EnergyLogDTO {

    private int logId;
    private int deviceId;

    private Double dailyKwh;
    private Double cost;
    private Double efficiency;

    private Date logDate;

    private String deviceName;
    private String groupName;
}