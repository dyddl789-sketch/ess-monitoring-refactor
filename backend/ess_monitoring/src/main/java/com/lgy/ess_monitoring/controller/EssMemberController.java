package com.lgy.ess_monitoring.controller;

import java.util.HashMap;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssMemberDTO;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.EssMemberService;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class EssMemberController {

    @Autowired
    private EssMemberService memberService;

    @Autowired
    private EssDeviceService deviceService;

    // 메인 페이지
    @RequestMapping("/main")
    public String main(HttpSession session, Model model) {
        log.info("@# main()");

        Integer memberId = (Integer) session.getAttribute("memberId");
        String memberAddress = (String) session.getAttribute("memberAddress");

        log.info("@# memberId => " + memberId);
        log.info("@# memberAddress => " + memberAddress);

        String weatherAddress = memberAddress;
        String weatherBaseType = "회원 주소";

        EssDeviceDTO mainDevice = null;

        if (memberId != null) {
            int deviceCount = deviceService.getDeviceCount(memberId);
            model.addAttribute("deviceCount", deviceCount);

            mainDevice = deviceService.getMainDevice(memberId);

            if (mainDevice != null
                    && mainDevice.getLocation() != null
                    && !mainDevice.getLocation().trim().isEmpty()) {

                weatherAddress = mainDevice.getLocation();
                weatherBaseType = "대표 디바이스 위치";
            }
        } else {
            model.addAttribute("deviceCount", 0);
        }

        model.addAttribute("address", weatherAddress);
        model.addAttribute("weatherBaseType", weatherBaseType);
        model.addAttribute("mainDevice", mainDevice);
        return "main";
    }

    // 로그인 화면
    @RequestMapping("/login_view")
    public String loginView() {
        return "login_view";
    }

    // 로그인 처리
    @RequestMapping("/login")
    public String login(@RequestParam("memberUserid") String memberUserid,
                        @RequestParam("memberPw") String memberPw,
                        HttpSession session,
                        Model model) {

        HashMap<String, String> params = new HashMap<>();
        params.put("memberUserid", memberUserid);
        params.put("memberPw", memberPw);

        EssMemberDTO memberDto = memberService.login(params);

        if (memberDto == null) {
            model.addAttribute("msg", "아이디 또는 비밀번호가 틀렸습니다.");
            return "login_view";
        }

        session.setAttribute("loginMember", memberDto);
        session.setAttribute("memberId", memberDto.getMemberId());
        session.setAttribute("memberName", memberDto.getMemberName());
        session.setAttribute("memberUserid", memberDto.getMemberUserid());
        session.setAttribute("userType", memberDto.getUserType());
        session.setAttribute("memberAddress", memberDto.getAddress());

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

        memberService.join(params);

        return "redirect:/login_view";
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
    
 // 내 정보 화면
    @RequestMapping("/member/info")
    public String memberInfo(HttpSession session, Model model) {
        log.info("@# memberInfo()");

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        EssMemberDTO member = memberService.getMemberInfo(memberId);

        model.addAttribute("member", member);

        return "member_info";
    }

    // 내 정보 수정
    @RequestMapping("/member/update")
    public String updateMemberInfo(EssMemberDTO memberDto,
                                   HttpSession session) {
        log.info("@# updateMemberInfo()");
        log.info("@# memberDto => {}", memberDto);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        memberDto.setMemberId(memberId);
        memberService.updateMemberInfo(memberDto);

        // 세션 이름도 최신화
        session.setAttribute("memberName", memberDto.getMemberName());
        session.setAttribute("memberAddress", memberDto.getAddress());

        return "redirect:/member/info";
    }
}