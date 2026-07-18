package com.chatbot.chatbot.controller;

import com.chatbot.chatbot.model.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user != null && user.getId() != null) {
            return "redirect:/dashboard";
        }
        return "index";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user != null && user.getId() != null) {
            model.addAttribute("username", user.getUsername());
            model.addAttribute("fullName", user.getFullName());
        }
        return "dashboard";
    }


}
