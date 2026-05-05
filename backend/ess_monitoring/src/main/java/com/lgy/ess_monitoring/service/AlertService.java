package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.AlertDTO;

public interface AlertService {

    List<AlertDTO> getAlertList(int memberId);

    AlertDTO getAlertDetail(int alertId, int memberId);

    int updateAlertStatus(int alertId, int memberId, String status);

    void createSocAlertIfNeeded(int deviceId, double soc);
}
