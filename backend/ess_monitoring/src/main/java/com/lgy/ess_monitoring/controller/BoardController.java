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

    private Integer getLoginMemberId(HttpSession session) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            memberId = (Integer) session.getAttribute("member_id");
        }

        return memberId;
    }

    private String getRole(HttpSession session) {
        return (String) session.getAttribute("role");
    }

    private void setBoardPageModel(Model model, Criteria criteria) {
        List<BoardDTO> boardList = boardService.listWithPaging(criteria);
        int totalCount = boardService.getTotalCount(criteria);

        model.addAttribute("list", boardList);
        model.addAttribute("pageMaker", new PageDTO(totalCount, criteria));
        model.addAttribute("boardType", criteria.getBoardType());
    }

    @RequestMapping("/board_list")
    public String boardList(Criteria criteria, Model model) {
        // boardType이 비어 있으면 전체 조회
        if (criteria.getBoardType() != null
                && criteria.getBoardType().trim().equals("")) {
            criteria.setBoardType(null);
        }

        setBoardPageModel(model, criteria);
        return "board_list";
    }

    @RequestMapping("/notice_list")
    public String noticeList(Criteria criteria, Model model) {
        criteria.setBoardType("NOTICE");
        setBoardPageModel(model, criteria);
        return "board_list";
    }

    @RequestMapping("/qna_list")
    public String qnaList(Criteria criteria, Model model) {
        criteria.setBoardType("QNA");
        setBoardPageModel(model, criteria);
        return "board_list";
    }

    @RequestMapping("/board_write_view")
    public String boardWriteView(String boardType,
                                 HttpSession session,
                                 Model model) {

        if (boardType == null || boardType.equals("")) {
            boardType = "QNA";
        }

        if ("NOTICE".equals(boardType)) {
            String role = getRole(session);

            if (!"ADMIN".equals(role)) {
                return "redirect:/notice_list";
            }
        }

        model.addAttribute("boardType", boardType);

        return "board_write_view";
    }

    @RequestMapping("/board_write")
    public String boardWrite(@RequestParam HashMap<String, String> params,
                             HttpSession session) {

        Integer memberId = getLoginMemberId(session);

        if (memberId == null) {
            return "redirect:/login_view";
        }

        String boardType = params.get("boardType");

        if (boardType == null || boardType.equals("")) {
            boardType = "QNA";
        }

        if ("NOTICE".equals(boardType)) {
            String role = getRole(session);

            if (!"ADMIN".equals(role)) {
                return "redirect:/notice_list";
            }
        }

        params.put("memberId", String.valueOf(memberId));
        params.put("boardType", boardType);

        boardService.write(params);

        if ("NOTICE".equals(boardType)) {
            return "redirect:/notice_list";
        }

        return "redirect:/qna_list";
    }

    @RequestMapping("/board_content_view")
    public String boardContentView(@RequestParam HashMap<String, String> params,
                                   @ModelAttribute("cri") Criteria criteria,
                                   Model model,
                                   HttpSession session) {

        String boardNoText = params.get("boardNo");

        if (boardNoText == null || boardNoText.trim().equals("")) {
            throw new RuntimeException("boardNo 없음");
        }

        int boardNo = Integer.parseInt(boardNoText);

        boardService.increaseHit(boardNo);

        BoardDTO boardDto = boardService.contentView(params);

        Integer loginMemberId = getLoginMemberId(session);
        String role = getRole(session);

        List<BoardCommentDTO> commentList = null;

        if (boardDto != null && "QNA".equals(boardDto.getBoardType())) {
            commentList = boardCommentService.getCommentList(boardNo);
        }

        String listPath = "qna_list";

        if (boardDto != null && "NOTICE".equals(boardDto.getBoardType())) {
            listPath = "notice_list";
        }

        model.addAttribute("content_view", boardDto);
        model.addAttribute("commentList", commentList);
        model.addAttribute("loginMemberId", loginMemberId);
        model.addAttribute("role", role);
        model.addAttribute("cri", criteria);
        model.addAttribute("listPath", listPath);

        return "board_content_view";
    }

    @RequestMapping("/board_modify_view")
    public String boardModifyView(@RequestParam HashMap<String, String> params,
                                  @ModelAttribute("cri") Criteria criteria,
                                  Model model,
                                  RedirectAttributes redirectAttributes,
                                  HttpSession session) {

        Integer loginMemberId = getLoginMemberId(session);

        if (loginMemberId == null) {
            return "redirect:/login_view";
        }

        String boardNoText = params.get("boardNo");

        if (boardNoText == null || boardNoText.trim().equals("")) {
            throw new RuntimeException("boardNo 없음");
        }

        int boardNo = Integer.parseInt(boardNoText);

        BoardDTO boardDto = boardService.contentView(params);

        if (boardDto == null) {
            return "redirect:/qna_list";
        }

        String role = getRole(session);

        if ("NOTICE".equals(boardDto.getBoardType())) {
            if (!"ADMIN".equals(role)) {
                return "redirect:/notice_list";
            }
        } else {
            int writerMemberId = boardService.getWriterMemberId(boardNo);

            if (!loginMemberId.equals(writerMemberId)) {
                redirectAttributes.addAttribute("boardNo", boardNo);
                return "redirect:/board_content_view";
            }
        }

        model.addAttribute("content_view", boardDto);
        model.addAttribute("cri", criteria);

        return "board_modify_view";
    }

    @RequestMapping("/modify")
    public String modify(@RequestParam HashMap<String, String> params,
                         @ModelAttribute("cri") Criteria criteria,
                         RedirectAttributes redirectAttributes,
                         HttpSession session) {

        Integer loginMemberId = getLoginMemberId(session);

        if (loginMemberId == null) {
            return "redirect:/login_view";
        }

        int boardNo = Integer.parseInt(params.get("boardNo"));

        BoardDTO boardDto = boardService.contentView(params);

        if (boardDto == null) {
            return "redirect:/qna_list";
        }

        String boardType = boardDto.getBoardType();
        String role = getRole(session);

        if ("NOTICE".equals(boardType)) {
            if (!"ADMIN".equals(role)) {
                return "redirect:/notice_list";
            }
        } else {
            int writerMemberId = boardService.getWriterMemberId(boardNo);

            if (!loginMemberId.equals(writerMemberId)) {
                redirectAttributes.addAttribute("boardNo", boardNo);
                return "redirect:/board_content_view";
            }
        }

        boardService.modify(params);

        if ("NOTICE".equals(boardType)) {
            return "redirect:/notice_list";
        }

        return "redirect:/qna_list";
    }

    @RequestMapping("/delete")
    public String delete(@RequestParam HashMap<String, String> params,
                         @ModelAttribute("cri") Criteria criteria,
                         RedirectAttributes redirectAttributes,
                         HttpSession session) {

        Integer loginMemberId = getLoginMemberId(session);

        if (loginMemberId == null) {
            return "redirect:/login_view";
        }

        int boardNo = Integer.parseInt(params.get("boardNo"));

        BoardDTO boardDto = boardService.contentView(params);

        if (boardDto == null) {
            return "redirect:/qna_list";
        }

        String boardType = boardDto.getBoardType();
        String role = getRole(session);

        if ("NOTICE".equals(boardType)) {
            if (!"ADMIN".equals(role)) {
                return "redirect:/notice_list";
            }
        } else {
            int writerMemberId = boardService.getWriterMemberId(boardNo);

            if (!loginMemberId.equals(writerMemberId)) {
                redirectAttributes.addAttribute("boardNo", boardNo);
                return "redirect:/board_content_view";
            }
        }

        boardService.delete(params);

        if ("NOTICE".equals(boardType)) {
            return "redirect:/notice_list";
        }

        return "redirect:/qna_list";
    }
}