package com.lgy.ess_monitoring.scheduler;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Random;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.lgy.ess_monitoring.dao.SchedulerDAO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.WeatherDataDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class EssMonitoringScheduler {

    @Autowired
    private SqlSession sqlSession;

    private final Random random = new Random();

    /*
     * 영상 시연용 SOC 하락 모드
     * true  : SOC가 자연스럽게 하락해서 알림 테스트 가능
     * false : 일반 운영 모드
     */
    private static final boolean DEMO_DAY_MODE = true;
    private static final boolean DEMO_DRAIN_MODE = true;

    private SchedulerDAO getDao() {
        return sqlSession.getMapper(SchedulerDAO.class);
    }

    /*
     * 모니터링 자동 생성
     *
     * 테스트/영상용: 10초
     * 운영용 변경: 60000
     */
    @Scheduled(fixedRate = 10000)
    @Transactional
    public void createMonitoringData() {

        log.info("EssMonitoringScheduler start");

        List<EssDeviceDTO> deviceList =
                getDao().getActiveDeviceList();

        if (deviceList == null || deviceList.isEmpty()) {
            log.info("active device empty");
            return;
        }

        for (EssDeviceDTO device : deviceList) {
            createDeviceMonitoring(device);
        }

        log.info("EssMonitoringScheduler end");
    }

    // 장비별 모니터링 데이터 생성
    private void createDeviceMonitoring(EssDeviceDTO device) {

//        LocalTime now = LocalTime.now();
        LocalTime now;
        if (DEMO_DAY_MODE) {
            // 영상 시연용: 항상 오후 1시 기준
            now = LocalTime.of(13, 0);
        } else {
            now = LocalTime.now();
        }

        double capacityKw = safe(device.getCapacityKw());
        double essCapacityKwh = safe(device.getEssCapacityKwh());
        double currentChargeKwh = safe(device.getCurrentChargeKwh());
        double electricityRate = safe(device.getElectricityRate());

        if (essCapacityKwh <= 0) {
            return;
        }

        WeatherDataDTO weather =
                getCurrentWeather(device.getDeviceId(), now);

        double solarFactor =
                getSolarFactor(weather, now);

        double weatherNoise =
                0.97 + random.nextDouble() * 0.04;

        double powerOutput =
                round(capacityKw * solarFactor * weatherNoise);
     // 드레인 모드일 때 출력도 일부 감소
        if (DEMO_DRAIN_MODE) {

            powerOutput =
                    round(powerOutput * 0.88);

        }
        double generatedKwh =
                round(powerOutput / 360.0);

        double usedEnergyKwh;

        if (DEMO_DRAIN_MODE) {
            // 드레인 모드: 사용량 증가로 SOC 감소 유도
            usedEnergyKwh =
                    round(capacityKw * (0.008 + random.nextDouble() * 0.004));
        } else {
            // 정상 낮 모드: 사용량을 작게 설정하여 SOC 유지/상승
            usedEnergyKwh =
                    round(capacityKw * (0.001 + random.nextDouble() * 0.001));
        }

        double chargedEnergyKwh;

        if (DEMO_DAY_MODE) {

            if (DEMO_DRAIN_MODE) {
                // 드레인 모드: 발전은 되지만 충전 효율이 낮은 상태
                chargedEnergyKwh =
                        round(generatedKwh * (0.10 + random.nextDouble() * 0.10));
            } else {
                // 정상 낮 모드: 발전량의 상당 부분이 ESS에 충전
            	chargedEnergyKwh =
            	        round(generatedKwh * (1.20 + random.nextDouble() * 0.30));
            }

        } else {
            // 일반 운영 모드: 발전 후 사용하고 남은 전력만 충전
            chargedEnergyKwh =
                    round(Math.max(generatedKwh - usedEnergyKwh, 0));
        }

        double newChargeKwh =
                currentChargeKwh + chargedEnergyKwh - usedEnergyKwh;

        newChargeKwh =
                Math.max(0, Math.min(newChargeKwh, essCapacityKwh));

        double soc =
                round((newChargeKwh / essCapacityKwh) * 100);

        double voltage =
                round(360 + random.nextDouble() * 30);

        double currentA = powerOutput > 0
                ? round((powerOutput * 1000) / voltage)
                : 0;

        double savedCost =
                round(generatedKwh * electricityRate);

        String status =
                getDeviceStatus(soc,
                        powerOutput,
                        now,
                        weather);

        EssMonitoringDTO dto = new EssMonitoringDTO();

        dto.setDeviceId(device.getDeviceId());
        dto.setVoltage(BigDecimal.valueOf(voltage));

        dto.setCurrentA(BigDecimal.valueOf(currentA));

        dto.setSoc(BigDecimal.valueOf(soc));

        dto.setPowerOutput(BigDecimal.valueOf(powerOutput));

        dto.setSolarGenerationKwh(
                BigDecimal.valueOf(generatedKwh));

        dto.setChargedEnergyKwh(
                BigDecimal.valueOf(chargedEnergyKwh));

        dto.setUsedEnergyKwh(
                BigDecimal.valueOf(usedEnergyKwh));

        dto.setSavedCost(
                BigDecimal.valueOf(savedCost));

        getDao().insertMonitoring(dto);

        getDao().upsertEnergyLog(
                device.getDeviceId(),
                generatedKwh,
                savedCost,
                getEfficiency(generatedKwh, usedEnergyKwh)
        );

        getDao().updateDeviceRuntimeState(
                device.getDeviceId(),
                newChargeKwh,
                status
        );

        createAlertIfNeeded(
                device.getDeviceId(),
                soc,
                powerOutput,
                status
        );

        log.info(
        	    "deviceId=" + device.getDeviceId()
        	    + ", soc=" + soc
        	    + ", status=" + status
        	    + ", generation=" + generatedKwh
        	    + ", savedCost=" + savedCost
        	    + ", solarFactor=" + solarFactor
        	);
    }



    // 장비 대표 상태 판단
    private String getDeviceStatus(
            double soc,
            double powerOutput,
            LocalTime time,
            WeatherDataDTO weather
    ) {

        if (soc <= 10) {
            return "ERROR";
        }

        if (soc <= 25) {
            return "WARNING";
        }

        if (isDaytime(time, weather) && powerOutput <= 0.1) {
            return "WARNING";
        }

        return "NORMAL";
    }

 // weather_data sunrise/sunset 기준 주간 여부 판단
    private boolean isDaytime(
            LocalTime now,
            WeatherDataDTO weather
    ) {

        if (weather == null) {
            return getFallbackDaytime(now);
        }

        try {

            String sunrise = weather.getSunrise();
            String sunset = weather.getSunset();

            if (sunrise == null || sunset == null) {
                return getFallbackDaytime(now);
            }

            if (sunrise.length() < 4 || sunset.length() < 4) {
                return getFallbackDaytime(now);
            }

            LocalTime sunriseTime =
                    LocalTime.of(
                            Integer.parseInt(sunrise.substring(0, 2)),
                            Integer.parseInt(sunrise.substring(2, 4))
                    );

            LocalTime sunsetTime =
                    LocalTime.of(
                            Integer.parseInt(sunset.substring(0, 2)),
                            Integer.parseInt(sunset.substring(2, 4))
                    );

            return !now.isBefore(sunriseTime)
                    && now.isBefore(sunsetTime);

        } catch (Exception e) {

            log.warn("sunrise/sunset parse error", e);

            return getFallbackDaytime(now);
        }
    }


    // fallback 주간 판단
    private boolean getFallbackDaytime(LocalTime now) {

        return !now.isBefore(LocalTime.of(8, 0))
                && now.isBefore(LocalTime.of(18, 0));
    }

    // 효율 계산
    private double getEfficiency(
            double generatedKwh,
            double usedEnergyKwh
    ) {

        if (generatedKwh <= 0) {
            return 80;
        }

        double efficiency =
                ((generatedKwh - usedEnergyKwh) / generatedKwh) * 100;

        return round(
                Math.max(60, Math.min(efficiency, 98))
        );
    }

    // 상태에 따른 알림 생성
    private void createAlertIfNeeded(
            int deviceId,
            double soc,
            double powerOutput,
            String status
    ) {

        if ("ERROR".equals(status)) {

            getDao().insertAlertIfNotExists(
                    deviceId,
                    "SOC_LOW",
                    "CRITICAL",
                    "배터리 충전량이 매우 낮습니다.",
                    "미처리"
            );

            return;
        }

        if ("WARNING".equals(status) && soc <= 25) {

            getDao().insertAlertIfNotExists(
                    deviceId,
                    "SOC_WARNING",
                    "WARNING",
                    "배터리 충전량이 낮습니다.",
                    "미처리"
            );

            return;
        }

        if ("WARNING".equals(status) && powerOutput <= 0.1) {

            getDao().insertAlertIfNotExists(
                    deviceId,
                    "POWER_LOW",
                    "WARNING",
                    "주간 시간대 발전 출력이 낮습니다.",
                    "미처리"
            );
        }
    }

    private double safe(Number value) {

        if (value == null) {
            return 0;
        }

        return value.doubleValue();
    }

    private double round(double value) {

        return Math.round(value * 100.0) / 100.0;
    }
    
 // 현재 시간에 가장 가까운 날씨 예보 조회
    private WeatherDataDTO getCurrentWeather(
            int deviceId,
            LocalTime now
    ) {

        String fcstDate =
                LocalDate.now().format(
                        DateTimeFormatter.ofPattern("yyyyMMdd")
                );

        String fcstTime =
                String.format("%02d00", now.getHour());

        return getDao().getLatestWeatherForScheduler(
                deviceId,
                fcstDate,
                fcstTime
        );
    }

 // weather_data.solar_radiation 기준 발전 보정값
    private double getSolarFactor(
            WeatherDataDTO weather,
            LocalTime now
    ) {

        if (DEMO_DAY_MODE) {
            return 0.85;
        }

        if (weather == null || weather.getSolarRadiation() == null) {
            return getFallbackSolarFactor(now);
        }

        double solarRadiation =
                weather.getSolarRadiation().doubleValue();

        if (solarRadiation <= 0) {
            return 0;
        }

        double factor = solarRadiation / 850.0;

        return Math.max(0, Math.min(factor, 1.1));
    }


    // 날씨 데이터가 없을 때만 사용하는 fallback
    private double getFallbackSolarFactor(LocalTime time) {

        int hour = time.getHour();

        if (hour < 6 || hour >= 19) {
            return 0;
        }

        if (hour < 9) {
            return 0.25;
        }

        if (hour < 12) {
            return 0.65;
        }

        if (hour < 15) {
            return 0.95;
        }

        if (hour < 17) {
            return 0.55;
        }

        return 0.25;
    }

}