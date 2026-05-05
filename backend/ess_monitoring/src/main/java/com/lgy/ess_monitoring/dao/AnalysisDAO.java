package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.GenerationAnalysisDTO;
import com.lgy.ess_monitoring.dto.EnergyStatsDTO;

public interface AnalysisDAO {

    List<GenerationAnalysisDTO> getDailyGeneration(
            @Param("memberId") int memberId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate,
            @Param("deviceId") Integer deviceId
    );

    List<GenerationAnalysisDTO> getDeviceGeneration(
            @Param("memberId") int memberId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );
    
    List<EnergyStatsDTO> getDailyEnergyStats(
            @Param("memberId") int memberId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate,
            @Param("deviceId") Integer deviceId
    );

    List<EnergyStatsDTO> getDeviceEnergyStats(
            @Param("memberId") int memberId,
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );
}
