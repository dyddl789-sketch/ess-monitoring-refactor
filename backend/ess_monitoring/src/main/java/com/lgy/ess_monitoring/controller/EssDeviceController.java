package com.lgy.ess_monitoring.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;
import com.lgy.ess_monitoring.service.EssDeviceService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/device")
public class EssDeviceController {

    @Autowired
    private EssDeviceService deviceService;

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

        deviceDto.setMemberId(memberId);

        if (deviceDto.getStatus() == null || deviceDto.getStatus().isEmpty()) {
            deviceDto.setStatus("NORMAL");
        }

        deviceService.insertDevice(deviceDto);

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
    
    @ResponseBody
    @RequestMapping(value = "/main/set", method = RequestMethod.POST)
    public String setMainDevice(@RequestParam("deviceId") int deviceId,
                                HttpSession session) {

        log.info("@# setMainDevice()");
        log.info("@# deviceId => " + deviceId);

        /*
         * 1. 로그인 여부 확인
         * 세션에 memberId가 없으면 로그인하지 않은 상태
         */
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            log.info("@# 대표 디바이스 설정 실패: 로그인 필요");
            return "login_required";
        }

        log.info("@# memberId => " + memberId);

        /*
         * 2. 대표 디바이스 설정
         * Service에서 기존 대표 해제 후 선택 기기를 대표로 설정한다.
         */
        deviceService.setMainDevice(memberId, deviceId);

        log.info("@# 대표 디바이스 설정 성공");

        return "success";
    }
}