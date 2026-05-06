package com.lgy.ess_monitoring.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssMonitoringDAO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;
import com.lgy.ess_monitoring.dto.WeatherDataDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class SimulationServiceImpl implements SimulationService {

    @Autowired
    private EssDeviceService deviceService;

    @Autowired
    private WeatherDataService weatherDataService;

    @Autowired
    private AlertService alertService;

    @Autowired
    private SqlSession sqlSession;

    private EssMonitoringDAO getDao() {
        return sqlSession.getMapper(EssMonitoringDAO.class);
    }

    @Override
    public void runSimulation(int deviceId) {
        log.info("@# runSimulation() deviceId => " + deviceId);

        try {
            // 장비 정보 조회
            EssDeviceDTO device = deviceService.deviceDetail(deviceId);

            if (device == null) {
                log.warn("@# device 없음 deviceId => " + deviceId);
                return;
            }

            // 현재 날씨 조회
            WeatherDataDTO weather = weatherDataService.getOrFetchCurrentWeather(deviceId);

            if (weather == null) {
                log.warn("@# weather 없음 deviceId => " + deviceId);
                return;
            }

            // 이전 모니터링 데이터 조회
            EssMonitoringDTO latest = getDao().getLatestMonitoring(deviceId);

            // 설비 기본값
            double capacityKw = device.getCapacityKw();
            double essCapacityKwh = device.getEssCapacityKwh();
            double chargeEfficiency = device.getChargeEfficiency() / 100.0;
            double electricityRate = device.getElectricityRate();

            if (capacityKw <= 0 || essCapacityKwh <= 0) {
                log.warn(
                    "@# 설비 용량 오류 deviceId=" + deviceId
                    + ", capacityKw=" + capacityKw
                    + ", essCapacityKwh=" + essCapacityKwh
                );
                return;
            }

            // 날씨 기반 발전 효율
            double weatherFactor = getWeatherFactor(weather);

            // 일사량 기반 보정값
            double radiationFactor = getRadiationFactor(weather);

            // 시간대별 태양광 발전 보정
            radiationFactor =
                    applyTimeFactor(radiationFactor, weather);

            // 태양광 시스템 손실률 반영
            double systemEfficiency = 0.85;

            // 출력 변동률: ±3%
            double outputNoise = 0.97 + (Math.random() * 0.06);

            // 현재 출력 전력(kW)
            double powerOutput =
                    capacityKw
                    * weatherFactor
                    * radiationFactor
                    * systemEfficiency
                    * outputNoise;

            if (powerOutput < 0) {
                powerOutput = 0;
            }

            if (powerOutput > capacityKw) {
                powerOutput = capacityKw;
            }

            // 1분 단위 발전량(kWh)
            double solarGenerationKwh = powerOutput / 60.0;

            // 1분 단위 충전량(kWh)
            double chargedEnergyKwh = solarGenerationKwh * chargeEfficiency;

            // 부하 변동률: ±10%
            double loadNoise = 0.90 + (Math.random() * 0.20);

            // 1분 단위 사용량(kWh)
            double usedEnergyKwh =
                    calculateUsedEnergyPerMinute(device, weather)
                    * loadNoise;

            // 충전/방전 속도 제한
            double maxChargePerMinute = essCapacityKwh * 0.02;
            double maxDischargePerMinute = essCapacityKwh * 0.025;

            if (chargedEnergyKwh > maxChargePerMinute) {
                chargedEnergyKwh = maxChargePerMinute;
            }

            if (usedEnergyKwh > maxDischargePerMinute) {
                usedEnergyKwh = maxDischargePerMinute;
            }

            // 이전 충전량(kWh)
            double previousChargeKwh = getPreviousChargeKwh(device, latest);

            // 현재 충전량(kWh)
            double currentChargeKwh =
                    previousChargeKwh
                    + chargedEnergyKwh
                    - usedEnergyKwh;

            if (currentChargeKwh < 0) {
                currentChargeKwh = 0;
            }

            if (currentChargeKwh > essCapacityKwh) {
                currentChargeKwh = essCapacityKwh;
            }

            // SOC(%)
            double soc = (currentChargeKwh / essCapacityKwh) * 100.0;

            if (soc < 0) {
                soc = 0;
            }

            if (soc > 100) {
                soc = 100;
            }

            // 전압(V)
            double voltage = calculateVoltage(device, soc);

            // 전압 변동률: ±1.5%
            double voltageNoise = 0.985 + (Math.random() * 0.03);
            voltage = voltage * voltageNoise;

            // 전류(A) = P(kW) * 1000 / (V * 효율)
            double currentA = 0;

            if (voltage > 0) {
                currentA =
                        (powerOutput * 1000.0)
                        / (voltage * 0.92);
            }

            // 1분 기준 절감 금액
            double savedCost = solarGenerationKwh * electricityRate;

            // DTO 생성
            EssMonitoringDTO dto = new EssMonitoringDTO();

            dto.setDeviceId(deviceId);
            dto.setVoltage(toDecimal(voltage, 2));
            dto.setCurrentA(toDecimal(currentA, 2));
            dto.setSoc(toDecimal(soc, 2));
            dto.setPowerOutput(toDecimal(powerOutput, 2));
            dto.setSolarGenerationKwh(toDecimal(solarGenerationKwh, 4));
            dto.setChargedEnergyKwh(toDecimal(chargedEnergyKwh, 4));
            dto.setUsedEnergyKwh(toDecimal(usedEnergyKwh, 4));
            dto.setSavedCost(toDecimal(savedCost, 2));

            // 모니터링 저장
            getDao().insertMonitoring(dto);

            // 알림 자동 생성
            alertService.createAlertIfNeeded(
                    deviceId,
                    dto.getSoc(),
                    dto.getVoltage(),
                    dto.getSolarGenerationKwh()
            );

            log.info(
                "@# monitoring 저장 완료 deviceId=" + deviceId
                + ", soc=" + dto.getSoc()
                + ", generation=" + dto.getSolarGenerationKwh() + "kWh"
                + ", powerOutput=" + dto.getPowerOutput() + "kW"
            );

        } catch (Exception e) {
            log.error("@# simulation error deviceId => " + deviceId, e);
        }
    }

    // 날씨 상태별 발전 효율
    private double getWeatherFactor(WeatherDataDTO weather) {
        double factor = 1.0;

        if ("맑음".equals(weather.getSkyStatus())) {
            factor = 1.0;
        } else if ("구름많음".equals(weather.getSkyStatus())) {
            factor = 0.7;
        } else if ("흐림".equals(weather.getSkyStatus())) {
            factor = 0.4;
        }

        if (weather.getRainType() != null
                && !"없음".equals(weather.getRainType())) {
            factor *= 0.45;
        }

        return factor;
    }

    // 일사량 기반 보정값
    private double getRadiationFactor(WeatherDataDTO weather) {
        if (weather.getSolarRadiation() == null) {
            return 0.75;
        }

        double radiation = weather.getSolarRadiation().doubleValue();

        if (radiation <= 0) {
            return 0.1;
        }

        double factor = radiation / 1000.0;

        if (factor > 1.0) {
            factor = 1.0;
        }

        if (factor < 0.1) {
            factor = 0.1;
        }

        return factor;
    }

 // ===============================
 // 일출/일몰 기반 발전량 보정
 // ===============================
 private double applyTimeFactor(
         double radiationFactor,
         WeatherDataDTO weather
 ) {

     java.util.Calendar cal =
             java.util.Calendar.getInstance();

     int currentHour =
             cal.get(java.util.Calendar.HOUR_OF_DAY);

     int sunriseHour = 6;
     int sunsetHour = 19;

     try {

         // sunrise 예: "0540"
         if (weather.getSunrise() != null
                 && weather.getSunrise().length() >= 2) {

             sunriseHour =
                     Integer.parseInt(
                         weather.getSunrise().substring(0, 2)
                     );
         }

         // sunset 예: "1918"
         if (weather.getSunset() != null
                 && weather.getSunset().length() >= 2) {

             sunsetHour =
                     Integer.parseInt(
                         weather.getSunset().substring(0, 2)
                     );
         }

     } catch (Exception e) {

         log.warn(
             "@# sunrise/sunset parsing 실패 → 기본시간 사용"
         );
     }

     // ===============================
     // 야간 발전 없음
     // ===============================
     if (currentHour < sunriseHour
             || currentHour >= sunsetHour) {

         return 0.0;
     }

     // ===============================
     // 태양광 발전 비율 계산
     // ===============================

     // 일출~일몰 전체 시간
     double totalDaylightHours =
             sunsetHour - sunriseHour;

     // 현재 진행률(0~1)
     double progress =
             (currentHour - sunriseHour)
             / totalDaylightHours;

     // ===============================
     // 오전 → 발전 증가
     // ===============================
     if (progress < 0.5) {

         radiationFactor *=
                 (0.4 + progress);
     }

     // ===============================
     // 오후 → 발전 감소
     // ===============================
     else {

         radiationFactor *=
                 (1.4 - progress);
     }

     // ===============================
     // 최대/최소 제한
     // ===============================
     if (radiationFactor > 1.0) {
         radiationFactor = 1.0;
     }

     if (radiationFactor < 0.0) {
         radiationFactor = 0.0;
     }

     return radiationFactor;
 }
    // 이전 충전량 계산
    private double getPreviousChargeKwh(
            EssDeviceDTO device,
            EssMonitoringDTO latest
    ) {
        if (latest != null && latest.getSoc() != null) {
            return latest.getSoc().doubleValue()
                    / 100.0
                    * device.getEssCapacityKwh();
        }

        if (device.getCurrentChargeKwh() != null) {
            return device.getCurrentChargeKwh();
        }

        return device.getEssCapacityKwh() * 0.5;
    }

 // 1분 단위 사용량 계산
    private double calculateUsedEnergyPerMinute(
            EssDeviceDTO device,
            WeatherDataDTO weather
    ) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int hour = cal.get(java.util.Calendar.HOUR_OF_DAY);

        // 기본 부하
        double baseLoadKw = device.getCapacityKw() * 0.12;

        // 낮 시간 부하 증가
        if (hour >= 9 && hour <= 18) {
            baseLoadKw *= 1.25;
        }

        // 야간 ESS 사용 증가
        if (hour >= 19 || hour <= 5) {
            baseLoadKw *= 1.4;
        }

        if (weather.getTemperature() != null) {
            double temp = weather.getTemperature().doubleValue();

            if (temp >= 30) {
                baseLoadKw *= 1.15;
            } else if (temp <= 0) {
                baseLoadKw *= 1.1;
            }
        }

        return baseLoadKw / 60.0;
    }

    // 전압 계산
    private double calculateVoltage(EssDeviceDTO device, double soc) {
        double baseVoltage =
                device.getCapacityKw() >= 50
                ? 380.0
                : 220.0;

        if (soc < 20) {
            baseVoltage *= 0.97;
        } else if (soc > 80) {
            baseVoltage *= 1.01;
        }

        return baseVoltage;
    }

    // BigDecimal 변환
    private BigDecimal toDecimal(double value, int scale) {
        return BigDecimal.valueOf(value)
                .setScale(scale, RoundingMode.HALF_UP);
    }
}