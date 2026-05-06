package com.lgy.ess_monitoring.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.WeatherDataDTO;
import com.lgy.ess_monitoring.service.EssMonitoringService;
import com.lgy.ess_monitoring.service.WeatherDataService;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.service.EssDeviceService;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/monitoring")
public class EssMonitoringController {

    @Autowired
    private EssMonitoringService monitoringService;

    @Autowired
    private WeatherDataService weatherDataService;
    
    @Autowired
    private EssDeviceService deviceService;

    // 실시간 모니터링 메인 화면
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

        log.info("@# session memberId => {}", memberId);

        if (memberId == null) {
            return "redirect:/login_view";
        }

        /*
         * 장비 목록 조회
         */
        List<EssDeviceDTO> deviceList =
            deviceService.getDeviceList(memberId);

        /*
         * JSP 전달
         */
        model.addAttribute("deviceId", deviceId);

        model.addAttribute(
            "deviceList",
            deviceList
        );

        return "monitoring_main";
    }



    // 최신 모니터링 데이터 조회
    @ResponseBody
    @RequestMapping(
        value = "/latest",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public EssMonitoringDTO latestMonitoring(
            int deviceId,
            HttpSession session
    ) {
        log.info("@# latestMonitoring()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return monitoringService.getLatestMonitoring(deviceId);
    }

    // 최근 모니터링 이력 조회
    // 그래프 초기 데이터용
    @ResponseBody
    @RequestMapping(
        value = "/history",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<EssMonitoringDTO> monitoringHistory(
            int deviceId,
            HttpSession session
    ) {
        log.info("@# monitoringHistory()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return monitoringService.getMonitoringHistory(deviceId);
    }

    // 현재 날씨 조회
    @ResponseBody
    @RequestMapping(
        value = "/weather/current",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public WeatherDataDTO currentWeather(
            int deviceId,
            HttpSession session
    ) {
        log.info("@# currentWeather()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return weatherDataService.getOrFetchCurrentWeather(deviceId);
    }

    // 시간별 날씨 목록 조회
    @ResponseBody
    @RequestMapping(
        value = "/weather/list",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<WeatherDataDTO> weatherList(
            int deviceId,
            HttpSession session
    ) {
        log.info("@# weatherList()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return null;
        }

        return weatherDataService.getOrFetchWeatherList(deviceId);
    }
}