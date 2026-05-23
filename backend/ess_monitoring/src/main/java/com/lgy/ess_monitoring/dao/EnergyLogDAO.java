package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.EnergyLogDTO;

public interface EnergyLogDAO {

    EnergyLogDTO getEnergyLogByDeviceAndDate(
            @Param("deviceId") int deviceId,
            @Param("logDate") String logDate
    );

    List<EnergyLogDTO> getEnergyLogListByDevice(
            @Param("deviceId") int deviceId
    );

    int insertEnergyLog(EnergyLogDTO dto);

    int updateEnergyLog(EnergyLogDTO dto);

    int upsertEnergyLog(EnergyLogDTO dto);

    int deleteEnergyLogByDevice(
            @Param("deviceId") int deviceId
    );
    
    EnergyLogDTO calculateDailyEnergyLog(
            @Param("deviceId") int deviceId,
            @Param("logDate") String logDate
    );

    List<Integer> getActiveDeviceIdsByMember(
            @Param("memberId") int memberId
    );
}