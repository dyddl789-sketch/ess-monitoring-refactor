package com.lgy.ess_monitoring.dao;

import java.util.List;

import com.lgy.ess_monitoring.dto.WeatherDataDTO;

public interface WeatherDataDAO {

    // 특정 기기의 최신 날씨 1건 조회
    WeatherDataDTO getLatestWeather(int deviceId);

    // 날씨 데이터 저장
    void insertWeatherData(WeatherDataDTO dto);

    // 특정 기기의 예보 목록 조회
    List<WeatherDataDTO> getWeatherList(int deviceId);

    // 현재 화면 상단 대표 날씨 1건 조회
    WeatherDataDTO getCurrentWeather(int deviceId);
}