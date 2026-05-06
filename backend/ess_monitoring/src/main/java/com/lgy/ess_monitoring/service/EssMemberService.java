package com.lgy.ess_monitoring.service;

import java.util.HashMap;

import com.lgy.ess_monitoring.dto.EssMemberDTO;

public interface EssMemberService {

    // 회원가입
    void join(HashMap<String, String> params);

    // 로그인
    EssMemberDTO login(HashMap<String, String> params);

    // 아이디 중복 체크
    int idCheck(String memberUserid);

    // 이메일 중복 체크
    int emailCheck(String email);
}