package com.lgy.ess_monitoring.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EssMemberDTO {

    private int memberId;
    private String memberName;
    private String memberUserid;
    private String memberPw;
    private String userType;
    private String phone;
    private String email;
    private String address;
    private String joinDate;
    private String role;
}