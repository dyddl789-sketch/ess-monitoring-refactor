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

    @Override
    public void join(HashMap<String, String> params) {
        EssMemberDAO memberDao = sqlSession.getMapper(EssMemberDAO.class);
        memberDao.join(params);
    }

    @Override
    public EssMemberDTO login(HashMap<String, String> params) {
        EssMemberDAO memberDao = sqlSession.getMapper(EssMemberDAO.class);
        return memberDao.login(params);
    }

    @Override
    public int idCheck(String memberUserid) {
        EssMemberDAO memberDao = sqlSession.getMapper(EssMemberDAO.class);
        return memberDao.idCheck(memberUserid);
    }

    @Override
    public int emailCheck(String email) {
        EssMemberDAO memberDao = sqlSession.getMapper(EssMemberDAO.class);
        return memberDao.emailCheck(email);
    }
}