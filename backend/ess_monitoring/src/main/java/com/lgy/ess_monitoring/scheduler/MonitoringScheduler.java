package com.lgy.ess_monitoring.scheduler;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.SimulationService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MonitoringScheduler {

    @Autowired
    private EssDeviceService deviceService;

    @Autowired
    private SimulationService simulationService;

    // 테스트용: 1분마다 실행
//    @Scheduled(fixedRate = 60000)
    public void runMonitoringSimulation() {
        log.info("@# [Scheduler] 모니터링 시뮬레이션 시작");

        List<EssDeviceDTO> deviceList = deviceService.getAllActiveDevices();

        if (deviceList == null || deviceList.isEmpty()) {
            log.info("@# [Scheduler] 실행 대상 장비 없음");
            return;
        }

        for (EssDeviceDTO device : deviceList) {
            try {
                log.info("@# [Scheduler] deviceId={} 실행", device.getDeviceId());
                simulationService.runSimulation(device.getDeviceId());

            } catch (Exception e) {
                log.error("@# [Scheduler] deviceId={} 실행 실패", device.getDeviceId(), e);
            }
        }

        log.info("@# [Scheduler] 모니터링 시뮬레이션 종료");
    }
}
