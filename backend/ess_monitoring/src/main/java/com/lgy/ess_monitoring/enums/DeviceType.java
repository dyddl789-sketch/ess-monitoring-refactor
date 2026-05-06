package com.lgy.ess_monitoring.enums;

public enum DeviceType {
    HYBRID("태양광+ESS"),
    SOLAR("태양광"),
    ESS("ESS");

    private final String label;

    DeviceType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}