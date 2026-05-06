package com.lgy.ess_monitoring.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URL;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lgy.ess_monitoring.dao.WeatherDataDAO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.WeatherDataDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class WeatherDataServiceImpl implements WeatherDataService {

    @Autowired
    private SqlSession sqlSession;

    @Autowired
    private EssDeviceService deviceService;

    // DAO 가져오기 (중복 제거)
    private WeatherDataDAO getDao() {
        return sqlSession.getMapper(WeatherDataDAO.class);
    }

    // ===============================
    // SKY 코드 변환
    // ===============================
    private String convertSky(String value) {
        if ("1".equals(value)) return "맑음";
        if ("3".equals(value)) return "구름많음";
        if ("4".equals(value)) return "흐림";
        return value;
    }

    // ===============================
    // PTY 코드 변환
    // ===============================
    private String convertPty(String value) {
        if ("0".equals(value)) return "없음";
        if ("1".equals(value)) return "비";
        if ("2".equals(value)) return "비/눈";
        if ("3".equals(value)) return "눈";
        if ("4".equals(value)) return "소나기";
        return value;
    }

    // ===============================
    // base_time 계산
    // ===============================
    private String getBaseTime() {
        LocalTime now = LocalTime.now();
        int hour = now.getHour();
        int minute = now.getMinute();

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

    // ===============================
    // base_date 계산
    // ===============================
    private String getBaseDate(String baseTime) {
        LocalDate today = LocalDate.now();

        if ("2300".equals(baseTime) && LocalTime.now().getHour() < 2) {
            today = today.minusDays(1);
        }

        return today.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    }

    // ===============================
    // 현재 날씨 조회
    // ===============================
    @Override
    public WeatherDataDTO getCurrentWeather(int deviceId) {
        log.info("getCurrentWeather deviceId={}", deviceId);
        return getDao().getCurrentWeather(deviceId);
    }

    // ===============================
    // 시간별 날씨 목록 조회
    // ===============================
    @Override
    public List<WeatherDataDTO> getWeatherList(int deviceId) {
        log.info("getWeatherList deviceId={}", deviceId);

        List<WeatherDataDTO> list = getDao().getWeatherList(deviceId);
        return list == null ? new ArrayList<>() : list;
    }

    // ===============================
    // API 호출 → DTO 변환
    // ===============================
    @Override
    public List<WeatherDataDTO> fetchWeatherByDeviceId(int deviceId) {

        List<WeatherDataDTO> resultList = new ArrayList<>();

        try {
            EssDeviceDTO device = deviceService.deviceDetail(deviceId);

            if (device == null) {
                log.warn("device 없음 deviceId={}", deviceId);
                return resultList;
            }

            String nx = String.valueOf(device.getNx());
            String ny = String.valueOf(device.getNy());

            if ("0".equals(nx) || "0".equals(ny)) {
                log.warn("좌표 없음 deviceId={}", deviceId);
                return resultList;
            }

            String serviceKey = "0158e6e63feeaa94d850ceb2717eb35dd38ef7e913623ad5170645f214bc880e";

            String baseTime = getBaseTime();
            String baseDate = getBaseDate(baseTime);

            StringBuilder urlBuilder = new StringBuilder(
                "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
            );

            urlBuilder.append("?serviceKey=").append(serviceKey);
            urlBuilder.append("&dataType=JSON");
            urlBuilder.append("&base_date=").append(baseDate);
            urlBuilder.append("&base_time=").append(baseTime);
            urlBuilder.append("&nx=").append(nx);
            urlBuilder.append("&ny=").append(ny);

            URL url = new URL(urlBuilder.toString());

            BufferedReader br = new BufferedReader(
                new InputStreamReader(url.openStream(), "UTF-8")
            );

            StringBuilder sb = new StringBuilder();
            String line;

            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            br.close();

            ObjectMapper mapper = new ObjectMapper();
            JsonNode items = mapper.readTree(sb.toString())
                .path("response").path("body").path("items").path("item");

            Map<String, WeatherDataDTO> map = new LinkedHashMap<>();

            for (JsonNode item : items) {
                String key = item.path("fcstDate").asText() + "_" + item.path("fcstTime").asText();

                map.putIfAbsent(key, new WeatherDataDTO());
                WeatherDataDTO dto = map.get(key);

                dto.setDeviceId(deviceId);
                dto.setFcstDate(item.path("fcstDate").asText());
                dto.setFcstTime(item.path("fcstTime").asText());

                String category = item.path("category").asText();
                String value = item.path("fcstValue").asText();

                switch (category) {
                    case "TMP": dto.setTemperature(new BigDecimal(value)); break;
                    case "SKY": dto.setSkyStatus(convertSky(value)); break;
                    case "PTY": dto.setRainType(convertPty(value)); break;
                }
            }

            resultList.addAll(map.values());

        } catch (Exception e) {
            log.error("API 오류", e);
        }

        return resultList;
    }

    // ===============================
    // API → DB 저장
    // ===============================
    @Override
    public void fetchAndSaveWeatherByDeviceId(int deviceId) {

        List<WeatherDataDTO> list = fetchWeatherByDeviceId(deviceId);

        for (WeatherDataDTO dto : list) {
            getDao().insertWeatherData(dto);
        }
    }

    // ===============================
    // 현재 날씨 (없으면 API)
    // ===============================
    @Override
    public WeatherDataDTO getOrFetchCurrentWeather(int deviceId) {

        WeatherDataDTO weather = getDao().getCurrentWeather(deviceId);

        if (weather == null) {
            fetchAndSaveWeatherByDeviceId(deviceId);
            weather = getDao().getCurrentWeather(deviceId);
        }

        return weather;
    }

    // ===============================
    // 날씨 목록 (없으면 API)
    // ===============================
    @Override
    public List<WeatherDataDTO> getOrFetchWeatherList(int deviceId) {

        List<WeatherDataDTO> list = getDao().getWeatherList(deviceId);

        if (list == null || list.isEmpty()) {
            fetchAndSaveWeatherByDeviceId(deviceId);
            list = getDao().getWeatherList(deviceId);
        }

        return list;
    }
}