package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EnergyLogDAO;
import com.lgy.ess_monitoring.dto.EnergyLogDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EnergyLogServiceImpl implements EnergyLogService {

    @Autowired
    private SqlSession sqlSession;

    private EnergyLogDAO getDao() {
        return sqlSession.getMapper(EnergyLogDAO.class);
    }

    @Override
    public EnergyLogDTO getEnergyLogByDeviceAndDate(
            int deviceId,
            String logDate
    ) {
        log.info("getEnergyLogByDeviceAndDate() deviceId={}, logDate={}",
                deviceId,
                logDate
        );

        return getDao().getEnergyLogByDeviceAndDate(
                deviceId,
                logDate
        );
    }

    @Override
    public List<EnergyLogDTO> getEnergyLogListByDevice(
            int deviceId
    ) {
        log.info("getEnergyLogListByDevice() deviceId={}", deviceId);

        return getDao().getEnergyLogListByDevice(deviceId);
    }

    @Override
    public int saveEnergyLog(EnergyLogDTO dto) {
        log.info("saveEnergyLog() deviceId={}, logDate={}",
                dto.getDeviceId(),
                dto.getLogDate()
        );

        return getDao().upsertEnergyLog(dto);
    }
    
    @Override
    public int aggregateDailyEnergyLog(
            int deviceId,
            String logDate
    ) {
        log.info("aggregateDailyEnergyLog() deviceId={}, logDate={}",
                deviceId,
                logDate
        );

        EnergyLogDTO dto =
                getDao().calculateDailyEnergyLog(
                        deviceId,
                        logDate
                );

        if (dto == null) {
            return 0;
        }

        return getDao().upsertEnergyLog(dto);
    }


    @Override
    public int aggregateDailyEnergyLogByMember(
            int memberId,
            String logDate
    ) {
        log.info("aggregateDailyEnergyLogByMember() memberId={}, logDate={}",
                memberId,
                logDate
        );

        List<Integer> deviceIds =
                getDao().getActiveDeviceIdsByMember(memberId);

        int count = 0;

        if (deviceIds == null || deviceIds.isEmpty()) {
            return count;
        }

        for (Integer deviceId : deviceIds) {

            if (deviceId == null) {
                continue;
            }

            count += aggregateDailyEnergyLog(
                    deviceId,
                    logDate
            );
        }

        return count;
    }

    @Override
    public int deleteEnergyLogByDevice(
            int deviceId
    ) {
        log.info("deleteEnergyLogByDevice() deviceId={}", deviceId);

        return getDao().deleteEnergyLogByDevice(deviceId);
    }
}