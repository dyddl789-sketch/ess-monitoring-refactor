package com.lgy.ess_monitoring.controller;

import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.lgy.ess_monitoring.dto.BoardCommentDTO;
import com.lgy.ess_monitoring.dto.BoardDTO;
import com.lgy.ess_monitoring.dto.Criteria;
import com.lgy.ess_monitoring.dto.PageDTO;
import com.lgy.ess_monitoring.service.BoardCommentService;
import com.lgy.ess_monitoring.service.BoardService;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class BoardController {

    @Autowired
    private BoardService boardService;

    @Autowired
    private BoardCommentService boardCommentService;

    @RequestMapping("/board_list")
    public String boardList(Criteria criteria, Model model) {
        List<BoardDTO> boardList = boardService.listWithPaging(criteria);
        int totalCount = boardService.getTotalCount(criteria);

        model.addAttribute("list", boardList);
        model.addAttribute("pageMaker", new PageDTO(totalCount, criteria));

        return "board_list";
    }

    @RequestMapping("/board_write_view")
    public String boardWriteView() {
        return "board_write_view";
    }

    @RequestMapping("/board_write")
    public String boardWrite(@RequestParam HashMap<String, String> params,
                             HttpSession session) {

        // 기존 프로젝트에서 memberId를 쓰는 경우
        Integer memberId = (Integer) session.getAttribute("memberId");

        // 다른 화면에서 member_id로 저장된 경우까지 대비
        if (memberId == null) {
            memberId = (Integer) session.getAttribute("member_id");
        }

        if (memberId == null) {
            return "redirect:/login_view";
        }

        params.put("memberId", String.valueOf(memberId));
        boardService.write(params);

        return "redirect:/board_list";
    }

    @RequestMapping("/board_content_view")
    public String boardContentView(@RequestParam HashMap<String, String> params,
                                   Model model,
                                   HttpSession session) {

        int boardNo = Integer.parseInt(params.get("boardNo"));

        log.info("@# board_content_view()");
        log.info("@# boardNo => " + boardNo);

        // 1. 조회수 증가
        boardService.increaseHit(boardNo);

        // 2. 게시글 상세 조회
        BoardDTO boardDto = boardService.contentView(params);

        // 3. 로그인 회원 번호 가져오기
        Integer loginMemberId = (Integer) session.getAttribute("memberId");

        // 세션 이름이 member_id로 저장된 경우도 대비
        if (loginMemberId == null) {
            loginMemberId = (Integer) session.getAttribute("member_id");
        }

        // 4. 회원 유형 가져오기
        String userType = (String) session.getAttribute("userType");

        // 5. 권한 역할 가져오기
        // 관리자 여부는 userType이 아니라 role로 판단한다.
        String role = (String) session.getAttribute("role");

        log.info("@# loginMemberId => " + loginMemberId);
        log.info("@# userType => " + userType);
        log.info("@# role => " + role);
        // 세션 이름이 user_type으로 저장된 경우도 대비
        if (userType == null) {
            userType = (String) session.getAttribute("user_type");
        }

        log.info("@# loginMemberId => " + loginMemberId);
        log.info("@# userType => " + userType);

        // 6. 관리자 답변 목록 조회
        List<BoardCommentDTO> commentList = boardCommentService.getCommentList(boardNo);

        log.info("@# commentList size => " + commentList.size());

        // 7. JSP로 데이터 전달
        model.addAttribute("content_view", boardDto);
        model.addAttribute("pageMaker", params);
        model.addAttribute("loginMemberId", loginMemberId);

        // 댓글 목록
        model.addAttribute("commentList", commentList);

        // JSP에서 둘 다 대응 가능하게 전달
        model.addAttribute("userType", userType);
        model.addAttribute("user_type", userType);

        // 관리자 권한 전달
        model.addAttribute("role", role);

        return "board_content_view";
    }

    @RequestMapping("/modify")
    public String modify(@RequestParam HashMap<String, String> params,
                         @ModelAttribute("cri") Criteria criteria,
                         RedirectAttributes redirectAttributes,
                         HttpSession session) {

        Integer loginMemberId = (Integer) session.getAttribute("memberId");

        if (loginMemberId == null) {
            loginMemberId = (Integer) session.getAttribute("member_id");
        }

        if (loginMemberId == null) {
            return "redirect:/login_view";
        }

        int boardNo = Integer.parseInt(params.get("boardNo"));
        int writerMemberId = boardService.getWriterMemberId(boardNo);

        if (!loginMemberId.equals(writerMemberId)) {
            redirectAttributes.addAttribute("boardNo", boardNo);
            redirectAttributes.addAttribute("pageNum", criteria.getPageNum());
            redirectAttributes.addAttribute("amount", criteria.getAmount());
            redirectAttributes.addAttribute("type", criteria.getType());
            redirectAttributes.addAttribute("keyword", criteria.getKeyword());

            return "redirect:/board_content_view";
        }

        boardService.modify(params);

        redirectAttributes.addAttribute("pageNum", criteria.getPageNum());
        redirectAttributes.addAttribute("amount", criteria.getAmount());
        redirectAttributes.addAttribute("type", criteria.getType());
        redirectAttributes.addAttribute("keyword", criteria.getKeyword());

        return "redirect:/board_list";
    }

    @RequestMapping("/delete")
    public String delete(@RequestParam HashMap<String, String> params,
                         @ModelAttribute("cri") Criteria criteria,
                         RedirectAttributes redirectAttributes,
                         HttpSession session) {

        Integer loginMemberId = (Integer) session.getAttribute("memberId");

        if (loginMemberId == null) {
            loginMemberId = (Integer) session.getAttribute("member_id");
        }

        if (loginMemberId == null) {
            return "redirect:/login_view";
        }

        String boardNoText = params.get("boardNo");

        if (boardNoText == null || boardNoText.trim().isEmpty()) {
            throw new RuntimeException("boardNo 없음");
        }

        int boardNo = Integer.parseInt(boardNoText);
        int writerMemberId = boardService.getWriterMemberId(boardNo);

        if (!loginMemberId.equals(writerMemberId)) {
            redirectAttributes.addAttribute("boardNo", boardNo);
            redirectAttributes.addAttribute("pageNum", criteria.getPageNum());
            redirectAttributes.addAttribute("amount", criteria.getAmount());
            redirectAttributes.addAttribute("type", criteria.getType());
            redirectAttributes.addAttribute("keyword", criteria.getKeyword());

            return "redirect:/board_content_view";
        }

        boardService.delete(params);

        redirectAttributes.addAttribute("pageNum", criteria.getPageNum());
        redirectAttributes.addAttribute("amount", criteria.getAmount());
        redirectAttributes.addAttribute("type", criteria.getType());
        redirectAttributes.addAttribute("keyword", criteria.getKeyword());

        return "redirect:/board_list";
    }
}