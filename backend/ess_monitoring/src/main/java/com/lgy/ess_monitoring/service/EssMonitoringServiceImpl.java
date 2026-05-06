package com.lgy.ess_monitoring.service;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgy.ess_monitoring.dao.EssMonitoringDAO;
import com.lgy.ess_monitoring.dto.EssMonitoringDTO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EssMonitoringServiceImpl implements EssMonitoringService {

    @Autowired
    private SqlSession sqlSession;

    @Override
    public List<EssMonitoringDTO> getMonitoringListByMemberId(int memberId) {
        log.info("@# [EssMonitoringServiceImpl] getMonitoringListByMemberId()");
        log.info("@# [EssMonitoringServiceImpl] memberId => {}", memberId);

        EssMonitoringDAO dao = sqlSession.getMapper(EssMonitoringDAO.class);
        List<EssMonitoringDTO> list = dao.getMonitoringListByMemberId(memberId);

        log.info("@# [EssMonitoringServiceImpl] list size => {}", list.size());

        return list;
    }

    @Override
    public EssMonitoringDTO getLatestMonitoring(int deviceId) {
        log.info("@# [EssMonitoringServiceImpl] getLatestMonitoring()");
        log.info("@# [EssMonitoringServiceImpl] deviceId => {}", deviceId);

        EssMonitoringDAO dao = sqlSession.getMapper(EssMonitoringDAO.class);
        EssMonitoringDTO dto = dao.getLatestMonitoring(deviceId);

        log.info("@# [EssMonitoringServiceImpl] dto => {}", dto);

        return dto;
    }


    @Override
    public int getTotalCount() {
        log.info("@# [EssMonitoringServiceImpl] getTotalCount()");

        EssMonitoringDAO dao = sqlSession.getMapper(EssMonitoringDAO.class);
        return dao.getTotalCount();
    }

    @Override
    public int getMemberCount(int memberId) {
        log.info("@# [EssMonitoringServiceImpl] getMemberCount()");
        log.info("@# [EssMonitoringServiceImpl] memberId => {}", memberId);

        EssMonitoringDAO dao = sqlSession.getMapper(EssMonitoringDAO.class);
        return dao.getMemberCount(memberId);
    }
}