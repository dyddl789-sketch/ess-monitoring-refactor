package com.lgy.ess_monitoring.service;

import java.util.HashMap;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssMemberDAO;
import com.lgy.ess_monitoring.dto.EssMemberDTO;

@Service
public class EssMemberServiceImpl implements EssMemberService {

    @Autowired
    private SqlSession sqlSession;

    private EssMemberDAO getDao() {
        return sqlSession.getMapper(EssMemberDAO.class);
    }

    @Override
    public void join(HashMap<String, String> params) {
        getDao().join(params);
    }

    @Override
    public EssMemberDTO login(HashMap<String, String> params) {
        return getDao().login(params);
    }

    @Override
    public int idCheck(String memberUserid) {
        return getDao().idCheck(memberUserid);
    }

    @Override
    public int emailCheck(String email) {
        return getDao().emailCheck(email);
    }

    @Override
    public EssMemberDTO getMemberInfo(int memberId) {
        return getDao().getMemberInfo(memberId);
    }

    @Override
    public int updateMemberInfo(EssMemberDTO member) {
        return getDao().updateMemberInfo(member);
    }
}