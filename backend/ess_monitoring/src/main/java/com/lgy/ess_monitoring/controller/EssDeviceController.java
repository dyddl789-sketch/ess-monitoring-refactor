package com.lgy.ess_monitoring.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.service.EssDeviceService;
import com.lgy.ess_monitoring.service.SimulationService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/device")
public class EssDeviceController {

    @Autowired
    private EssDeviceService deviceService;
    @Autowired
    private SimulationService simulationService;

    // 장비 상태 화면
    @RequestMapping(value = "/status", method = RequestMethod.GET)
    public String deviceStatus(HttpSession session) {
        log.info("@# deviceStatus()");

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        return "device_status";
    }

    // 장비 등록 페이지
    @RequestMapping(value = "/registerForm", method = RequestMethod.GET)
    public String registerForm(HttpSession session) {
        log.info("@# registerForm()");

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        return "device/registerForm";
    }

 // 장비 등록
    @RequestMapping(value = "/register", method = RequestMethod.POST)
    @ResponseBody
    public String deviceRegister(EssDeviceDTO deviceDto, HttpSession session) {
        log.info("@# deviceRegister()");
        log.info("@# deviceDto => {}", deviceDto);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "login_required";
        }

        // 로그인 회원 ID 세팅
        deviceDto.setMemberId(memberId);

        // 상태 기본값
        if (deviceDto.getStatus() == null || deviceDto.getStatus().isEmpty()) {
            deviceDto.setStatus("NORMAL");
        }

        // 장비 타입 기본값
        if (deviceDto.getDeviceType() == null || deviceDto.getDeviceType().isEmpty()) {
            deviceDto.setDeviceType("HYBRID");
        }

        // 대표 장비 기본값
        if (deviceDto.getIsMain() == null || deviceDto.getIsMain().isEmpty()) {
            deviceDto.setIsMain("N");
        }

        // 장비 등록
        deviceService.insertDevice(deviceDto);

        // insert 후 생성된 deviceId
        int deviceId = deviceDto.getDeviceId();

        log.info("@# 등록된 deviceId => {}", deviceId);

        // 장비 등록 직후 날씨 + 모니터링 시뮬레이션 생성
        if (deviceId > 0) {
            simulationService.runSimulation(deviceId);
        }

        return "success";
    }
    
    // 장비 목록 Ajax
    @RequestMapping(
        value = "/listAjax",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    @ResponseBody
    public String deviceList(HttpSession session) throws Exception {
        log.info("@# deviceList()");

        Integer memberId = (Integer) session.getAttribute("memberId");

        List<EssDeviceDTO> deviceList = new ArrayList<>();

        if (memberId != null) {
            deviceList = deviceService.getDeviceList(memberId);
        }

        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.writeValueAsString(deviceList);
    }

    // 장비 삭제
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public String deleteDevice(int deviceId, HttpSession session) {
        log.info("@# deleteDevice()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "login_required";
        }

        int result = deviceService.deleteDevice(deviceId, memberId);

        return result == 1 ? "success" : "fail";
    }
 // 장비 관리 화면
    @RequestMapping(value = "/manage", method = RequestMethod.GET)
    public String deviceManage(HttpSession session) {
        log.info("@# deviceManage()");

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        return "device_manage";
    }
}