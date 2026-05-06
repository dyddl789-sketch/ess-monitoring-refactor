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
        log.info("@# deviceId => {}", deviceId);

        if (memberId == null) {
            return "redirect:/login_view";
        }

        /*
         * 상세 모니터링 페이지에서는 선택한 장비의 실시간 데이터만 표시한다.
         * 날씨 정보는 대시보드에서 대표 디바이스 기준으로 표시한다.
         */
        model.addAttribute("deviceId", deviceId);

        return "monitoring_main";
    }
}