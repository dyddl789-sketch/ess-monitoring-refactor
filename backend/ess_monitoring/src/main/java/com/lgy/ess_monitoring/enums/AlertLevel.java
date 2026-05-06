package com.lgy.ess_monitoring.enums;

public enum AlertLevel {
    INFO("정보", "badge-info"),
    WARNING("경고", "badge-warning"),
    CRITICAL("위험", "badge-critical");

    private final String label;
    private final String cssClass;

    AlertLevel(String label, String cssClass) {
        this.label = label;
        this.cssClass = cssClass;
    }

    public String getLabel() {
        return label;
    }

    public String getCssClass() {
        return cssClass;
    }
}