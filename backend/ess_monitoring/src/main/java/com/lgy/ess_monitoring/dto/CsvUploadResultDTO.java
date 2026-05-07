package com.lgy.ess_monitoring.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

/**
 * CSV 업로드 결과를 화면으로 반환하기 위한 DTO
 *
 * 예)
 * 총 10건 중
 * 성공 8건
 * 실패 2건
 * 실패 사유 목록 출력
 */

@Data
public class CsvUploadResultDTO {

	// CSV 파일에서 읽은 전체 데이터 행 수
    private int totalCount;

    // 정상 등록된 행 수
    private int successCount;

    // 등록 실패한 행 수
    private int failCount;

    // 실패한 행의 오류 메시지 목록
    private List<String> errorList = new ArrayList<String>();

    /**
     * 성공 건수 1 증가
     */
    public void addSuccess() {
        this.successCount++;
    }

    /**
     * 실패 건수 1 증가 + 실패 사유 저장
     *
     * @param message 실패 사유 메시지
     */
    public void addFail(String message) {
        this.failCount++;
        this.errorList.add(message);
    }
}