package com.lgy.ess_monitoring.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.lgy.ess_monitoring.dto.BoardDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.WeatherDTO;
import com.lgy.ess_monitoring.service.BoardService;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.WeatherService;

import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class MainController {

    @Autowired
    private EssDeviceService deviceService;

    @Autowired
    private WeatherService weatherService;

    @Autowired
    private BoardService boardService;

    @RequestMapping("/main")
    public String main(HttpSession session, Model model) {

        log.info("@# main()");

        Integer memberId = (Integer) session.getAttribute("memberId");
        String memberAddress = (String) session.getAttribute("memberAddress");

        String weatherAddress = memberAddress;
        String weatherBaseText = "회원 주소 기준";

        if (memberId != null) {

            int deviceCount = deviceService.getDeviceCount(memberId);
            model.addAttribute("deviceCount", deviceCount);

            EssDeviceDTO mainDevice = deviceService.getMainDevice(memberId);

            if (mainDevice != null
                    && mainDevice.getLocation() != null
                    && !mainDevice.getLocation().trim().equals("")) {

                weatherAddress = mainDevice.getLocation();
                weatherBaseText = "대표 ESS 위치 기준";

                model.addAttribute("mainDevice", mainDevice);
            }

        } else {
            model.addAttribute("deviceCount", 0);
            weatherBaseText = "기본 지역 기준";
        }

        try {
            List<WeatherDTO> weatherList =
                    weatherService.forecastByAddress(weatherAddress);

            model.addAttribute("weatherList", weatherList);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);

        } catch (Exception e) {
            log.error("@# weather load error", e);

            model.addAttribute("weatherList", null);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);
        }

        try {
            List<BoardDTO> recentNoticeList =
                    boardService.getRecentNoticeList();

            model.addAttribute("recentNoticeList", recentNoticeList);

        } catch (Exception e) {
            log.error("@# recent notice load error", e);
            model.addAttribute("recentNoticeList", null);
        }

        return "main";
    }
}