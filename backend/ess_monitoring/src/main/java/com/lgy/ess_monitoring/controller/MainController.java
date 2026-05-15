package com.lgy.ess_monitoring.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.WeatherDTO;
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

    // 메인 페이지
    @RequestMapping("/main")
    public String main(HttpSession session, Model model) {

        log.info("@# main()");

        Integer memberId = (Integer) session.getAttribute("memberId");
        String memberAddress = (String) session.getAttribute("memberAddress");

        log.info("@# memberId => " + memberId);
        log.info("@# memberAddress => " + memberAddress);

        /*
         * 날씨 조회 기준 주소
         *
         * 1순위: 대표 디바이스 위치
         * 2순위: 회원 주소
         * 3순위: WeatherServiceImpl 기본값 부산
         */
        String weatherAddress = memberAddress;
        String weatherBaseText = "회원 주소 기준";

        // 1. 로그인 회원의 ESS 기기 개수 조회
        if (memberId != null) {

            int deviceCount = deviceService.getDeviceCount(memberId);
            model.addAttribute("deviceCount", deviceCount);

            log.info("@# deviceCount => " + deviceCount);

            // 2. 대표 디바이스 조회
            EssDeviceDTO mainDevice = deviceService.getMainDevice(memberId);

            log.info("@# mainDevice => " + mainDevice);

            // 3. 대표 디바이스가 있으면 대표 디바이스 위치를 날씨 기준으로 사용
            if (mainDevice != null
                    && mainDevice.getLocation() != null
                    && !mainDevice.getLocation().trim().equals("")) {

                weatherAddress = mainDevice.getLocation();
                weatherBaseText = "대표 ESS 위치 기준";

                model.addAttribute("mainDevice", mainDevice);

                log.info("@# 대표 디바이스 위치 사용 => " + weatherAddress);

            } else {

                log.info("@# 대표 디바이스 없음. 회원 주소 사용 => " + weatherAddress);
            }

        } else {

            model.addAttribute("deviceCount", 0);
            weatherBaseText = "기본 지역 기준";

            log.info("@# 비로그인 상태. 기본 지역 사용");
        }

        // 4. 날씨 조회
        try {

            log.info("@# weatherAddress => " + weatherAddress);
            log.info("@# weatherBaseText => " + weatherBaseText);

            List<WeatherDTO> weatherList =
                    weatherService.forecastByAddress(weatherAddress);

            log.info("@# weatherList size => " + weatherList.size());

            model.addAttribute("weatherList", weatherList);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);

        } catch (Exception e) {

            log.error("@# weather load error", e);

            // 날씨 API 오류가 나도 메인 화면은 뜨게 처리
            model.addAttribute("weatherList", null);
            model.addAttribute("weatherAddress", weatherAddress);
            model.addAttribute("weatherBaseText", weatherBaseText);
        }

        return "main";
    }
}