package com.lgy.ess_monitoring.controller;

import java.util.HashMap;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
        return "login_view";
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

        HashMap<String, String> params = new HashMap<>();

        params.put("memberUserid", memberUserid);
        params.put("memberPw", memberPw);
        params.put("userType", userType);

        log.info("@# login params => " + params);

        EssMemberDTO memberDto = memberService.login(params);

        log.info("@# memberDto => " + memberDto);

        if (memberDto == null) {

            log.info("@# login fail");

            model.addAttribute("msg",
                    "아이디, 비밀번호 또는 회원유형이 일치하지 않습니다.");

            return "login_view";
        }

        log.info("@# login success");

        session.setAttribute("loginMember", memberDto);
        session.setAttribute("memberId", memberDto.getMemberId());
        session.setAttribute("memberName", memberDto.getMemberName());
        session.setAttribute("memberUserid", memberDto.getMemberUserid());
        session.setAttribute("userType", memberDto.getUserType());
        session.setAttribute("role", memberDto.getRole());
        session.setAttribute("memberAddress", memberDto.getAddress());

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
        return "join_view";
    }

    // 회원가입 처리
    @RequestMapping("/join")
    public String join(@RequestParam HashMap<String, String> params,
                       Model model) {

        String memberName = params.get("memberName");
        String memberUserid = params.get("memberUserid");
        String memberPw = params.get("memberPw");
        String userType = params.get("userType");
        String email = params.get("email");

        if (memberName == null || memberName.trim().isEmpty()) {
            model.addAttribute("msg", "이름을 입력해주세요.");
            return "join_view";
        }

        if (memberUserid == null || memberUserid.trim().isEmpty()) {
            model.addAttribute("msg", "아이디를 입력해주세요.");
            return "join_view";
        }

        if (memberPw == null || memberPw.trim().isEmpty()) {
            model.addAttribute("msg", "비밀번호를 입력해주세요.");
            return "join_view";
        }

        if (userType == null || userType.trim().isEmpty()) {
            model.addAttribute("msg", "회원 유형을 선택해주세요.");
            return "join_view";
        }

        int idCount = memberService.idCheck(memberUserid);
        if (idCount > 0) {
            model.addAttribute("msg", "이미 사용 중인 아이디입니다.");
            return "join_view";
        }

        if (email != null && !email.trim().isEmpty()) {
            int emailCount = memberService.emailCheck(email);

            if (emailCount > 0) {
                model.addAttribute("msg", "이미 사용 중인 이메일입니다.");
                return "join_view";
            }
        }
        
     // userType 값 확인
        log.info("@# join userType before => " + params.get("userType"));

        // userType 한글값/화면값을 DB 허용값으로 변환
        String fixedUserType = params.get("userType");

        if ("개인".equals(fixedUserType) 
                || "개인용".equals(fixedUserType) 
                || "개인회원".equals(fixedUserType) 
                || "일반회원".equals(fixedUserType)) {

            params.put("userType", "PERSONAL");

        } else if ("기업".equals(fixedUserType) 
                || "기업용".equals(fixedUserType) 
                || "기업회원".equals(fixedUserType)) {

            params.put("userType", "COMPANY");

        } else if (!"PERSONAL".equals(fixedUserType) && !"COMPANY".equals(fixedUserType)) {

            // 예상 밖 값이면 기본값 PERSONAL로 처리
            params.put("userType", "PERSONAL");
        }

        log.info("@# join userType after => " + params.get("userType"));
        
        memberService.join(params);

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
                                 Model model) {

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

        model.addAttribute("msg", "비밀번호가 변경되었습니다.");
        return "member/password_change";
    }
    
    
    
    
    // 로그아웃
    @RequestMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/main";
    }

    // signup.jsp 따로 사용할 경우
    @RequestMapping("/signup")
    public String signup() {
        return "signup";
    }
}