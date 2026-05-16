package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface EssGroupService {

    List<EssGroupDTO> getGroupList(int memberId);

    int insertGroup(EssGroupDTO group);

    int updateGroup(EssGroupDTO group);

    int deleteGroup(int groupId, int memberId);
}
