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
import com.lgy.ess_monitoring.dto.EssGroupDTO;
import com.lgy.ess_monitoring.dto.WeatherDTO;
import com.lgy.ess_monitoring.service.DashboardService;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.WeatherService;
import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.AlertDTO;
import com.lgy.ess_monitoring.service.AlertService;

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

        log.info("getSummary() selectedDate={}, memberId={}", selectedDate, memberId);

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
        log.info("@# dashboardMain()");

        Integer memberId = (Integer) session.getAttribute("memberId");
        String memberAddress = (String) session.getAttribute("memberAddress");

        log.info("@# dashboard memberId => {}", memberId);
        log.info("@# dashboard memberAddress => {}", memberAddress);

        if (memberId == null) {
            return "redirect:/login_view";
        }

        String selectedDate = LocalDate.now().toString();

        // =============================
        // 1. 대시보드 기본 데이터 조회
        // =============================
        List<EssGroupDTO> groupList = dashboardService.getGroups(memberId);

        List<EssDeviceDTO> deviceList =
                dashboardService.getDashboardDeviceStatusList(
                        memberId,
                        selectedDate,
                        null,
                        null
                );

        log.info("@# groupList size => {}", groupList == null ? 0 : groupList.size());
        log.info("@# deviceList size => {}", deviceList == null ? 0 : deviceList.size());

        model.addAttribute("selectedDate", selectedDate);
        model.addAttribute("groupList", groupList);
        model.addAttribute("deviceList", deviceList);

        // =============================
        // 2. 대표 디바이스 기준 날씨 조회
        // =============================
        /*
         * 날씨 기준 우선순위
         *
         * 1순위: 대표 디바이스 위치
         * 2순위: 회원 주소
         * 3순위: WeatherServiceImpl 기본값 부산
         */
        String weatherAddress = memberAddress;
        String weatherBaseText = "회원 주소 기준";

        EssDeviceDTO mainDevice = deviceService.getMainDevice(memberId);

        log.info("@# dashboard mainDevice => {}", mainDevice);

        if (mainDevice != null
                && mainDevice.getLocation() != null
                && !mainDevice.getLocation().trim().equals("")) {

            weatherAddress = mainDevice.getLocation();
            weatherBaseText = "대표 ESS 위치 기준";

            model.addAttribute("mainDevice", mainDevice);

            log.info("@# 대시보드 대표 디바이스 위치 사용 => {}", weatherAddress);

        } else {
            log.info("@# 대표 디바이스 없음. 회원 주소 기준 날씨 사용 => {}", weatherAddress);
        }

        try {
            List<WeatherDTO> weatherList = weatherService.forecastByAddress(weatherAddress);

            log.info("@# dashboard weatherList size => {}",
                    weatherList == null ? 0 : weatherList.size());

            model.addAttribute("weatherList", weatherList);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);

        } catch (Exception e) {
            log.error("@# dashboard weather load error", e);

            model.addAttribute("weatherList", null);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);
        }

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
            selectedDate = LocalDate.now().toString();
        }

        log.info("getGenerationChart() memberId={}, selectedDate={}",
                memberId, selectedDate);

        return dashboardService.getGenerationChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );      
    }
 // 시간별 발전량 / SOC 비교 차트
    @ResponseBody
    @RequestMapping(
        value = "/chart/hourly",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> hourlyChart(
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

        return dashboardService.getHourlyCompareChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }
 // 장비별 발전량 비교 차트
    @ResponseBody
    @RequestMapping(
        value = "/chart/device",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> deviceChart(
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

        return dashboardService.getDeviceCompareChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }   
    
 // 대시보드 필터 기준 최근 알림 조회
    @ResponseBody
    @RequestMapping(
        value = "/alerts",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<AlertDTO> dashboardAlerts(
            String selectedDate,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate =
                    java.time.LocalDate.now().toString();
        }

        return alertService.getDashboardAlerts(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }
    
    // 최근 7일 발전량 차트
    @ResponseBody
    @RequestMapping(
        value = "/chart/weekly",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> weeklyChart(
            String selectedDate,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate =
                    LocalDate.now().toString();
        }

        return dashboardService.getWeeklyGenerationChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }


    // 최근 6개월 월별 발전량 차트
    @ResponseBody
    @RequestMapping(
        value = "/chart/monthly",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> monthlyChart(
            String selectedDate,
            Integer groupId,
            Integer deviceId,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate =
                    LocalDate.now().toString();
        }

        return dashboardService.getMonthlyGenerationChart(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }


    // 장비별 월간 발전량 TOP5 차트
    @ResponseBody
    @RequestMapping(
        value = "/chart/device-top",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<DashboardChartDTO> deviceTopChart(
            String selectedDate,
            Integer groupId,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        if (selectedDate == null || selectedDate.isEmpty()) {
            selectedDate =
                    LocalDate.now().toString();
        }

        return dashboardService.getTopDeviceGenerationChart(
                memberId,
                selectedDate,
                groupId
        );
    }
}