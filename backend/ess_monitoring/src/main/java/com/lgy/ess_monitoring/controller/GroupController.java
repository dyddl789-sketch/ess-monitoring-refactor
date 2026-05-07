package com.lgy.ess_monitoring.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.lgy.ess_monitoring.dto.EssDeviceGroupDTO;
import com.lgy.ess_monitoring.service.GroupService;

@Controller
@RequestMapping("/group")
public class GroupController {

    @Autowired
    private GroupService groupService;

    // 그룹 관리 화면
    @RequestMapping("/manage")
    public String manage(HttpSession session, Model model) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        model.addAttribute("groupList", groupService.getGroupList(memberId));
        System.out.println("memberId = " + memberId);
        System.out.println("groupList = " + groupService.getGroupList(memberId));

        return "group_manage";
    }

    // 그룹 등록
    @RequestMapping("/insert")
    public String insert(EssDeviceGroupDTO group, HttpSession session) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        group.setMemberId(memberId);
        groupService.insertGroup(group);

        return "redirect:/group/manage";
    }

    // 그룹 수정
    @RequestMapping("/update")
    public String update(EssDeviceGroupDTO group, HttpSession session) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        group.setMemberId(memberId);
        groupService.updateGroup(group);

        return "redirect:/group/manage";
    }

    // 그룹 삭제
    @RequestMapping("/delete")
    public String delete(Integer groupId, HttpSession session) {
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            return "redirect:/login_view";
        }

        groupService.deleteGroup(groupId, memberId);

        return "redirect:/group/manage";
    }
}
