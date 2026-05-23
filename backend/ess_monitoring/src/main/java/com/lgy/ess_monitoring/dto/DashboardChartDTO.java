package com.lgy.ess_monitoring.dto;

import lombok.Data;

@Data
public class DashboardChartDTO {

    private String label;

    private Double monthlyKwh;
    private Double savedCost;
    private Double efficiency;

    private Double dailyKwh;
    private Double cost;

    private String deviceName;
    private String groupName;

    private Double value;
}