package com.lgy.ess_monitoring.service;

import java.util.ArrayList;

import com.lgy.ess_monitoring.dto.BoardCommentDTO;

public interface BoardCommentService {
	
	public ArrayList<BoardCommentDTO> getCommentList(int board_no);

	public void insertComment(BoardCommentDTO dto);

	public void deleteComment(BoardCommentDTO dto);
	
	public void updateComment(BoardCommentDTO dto);
}
