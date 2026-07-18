package com.chatbot.chatbot.controller;

import com.chatbot.chatbot.model.ChatMessage;
import com.chatbot.chatbot.model.User;
import com.chatbot.chatbot.repository.ChatMessageRepository;
import com.chatbot.chatbot.service.ImageRecognitionService;
import com.chatbot.chatbot.service.OCRService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Controller
public class WebController {

    private final ImageRecognitionService imageRecognitionService;
    private final OCRService ocrService;
    private final ChatMessageRepository chatMessageRepository;

    public WebController(ImageRecognitionService imageRecognitionService, OCRService ocrService, ChatMessageRepository chatMessageRepository) {
        this.imageRecognitionService = imageRecognitionService;
        this.ocrService = ocrService;
        this.chatMessageRepository = chatMessageRepository;
    }

    @PostMapping("/upload")
    public String handleFileUpload(@RequestParam("image") MultipartFile imageFile, HttpSession session, RedirectAttributes redirectAttributes) {
        try {
            if (imageFile.isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "Please select an image to upload.");
                return "redirect:/";
            }

            // Validations
            if (imageFile.getSize() > 10 * 1024 * 1024) {
                redirectAttributes.addFlashAttribute("error", "File size exceeds the 10MB limit.");
                return "redirect:/";
            }

            String contentType = imageFile.getContentType();
            String originalFilename = imageFile.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
            }

            boolean isValidMime = contentType != null && 
                    (contentType.equals("image/jpeg") || contentType.equals("image/jpg") || contentType.equals("image/png"));
            boolean isValidExtension = extension.equals(".jpg") || extension.equals(".jpeg") || extension.equals(".png");

            if (!isValidMime && !isValidExtension) {
                redirectAttributes.addFlashAttribute("error", "Unsupported file format. Please upload JPG, JPEG, or PNG images.");
                return "redirect:/";
            }

            String uploadDir = System.getProperty("user.dir") + File.separator + "uploads" + File.separator;
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            String uniqueFilename = UUID.randomUUID().toString() + "_" + originalFilename;
            File savedFile = new File(uploadDir + uniqueFilename);
            imageFile.transferTo(savedFile);

            String imagePath = "/uploads/" + uniqueFilename;
            session.setAttribute("imagePath", imagePath);
            session.setAttribute("originalFilename", originalFilename);
            
            // Perform analysis
            List<ImageRecognitionService.DetectedObject> detectedObjects = imageRecognitionService.detectObjects(savedFile);
            String ocrText = ocrService.extractText(savedFile);
            
            List<String> dominantColors = detectedObjects.stream()
                .map(ImageRecognitionService.DetectedObject::getColor)
                .filter(color -> color != null && !color.isEmpty())
                .distinct()
                .collect(Collectors.toList());

            session.setAttribute("detectedObjects", detectedObjects);
            session.setAttribute("dominantColors", dominantColors);
            session.setAttribute("ocrText", ocrText);

            return "redirect:/chat";

        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Failed to process image: " + e.getMessage());
            return "redirect:/";
        }
    }

    @GetMapping("/chat")
    public String showChatPage(HttpSession session, Model model) {
        String imagePath = (String) session.getAttribute("imagePath");
        if (imagePath == null) {
            return "redirect:/"; // Redirect to home if no image uploaded
        }

        model.addAttribute("originalFilename", session.getAttribute("originalFilename"));
        model.addAttribute("imagePath", imagePath);
        model.addAttribute("detectedObjects", session.getAttribute("detectedObjects"));
        model.addAttribute("dominantColors", session.getAttribute("dominantColors"));
        model.addAttribute("ocrText", session.getAttribute("ocrText"));

        User user = (User) session.getAttribute("user");
        List<ChatMessage> chatHistory = new ArrayList<>();
        if (user != null) {
            chatHistory = chatMessageRepository.findByUserOrderByIdAsc(user);
        } else {
            // Provide a dummy user for the session so chat.html doesn't crash on session.user.fullName
            User dummy = User.builder().username("guest").fullName("Guest User").build();
            session.setAttribute("user", dummy);
        }
        
        model.addAttribute("chatHistory", chatHistory);

        return "chat";
    }
}
