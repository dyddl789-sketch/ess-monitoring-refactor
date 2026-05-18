package com.lgy.ess_monitoring.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
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
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;
import com.lgy.ess_monitoring.dto.WeatherDTO;
import com.lgy.ess_monitoring.service.AlertService;
import com.lgy.ess_monitoring.service.DashboardService;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.WeatherService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/dashboard")
public class DashboardController {

    @Autowired
    private DashboardService dashboardService;

    @Autowired
    private EssDeviceService deviceService;

    @Autowired
    private WeatherService weatherService;

    @Autowired
    private AlertService alertService;

    // 대시보드 화면
    @RequestMapping(value = "/main", method = RequestMethod.GET)
    public String dashboardMain(HttpSession session, Model model) {

        Integer memberId = (Integer) session.getAttribute("memberId");
        String memberAddress = (String) session.getAttribute("memberAddress");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        String selectedMonth =
                LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));

        String selectedDate =
                LocalDate.now().toString();

        List<EssGroupDTO> groupList =
                dashboardService.getGroups(memberId);

        List<EssDeviceDTO> deviceList =
                dashboardService.getDashboardDeviceStatusList(
                        memberId,
                        null,
                        null
                );

        model.addAttribute("selectedMonth", selectedMonth);
        model.addAttribute("selectedDate", selectedDate);
        model.addAttribute("groupList", groupList);
        model.addAttribute("deviceList", deviceList);

        // 날씨
        String weatherAddress = memberAddress;
        String weatherBaseText = "회원 주소 기준";

        EssDeviceDTO mainDevice = deviceService.getMainDevice(memberId);

        if (mainDevice != null
                && mainDevice.getLocation() != null
                && !mainDevice.getLocation().trim().equals("")) {

            weatherAddress = mainDevice.getLocation();
            weatherBaseText = "대표 ESS 위치 기준";

            model.addAttribute("mainDevice", mainDevice);
        }

        try {
            List<WeatherDTO> weatherList =
                    weatherService.forecastByAddress(weatherAddress);

            model.addAttribute("weatherList", weatherList);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);

        } catch (Exception e) {
            log.error("dashboard weather load error", e);

            model.addAttribute("weatherList", null);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);
        }

        return "dashboard_main";
    }

    // 요약 카드
    @ResponseBody
    @RequestMapping(
        value = "/summary",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public DashboardSummaryDTO getSummary(
            String selectedMonth,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedMonth == null || selectedMonth.isEmpty()) {
            selectedMonth =
                    LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }

        return dashboardService.getDashboardSummary(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    // 장비 셀렉트
    @ResponseBody
    @RequestMapping(
        value = "/devices",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<EssDeviceDTO> getDevices(
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return dashboardService.getDashboardDeviceStatusList(
                memberId,
                groupId,
                deviceId
        );
    }

    // 월별 발전량
    @ResponseBody
    @RequestMapping(
        value = "/chart/monthly-generation",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> monthlyGenerationChart(
            String selectedMonth,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedMonth == null || selectedMonth.isEmpty()) {
            selectedMonth =
                    LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }

        return dashboardService.getMonthlyGenerationChart(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    // 월별 절감 금액
    @ResponseBody
    @RequestMapping(
        value = "/chart/monthly-cost",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> monthlyCostChart(
            String selectedMonth,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedMonth == null || selectedMonth.isEmpty()) {
            selectedMonth =
                    LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }

        return dashboardService.getMonthlyCostChart(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    // 장비별 TOP5
    @ResponseBody
    @RequestMapping(
        value = "/chart/device-top",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> deviceTopChart(
            String selectedMonth,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedMonth == null || selectedMonth.isEmpty()) {
            selectedMonth =
                    LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }

        return dashboardService.getTopDeviceGenerationChart(
                memberId,
                selectedMonth,
                groupId,
                deviceId
        );
    }

    // 최근 알림
    @ResponseBody
    @RequestMapping(
        value = "/alerts",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<AlertDTO> dashboardAlerts(
            String selectedMonth,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        String selectedDate =
                LocalDate.now().toString();

        return alertService.getDashboardAlerts(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }
}