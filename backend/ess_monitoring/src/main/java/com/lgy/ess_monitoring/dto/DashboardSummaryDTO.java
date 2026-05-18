package com.lgy.ess_monitoring.dto;

import lombok.Data;

@Data
public class DashboardSummaryDTO {

    private int totalDeviceCount;
    private int operatingDeviceCount;
    private int offlineDeviceCount;
    private int loggedDeviceCount;

    private Double monthlyGenerationKwh;
    private Double monthlySavedCost;
    private Double averageEfficiency;
}