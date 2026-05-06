package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.AnalysisDAO;
import com.lgy.ess_monitoring.dto.EnergyStatsDTO;
import com.lgy.ess_monitoring.dto.GenerationAnalysisDTO;

@Service
public class AnalysisServiceImpl implements AnalysisService {

    @Autowired
    private SqlSession sqlSession;

    private AnalysisDAO getDao() {
        return sqlSession.getMapper(AnalysisDAO.class);
    }

    @Override
    public List<GenerationAnalysisDTO> getDailyGeneration(
            int memberId,
            String startDate,
            String endDate,
            Integer deviceId
    ) {
        return getDao().getDailyGeneration(memberId, startDate, endDate, deviceId);
    }

    @Override
    public List<GenerationAnalysisDTO> getDeviceGeneration(
            int memberId,
            String startDate,
            String endDate
    ) {
        return getDao().getDeviceGeneration(memberId, startDate, endDate);
    }
    @Override
    public List<EnergyStatsDTO> getDailyEnergyStats(
            int memberId,
            String startDate,
            String endDate,
            Integer deviceId
    ) {
        return getDao().getDailyEnergyStats(memberId, startDate, endDate, deviceId);
    }

    @Override
    public List<EnergyStatsDTO> getDeviceEnergyStats(
            int memberId,
            String startDate,
            String endDate
    ) {
        return getDao().getDeviceEnergyStats(memberId, startDate, endDate);
    }
}
