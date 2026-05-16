package com.lgy.ess_monitoring.controller;

import java.util.HashMap;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.lgy.ess_monitoring.dto.EssMemberDTO;
import com.lgy.ess_monitoring.service.EssMemberService;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class EssMemberController {

    @Autowired
    private EssMemberService memberService;

    // 로그인 화면
    @RequestMapping("/login_view")
    public String loginView() {
        return "member/login_view";
    }

 // 로그인 처리
    @RequestMapping("/login")
    public String login(@RequestParam("memberUserid") String memberUserid,
                        @RequestParam("memberPw") String memberPw,
                        @RequestParam("userType") String userType,
                        HttpSession session,
                        Model model) {

        log.info("@# login()");
        log.info("@# memberUserid => " + memberUserid);
        log.info("@# userType => " + userType);

        // 아이디 기준 회원 조회
        EssMemberDTO memberDto =
                memberService.findByUserid(memberUserid);

        log.info("@# memberDto => " + memberDto);

        // 1. 아이디 없음
        if (memberDto == null) {

            log.info("@# login fail : invalid userid");

            model.addAttribute("msg",
                    "등록되지 않은 아이디입니다.");

            return "member/login_view";
        }

        // 2. 회원유형 불일치
        if (!userType.equals(memberDto.getUserType())) {

            log.info("@# login fail : invalid userType");

            model.addAttribute("msg",
                    "선택한 회원유형과 계정 정보가 일치하지 않습니다.");

            return "member/login_view";
        }

        // 3. 비밀번호 불일치
        if (!memberPw.equals(memberDto.getMemberPw())) {

            log.info("@# login fail : invalid password");

            model.addAttribute("msg",
                    "비밀번호가 일치하지 않습니다.");

            return "member/login_view";
        }

        log.info("@# login success");

        setLoginSession(session, memberDto);

        log.info("@# session memberId => " + memberDto.getMemberId());
        log.info("@# session memberName => " + memberDto.getMemberName());
        log.info("@# session userType => " + memberDto.getUserType());
        log.info("@# session role => " + memberDto.getRole());
        log.info("@# session memberAddress => " + memberDto.getAddress());

        return "redirect:/main";
    }

    // 회원가입 화면
    @RequestMapping("/join_view")
    public String joinView() {
        return "member/join_view";
    }

    // 회원가입 처리
    @RequestMapping("/join")
    public String join(@RequestParam HashMap<String, String> params,
            Model model,
            RedirectAttributes redirectAttributes) {

        String memberName = params.get("memberName");
        String memberUserid = params.get("memberUserid");
        String memberPw = params.get("memberPw");
        String userType = params.get("userType");
        String email = params.get("email");

        if (memberName == null || memberName.trim().isEmpty()) {
            model.addAttribute("msg", "이름을 입력해주세요.");
            return "member/join_view";
        }

        if (memberUserid == null || memberUserid.trim().isEmpty()) {
            model.addAttribute("msg", "아이디를 입력해주세요.");
            return "member/join_view";
        }

        if (memberPw == null || memberPw.trim().isEmpty()) {
            model.addAttribute("msg", "비밀번호를 입력해주세요.");
            return "member/join_view";
        }

        if (userType == null || userType.trim().isEmpty()) {
            model.addAttribute("msg", "회원 유형을 선택해주세요.");
            return "member/join_view";
        }

        int idCount = memberService.idCheck(memberUserid);
        if (idCount > 0) {
            model.addAttribute("msg", "이미 사용 중인 아이디입니다.");
            return "member/join_view";
        }

        if (email != null && !email.trim().isEmpty()) {
            int emailCount = memberService.emailCheck(email);

            if (emailCount > 0) {
                model.addAttribute("msg", "이미 사용 중인 이메일입니다.");
                return "member/join_view";
            }
        }
     // userType 값 확인
        log.info("@# join userType before => " + params.get("userType"));

        params.put("userType",
                normalizeUserType(params.get("userType")));

        log.info("@# join userType after => " + params.get("userType"));
        
        memberService.join(params);

        redirectAttributes.addFlashAttribute(
                "successMsg",
                "회원가입이 완료되었습니다. 로그인해주세요.");

        return "redirect:/login_view";
    }
 // 회원정보수정 화면
    @RequestMapping("/member/info")
    public String memberInfo(HttpSession session, Model model) {

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
        	return "redirect:/login_view";
        }

        EssMemberDTO memberDto = memberService.getMemberInfo(memberId);
        model.addAttribute("member", memberDto);

        return "member/member_info";
    }


    // 회원정보수정 처리
    @RequestMapping("/member/update")
    public String updateMember(@RequestParam HashMap<String, String> params,
                               HttpSession session,
                               Model model) {

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
        	return "redirect:/login_view";
        }

        EssMemberDTO member = new EssMemberDTO();

        member.setMemberId(memberId);
        member.setMemberName(params.get("memberName"));
        member.setPhone(params.get("phone"));
        member.setEmail(params.get("email"));
        member.setAddress(params.get("address"));

        memberService.updateMemberInfo(member);

        EssMemberDTO updatedMember = memberService.getMemberInfo(memberId);

        session.setAttribute("loginMember", updatedMember);
        session.setAttribute("memberName", updatedMember.getMemberName());
        session.setAttribute("memberAddress", updatedMember.getAddress());

        model.addAttribute("msg", "회원정보가 수정되었습니다.");
        model.addAttribute("member", updatedMember);

        return "member/member_info";
    }


    // 비밀번호 변경 화면
    @RequestMapping("/member/password")
    public String passwordView(HttpSession session) {

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
        	return "redirect:/login_view";
        }

        return "member/password_change";
    }


 // 비밀번호 변경 처리
    @RequestMapping("/member/password/update")
    public String passwordUpdate(@RequestParam HashMap<String, String> params,
                                 HttpSession session,
                                 Model model,
                                 RedirectAttributes rttr) {

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
        	return "redirect:/login_view";
        }

        String currentPw = params.get("currentPw");
        String newPw = params.get("newPw");
        String newPwCheck = params.get("newPwCheck");

        if (currentPw == null || currentPw.trim().isEmpty()) {
            model.addAttribute("msg", "현재 비밀번호를 입력해주세요.");
            return "member/password_change";
        }

        if (newPw == null || newPw.trim().isEmpty()) {
            model.addAttribute("msg", "새 비밀번호를 입력해주세요.");
            return "member/password_change";
        }

        if (newPw.length() < 8) {
            model.addAttribute("msg", "새 비밀번호는 8자 이상 입력해주세요.");
            return "member/password_change";
        }

        if (!newPw.equals(newPwCheck)) {
            model.addAttribute("msg", "새 비밀번호가 일치하지 않습니다.");
            return "member/password_change";
        }

        if (currentPw.equals(newPw)) {
            model.addAttribute("msg", "현재 비밀번호와 새 비밀번호가 같습니다.");
            return "member/password_change";
        }

        params.put("memberId", String.valueOf(memberId));

        int result = memberService.updatePassword(params);

        if (result == 0) {
            model.addAttribute("msg", "현재 비밀번호가 일치하지 않습니다.");
            return "member/password_change";
        }

        session.invalidate();

        rttr.addFlashAttribute(
            "msg",
            "비밀번호가 변경되었습니다. 변경된 비밀번호로 다시 로그인해주세요."
        );

        return "redirect:/login_view";
    }
    
    
    
    
    // 로그아웃
    @RequestMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/main";
    }


    /*
     * =========================================================
     * Helper Method
     * =========================================================
     */
    // 로그인 세션 저장
    private void setLoginSession(HttpSession session,
                                 EssMemberDTO memberDto) {

        session.setAttribute("loginMember", memberDto);
        session.setAttribute("memberId", memberDto.getMemberId());
        session.setAttribute("memberName", memberDto.getMemberName());
        session.setAttribute("memberUserid", memberDto.getMemberUserid());
        session.setAttribute("userType", memberDto.getUserType());
        session.setAttribute("role", memberDto.getRole());
        session.setAttribute("memberAddress", memberDto.getAddress());
    }


    // 회원 유형 변환
    private String normalizeUserType(String userType) {

        if ("PERSONAL".equals(userType)
                || "COMPANY".equals(userType)) {

            return userType;
        }

        if ("개인".equals(userType)
                || "개인용".equals(userType)
                || "개인회원".equals(userType)
                || "일반회원".equals(userType)) {

            return "PERSONAL";
        }

        if ("기업".equals(userType)
                || "기업용".equals(userType)
                || "기업회원".equals(userType)) {

            return "COMPANY";
        }

        // 예상 밖 값이면 기본값 PERSONAL 처리
        return "PERSONAL";
    }
}