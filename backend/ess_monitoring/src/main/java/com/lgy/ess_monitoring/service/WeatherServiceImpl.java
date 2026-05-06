package com.lgy.ess_monitoring.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lgy.ess_monitoring.dto.WeatherDTO;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class WeatherServiceImpl implements WeatherService {
	
	// 날씨 API 호출 결과 캐시
	private Map<String, List<WeatherDTO>> weatherCache = new HashMap<>();

	// 캐시 저장 시간
	private Map<String, Long> weatherCacheTime = new HashMap<>();

	// 캐시 유지 시간: 30분
	private static final long WEATHER_CACHE_MILLIS = 30 * 60 * 1000;
	
	
	/*
	  SKY 코드 → 한글 변환
	  
	  SKY 값은 1,3,4만 존재 (가져온 데이터가 원래 이렇다고 함)
	  1: 맑음 / 3: 구름많음 / 4: 흐림
	*/
	private String convertSky(String value) {
		if ("1".equals(value)) return "맑음";
		if ("3".equals(value)) return "구름많음";
		if ("4".equals(value)) return "흐림";
		return value;
	}
	
	/*
	  PTY 코드 → 한글 변환
	  0: 없음 / 1: 비 / 2: 비/눈 / 3: 눈 / 4: 소나기
	*/
	private String convertPty(String value) {
		if ("0".equals(value)) return "없음";
		if ("1".equals(value)) return "비";
		if ("2".equals(value)) return "비/눈";
		if ("3".equals(value)) return "눈";
		if ("4".equals(value)) return "소나기";
		return value;
	}
	
	// ex) "1500" => "15:00" 형태로 변환
	private String formatTime(String time) {
		if(time!=null && time.length() == 4) {
			return time.substring(0, 2) + ":" + time.substring(2, 4);
		}
		return time;
	}
	
	// ex) "1500" => "15:00" 형태로 변환
	private String formatSunset(String sunset) {
		if (sunset != null && sunset.length() == 4) {
	        return sunset.substring(0, 2) + ":" + sunset.substring(2, 4);
	    }
	    return sunset;
	}
	
	private boolean isNightBySun(String fcstTime, String sunrise,String sunset) {
		if (fcstTime == null ||  sunrise == null || sunset == null) return false;
		
		try {
			String time = fcstTime.replace(":", "");
			int forecast = Integer.parseInt(time);
			int sunsetTime = Integer.parseInt(sunset);
			int sunriseTime = Integer.parseInt(sunrise);
			
			return forecast >= sunsetTime || forecast < sunriseTime;
		} catch (Exception e) {
			return false;
		}
	}
	
	/*
	  기상청 단기예보 발표 시각 기준으로 baseTime 계산
	  발표 시각: 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300
	 */
	private String getBaseTime() {
		LocalTime now = LocalTime.now();
		int hour = now.getHour();
		int minute = now.getMinute();
		
		// 발표 직후 바로 조회 안 될 수 있어서 10분 정도 여유
	    if (hour < 2 || (hour == 2 && minute < 10)) return "2300";
	    if (hour < 5 || (hour == 5 && minute < 10)) return "0200";
	    if (hour < 8 || (hour == 8 && minute < 10)) return "0500";
	    if (hour < 11 || (hour == 11 && minute < 10)) return "0800";
	    if (hour < 14 || (hour == 14 && minute < 10)) return "1100";
	    if (hour < 17 || (hour == 17 && minute < 10)) return "1400";
	    if (hour < 20 || (hour == 20 && minute < 10)) return "1700";
	    if (hour < 23 || (hour == 23 && minute < 10)) return "2000";

	    return "2300";
	}
	
	/*
	  baseTime이 2300이고 현재 시간이 새벽 2시 이전이면
	  전날 날짜를 써야 함
	 */
	private String getBaseDate(String baseTime) {
	    LocalDate today = LocalDate.now();

	    if ("2300".equals(baseTime) && LocalTime.now().getHour() < 2) {
	        today = today.minusDays(1);
	    }

	    return today.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
	}
	
	/*
	  한국천문연구원 출몰시각 API를 호출해서 해당 날짜, 해당 지역의 일몰시간(sunset)을 가져오는 메서드
	  
	  locdate  날짜 (예: 20260423)
	  location 지역명 (예: 서울)
	  return 일몰시간 (예: 1845)
	*/
	
	//서울, 부산, 대구, 인천, 광주, 대전, 울산, 제주 좌표 추가
	private Map<String, String[]> getCityMap() {
		Map<String, String[]> cityMap = new LinkedHashMap<>();
		
		cityMap.put("서울", new String[]{"60", "127"});
	    cityMap.put("부산", new String[]{"98", "76"});
	    cityMap.put("대구", new String[]{"89", "90"});
	    cityMap.put("인천", new String[]{"55", "124"});
	    cityMap.put("광주", new String[]{"58", "74"});
	    cityMap.put("대전", new String[]{"67", "100"});
	    cityMap.put("울산", new String[]{"102", "84"});
	    cityMap.put("제주", new String[]{"52", "38"});
	    
	    return cityMap;
	}
	
	private Map<String, String> getSunTime(String locdate, String location) {
	    BufferedReader br = null;
	    Map<String, String> sunMap = new HashMap<>();

	    try {
	        String serviceKey = "05f37cb6730500f4692992eb12847bfda92c57b96d8c8c372dc74ea7d1cb944a";

	        StringBuilder urlBuilder = new StringBuilder(
	            "http://apis.data.go.kr/B090041/openapi/service/RiseSetInfoService/getAreaRiseSetInfo"
	        );

	        urlBuilder.append("?" + URLEncoder.encode("serviceKey", "UTF-8") + "=" + serviceKey);
	        urlBuilder.append("&locdate=" + locdate);
	        urlBuilder.append("&location=" + URLEncoder.encode(location, "UTF-8"));

	        URL url = new URL(urlBuilder.toString());
	        br = new BufferedReader(new InputStreamReader(url.openStream(), "UTF-8"));

	        StringBuilder sb = new StringBuilder();
	        String line;

	        while ((line = br.readLine()) != null) {
	            sb.append(line);
	        }

	        String xml = sb.toString();

	        // 일출 파싱
	        int sunriseStart = xml.indexOf("<sunrise>");
	        int sunriseEnd = xml.indexOf("</sunrise>");

	        if (sunriseStart != -1 && sunriseEnd != -1) {
	            String sunrise = xml.substring(sunriseStart + 9, sunriseEnd).trim();
	            sunMap.put("sunrise", sunrise);
	        }

	        // 일몰 파싱
	        int sunsetStart = xml.indexOf("<sunset>");
	        int sunsetEnd = xml.indexOf("</sunset>");

	        if (sunsetStart != -1 && sunsetEnd != -1) {
	            String sunset = xml.substring(sunsetStart + 8, sunsetEnd).trim();
	            sunMap.put("sunset", sunset);
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        try {
	            if (br != null) br.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }

	    return sunMap;
	}
	
//	강수 형태가 있으면 비, 눈 아이콘, 강수가 없으면 하늘 상태를 기준으로 아이콘 결정
	private String getWeatherIcon(String skyStatus, String rainType) {
		 // 비 또는 소나기
        if ("비".equals(rainType) || "소나기".equals(rainType)) {
            return "🌧️";
        }

        // 눈
        if ("눈".equals(rainType)) {
            return "❄️";
        }

        // 비/눈
        if ("비/눈".equals(rainType)) {
            return "🌨️";
        }

        // 하늘 상태 기준
        if ("맑음".equals(skyStatus)) {
            return "☀️";
        }

        if ("구름많음".equals(skyStatus)) {
            return "⛅";
        }

        if ("흐림".equals(skyStatus)) {
            return "☁️";
        }

        // 값이 없거나 예상 밖이면 기본 아이콘
        return "🌡️";
	}
	
//	(47051) 부산 사상구 대동로64번길 25 103동 1402호(문자열 안에 "부산"이 포함되어 있으면 부산을 대표도시로 설정
	private String getCityFromAddress(String address) {
		if(address == null || address.trim().equals("")) {
			return "부산";
		}
		if (address.contains("서울")) return "서울";
        if (address.contains("부산")) return "부산";
        if (address.contains("대구")) return "대구";
        if (address.contains("인천")) return "인천";
        if (address.contains("광주")) return "광주";
        if (address.contains("대전")) return "대전";
        if (address.contains("울산")) return "울산";
        if (address.contains("제주")) return "제주";

        // 위 도시가 없으면 기본값
        return "부산";
	}
	
//	대표 도시명을 좌표로 변환
	private String[] getNxNyByCity(String city) {
        Map<String, String[]> cityMap = new HashMap<>();

        cityMap.put("서울", new String[]{"60", "127"});
        cityMap.put("부산", new String[]{"98", "76"});
        cityMap.put("대구", new String[]{"89", "90"});
        cityMap.put("인천", new String[]{"55", "124"});
        cityMap.put("광주", new String[]{"58", "74"});
        cityMap.put("대전", new String[]{"67", "100"});
        cityMap.put("울산", new String[]{"102", "84"});
        cityMap.put("제주", new String[]{"52", "38"});

        if (cityMap.containsKey(city)) {
            return cityMap.get(city);
        }

        // 못 찾으면 부산 좌표
        return cityMap.get("부산");
    }
	
	
	public List<WeatherDTO> getCityWeather(String city, String nx, String ny) {
	    List<WeatherDTO> weatherList = new ArrayList<>();
	    BufferedReader br = null;
	    
	    try {
	        String serviceKey = "05f37cb6730500f4692992eb12847bfda92c57b96d8c8c372dc74ea7d1cb944a";
	        
	        //실시간 반영
	        String baseTime = getBaseTime();
	        String baseDate = getBaseDate(baseTime);

//	        날짜가 4/22로 고정되어 있어서 실시간 반영 불가능
//	        String baseDate = "20260422";
//	        String baseTime = "0500"; 
	        
	        
	        StringBuilder urlBuilder = new StringBuilder(
	            "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
	        );

	        urlBuilder.append("?" + URLEncoder.encode("serviceKey", "UTF-8") + "=" + serviceKey);
	        urlBuilder.append("&pageNo=1");
	        urlBuilder.append("&numOfRows=1000");
	        urlBuilder.append("&dataType=JSON");
	        urlBuilder.append("&base_date=" + baseDate);
	        urlBuilder.append("&base_time=" + baseTime);
	        urlBuilder.append("&nx=" + nx);
	        urlBuilder.append("&ny=" + ny);

	        URL url = new URL(urlBuilder.toString());
	        br = new BufferedReader(new InputStreamReader(url.openStream(), "UTF-8"));

	        StringBuilder sb = new StringBuilder();
	        String line;

	        while ((line = br.readLine()) != null) {
	            sb.append(line);
	        }
	        
	        //json 파싱
	        ObjectMapper mapper = new ObjectMapper();
	        JsonNode items = mapper.readTree(sb.toString())
	                .path("response")
	                .path("body")
	                .path("items")
	                .path("item");

	        //시간별 데이터 묶기
	        Map<String, WeatherDTO> map = new LinkedHashMap<>();

	        for (JsonNode item : items) {
	            String category = item.path("category").asText();
	            String fcstDate = item.path("fcstDate").asText();
	            String fcstTime = item.path("fcstTime").asText();
	            String value = item.path("fcstValue").asText();

	            String key = fcstDate + "_" + fcstTime;

	            map.putIfAbsent(key, new WeatherDTO());

	            WeatherDTO dto = map.get(key);
	            
	            dto.setCity(city);
	            dto.setFcstDate(fcstDate);
	            dto.setFcstTime(formatTime(fcstTime));

	            switch (category) {
	                case "TMP":
	                    dto.setTemperature(value + "℃");
	                    break;
	                case "SKY":
	                    dto.setSkyStatus(convertSky(value));
	                    break;
	                case "POP":
	                    dto.setRainProb(value + "%");
	                    break;
	                case "PTY":
	                    dto.setRainType(convertPty(value));
	                    break;
	            }
	        }

//	        날짜별 일출/일몰 캐싱(API 호출 최소화)
	        Map<String, Map<String, String>> sunTimeMap = new HashMap<>();

	        for (WeatherDTO dto : map.values()) {

	            String date = dto.getFcstDate();
	            
	            Map<String, String> sunInfo = sunTimeMap.get(date);
	            
//	            해당 날짜 데이터 없으면 api 호출
	            if (sunInfo == null) {
	                sunInfo = getSunTime(date, city);
	                sunTimeMap.put(date, sunInfo);
	            }
	            
	            String sunrise = sunInfo.get("sunrise");
	            String sunset = sunInfo.get("sunset");
	            
	            //화면 표시용 (HH:mm 형태)
	            dto.setSunrise(formatSunset(sunrise));
	            dto.setSunset(formatSunset(sunset));
	            
	            //상태 판단
	            dto.setRainy(dto.getRainType() != null && !"없음".equals(dto.getRainType()));
	            dto.setCloudy("흐림".equals(dto.getSkyStatus()) || "구름많음".equals(dto.getSkyStatus()));
	            
	            //야간 여부
	            dto.setNight(isNightBySun(dto.getFcstTime(), sunrise, sunset));
	            
	            dto.setWeatherIcon(getWeatherIcon(dto.getSkyStatus(), dto.getRainType()));
	            weatherList.add(dto);
	            
	            
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	        return weatherList;

	    } finally {
	        try {
	            if (br != null) br.close();
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	    }
		return weatherList;
	   
	}

	/*
	  전체 도시 날씨를 가져오는 메서드
	  광역시/주요 도시 목록을 순회하면서 각 도시의 날씨 데이터를 가져와 하나의 리스트로 합침
	*/
	@Override
	public List<WeatherDTO> forecast() {
		List<WeatherDTO> weatherList = new ArrayList<>();
		
		//도시별 좌표 정보 가져오기
		Map<String, String[]> cityMap = getCityMap();
		
		//각 도시마다 API 호출
		for(Map.Entry<String, String[]> entry : cityMap.entrySet()) {
			String city = entry.getKey();
			String nx = entry.getValue()[0];
			String ny = entry.getValue()[1];
			
			weatherList.addAll(getCityWeather(city, nx, ny));
		}
		return weatherList;
	}

	@Override
	public List<WeatherDTO> forecastByAddress(String address) {
	    log.info("@# forecastByAddress()");
	    log.info("@# address => " + address);

	    // 주소 문자열에서 대표 도시 추출
	    String city = getCityFromAddress(address);
	    log.info("@# city => " + city);

	    // 캐시 key: 도시 기준
	    String cacheKey = city;

	    long now = System.currentTimeMillis();

	    // 캐시에 데이터가 있고, 30분이 지나지 않았으면 API 호출 없이 재사용
	    if (weatherCache.containsKey(cacheKey) && weatherCacheTime.containsKey(cacheKey)) {
	        long savedTime = weatherCacheTime.get(cacheKey);

	        if (now - savedTime < WEATHER_CACHE_MILLIS) {
	            log.info("@# weather cache hit => " + cacheKey);
	            return weatherCache.get(cacheKey);
	        }
	    }

	    log.info("@# weather cache miss => " + cacheKey);

	    // 대표 도시를 기상청 격자 좌표로 변환
	    String[] xy = getNxNyByCity(city);
	    log.info("@# nx => " + xy[0] + ", ny => " + xy[1]);

	    // 해당 도시의 날씨 조회
	    List<WeatherDTO> weatherList = getCityWeather(city, xy[0], xy[1]);

	    // 조회 성공 시 캐시에 저장
	    if (weatherList != null && !weatherList.isEmpty()) {
	        weatherCache.put(cacheKey, weatherList);
	        weatherCacheTime.put(cacheKey, now);

	        log.info("@# weather cache save => " + cacheKey);
	    }

	    return weatherList;
	}
}


























