package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;

public interface GroupService {

    List<EssDeviceGroupDTO> getGroupList(int memberId);

    int insertGroup(EssDeviceGroupDTO group);

    int updateGroup(EssDeviceGroupDTO group);

    int deleteGroup(int groupId, int memberId);
}
