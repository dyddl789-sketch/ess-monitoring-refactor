package com.lgy.ess_monitoring.dto;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class EssDeviceGroupDTO {

    private int groupId;
    private int memberId;

    private String groupName;
    private String description;

    private Timestamp createdAt;

    // 그룹별 장비 수
    private int deviceCount;
}