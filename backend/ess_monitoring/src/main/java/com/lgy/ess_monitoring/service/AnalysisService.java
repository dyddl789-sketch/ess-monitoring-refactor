package com.lgy.ess_monitoring.service;

import java.util.List;

import com.lgy.ess_monitoring.dto.GenerationAnalysisDTO;
import com.lgy.ess_monitoring.dto.EnergyStatsDTO;

public interface AnalysisService {

    List<GenerationAnalysisDTO> getDailyGeneration(
            int memberId,
            String startDate,
            String endDate,
            Integer deviceId
    );

    List<GenerationAnalysisDTO> getDeviceGeneration(
            int memberId,
            String startDate,
            String endDate
    );
    
    List<EnergyStatsDTO> getDailyEnergyStats(
            int memberId,
            String startDate,
            String endDate,
            Integer deviceId
    );

    List<EnergyStatsDTO> getDeviceEnergyStats(
            int memberId,
            String startDate,
            String endDate
    );
}
