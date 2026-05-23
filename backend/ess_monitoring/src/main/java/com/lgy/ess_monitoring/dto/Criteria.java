package com.lgy.ess_monitoring.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
public class Criteria {
	private int pageNum; //페이지 번호
	private int amount; //페이지당 글 개수
	private String boardType;
	
	private String type; //검색 종류
	private String keyword; // 검색어
	
	public Criteria() {
		this.pageNum = 1; //기본 1페이지
		this.amount = 10; //기본 10개씩 출력
	}
	
	public Criteria(int pageNum, int amount) {
		this.pageNum = pageNum;
		this.amount = amount;
	}
	
	
	public String[] getTypeArr() {
//		type 이 없으면 빈 스트링 객체(기본 목록 조회), 있으면 분리
		 return type == null || type.trim().equals("") ? new String[] {} : type.split("");
	}
	
	//페이징 시작 위치
	public int getPageStart() {
		return (pageNum - 1) * amount;
	}


}
