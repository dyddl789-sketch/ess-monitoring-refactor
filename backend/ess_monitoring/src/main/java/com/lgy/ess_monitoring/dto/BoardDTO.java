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
    private String boardTitle;
    private int boardHit;
    private String boardContent;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // ess_member 조인용
    private String memberName;
}