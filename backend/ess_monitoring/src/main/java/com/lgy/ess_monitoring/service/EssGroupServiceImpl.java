package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssGroupDAO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

@Service
public class EssGroupServiceImpl implements EssGroupService {

    @Autowired
    private SqlSession sqlSession;

    private EssGroupDAO getDao() {
        return sqlSession.getMapper(EssGroupDAO.class);
    }

    @Override
    public List<EssGroupDTO> getGroupList(int memberId) {
        return getDao().getGroupList(memberId);
    }

    @Override
    public int insertGroup(EssGroupDTO group) {
        return getDao().insertGroup(group);
    }

    @Override
    public int updateGroup(EssGroupDTO group) {
        return getDao().updateGroup(group);
    }

    @Override
    public int deleteGroup(int groupId, int memberId) {
        return getDao().deleteGroup(groupId, memberId);
    }
}
