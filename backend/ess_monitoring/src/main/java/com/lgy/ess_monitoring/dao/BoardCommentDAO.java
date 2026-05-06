package com.lgy.ess_monitoring.dao;

import java.util.ArrayList;

import com.lgy.ess_monitoring.dto.BoardCommentDTO;

/**
 * 문의게시판 댓글 DAO
 * 
 * MyBatis Mapper XML과 연결되는 인터페이스
 * 메서드 이름은 BoardCommentMapper.xml의 id와 반드시 일치해야 한다.
 */
public interface BoardCommentDAO {
	// 특정 게시글의 댓글 목록 조회
	// @param board_no 댓글을 조회할 게시글 번호
	// @return 해당 게시글의 댓글 목록
    public ArrayList<BoardCommentDTO> getCommentList(int board_no);

    // 관리자 댓글 등록
    // @param dto 댓글 정보
    public void insertComment(BoardCommentDTO dto);


    // 댓글 삭제
    // @param dto 삭제할 댓글 정보
    public void deleteComment(BoardCommentDTO dto);
    
    // 댓글 수정
    public void updateComment(BoardCommentDTO dto);

    

}
