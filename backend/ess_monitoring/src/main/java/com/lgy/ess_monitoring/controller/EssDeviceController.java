package com.lgy.ess_monitoring.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lgy.ess_monitoring.dto.CsvUploadResultDTO;
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
    @ResponseBody
    @RequestMapping(value = "/register", method = RequestMethod.POST)
    public String deviceRegister(EssDeviceDTO deviceDto, HttpSession session) {
        log.info("@# deviceRegister()");
        log.info("@# deviceDto => {}", deviceDto);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "login_required";
        }

        deviceDto.setMemberId(memberId);

        if (deviceDto.getGroupId() != null && deviceDto.getGroupId() == 0) {
            deviceDto.setGroupId(null);
        }

        if (deviceDto.getStatus() == null || deviceDto.getStatus().isEmpty()) {
            deviceDto.setStatus("NORMAL");
        }

        deviceService.insertDevice(deviceDto);

        return "success";
    }

    // 장비 목록 Ajax
    @ResponseBody
    @RequestMapping(
        value = "/listAjax",
        method = RequestMethod.GET,
        produces = "application/json; charset=UTF-8"
    )
    public String deviceList(HttpSession session) throws Exception {
        log.info("@# deviceList()");

        Integer memberId = (Integer) session.getAttribute("memberId");

        List<EssDeviceDTO> deviceList = new ArrayList<EssDeviceDTO>();

        if (memberId != null) {
            deviceList = deviceService.getDeviceList(memberId);
        }

        ObjectMapper objectMapper = new ObjectMapper();

        return objectMapper.writeValueAsString(deviceList);
    }

    // 장비 삭제
    @ResponseBody
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
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

    // 대표 장비 설정
    @ResponseBody
    @RequestMapping(value = "/main/set", method = RequestMethod.POST)
    public String setMainDevice(
            @RequestParam("deviceId") int deviceId,
            HttpSession session
    ) {
        log.info("@# setMainDevice()");
        log.info("@# deviceId => {}", deviceId);

        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            log.info("@# 대표 디바이스 설정 실패: 로그인 필요");
            return "login_required";
        }

        log.info("@# memberId => {}", memberId);

        deviceService.setMainDevice(memberId, deviceId);

        log.info("@# 대표 디바이스 설정 성공");

        return "success";
    }
    
    /**
     * CSV 파일을 업로드해서 여러 기기를 한 번에 등록
     *
     * 요청 URL:
     * POST /device/csv/upload
     *
     * formData key:
     * csvFile
     */
    @ResponseBody
    @RequestMapping(value = "/csv/upload", method = RequestMethod.POST)
    public CsvUploadResultDTO uploadDeviceCsv(@RequestParam("csvFile") MultipartFile csvFile,
                                              HttpSession session) {

        log.info("@# uploadDeviceCsv()");

        // 로그인한 회원 번호 확인
        Integer memberId = (Integer) session.getAttribute("memberId");

        // 로그인하지 않은 경우 실패 결과 반환
        if (memberId == null) {
            CsvUploadResultDTO result = new CsvUploadResultDTO();
            result.addFail("로그인이 필요합니다.");
            return result;
        }

        /*
         * Service에 CSV 처리 위임
         * Controller는 파일과 회원 번호만 넘긴다.
         */
        return deviceService.uploadDeviceCsv(csvFile, memberId);
    }
    
    /**
     * CSV 양식 샘플을 문자열로 반환
     *
     * 요청 URL:
     * GET /device/csv/template
     *
     * 일단은 브라우저에 CSV 텍스트가 표시되는 간단 버전
     */
    @RequestMapping(value = "/csv/template", method = RequestMethod.GET)
    public void downloadCsvTemplate(HttpServletResponse response) throws Exception {

        log.info("@# downloadCsvTemplate()");

        // CSV 다운로드 응답 설정
        response.setContentType("application/octet-stream");
        response.setCharacterEncoding("UTF-8");

        // 다운로드 파일명
        response.setHeader(
                "Content-Disposition",
                "attachment; filename=\"device_template.csv\""
        );

        // UTF-8 BOM (엑셀 한글 깨짐 방지)
        String csv =
                "\uFEFF" +
                "groupName,deviceName,location,capacityKw,deviceType,status,latitude,longitude,essCapacityKwh,currentChargeKwh,chargeEfficiency,dischargeEfficiency,electricityRate\r\n" +

                "부산공장,CSV_부산공장_1호기,부산 동구,50,HYBRID,NORMAL,35.129,129.045,100,50,95,90,150\r\n" +

                "부산공장,CSV_부산공장_2호기,부산 사하구,80,HYBRID,NORMAL,35.104,128.974,160,80,95,90,150\r\n" +

                ",CSV_그룹없음_1호기,부산 해운대구,30,HYBRID,NORMAL,35.163,129.163,60,20,95,90,150\r\n";

        byte[] bytes = csv.getBytes("UTF-8");

        response.setContentLength(bytes.length);

        response.getOutputStream().write(bytes);
        response.getOutputStream().flush();
    }
}





