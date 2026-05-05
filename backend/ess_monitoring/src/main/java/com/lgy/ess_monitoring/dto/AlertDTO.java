package com.lgy.ess_monitoring.dto;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class AlertDTO {

    private int alertId;
    private int deviceId;

    private String deviceName;

    private String alertType;
    private String alertLevel;
    private String message;
    private String status;
    private String controlAction;

    private Timestamp createdAt;
}