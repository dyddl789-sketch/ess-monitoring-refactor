package com.lgy.ess_monitoring.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lgy.ess_monitoring.dto.BoardCommentDTO;
import com.lgy.ess_monitoring.service.BoardCommentService;

import lombok.extern.slf4j.Slf4j;

/**
 * 문의게시판 댓글 Controller
 *
 * 역할:
 * - 문의게시판 상세 페이지에서 관리자 답변 등록, 수정, 삭제 요청을 처리한다.
 * - 일반 회원은 댓글을 작성/수정/삭제할 수 없고, 사이트 관리자만 가능하게 제한한다.
 */
@Controller
@Slf4j
public class BoardCommentController {

    /**
     * 문의게시판 댓글 Service
     *
     * 역할:
     * - 댓글 등록 / 수정 / 삭제 기능을 Service 계층으로 위임한다.
     */
    @Autowired
    private BoardCommentService commentService;

    /**
     * 로그인 회원 ID 조회
     *
     * 프로젝트 내 세션명이 memberId / member_id로 섞여 있을 수 있으므로
     * 두 가지 이름을 모두 확인한다.
     */
    private Integer getLoginMemberId(HttpSession session) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            memberId = (Integer) session.getAttribute("member_id");
        }

        return memberId;
    }

    /**
     * 세션 문자열 값 조회
     *
     * 예:
     * getSessionText(session, "userType", "user_type")
     */
    private String getSessionText(HttpSession session, String camelName, String snakeName) {
        String value = (String) session.getAttribute(camelName);

        if (value == null) {
            value = (String) session.getAttribute(snakeName);
        }

        return value;
    }

    /**
     * 관리자 댓글 등록
     *
     * 요청 URL:
     * - /comment_write
     *
     * Ajax 전송 데이터:
     * - boardNo
     * - commentContent
     */
    @ResponseBody
    @RequestMapping("/comment_write")
    public String commentWrite(@RequestParam("boardNo") int boardNo,
                               @RequestParam("commentContent") String commentContent,
                               HttpSession session) {

        log.info("@# comment_write()");
        log.info("@# boardNo => " + boardNo);
        log.info("@# commentContent => " + commentContent);

        // 로그인 회원 번호 조회
        Integer memberId = getLoginMemberId(session);

        // 회원 유형 조회
        String userType = getSessionText(session, "userType", "user_type");

        // 관리자 권한 조회
        String role = (String) session.getAttribute("role");

        log.info("@# memberId => " + memberId);
        log.info("@# userType => " + userType);
        log.info("@# role => " + role);

        // 1. 로그인 여부 체크
        if (memberId == null) {
            log.info("@# 댓글 등록 실패: 로그인 필요");
            return "login_required";
        }

        // 2. 관리자 여부 체크
        // DB 구조상 관리자 판별은 userType이 아니라 role로 한다.
        if (!"ADMIN".equals(role)) {
            log.info("@# 댓글 작성 실패: 관리자 권한 없음");
            return "forbidden";
        }

        // 3. 댓글 내용 빈 값 체크
        if (commentContent == null || commentContent.trim().equals("")) {
            log.info("@# 댓글 등록 실패: 댓글 내용 없음");
            return "empty";
        }

        // 4. 댓글 DTO 생성
        BoardCommentDTO dto = new BoardCommentDTO();
        dto.setBoardNo(boardNo);
        dto.setMemberId(memberId);
        dto.setCommentContent(commentContent.trim());

        log.info("@# insert comment dto => " + dto);

        // 5. 댓글 등록 처리
        commentService.insertComment(dto);

        log.info("@# 댓글 등록 성공");

        return "success";
    }

    /**
     * 관리자 댓글 수정
     *
     * 요청 URL:
     * - /comment_modify
     *
     * Ajax 전송 데이터:
     * - commentId
     * - commentContent
     */
    @ResponseBody
    @RequestMapping("/comment_modify")
    public String commentModify(@RequestParam("commentId") int commentId,
                                @RequestParam("commentContent") String commentContent,
                                HttpSession session) {

        log.info("@# comment_modify()");
        log.info("@# commentId => " + commentId);
        log.info("@# commentContent => " + commentContent);

        // 로그인 회원 번호 조회
        Integer memberId = getLoginMemberId(session);

        // 관리자 권한 조회
        String role = (String) session.getAttribute("role");

        log.info("@# memberId => " + memberId);
        log.info("@# role => " + role);

        // 1. 로그인 여부 체크
        if (memberId == null) {
            log.info("@# 댓글 수정 실패: 로그인 필요");
            return "login_required";
        }

        // 2. 관리자 여부 체크
        if (!"ADMIN".equals(role)) {
            log.info("@# 댓글 수정 실패: 관리자 권한 없음");
            return "forbidden";
        }

        // 3. 댓글 내용 빈 값 체크
        if (commentContent == null || commentContent.trim().equals("")) {
            log.info("@# 댓글 수정 실패: 댓글 내용 없음");
            return "empty";
        }

        // 4. 수정할 댓글 DTO 생성
        BoardCommentDTO dto = new BoardCommentDTO();
        dto.setCommentId(commentId);
        dto.setCommentContent(commentContent.trim());

        log.info("@# update comment dto => " + dto);

        // 5. 댓글 수정 처리
        commentService.updateComment(dto);

        log.info("@# 댓글 수정 성공");

        return "success";
    }

    /**
     * 관리자 댓글 삭제
     *
     * 요청 URL:
     * - /comment_delete
     *
     * Ajax 전송 데이터:
     * - commentId
     */
    @ResponseBody
    @RequestMapping("/comment_delete")
    public String commentDelete(@RequestParam("commentId") int commentId,
                                HttpSession session) {

        log.info("@# comment_delete()");
        log.info("@# commentId => " + commentId);

        // 로그인 회원 번호 조회
        Integer memberId = getLoginMemberId(session);

        // 관리자 권한 조회
        String role = (String) session.getAttribute("role");

        log.info("@# memberId => " + memberId);
        log.info("@# role => " + role);

        // 1. 로그인 여부 체크
        if (memberId == null) {
            log.info("@# 댓글 삭제 실패: 로그인 필요");
            return "login_required";
        }

        // 2. 관리자 여부 체크
        if (!"ADMIN".equals(role)) {
            log.info("@# 댓글 삭제 실패: 관리자 권한 없음");
            return "forbidden";
        }

        // 3. 삭제할 댓글 DTO 생성
        BoardCommentDTO dto = new BoardCommentDTO();
        dto.setCommentId(commentId);

        log.info("@# delete comment dto => " + dto);

        // 4. 댓글 삭제 처리
        commentService.deleteComment(dto);

        log.info("@# 댓글 삭제 성공");

        return "success";
    }
}