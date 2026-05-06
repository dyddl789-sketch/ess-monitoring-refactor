package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.GroupDAO;
import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;

@Service
public class GroupServiceImpl implements GroupService {

    @Autowired
    private SqlSession sqlSession;

    private GroupDAO getDao() {
        return sqlSession.getMapper(GroupDAO.class);
    }

    @Override
    public List<EssDeviceGroupDTO> getGroupList(int memberId) {
        return getDao().getGroupList(memberId);
    }

    @Override
    public int insertGroup(EssDeviceGroupDTO group) {
        return getDao().insertGroup(group);
    }

    @Override
    public int updateGroup(EssDeviceGroupDTO group) {
        return getDao().updateGroup(group);
    }

    @Override
    public int deleteGroup(int groupId, int memberId) {
        return getDao().deleteGroup(groupId, memberId);
    }
}
