package com.lgy.ess_monitoring.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BoardCommentDTO {

    // 댓글 번호
    private int commentId;

    // 게시글 번호
    private int boardNo;

    // 작성자 회원 번호
    private int memberId;

    // 작성자 이름
    private String memberName;

    // 댓글 내용
    private String commentContent;

    // 작성일
    private Timestamp createdAt;

    // 수정일
    private Timestamp updatedAt;
}