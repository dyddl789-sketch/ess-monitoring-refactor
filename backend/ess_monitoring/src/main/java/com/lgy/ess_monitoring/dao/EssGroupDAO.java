package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface EssGroupDAO {

    List<EssGroupDTO> getGroupList(int memberId);

    int insertGroup(EssGroupDTO group);

    int updateGroup(EssGroupDTO group);

    int deleteGroup(
            @Param("groupId") int groupId,
            @Param("memberId") int memberId
    );
}