package com.lgy.ess_monitoring.controller;

import java.time.LocalDate;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lgy.ess_monitoring.dto.DashboardChartResponseDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;
import com.lgy.ess_monitoring.service.DashboardService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    // 요약 출력
    @ResponseBody
    @RequestMapping(
        value = "/summary",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public DashboardSummaryDTO getSummary(
            String selectedDate,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate = LocalDate.now().toString();
        }

        log.info("getSummary() selectedDate={}, memberId={}",
                selectedDate, memberId);

        return dashboardService.getDashboardSummary(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    // 장비 상태 조회
    @ResponseBody
    @RequestMapping(
        value = "/devices",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<EssDeviceDTO> getDashboardDeviceStatusList(
            String selectedDate,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate = LocalDate.now().toString();
        }

        log.info("getDashboardDeviceStatusList() memberId={}, selectedDate={}",
                memberId, selectedDate);

        return dashboardService.getDashboardDeviceStatusList(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }

    // 대시보드 메인 화면
    @RequestMapping(value = "/main", method = RequestMethod.GET)
    public String dashboardMain(HttpSession session, Model model) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        log.info("dashboardMain() memberId => {}", memberId);

        if (memberId == null) {
            return "redirect:/login";
        }

        String selectedDate = LocalDate.now().toString();

        List<EssDeviceGroupDTO> groupList = dashboardService.getGroups(memberId);
        List<EssDeviceDTO> deviceList =
                dashboardService.getDashboardDeviceStatusList(
                        memberId,
                        selectedDate,
                        null,
                        null
                );

        log.info("groupList size => {}", groupList == null ? 0 : groupList.size());
        log.info("deviceList size => {}", deviceList == null ? 0 : deviceList.size());

        model.addAttribute("selectedDate", selectedDate);
        model.addAttribute("groupList", groupList);
        model.addAttribute("deviceList", deviceList);

        return "dashboard_main";
    }
    
 // 발전량 차트 조회
    @ResponseBody
    @RequestMapping(
        value = "/generationChart",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public DashboardChartResponseDTO getGenerationChart(
            String selectedDate,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate = java.time.LocalDate.now().toString();
        }

        return dashboardService.getGenerationChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }
    
    
}