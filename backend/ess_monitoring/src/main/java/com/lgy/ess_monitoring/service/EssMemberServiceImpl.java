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

    // DAO 객체 반환
    private EssMemberDAO getDao() {
        return sqlSession.getMapper(EssMemberDAO.class);
    }

    // 회원가입
    @Override
    public void join(HashMap<String, String> params) {

        getDao().join(params);
    }

    // 로그인
//    @Override
//    public EssMemberDTO login(HashMap<String, String> params) {
//
//        return getDao().login(params);
//    }
    
    // 아이디로 회원 조회 로그인
    @Override
    public EssMemberDTO findByUserid(String memberUserid) {

        return getDao().findByUserid(memberUserid);
    }
    
    // 아이디 중복 체크
    @Override
    public int idCheck(String memberUserid) {

        return getDao().idCheck(memberUserid);
    }

    // 이메일 중복 체크
    @Override
    public int emailCheck(String email) {

        return getDao().emailCheck(email);
    }

    // 회원 정보 조회
    @Override
    public EssMemberDTO getMemberInfo(int memberId) {

        return getDao().getMemberInfo(memberId);
    }

    // 회원 정보 수정
    @Override
    public int updateMemberInfo(EssMemberDTO member) {

        return getDao().updateMemberInfo(member);
    }

    // 비밀번호 변경
    @Override
    public int updatePassword(HashMap<String, String> params) {

        return getDao().updatePassword(params);
    }
}