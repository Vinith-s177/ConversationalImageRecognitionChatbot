package com.chatbot.chatbot.controller;

import com.chatbot.chatbot.model.ChatMessage;
import com.chatbot.chatbot.model.User;
import com.chatbot.chatbot.repository.ChatMessageRepository;
import com.chatbot.chatbot.service.AuthService;
import com.chatbot.chatbot.service.ChatbotService;
import com.chatbot.chatbot.service.ImageRecognitionService;
import com.chatbot.chatbot.service.OCRService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatbotService chatbotService;
    private final ChatMessageRepository chatMessageRepository;
    private final AuthService authService;
    private final ImageRecognitionService imageRecognitionService;
    private final OCRService ocrService;

    public ChatController(ChatbotService chatbotService, ChatMessageRepository chatMessageRepository, 
                          AuthService authService, ImageRecognitionService imageRecognitionService, OCRService ocrService) {
        this.chatbotService = chatbotService;
        this.chatMessageRepository = chatMessageRepository;
        this.authService = authService;
        this.imageRecognitionService = imageRecognitionService;
        this.ocrService = ocrService;
    }

    @GetMapping("/history")
    public ResponseEntity<List<ChatMessage>> getHistory(@RequestHeader("Authorization") String token) {
        if (token == null || !token.startsWith("Bearer ")) return ResponseEntity.status(401).build();
        
        Optional<User> userOpt = authService.getUserByToken(token.substring(7));
        if (userOpt.isEmpty()) return ResponseEntity.status(401).build();

        List<ChatMessage> history = chatMessageRepository.findByUserOrderByIdAsc(userOpt.get());
        return ResponseEntity.ok(history);
    }

    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> sendMessage(
            @RequestHeader("Authorization") String token,
            @RequestBody Map<String, String> payload) {

        if (token == null || !token.startsWith("Bearer ")) return ResponseEntity.status(401).build();
        
        Optional<User> userOpt = authService.getUserByToken(token.substring(7));
        if (userOpt.isEmpty()) return ResponseEntity.status(401).build();

        User user = userOpt.get();
        String userMessage = payload.get("message");
        String imagePath = payload.get("imagePath"); // Relative path from upload e.g., /uploads/filename.jpg

        Map<String, Object> response = new HashMap<>();

        try {
            List<ChatMessage> chatHistory = chatMessageRepository.findByUserOrderByIdAsc(user);

            // 1. Save user message
            ChatMessage userMsg = new ChatMessage("user", userMessage);
            userMsg.setUser(user);
            userMsg.setImageUrl(imagePath);
            chatMessageRepository.save(userMsg);
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
            botMsg.setUser(user);
            chatMessageRepository.save(botMsg);

            // 5. Return response
            response.put("success", true);
            response.put("reply", botMsg);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("error", "An error occurred during message processing: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    @PostMapping("/clear")
    public ResponseEntity<Map<String, Object>> clearHistory(@RequestHeader("Authorization") String token) {
        if (token == null || !token.startsWith("Bearer ")) return ResponseEntity.status(401).build();
        
        Optional<User> userOpt = authService.getUserByToken(token.substring(7));
        if (userOpt.isEmpty()) return ResponseEntity.status(401).build();

        // Need @Transactional on repository or just delete in loop
        List<ChatMessage> msgs = chatMessageRepository.findByUserOrderByIdAsc(userOpt.get());
        chatMessageRepository.deleteAll(msgs);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        return ResponseEntity.ok(response);
    }
}
