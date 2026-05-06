package com.lgy.ess_monitoring.service;

import java.util.ArrayList;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.BoardCommentDAO;
import com.lgy.ess_monitoring.dto.BoardCommentDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class BoardCommentServiceImpl implements BoardCommentService{

	@Autowired
	private SqlSession sqlSession;
	
	//댓글 목록 조회
	@Override
	public ArrayList<BoardCommentDTO> getCommentList(int board_no) {
		log.info("@# getCommentList()");
		log.info("@# board_no=>" + board_no);
		
        // MyBatis가 BoardCommentDAO 인터페이스와 Mapper XML을 연결해준다.
		BoardCommentDAO dao = sqlSession.getMapper(BoardCommentDAO.class);
		// 특정 게시글에 달린 댓글 목록을 DB에서 조회한다.
		return dao.getCommentList(board_no);
	}

	//관리자 댓글 등록
	@Override
	public void insertComment(BoardCommentDTO dto) {
		log.info("@# insertComment()");
        log.info("@# dto => " + dto);

        // MyBatis Mapper 객체 가져오기
        BoardCommentDAO dao = sqlSession.getMapper(BoardCommentDAO.class);

        // 댓글 등록 SQL 실행
        dao.insertComment(dto);
	}

	//댓글 삭제
	@Override
	public void deleteComment(BoardCommentDTO dto) {
		log.info("@# deleteComment()");
        log.info("@# dto => " + dto);

        // MyBatis Mapper 객체 가져오기
        BoardCommentDAO dao = sqlSession.getMapper(BoardCommentDAO.class);

        // 댓글 삭제 SQL 실행
        dao.deleteComment(dto);
	}

	@Override
	public void updateComment(BoardCommentDTO dto) {
		log.info("@# updateComment()");
	    log.info("@# dto => " + dto);

	    // MyBatis Mapper 객체 가져오기
	    BoardCommentDAO dao = sqlSession.getMapper(BoardCommentDAO.class);

	    // 댓글 수정 SQL 실행
	    dao.updateComment(dto);		
	}
	
	
}
