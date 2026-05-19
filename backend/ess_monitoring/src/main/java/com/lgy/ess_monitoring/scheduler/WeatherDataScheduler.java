package com.lgy.ess_monitoring.scheduler;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.lgy.ess_monitoring.dao.SchedulerDAO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.service.WeatherDataService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class WeatherDataScheduler {

    @Autowired
    private SqlSession sqlSession;

    @Autowired
    private WeatherDataService weatherDataService;

    private SchedulerDAO getDao() {
        return sqlSession.getMapper(SchedulerDAO.class);
    }

    /*
     * 전체 장비 날씨 데이터 자동 수집
     * 테스트용: 1분마다
     * 운영용: 30분~1시간 추천
     */
    @Scheduled(cron = "0 */1 * * * *")
    public void collectWeatherData() {

        log.info("WeatherDataScheduler start");

        List<EssDeviceDTO> deviceList =
                getDao().getActiveDeviceList();

        if (deviceList == null || deviceList.isEmpty()) {
            log.info("weather device empty");
            return;
        }

        for (EssDeviceDTO device : deviceList) {

            try {
                if (device.getNx() == null || device.getNy() == null) {
                    log.info(
                        "weather skip deviceId="
                        + device.getDeviceId()
                        + ", reason=nx/ny empty"
                    );
                    continue;
                }

                weatherDataService.getOrFetchWeatherList(
                        device.getDeviceId()
                );

                log.info(
                    "weather collected deviceId="
                    + device.getDeviceId()
                    + ", deviceName="
                    + device.getDeviceName()
                );

            } catch (Exception e) {
                log.error(
                    "weather collect failed deviceId="
                    + device.getDeviceId(),
                    e
                );
            }
        }

        log.info("WeatherDataScheduler end");
    }
}