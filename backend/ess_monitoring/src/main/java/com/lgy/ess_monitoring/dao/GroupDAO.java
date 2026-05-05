package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;

public interface GroupDAO {

    List<EssDeviceGroupDTO> getGroupList(int memberId);

    int insertGroup(EssDeviceGroupDTO group);

    int updateGroup(EssDeviceGroupDTO group);

    int deleteGroup(
            @Param("groupId") int groupId,
            @Param("memberId") int memberId
    );
}