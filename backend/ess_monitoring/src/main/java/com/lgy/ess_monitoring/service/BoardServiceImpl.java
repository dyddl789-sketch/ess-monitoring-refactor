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

    @Override
    public List<BoardDTO> list() {
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        List<BoardDTO> boardList = boardDao.list();

        return boardList;
    }

    @Override
    public List<BoardDTO> listWithPaging(Criteria criteria) {
        log.info("@# criteria => " + criteria);

        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        return boardDao.listWithPaging(criteria);
    }

    @Override
    public void write(HashMap<String, String> params) {
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        boardDao.write(params);
    }

    @Override
    public BoardDTO contentView(HashMap<String, String> params) {
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        BoardDTO boardDto = boardDao.contentView(params);

        return boardDto;
    }

    @Override
    public void modify(HashMap<String, String> params) {
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        boardDao.modify(params);
    }

    @Override
    public void delete(HashMap<String, String> params) {
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        boardDao.delete(params);
    }

    @Override
    public int getTotalCount(Criteria criteria) {
        log.info("@# getTotalCount()");
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        return boardDao.getTotalCount(criteria);
    }

    @Override
    public void increaseHit(int boardNo) {
        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        boardDao.increaseHit(boardNo);
    }

    @Override
    public int getWriterMemberId(int boardNo) {
        log.info("@# getWriterMemberId()");

        BoardDAO boardDao = sqlSession.getMapper(BoardDAO.class);
        return boardDao.getWriterMemberId(boardNo);
    }
}