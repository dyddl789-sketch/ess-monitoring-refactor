package com.lgy.ess_monitoring.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URL;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
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

    private final Map<String, String[]> sunCache = new HashMap<>();

    private static final String SERVICE_KEY =
            "0158e6e63feeaa94d850ceb2717eb35dd38ef7e913623ad5170645f214bc880e";

    private WeatherDataDAO getDao() {
        return sqlSession.getMapper(WeatherDataDAO.class);
    }

    private String convertSky(String value) {
        if ("1".equals(value)) return "맑음";
        if ("3".equals(value)) return "구름많음";
        if ("4".equals(value)) return "흐림";
        return value;
    }

    private String convertPty(String value) {
        if ("0".equals(value)) return "없음";
        if ("1".equals(value)) return "비";
        if ("2".equals(value)) return "비/눈";
        if ("3".equals(value)) return "눈";
        if ("4".equals(value)) return "소나기";
        return value;
    }

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

    private String getBaseDate(String baseTime) {
        LocalDate today = LocalDate.now();

        if ("2300".equals(baseTime) && LocalTime.now().getHour() < 2) {
            today = today.minusDays(1);
        }

        return today.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    }

    private String getSunDate() {
        return LocalDate.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd"));
    }

    @Override
    public WeatherDataDTO getCurrentWeather(int deviceId) {
        return getDao().getCurrentWeather(deviceId);
    }

    @Override
    public List<WeatherDataDTO> getWeatherList(int deviceId) {
        List<WeatherDataDTO> list = getDao().getWeatherList(deviceId);
        return list == null ? new ArrayList<>() : list;
    }

    @Override
    public List<WeatherDataDTO> fetchWeatherByDeviceId(int deviceId) {

        List<WeatherDataDTO> resultList = new ArrayList<>();

        try {
            EssDeviceDTO device = deviceService.deviceDetail(deviceId);

            if (device == null) {
                log.warn("@# device 없음 deviceId={}", deviceId);
                return resultList;
            }

            String nx = String.valueOf(device.getNx());
            String ny = String.valueOf(device.getNy());

            if ("0".equals(nx) || "0".equals(ny)) {
                log.warn("@# 좌표 없음 deviceId={}", deviceId);
                return resultList;
            }

            String baseTime = getBaseTime();
            String baseDate = getBaseDate(baseTime);
            String sunDate = getSunDate();

            String[] sunInfo = getSunriseSunset(
                    sunDate,
                    device.getLatitude(),
                    device.getLongitude()
            );

            String sunrise = sunInfo[0];
            String sunset = sunInfo[1];

            log.info("@# 최종 sunrise => {}", sunrise);
            log.info("@# 최종 sunset => {}", sunset);

            StringBuilder urlBuilder = new StringBuilder(
                    "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
            );

            urlBuilder.append("?serviceKey=").append(SERVICE_KEY);
            urlBuilder.append("&dataType=JSON");
            urlBuilder.append("&pageNo=1");
            urlBuilder.append("&numOfRows=1000");
            urlBuilder.append("&base_date=").append(baseDate);
            urlBuilder.append("&base_time=").append(baseTime);
            urlBuilder.append("&nx=").append(nx);
            urlBuilder.append("&ny=").append(ny);

            URL url = new URL(urlBuilder.toString());

            BufferedReader br =
                    new BufferedReader(
                            new InputStreamReader(
                                    url.openStream(),
                                    "UTF-8"
                            )
                    );

            StringBuilder sb = new StringBuilder();
            String line;

            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            br.close();

            ObjectMapper mapper = new ObjectMapper();

            JsonNode items =
                    mapper.readTree(sb.toString())
                            .path("response")
                            .path("body")
                            .path("items")
                            .path("item");

            Map<String, WeatherDataDTO> map = new LinkedHashMap<>();

            for (JsonNode item : items) {

                String key =
                        item.path("fcstDate").asText()
                                + "_"
                                + item.path("fcstTime").asText();

                map.putIfAbsent(key, new WeatherDataDTO());

                WeatherDataDTO dto = map.get(key);

                dto.setDeviceId(deviceId);
                dto.setBaseDate(baseDate);
                dto.setBaseTime(baseTime);
                dto.setFcstDate(item.path("fcstDate").asText());
                dto.setFcstTime(item.path("fcstTime").asText());
                dto.setSunrise(sunrise);
                dto.setSunset(sunset);

                String category = item.path("category").asText();
                String value = item.path("fcstValue").asText();

                switch (category) {
                    case "TMP":
                        dto.setTemperature(new BigDecimal(value));
                        break;

                    case "SKY":
                        dto.setSkyStatus(convertSky(value));
                        break;

                    case "PTY":
                        dto.setRainType(convertPty(value));
                        break;

                    case "POP":
                        dto.setRainProb(Integer.parseInt(value));
                        break;

                    case "REH":
                        dto.setHumidity(Integer.parseInt(value));
                        break;

                    case "WSD":
                        dto.setWindSpeed(new BigDecimal(value));
                        break;
                }
            }

            for (WeatherDataDTO dto : map.values()) {
                dto.setSolarRadiation(estimateSolarRadiation(dto));
                dto.setEssStatus(analyzeEssStatus(dto));
            }

            resultList.addAll(map.values());

        } catch (Exception e) {
            log.error("@# 날씨 API 오류", e);
        }

        return resultList;
    }

    @Override
    public void fetchAndSaveWeatherByDeviceId(int deviceId) {
        List<WeatherDataDTO> list = fetchWeatherByDeviceId(deviceId);

        for (WeatherDataDTO dto : list) {
            getDao().insertWeatherData(dto);
        }
    }

    @Override
    public WeatherDataDTO getOrFetchCurrentWeather(int deviceId) {

        String currentBaseTime = getBaseTime();
        String currentBaseDate = getBaseDate(currentBaseTime);

        WeatherDataDTO weather = getDao().getCurrentWeather(deviceId);

        boolean needRefresh = false;

        if (weather == null) {
            needRefresh = true;
        } else if (
                !currentBaseDate.equals(weather.getBaseDate())
                        || !currentBaseTime.equals(weather.getBaseTime())
        ) {
            needRefresh = true;
        }

        if (needRefresh) {
            fetchAndSaveWeatherByDeviceId(deviceId);
            weather = getDao().getCurrentWeather(deviceId);
        }

        return weather;
    }

    @Override
    public List<WeatherDataDTO> getOrFetchWeatherList(int deviceId) {

        List<WeatherDataDTO> list = getDao().getWeatherList(deviceId);

        if (list == null || list.isEmpty()) {
            fetchAndSaveWeatherByDeviceId(deviceId);
            list = getDao().getWeatherList(deviceId);
        }

        return list;
    }

    private BigDecimal estimateSolarRadiation(WeatherDataDTO dto) {

        double radiation = 850.0;

        if ("구름많음".equals(dto.getSkyStatus())) {
            radiation *= 0.7;
        } else if ("흐림".equals(dto.getSkyStatus())) {
            radiation *= 0.4;
        }

        if (dto.getRainType() != null && !"없음".equals(dto.getRainType())) {
            radiation *= 0.3;
        }

        if (dto.getRainProb() != null && dto.getRainProb() >= 70) {
            radiation *= 0.6;
        }

        if (dto.getHumidity() != null && dto.getHumidity() >= 85) {
            radiation *= 0.85;
        }

        if (dto.getFcstTime() != null && dto.getFcstTime().length() >= 2) {

            int hour = Integer.parseInt(dto.getFcstTime().substring(0, 2));

            int sunriseHour = 6;
            int sunsetHour = 19;

            try {
                if (dto.getSunrise() != null && dto.getSunrise().length() >= 2) {
                    sunriseHour = Integer.parseInt(dto.getSunrise().substring(0, 2));
                }

                if (dto.getSunset() != null && dto.getSunset().length() >= 2) {
                    sunsetHour = Integer.parseInt(dto.getSunset().substring(0, 2));
                }
            } catch (Exception e) {
                log.warn("@# sunrise/sunset parsing 실패");
            }

            if (hour < sunriseHour || hour >= sunsetHour) {
                radiation = 0;
            } else if (hour >= 11 && hour <= 14) {
                radiation *= 1.0;
            } else if (hour >= 9 && hour < 11) {
                radiation *= 0.75;
            } else if (hour > 14 && hour <= 16) {
                radiation *= 0.65;
            } else {
                radiation *= 0.35;
            }
        }

        return BigDecimal.valueOf(radiation)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private String analyzeEssStatus(WeatherDataDTO dto) {

        if (dto.getSolarRadiation() == null) {
            return "분석불가";
        }

        double radiation = dto.getSolarRadiation().doubleValue();

        if (radiation >= 650) {
            return "발전양호";
        } else if (radiation >= 300) {
            return "발전보통";
        } else if (radiation > 0) {
            return "발전낮음";
        }

        return "발전없음";
    }

    private String extractXmlValue(String xml, String tagName) {

        if (xml == null || xml.isEmpty()) {
            return null;
        }

        String startTag = "<" + tagName + ">";
        String endTag = "</" + tagName + ">";

        int start = xml.indexOf(startTag);
        int end = xml.indexOf(endTag);

        if (start == -1 || end == -1) {
            return null;
        }

        return xml.substring(start + startTag.length(), end).trim();
    }

    private String[] getSunriseSunset(
            String locDate,
            BigDecimal latitude,
            BigDecimal longitude
    ) {
        clearOldSunCache();

        if (latitude == null || longitude == null) {
            log.warn("@# 위도/경도 없음. fallback 사용");
            return new String[] {"0600", "1900"};
        }

        String cacheKey = locDate + "_" + latitude + "_" + longitude;

        if (sunCache.containsKey(cacheKey)) {
            log.info("@# sunrise/sunset cache 사용 => {}", cacheKey);
            return sunCache.get(cacheKey);
        }

        try {
            String apiUrl =
                    "https://apis.data.go.kr/B090041/openapi/service/RiseSetInfoService/getLCRiseSetInfo"
                            + "?serviceKey=" + SERVICE_KEY
                            + "&locdate=" + locDate
                            + "&longitude=" + longitude
                            + "&latitude=" + latitude
                            + "&dnYn=Y";

            log.info("@# sunrise api url => {}", apiUrl);

            URL url = new URL(apiUrl);

            BufferedReader br =
                    new BufferedReader(
                            new InputStreamReader(
                                    url.openStream(),
                                    "UTF-8"
                            )
                    );

            StringBuilder sb = new StringBuilder();
            String line;

            while ((line = br.readLine()) != null) {
                sb.append(line);
            }

            br.close();

            String xml = sb.toString();

            log.info("@# sunrise api response => {}", xml);

            String resultCode = extractXmlValue(xml, "resultCode");
            String resultMsg = extractXmlValue(xml, "resultMsg");

            log.info("@# sunrise resultCode => {}", resultCode);
            log.info("@# sunrise resultMsg => {}", resultMsg);

            String sunrise = extractXmlValue(xml, "sunrise");
            String sunset = extractXmlValue(xml, "sunset");

            log.info("@# sunrise => {}", sunrise);
            log.info("@# sunset => {}", sunset);

            if (
                    sunrise != null && !sunrise.trim().isEmpty()
                            && sunset != null && !sunset.trim().isEmpty()
            ) {
                String[] result = new String[] {
                        sunrise,
                        sunset
                };

                sunCache.put(cacheKey, result);

                return result;
            }

        } catch (Exception e) {
            log.warn("@# sunrise/sunset API 실패", e);
        }

        log.warn("@# sunrise/sunset 조회 실패. fallback 사용");

        return new String[] {
                "0600",
                "1900"
        };
    }

    private void clearOldSunCache() {

        String today =
                LocalDate.now()
                        .format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        List<String> removeKeys = new ArrayList<>();

        for (String key : sunCache.keySet()) {
            if (!key.startsWith(today)) {
                removeKeys.add(key);
            }
        }

        for (String key : removeKeys) {
            sunCache.remove(key);
        }
    }
}