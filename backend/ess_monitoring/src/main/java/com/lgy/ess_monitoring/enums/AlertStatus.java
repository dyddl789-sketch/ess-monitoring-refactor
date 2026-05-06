package com.lgy.ess_monitoring.enums;

public enum AlertStatus {
    UNCHECKED("미확인"),
    CHECKED("확인"),
    RESOLVED("처리완료");

    private final String label;

    AlertStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}