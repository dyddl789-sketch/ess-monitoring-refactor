package com.lgy.ess_monitoring.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.lgy.ess_monitoring.dto.DashboardChartDTO;
import com.lgy.ess_monitoring.dto.DashboardSummaryDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.dto.EssGroupDTO;

public interface DashboardDAO {

    // =========================================================
    // 대시보드 요약 조회
    // =========================================================

    /**
     * 메인 대시보드 상단 요약 카드 조회
     *
     * 기준:
     * - selectedMonth
     * - groupId
     * - deviceId
     *
     * 사용 데이터:
     * - ess_device
     * - energy_log
     */
    DashboardSummaryDTO getDashboardSummary(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );


    // =========================================================
    // 필터용 장비 / 그룹 조회
    // =========================================================

    /**
     * 대시보드 장비 목록 조회
     *
     * 목적:
     * - 장비 셀렉트박스 구성
     * - 그룹 선택 시 해당 그룹 장비만 조회
     */
    List<EssDeviceDTO> getDashboardDeviceStatusList(
            @Param("memberId") int memberId,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );


    /**
     * 회원 기준 그룹 목록 조회
     */
    List<EssGroupDTO> getGroups(
            @Param("memberId") int memberId
    );

    /**
     * 회원 유형 조회
     * PERSONAL / COMPANY 구분이 필요할 경우 사용
     */
    String getUserType(
            @Param("memberId") int memberId
    );


    // =========================================================
    // 대시보드 차트 조회
    // =========================================================

    /**
     * 최근 6개월 월별 발전량 차트
     *
     * 계산 방식:
     * - energy_log.daily_kwh를 월별 SUM
     */
    List<DashboardChartDTO> getMonthlyGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    /**
     * 최근 6개월 월별 절감 금액 차트
     *
     * 계산 방식:
     * - energy_log.cost를 월별 SUM
     */
    List<DashboardChartDTO> getMonthlyCostChart(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );

    /**
     * 선택 월 기준 장비별 발전량 TOP5
     *
     * 계산 방식:
     * - 장비별 energy_log.daily_kwh 월간 SUM
     */
    List<DashboardChartDTO> getTopDeviceGenerationChart(
            @Param("memberId") int memberId,
            @Param("selectedMonth") String selectedMonth,
            @Param("groupId") Integer groupId,
            @Param("deviceId") Integer deviceId
    );
}