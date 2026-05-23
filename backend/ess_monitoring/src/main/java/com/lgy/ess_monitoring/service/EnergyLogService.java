package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.EnergyLogDTO;

public interface EnergyLogService {

    EnergyLogDTO getEnergyLogByDeviceAndDate(
            int deviceId,
            String logDate
    );

    List<EnergyLogDTO> getEnergyLogListByDevice(
            int deviceId
    );

    int saveEnergyLog(EnergyLogDTO dto);

    int deleteEnergyLogByDevice(
            int deviceId
    );
    
 // 특정 장비의 선택일 모니터링 데이터를 집계해서 energy_log 저장
    int aggregateDailyEnergyLog(
            int deviceId,
            String logDate
    );

    // 회원의 전체 장비 선택일 집계
    int aggregateDailyEnergyLogByMember(
            int memberId,
            String logDate
    );
}
