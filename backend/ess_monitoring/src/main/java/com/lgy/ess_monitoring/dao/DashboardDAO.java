package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface DashboardDAO {

    // 대시보드 요약 조회
    DashboardSummaryDTO getDashboardSummary(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    // 대시보드 장비 상태 목록 조회
    List<EssDeviceDTO> getDashboardDeviceStatusList(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    // 회원/그룹 기준 장비 셀렉트박스 조회
    List<EssDeviceDTO> getDevices(
            @Param("memberId") int memberId,
            @Param("groupId") Integer groupId
    );

    // 회원 기준 장비 그룹 목록 조회
    List<EssGroupDTO> getGroups(
            @Param("memberId") int memberId
    );

    // 회원 유형 조회
    String getUserType(
            @Param("memberId") int memberId
    );

    // 그룹별 발전량 차트
    List<DashboardChartDTO> getGroupGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("limit") int limit
    );

    // 장비별 발전량 차트
    List<DashboardChartDTO> getDeviceGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId,
            @Param("limit") int limit
    );

    // 그룹 차트 전체 개수
    int getGroupGenerationChartCount(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId
    );

    // 장비 차트 전체 개수
    int getDeviceGenerationChartCount(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );
    
 // 시간별 발전량/SOC 비교
    List<DashboardChartDTO> getHourlyCompareChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    // 장비별 발전량 비교
    List<DashboardChartDTO> getDeviceCompareChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );
    
    // ===============================
    // 최근 7일 발전량 차트
    // ===============================
    List<DashboardChartDTO> getWeeklyGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    // ===============================
    // 최근 6개월 월별 발전량 차트
    // ===============================
    List<DashboardChartDTO> getMonthlyGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    // ===============================
    // 장비별 발전량 TOP5
    // ===============================
    List<DashboardChartDTO> getTopDeviceGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedDate") String selectedDate,
            @Param("groupId") Integer groupId
    );
       
}