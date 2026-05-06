package com.lgy.ess_monitoring.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.service.AlertService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/alert")
public class AlertController {

    @Autowired
    private AlertService alertService;

    // 알림 목록 화면
    @RequestMapping("/list")
    public String list(HttpSession session, Model model) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        model.addAttribute("alertList", alertService.getAlertList(memberId));

        return "alert_list";
    }

    // 알림 상세 화면
    @RequestMapping("/detail")
    public String detail(Integer alertId, HttpSession session, Model model) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        AlertDTO alert = alertService.getAlertDetail(alertId, memberId);

        if (alert == null) {
            return "redirect:/alert/list";
        }

        model.addAttribute("alert", alert);

        return "alert_detail";
    }

    // 알림 처리 완료
    @RequestMapping("/resolve")
    public String resolve(Integer alertId, HttpSession session) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        alertService.updateAlertStatus(alertId, memberId, "RESOLVED");

        return "redirect:/alert/list";
    }
}