package com.lgy.ess_monitoring.controller;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/monitoring")
public class EssMonitoringController {

    // 실시간 모니터링 메인 화면
    @RequestMapping("/main")
    public String monitoringMain(
            Integer deviceId,
            HttpSession session,
            Model model
    ) {
        log.info("@# monitoringMain()");

        Integer memberId = (Integer) session.getAttribute("memberId");
        log.info("@# session memberId => {}", memberId);

        if (memberId == null) {
            return "redirect:/login";
        }

        model.addAttribute("deviceId", deviceId);

        return "monitoring_main";
    }
}