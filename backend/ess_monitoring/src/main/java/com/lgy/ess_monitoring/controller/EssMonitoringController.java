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

import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.MonitoringSummaryDTO;
import com.lgy.ess_monitoring.service.AlertService;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.EssMonitoringService;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/monitoring")
public class EssMonitoringController {

    @Autowired
    private EssMonitoringService monitoringService;

    @Autowired
    private EssDeviceService deviceService;

    @Autowired
    private AlertService alertService;

    // 상세 모니터링 메인 화면
    @RequestMapping(value = "/main", method = RequestMethod.GET)
    public String monitoringMain(
            Integer deviceId,
            HttpSession session,
            Model model
    ) {
        log.info("@# monitoringMain()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId =
            (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        // 그룹 목록
        List<EssGroupDTO> groupList =
            monitoringService.getGroups(memberId);

        // 장비 목록
        List<EssDeviceDTO> deviceList =
            monitoringService.getDevices(
                memberId,
                null
            );

        model.addAttribute("groupList", groupList);
        model.addAttribute("deviceList", deviceList);
        model.addAttribute("deviceId", deviceId);

        model.addAttribute(
            "selectedDate",
            LocalDate.now().toString()
        );

        return "monitoring_main";
    }

    // 그룹별 장비 목록
    @ResponseBody
    @RequestMapping(
        value = "/devices",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<EssDeviceDTO> getDevices(
            Integer groupId,
            HttpSession session
    ) {
        log.info("@# getDevices()");
        log.info("@# groupId => {}", groupId);

        Integer memberId =
            (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return monitoringService.getDevices(
            memberId,
            groupId
        );
    }

    // 상단 카드 / 최신 상태
    @ResponseBody
    @RequestMapping(
        value = "/summary",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public MonitoringSummaryDTO getMonitoringSummary(
            Integer deviceId,
            String selectedDate,
            HttpSession session
    ) {
        log.info("@# getMonitoringSummary()");
        log.info("@# deviceId => {}", deviceId);
        log.info("@# selectedDate => {}", selectedDate);

        Integer memberId =
            (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null
                || selectedDate.isEmpty()) {

            selectedDate =
                LocalDate.now().toString();
        }

        return monitoringService.getMonitoringSummary(
            memberId,
            deviceId,
            selectedDate
        );
    }

    // 시간별 모니터링 이력
    @ResponseBody
    @RequestMapping(
        value = "/history",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<EssMonitoringDTO> monitoringHistory(
            Integer deviceId,
            String selectedDate,
            HttpSession session
    ) {
        log.info("@# monitoringHistory()");
        log.info("@# deviceId => {}", deviceId);
        log.info("@# selectedDate => {}", selectedDate);

        Integer memberId =
            (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null
                || selectedDate.isEmpty()) {

            selectedDate =
                LocalDate.now().toString();
        }

        return monitoringService.getMonitoringHistory(
            memberId,
            deviceId,
            selectedDate
        );
    }

    // 최근 7일 차트
    @ResponseBody
    @RequestMapping(
        value = "/weekly",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> getWeeklyMonitoringChart(
            Integer deviceId,
            String selectedDate,
            HttpSession session
    ) {
        log.info("@# getWeeklyMonitoringChart()");
        log.info("@# deviceId => {}", deviceId);
        log.info("@# selectedDate => {}", selectedDate);

        Integer memberId =
            (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null
                || selectedDate.isEmpty()) {

            selectedDate =
                LocalDate.now().toString();
        }

        return monitoringService.getWeeklyMonitoringChart(
            memberId,
            deviceId,
            selectedDate
        );
    }

    // 최근 알림
    @ResponseBody
    @RequestMapping(
        value = "/alerts",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<AlertDTO> alerts(
            Integer deviceId,
            String selectedDate,
            HttpSession session
    ) {
        log.info("@# alerts()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId =
            (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return alertService
            .getRecentAlertsByDeviceId(deviceId);
    }
}