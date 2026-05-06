package com.lgy.ess_monitoring.enums;

public enum ControlResultStatus {
    SUCCESS("성공"),
    FAIL("실패"),
    PENDING("대기");

    private final String label;

    ControlResultStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}