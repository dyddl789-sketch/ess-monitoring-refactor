package com.lgy.ess_monitoring.service;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.BoardDAO;
import com.lgy.ess_monitoring.dto.BoardDTO;
import com.lgy.ess_monitoring.dto.Criteria;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class BoardServiceImpl implements BoardService {

    @Autowired
    private SqlSession sqlSession;

    private BoardDAO getDao() {
        return sqlSession.getMapper(BoardDAO.class);
    }

    @Override
    public List<BoardDTO> list() {
        return getDao().list();
    }

    @Override
    public List<BoardDTO> listWithPaging(Criteria criteria) {
        log.info("@# listWithPaging criteria => {}", criteria);
        return getDao().listWithPaging(criteria);
    }

    @Override
    public void write(HashMap<String, String> params) {
        getDao().write(params);
    }

    @Override
    public BoardDTO contentView(HashMap<String, String> params) {
        return getDao().contentView(params);
    }

    @Override
    public void modify(HashMap<String, String> params) {
        getDao().modify(params);
    }

    @Override
    public void delete(HashMap<String, String> params) {
        getDao().delete(params);
    }

    @Override
    public int getTotalCount(Criteria criteria) {
        return getDao().getTotalCount(criteria);
    }

    @Override
    public void increaseHit(int boardNo) {
        getDao().increaseHit(boardNo);
    }

    @Override
    public int getWriterMemberId(int boardNo) {
        return getDao().getWriterMemberId(boardNo);
    }

    @Override
    public List<BoardDTO> getRecentNoticeList() {
        return getDao().getRecentNoticeList();
    }
}