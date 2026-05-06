package com.lgy.ess_monitoring.enums;

public enum DeviceStatus {
    NORMAL("정상", "status-normal"),
    WARNING("경고", "status-warning"),
    ERROR("에러", "status-danger"),
    OFFLINE("오프라인", "status-offline");

    private final String label;
    private final String cssClass;

    DeviceStatus(String label, String cssClass) {
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