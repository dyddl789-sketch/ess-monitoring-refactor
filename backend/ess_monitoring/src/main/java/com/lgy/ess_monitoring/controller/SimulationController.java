package com.lgy.ess_monitoring.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lgy.ess_monitoring.service.SimulationService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/simulation")
public class SimulationController {

    @Autowired
    private SimulationService simulationService;

    // 테스트 실행
    @ResponseBody
    @RequestMapping("/run")
    public String run(int deviceId) {

        log.info("@# simulation run deviceId => {}", deviceId);

        simulationService.runSimulation(deviceId);

        return "simulation success";
    }
}