package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.WeatherDataDTO;

public interface WeatherDataService {

    // 특정 기기의 가장 가까운 예보 1건 조회
    WeatherDataDTO getCurrentWeather(int deviceId);

    // 특정 기기의 시간별 예보 목록 조회
    List<WeatherDataDTO> getWeatherList(int deviceId);

    // 기상청 API 호출 후 DTO 리스트로 변환
    List<WeatherDataDTO> fetchWeatherByDeviceId(int deviceId);

    // 기상청 API 호출 후 DB 저장
    void fetchAndSaveWeatherByDeviceId(int deviceId);

    // DB에 데이터가 없으면 API 호출 후 저장하고 다시 조회
    WeatherDataDTO getOrFetchCurrentWeather(int deviceId);

    // DB에 데이터가 없으면 API 호출 후 저장하고 시간별 목록 조회
    List<WeatherDataDTO> getOrFetchWeatherList(int deviceId);
}