package com.lgy.ess_monitoring.service;

import java.util.ArrayList;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssDeviceDAO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.util.GridConverter;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EssDeviceServiceImpl implements EssDeviceService {

    @Autowired
    private SqlSession sqlSession;

    private EssDeviceDAO getDao() {
        return sqlSession.getMapper(EssDeviceDAO.class);
    }

    @Override
    public void insertDevice(EssDeviceDTO deviceDto) {
        if (deviceDto.getLatitude() != null && deviceDto.getLongitude() != null) {
            double latitude = deviceDto.getLatitude().doubleValue();
            double longitude = deviceDto.getLongitude().doubleValue();

            int[] grid = GridConverter.convertToGrid(latitude, longitude);

            deviceDto.setNx(grid[0]);
            deviceDto.setNy(grid[1]);

            log.info("@# latitude => " + latitude);
            log.info("@# longitude => " + longitude);
            log.info("@# nx => " + grid[0]);
            log.info("@# ny => " + grid[1]);
        } else {
            log.warn("@# 좌표 없음 → nx/ny 계산 안됨");
        }

        getDao().insertDevice(deviceDto);
    }

    @Override
    public ArrayList<EssDeviceDTO> getDeviceList(int memberId) {
        return getDao().getDeviceList(memberId);
    }

    @Override
    public int getDeviceCount(int memberId) {
        return getDao().getDeviceCount(memberId);
    }

    @Override
    public int deleteDevice(int deviceId, int memberId) {
        return getDao().deleteDevice(deviceId, memberId);
    }

    @Override
    public EssDeviceDTO deviceDetail(int deviceId) {
        return getDao().deviceDetail(deviceId);
    }

    @Override
    public ArrayList<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    ) {
        return getDao().getDashboardDeviceStatusList(
                memberId,
                selectedDate,
                groupId,
                deviceId
        );
    }
}