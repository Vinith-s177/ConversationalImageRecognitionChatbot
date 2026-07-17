package com.chatbot.chatbot.service;

import com.chatbot.chatbot.model.ChatMessage;
import org.springframework.stereotype.Service;

import java.io.File;
import java.nio.file.Files;
import java.util.List;

@Service
public class ChatbotService {

    private final AIService aiService;

    public ChatbotService(AIService aiService) {
        this.aiService = aiService;
    }

    /**
     * Generates a conversational chatbot response.
     *
     * @param userQuestion      The question asked by the user.
     * @param history           The conversation history from the current session.
     * @param imageDescription  The detailed description / analysis of the image.
     * @param ocrContext        The extracted OCR text.
     * @param imageFile         The uploaded image file.
     * @return Chatbot response text.
     */
    public String getChatbotResponse(String userQuestion, List<ChatMessage> history, String imageDescription, String ocrContext, File imageFile) {
        if (aiService.isMockMode()) {
            return generateMockResponse(userQuestion, imageDescription, ocrContext);
        }

        try {
            byte[] imageBytes = null;
            String mimeType = null;

            if (imageFile != null && imageFile.exists()) {
                imageBytes = Files.readAllBytes(imageFile.toPath());
                mimeType = Files.probeContentType(imageFile.toPath());
                if (mimeType == null) {
                    mimeType = "image/jpeg";
                }
            }

            // Build conversation history transcript
            StringBuilder historyBuilder = new StringBuilder();
            for (ChatMessage msg : history) {
                if ("user".equalsIgnoreCase(msg.getSender())) {
                    historyBuilder.append("User: ").append(msg.getContent()).append("\n");
                } else {
                    historyBuilder.append("Model: ").append(msg.getContent()).append("\n");
                }
            }

            String prompt = String.format("""
                    You are AuraBot, a friendly and conversational visual assistant.
                    Your task is to answer user questions about the uploaded image based on the provided visual analysis.
                    
                    Rules:
                    - Respond in a natural, conversational manner.
                    - Feel free to describe the background, surroundings, colors, and any details requested by the user.
                    - If the image contains people, celebrities, animals, or complex scenes, use the analysis to give a rich and detailed response.
                    
                    Here is the visual analysis of the image:
                    %s
                    
                    Here is the conversation history:
                    %s
                    
                    User's Question: %s
                    """, 
                    imageDescription,
                    historyBuilder.toString(), 
                    userQuestion);

            return aiService.generateContent(prompt, imageBytes, mimeType);

        } catch (Exception e) {
            throw new RuntimeException("Chatbot API call failed: " + e.getMessage(), e);
        }
    }

    private String generateMockResponse(String question, String imageDescription, String ocrContext) {
        String lower = question.toLowerCase().trim();

        // 1. Check if the question is a greeting or general unrelated chat
        if (lower.matches("^(hi|hello|hey|greetings|howdy|yo|good morning|good afternoon|good evening|how are you|test|status)(\\s+.*)?$")) {
            return "Hello! I am AuraBot, your conversational visual assistant. I have analyzed your image. Feel free to ask me anything about it!";
        }

        // 2. Unrelated general questions detection
        boolean isUnrelated = lower.contains("capital of") || 
                              lower.contains("weather") || 
                              lower.contains("write a code") || 
                              lower.contains("python script") || 
                              lower.contains("math") || 
                              lower.contains("calculate") || 
                              lower.contains("formula");
                              
        if (isUnrelated) {
            if (lower.contains("capital of france")) {
                return "The capital of France is Paris. Let me know if you have any questions about the uploaded image as well!";
            }
            return "As your general AI assistant, I can help you with that! However, this thread is focused on the image you uploaded. Could you ask me something about the image, or let me know how else I can help?";
        }

        // 3. Question is about the image (contains keywords or refers to 'this', 'it', or elements in the description)
        if (imageDescription != null && !imageDescription.isEmpty()) {
            if (lower.contains("color") || lower.contains("colour")) {
                if (imageDescription.toLowerCase().contains("orange") || imageDescription.toLowerCase().contains("golden")) {
                    return "The main subject in the image has a vibrant golden-orange or orange color, set against a solid white background.";
                } else if (imageDescription.toLowerCase().contains("red")) {
                    return "The sports sedan has a glossy red color palette.";
                } else if (imageDescription.toLowerCase().contains("golden retriever")) {
                    return "The retriever features a lovely light golden-yellow fur coat.";
                }
                return "Based on the image details: The colors are described as " + imageDescription;
            }

            if (lower.contains("background")) {
                if (imageDescription.toLowerCase().contains("white background") || imageDescription.toLowerCase().contains("white wall")) {
                    return "The background is a clean, plain white wall, highlighting the subject in the center.";
                } else if (imageDescription.toLowerCase().contains("grass")) {
                    return "The background consists of a clean, lush green grass lawn stretching outwards.";
                }
                return "The background is detailed as follows: " + imageDescription;
            }

            if (lower.contains("how many") || lower.contains("number of") || lower.contains("count")) {
                if (imageDescription.toLowerCase().contains("cat") && !imageDescription.toLowerCase().contains("dog")) {
                    return "There is exactly 1 cat visible in the image.";
                } else if (imageDescription.toLowerCase().contains("dog")) {
                    return "There is 1 dog (Golden Retriever) and 1 tennis ball visible in the picture.";
                }
                return "Here are the count of elements identified: " + imageDescription;
            }

            if (lower.contains("explain") || lower.contains("describe") || lower.contains("what is this") || lower.contains("what is the image") || lower.contains("what is in") || lower.contains("detail")) {
                return "Here is the visual analysis of your uploaded image:\n\n" + imageDescription;
            }

            // General natural-language question matching image
            return "Based on the visual analysis of the photo: " + imageDescription;
        }

        return "I have received your message. Please upload an image first so I can analyze it and answer your questions!";
    }
}
