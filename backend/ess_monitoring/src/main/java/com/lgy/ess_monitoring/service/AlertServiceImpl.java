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
    public List<AlertDTO> getAlertList(int memberId) {
        return getDao().getAlertList(memberId);
    }

    @Override
    public AlertDTO getAlertDetail(int alertId, int memberId) {
        return getDao().getAlertDetail(alertId, memberId);
    }

    @Override
    public int updateAlertStatus(int alertId, int memberId, String status) {
        return getDao().updateAlertStatus(alertId, memberId, status);
    }

    @Override
    public void createAlertIfNeeded(
            int deviceId,
            BigDecimal soc,
            BigDecimal voltage,
            BigDecimal solarGenerationKwh
    ) {

        if (soc == null) {
            return;
        }

        double socValue = soc.doubleValue();

        // ===============================
        // SOC CRITICAL
        // ===============================
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

        // ===============================
        // SOC WARNING
        // ===============================
        if (socValue <= 20) {

            createAlertIfNotExists(
                    deviceId,
                    "SOC_LOW",
                    "WARNING",
                    "SOC가 20% 이하입니다.",
                    "CHARGE_RECOMMENDED"
            );
        }

        // ===============================
        // 전압 경고
        // ===============================
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

        // ===============================
        // 발전량 거의 없음
        // ===============================
        if (solarGenerationKwh != null) {

            double generation =
                    solarGenerationKwh.doubleValue();

            if (generation <= 0.001) {

                createAlertIfNotExists(
                        deviceId,
                        "LOW_GENERATION",
                        "INFO",
                        "현재 발전량이 매우 낮습니다.",
                        "WEATHER_CHECK"
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
}