package com.lgy.ess_monitoring.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {

    @RequestMapping("/goMain")
    public String main() {

        return "main";
    }
}
