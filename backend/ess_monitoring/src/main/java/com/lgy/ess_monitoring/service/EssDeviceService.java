package com.lgy.ess_monitoring.service;

import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.web.multipart.MultipartFile;

import com.lgy.ess_monitoring.dto.CsvUploadResultDTO;
import com.lgy.ess_monitoring.dto.EssDeviceDTO;

public interface EssDeviceService {

    // 기기 등록
    void insertDevice(EssDeviceDTO deviceDto);

    // 로그인한 회원의 기기 목록 조회
    ArrayList<EssDeviceDTO> getDeviceList(int memberId);

    // 로그인한 회원의 기기 수 조회
    int getDeviceCount(int memberId);

    // 기기 삭제
    int deleteDevice(@Param("deviceId") int deviceId,
                     @Param("memberId") int memberId);

    // 상세 보기
    EssDeviceDTO deviceDetail(int deviceId);

    // 대시보드 기기 상태 목록 조회
    ArrayList<EssDeviceDTO> getDashboardDeviceStatusList(
            int memberId,
            String selectedDate,
            Integer groupId,
            Integer deviceId
    );

    // 스케줄러용 전체 장비 조회
    List<EssDeviceDTO> getAllActiveDevices();

    // 대표 디바이스 조회, 메인 화면 날씨 기준
    EssDeviceDTO getMainDevice(int memberId);

    // 대표 디바이스 설정
    void setMainDevice(int memberId, int deviceId);

    /**
     * CSV 파일을 이용한 ESS 기기 일괄 등록
     *
     * @param file 업로드된 CSV 파일
     * @param memberId 로그인한 회원 번호
     * @return 업로드 처리 결과 DTO
     */
    CsvUploadResultDTO uploadDeviceCsv(MultipartFile file, int memberId);
}