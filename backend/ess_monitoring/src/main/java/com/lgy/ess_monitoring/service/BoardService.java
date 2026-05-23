package com.lgy.ess_monitoring.service;

import java.util.HashMap;
import java.util.List;

import com.lgy.ess_monitoring.dto.BoardDTO;
import com.lgy.ess_monitoring.dto.Criteria;

public interface BoardService {

    List<BoardDTO> list();

    List<BoardDTO> listWithPaging(Criteria criteria);

    void write(HashMap<String, String> params);

    BoardDTO contentView(HashMap<String, String> params);

    void modify(HashMap<String, String> params);

    void delete(HashMap<String, String> params);

    int getTotalCount(Criteria criteria);

    void increaseHit(int boardNo);

    int getWriterMemberId(int boardNo);

    List<BoardDTO> getRecentNoticeList();
}