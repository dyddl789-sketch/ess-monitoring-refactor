package com.lgy.ess_monitoring.service;

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
    public void createSocAlertIfNeeded(int deviceId, double soc) {

        if (soc < 20) {
            createAlertIfNotExists(
                    deviceId,
                    "SOC_LOW",
                    "CRITICAL",
                    "SOC가 20% 미만입니다.",
                    "OPEN"
            );
        } else if (soc < 40) {
            createAlertIfNotExists(
                    deviceId,
                    "SOC_LOW",
                    "WARNING",
                    "SOC가 40% 미만입니다.",
                    "OPEN"
            );
        }
    }

    private void createAlertIfNotExists(
            int deviceId,
            String alertType,
            String alertLevel,
            String message,
            String status
    ) {
        int count = getDao().existsOpenAlert(deviceId, alertType);

        if (count > 0) {
            log.info("이미 열린 알림 존재 deviceId={}, alertType={}", deviceId, alertType);
            return;
        }

        AlertDTO alert = new AlertDTO();
        alert.setDeviceId(deviceId);
        alert.setAlertType(alertType);
        alert.setAlertLevel(alertLevel);
        alert.setMessage(message);
        alert.setStatus(status);
        alert.setControlAction(null);

        getDao().insertAlert(alert);
    }
}
