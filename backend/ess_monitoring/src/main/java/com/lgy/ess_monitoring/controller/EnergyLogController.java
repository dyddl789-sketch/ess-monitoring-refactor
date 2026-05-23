package com.lgy.ess_monitoring.controller;

import java.time.LocalDate;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lgy.ess_monitoring.service.EnergyLogService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/energy-log")
public class EnergyLogController {

    @Autowired
    private EnergyLogService energyLogService;

    // 선택 장비 일별 집계
    @ResponseBody
    @RequestMapping(
        value = "/aggregate/device",
        method = RequestMethod.POST,
        produces = "application/json; charset=UTF-8"
    )
    public String aggregateDevice(
            Integer deviceId,
            String logDate,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "{\"result\":\"LOGIN_REQUIRED\"}";
        }

        if (deviceId == null) {
            return "{\"result\":\"NO_DEVICE\"}";
        }

        if (logDate == null || logDate.isEmpty()) {
            logDate = LocalDate.now().toString();
        }

        int count =
                energyLogService.aggregateDailyEnergyLog(
                        deviceId,
                        logDate
                );

        return "{\"result\":\"SUCCESS\", \"count\":" + count + "}";
    }


    // 로그인 회원 전체 장비 일별 집계
    @ResponseBody
    @RequestMapping(
        value = "/aggregate/member",
        method = RequestMethod.POST,
        produces = "application/json; charset=UTF-8"
    )
    public String aggregateMember(
            String logDate,
            HttpSession session
    ) {
        Integer memberId =
                (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "{\"result\":\"LOGIN_REQUIRED\"}";
        }

        if (logDate == null || logDate.isEmpty()) {
            logDate = LocalDate.now().toString();
        }

        int count =
                energyLogService.aggregateDailyEnergyLogByMember(
                        memberId,
                        logDate
                );

        return "{\"result\":\"SUCCESS\", \"count\":" + count + "}";
    }
}