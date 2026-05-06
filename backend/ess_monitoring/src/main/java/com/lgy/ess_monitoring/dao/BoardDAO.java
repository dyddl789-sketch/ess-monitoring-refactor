package com.lgy.ess_monitoring.dao;

import java.util.HashMap;
import java.util.List;

import com.lgy.ess_monitoring.dto.BoardDTO;
import com.lgy.ess_monitoring.dto.Criteria;

public interface BoardDAO {

    List<BoardDTO> list(); // 전체 목록

    List<BoardDTO> listWithPaging(Criteria criteria); // 페이징 목록

    void write(HashMap<String, String> params); // 글쓰기

    BoardDTO contentView(HashMap<String, String> params); // 상세보기

    void modify(HashMap<String, String> params); // 수정

    void delete(HashMap<String, String> params); // 삭제

    int getTotalCount(Criteria criteria); // 전체 게시글 수

    void increaseHit(int boardNo); // 조회수 증가

    int getWriterMemberId(int boardNo); // 게시글 작성자 회원번호 조회
}