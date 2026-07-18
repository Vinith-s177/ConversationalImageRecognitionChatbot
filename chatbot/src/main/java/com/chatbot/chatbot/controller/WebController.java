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
import com.chatbot.chatbot.service.ChatbotService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ResponseBody;
import java.util.Map;
import java.util.HashMap;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class WebController {

    private final ImageRecognitionService imageRecognitionService;
    private final OCRService ocrService;
    private final ChatMessageRepository chatMessageRepository;
    private final ChatbotService chatbotService;

    public WebController(ImageRecognitionService imageRecognitionService, OCRService ocrService, ChatMessageRepository chatMessageRepository, ChatbotService chatbotService) {
        this.imageRecognitionService = imageRecognitionService;
        this.ocrService = ocrService;
        this.chatMessageRepository = chatMessageRepository;
        this.chatbotService = chatbotService;
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
        if (user != null && user.getId() != null) {
            chatHistory = chatMessageRepository.findByUserOrderByIdAsc(user);
        } else {
            // Provide a dummy user for the session so chat.html doesn't crash on session.user.fullName
            User dummy = User.builder().username("guest").fullName("Guest User").build();
            session.setAttribute("user", dummy);
            Object sessionHistory = session.getAttribute("guestChatHistory");
            if (sessionHistory instanceof List) {
                chatHistory = (List<ChatMessage>) sessionHistory;
            }
        }
        
        model.addAttribute("chatHistory", chatHistory);

        return "chat";
    }

    @PostMapping("/chat/send")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendMessage(
            @RequestParam("message") String userMessage,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        User user = (User) session.getAttribute("user");
        boolean isGuest = user == null || user.getId() == null;
        if (isGuest) {
            user = User.builder().username("guest").fullName("Guest User").build();
            session.setAttribute("user", user);
        }

        String imagePath = (String) session.getAttribute("imagePath");
        try {
            List<ChatMessage> chatHistory = new ArrayList<>();
            if (!isGuest) {
                chatHistory = chatMessageRepository.findByUserOrderByIdAsc(user);
            } else {
                Object sessionHistory = session.getAttribute("guestChatHistory");
                if (sessionHistory instanceof List) {
                    chatHistory = (List<ChatMessage>) sessionHistory;
                }
            }

            // 1. Save user message
            ChatMessage userMsg = new ChatMessage("user", userMessage);
            if (!isGuest) {
                userMsg.setUser(user);
                userMsg.setImageUrl(imagePath);
                chatMessageRepository.save(userMsg);
            }
            chatHistory.add(userMsg);

            // 2. Prepare visual context if image is provided
            String visualContext = "";
            String ocrText = "";
            File imageFile = null;

            if (imagePath != null && !imagePath.isEmpty()) {
                String absolutePath = System.getProperty("user.dir") + imagePath;
                imageFile = new File(absolutePath);
                
                if (imageFile.exists()) {
                    visualContext = imageRecognitionService.analyzeImageDescription(imageFile);
                    ocrText = ocrService.extractText(imageFile);
                }
            }

            // 3. Invoke chatbot service
            String botResponseText = chatbotService.getChatbotResponse(
                    userMessage, 
                    chatHistory, 
                    visualContext, 
                    ocrText, 
                    imageFile
            );

            // 4. Save bot message
            ChatMessage botMsg = new ChatMessage("bot", botResponseText);
            if (!isGuest) {
                botMsg.setUser(user);
                chatMessageRepository.save(botMsg);
            }
            chatHistory.add(botMsg);
            
            if (isGuest) {
                session.setAttribute("guestChatHistory", chatHistory);
            }

            // 5. Return response
            response.put("success", true);
            response.put("reply", botResponseText); 
            response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm")));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("error", "An error occurred during message processing: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    @PostMapping("/chat/reset")
    public String clearHistory(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user != null && user.getId() != null) {
            List<ChatMessage> msgs = chatMessageRepository.findByUserOrderByIdAsc(user);
            chatMessageRepository.deleteAll(msgs);
        } else {
            session.removeAttribute("guestChatHistory");
        }
        return "redirect:/chat";
    }
}
