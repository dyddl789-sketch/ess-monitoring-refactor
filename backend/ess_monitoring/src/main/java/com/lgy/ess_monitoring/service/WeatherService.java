package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.WeatherDTO;



public interface WeatherService {
	public List<WeatherDTO> forecast();
	
	//주소 기준으로 날씨 목록을 조회하는 메소드
	public List<WeatherDTO> forecastByAddress(String address);
}
