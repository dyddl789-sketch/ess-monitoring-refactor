package com.lgy.ess_monitoring.controller;

import java.time.LocalDate;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.lgy.ess_monitoring.service.AnalysisService;
import com.lgy.ess_monitoring.service.EssDeviceService;

@Controller
@RequestMapping("/analysis")
public class AnalysisController {

    @Autowired
    private AnalysisService analysisService;
    
    @Autowired
    private EssDeviceService deviceService;

    // 발전량 분석 화면
    @RequestMapping("/generation")
    public String generation(
            String startDate,
            String endDate,
            Integer deviceId,
            HttpSession session,
            Model model
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        if (endDate == null || endDate.isEmpty()) {
            endDate = LocalDate.now().toString();
        }

        if (startDate == null || startDate.isEmpty()) {
            startDate = LocalDate.now().minusDays(6).toString();
        }

        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("selectedDeviceId", deviceId);
        model.addAttribute("deviceSelectList", deviceService.getDeviceList(memberId));
        
        model.addAttribute(
                "dailyList",
                analysisService.getDailyGeneration(memberId, startDate, endDate, deviceId)
        );

        model.addAttribute(
                "deviceList",
                analysisService.getDeviceGeneration(memberId, startDate, endDate, deviceId)
        );

        return "analysis_generation";
    }
    
    @RequestMapping("/energy")
    public String energy(
            String startDate,
            String endDate,
            Integer deviceId,
            HttpSession session,
            Model model
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        if (endDate == null || endDate.isEmpty()) {
            endDate = LocalDate.now().toString();
        }

        if (startDate == null || startDate.isEmpty()) {
            startDate = LocalDate.now().minusDays(6).toString();
        }

        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);

        model.addAttribute(
                "dailyList",
                analysisService.getDailyEnergyStats(memberId, startDate, endDate, deviceId)
        );

        model.addAttribute(
                "deviceList",
                analysisService.getDeviceEnergyStats(memberId, startDate, endDate)
        );

        return "analysis_energy";
    }
    
}