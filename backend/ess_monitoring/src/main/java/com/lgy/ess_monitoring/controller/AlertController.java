package com.lgy.ess_monitoring.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.service.AlertService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/alert")
public class AlertController {

    @Autowired
    private AlertService alertService;

    // 알림 목록
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public String alertList(
            String alertLevel,
            String status,
            HttpSession session,
            Model model
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        // 기본값: 미처리 알림
        if (status == null || status.trim().equals("")) {
            status = "OPEN";
        }

        List<AlertDTO> alertList =
                alertService.getAlertList(
                        memberId,
                        alertLevel,
                        status
                );

        model.addAttribute("alertList", alertList);
        model.addAttribute("selectedLevel", alertLevel);
        model.addAttribute("selectedStatus", status);

        return "alert_list";
    }

    // 알림 상세 화면
    // 현재 목록에서는 사용하지 않지만 기존 기능 보존
    @RequestMapping(value = "/detail", method = RequestMethod.GET)
    public String detail(
            Integer alertId,
            HttpSession session,
            Model model
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        AlertDTO alert =
                alertService.getAlertDetail(
                        alertId,
                        memberId
                );

        if (alert == null) {
            return "redirect:/alert/list";
        }

        model.addAttribute("alert", alert);

        return "alert_detail";
    }

    // 기존 처리 완료 URL 보존
    @RequestMapping(value = "/resolve", method = RequestMethod.GET)
    public String resolve(
            Integer alertId,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        alertService.updateAlertStatus(
                alertId,
                memberId,
                "RESOLVED"
        );

        return "redirect:/alert/list";
    }

    // 장비 확인 후 처리완료 + 모니터링 이동
    @RequestMapping(value = "/confirm", method = RequestMethod.GET)
    public String confirmAlert(
            int alertId,
            int deviceId,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        alertService.confirmAlert(
                alertId,
                memberId
        );

        return "redirect:/monitoring/main?deviceId=" + deviceId;
    }
}