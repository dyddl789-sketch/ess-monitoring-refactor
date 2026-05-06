package com.lgy.ess_monitoring.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lgy.ess_monitoring.dto.WeatherDataDTO;
import com.lgy.ess_monitoring.service.WeatherDataService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class WeatherDataController {

    @Autowired
    private WeatherDataService weatherDataService;

    // 현재 날씨 조회
    @ResponseBody
    @RequestMapping(
        value = "/weather/current",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public WeatherDataDTO currentWeather(int deviceId) {

        log.info("currentWeather() deviceId => {}", deviceId);

        return weatherDataService.getOrFetchCurrentWeather(deviceId);
    }

    // 시간별 날씨 조회
    @ResponseBody
    @RequestMapping(
        value = "/weather/list",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public List<WeatherDataDTO> weatherList(int deviceId) {

        log.info("weatherList() deviceId => {}", deviceId);

        return weatherDataService.getOrFetchWeatherList(deviceId);
    }
}