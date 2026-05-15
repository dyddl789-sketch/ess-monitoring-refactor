package com.lgy.ess_monitoring.service;

import java.util.HashMap;

import com.lgy.ess_monitoring.dto.EssMemberDTO;

public interface EssMemberService {

    // 회원가입
    void join(HashMap<String, String> params);

    // 로그인
//    EssMemberDTO login(HashMap<String, String> params);
    
    // 아이디로 회원 조회
    EssMemberDTO findByUserid(String memberUserid);

    // 아이디 중복 체크
    int idCheck(String memberUserid);

    // 이메일 중복 체크
    int emailCheck(String email);

    // 회원 정보 조회
    EssMemberDTO getMemberInfo(int memberId);

    // 회원 정보 수정
    int updateMemberInfo(EssMemberDTO member);

    // 비밀번호 변경
    int updatePassword(HashMap<String, String> params);
}