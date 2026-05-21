package com.lgy.ess_monitoring.dto;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class BoardDTO {

    private int boardNo;
    private int memberId;

    // NOTICE / QNA
    private String boardType;

    private String boardTitle;
    private int boardHit;
    private String boardContent;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // 작성자명
    private String memberName;
}