package com.lgy.ess_monitoring.service;

import java.math.BigDecimal;
import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.AlertDAO;
import com.lgy.ess_monitoring.dto.AlertDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class AlertServiceImpl implements AlertService {

    @Autowired
    private SqlSession sqlSession;

    private AlertDAO getDao() {
        return sqlSession.getMapper(AlertDAO.class);
    }

    @Override
    public List<AlertDTO> getAlertList(
            int memberId,
            String alertLevel,
            String status
    ) {

        log.info("@# getAlertList()");
        log.info("@# memberId => {}", memberId);
        log.info("@# alertLevel => {}", alertLevel);
        log.info("@# status => {}", status);

        return getDao().getAlertList(
                memberId,
                alertLevel,
                status
        );
    }

    @Override
    public AlertDTO getAlertDetail(int alertId, int memberId) {
        return getDao().getAlertDetail(alertId, memberId);
    }

    @Override
    public int updateAlertStatus(int alertId, int memberId, String status) {
        return getDao().updateAlertStatus(alertId, memberId, status);
    }
    
 // 특정 장비 최근 알림 조회
    @Override
    public List<AlertDTO> getRecentAlertsByDeviceId(int deviceId) {
        log.info("@# getRecentAlertsByDeviceId()");
        log.info("@# deviceId => {}", deviceId);

        return getDao().getRecentAlertsByDeviceId(deviceId);
    }

    @Override
    public void createAlertIfNeeded(
            int deviceId,
            BigDecimal soc,
            BigDecimal voltage,
            BigDecimal solarGenerationKwh,
            BigDecimal powerOutput
    ) {

        if (soc == null) {
            return;
        }

        double socValue = soc.doubleValue();

        // SOC 위험
        if (socValue <= 10) {

            createAlertIfNotExists(
                    deviceId,
                    "SOC_CRITICAL",
                    "CRITICAL",
                    "SOC가 10% 이하입니다. 즉시 충전이 필요합니다.",
                    "AUTO_CHARGE"
            );

            return;
        }

        // SOC 경고
        if (socValue <= 20) {

            createAlertIfNotExists(
                    deviceId,
                    "SOC_LOW",
                    "WARNING",
                    "SOC가 20% 이하입니다.",
                    "CHARGE_RECOMMENDED"
            );
        }

        // 전압 경고
        if (voltage != null) {

            double voltageValue = voltage.doubleValue();

            if (voltageValue < 210) {

                createAlertIfNotExists(
                        deviceId,
                        "LOW_VOLTAGE",
                        "WARNING",
                        "전압이 낮습니다.",
                        "VOLTAGE_CHECK"
                );
            }
        }

        // 발전량 거의 없음
        if (solarGenerationKwh != null) {

            double generation =
                    solarGenerationKwh.doubleValue();

            if (generation <= 0.001) {

                createAlertIfNotExists(
                        deviceId,
                        "LOW_GENERATION",
                        "WARNING",
                        "현재 발전량이 매우 낮습니다.",
                        "WEATHER_CHECK"
                );
            }
        }

        // 출력 급감 위험
        if (powerOutput != null) {

            double output =
                    powerOutput.doubleValue();

            if (output < 1.0) {

                createAlertIfNotExists(
                        deviceId,
                        "OUTPUT_DROP",
                        "CRITICAL",
                        "출력 전력이 급격히 감소했습니다.",
                        "PCS 및 인버터 상태 점검 필요"
                );
            }
        }
    }

    // ===============================
    // 중복 방지 후 생성
    // ===============================
    private void createAlertIfNotExists(
            int deviceId,
            String alertType,
            String alertLevel,
            String message,
            String controlAction
    ) {

        int exists =
                getDao().existsOpenAlert(deviceId, alertType);

        if (exists > 0) {

            log.info(
                "@# 이미 열린 알림 존재 deviceId="
                + deviceId
                + ", alertType="
                + alertType
            );

            return;
        }

        AlertDTO alert =
                new AlertDTO();

        alert.setDeviceId(deviceId);
        alert.setAlertType(alertType);
        alert.setAlertLevel(alertLevel);
        alert.setMessage(message);
        alert.setStatus("OPEN");
        alert.setControlAction(controlAction);

        getDao().insertAlert(alert);

        log.info(
            "@# 알림 생성 완료 deviceId="
            + deviceId
            + ", type="
            + alertType
        );
    }
 // 대시보드 필터 기준 최근 알림 조회
    @Override
    public List<AlertDTO> getDashboardAlerts(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        log.info("@# getDashboardAlerts()");
        log.info("@# memberId => {}", memberId);
        log.info("@# selectedDate => {}", selectedDate);

        return getDao().getDashboardAlerts(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }
    


    @Override
    public void confirmAlert(int alertId, int memberId) {

        AlertDAO dao =
            sqlSession.getMapper(AlertDAO.class);

        dao.confirmAlert(alertId, memberId);
    }
}