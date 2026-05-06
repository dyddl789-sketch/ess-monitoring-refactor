package com.lgy.ess_monitoring.dto;

import lombok.Data;

@Data
public class WeatherDTO {
	private String city; //도시명(서울, 부산, 인천 ....)
	
	private String fcstTime; // 예보시간
	private String fcstDate; // 예보날짜
	
	private String skyStatus; // 하늘상태
	private String rainType; //강수형태
	private String rainProb; // 강수확률
	private String temperature; // 기온
    
	private String weatherIcon;// 날씨 아이콘
	
    private String sunset;
    private String sunrise;
    
    
    private boolean rainy;
    private boolean cloudy;
    private boolean night;
    
    private String essStatus;
}
