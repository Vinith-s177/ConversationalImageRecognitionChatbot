package com.chatbot.chatbot.service;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.File;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;

@Service
public class ImageRecognitionService {

    private final AIService aiService;
    private final Gson gson = new Gson();

    public ImageRecognitionService(AIService aiService) {
        this.aiService = aiService;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DetectedObject {
        private String name;
        private double confidence; // from 0.0 to 1.0 (or percentage 0 to 100)
        private String description;
        private String color;
    }

    /**
     * Identifies objects in the uploaded image.
     *
     * @param imageFile The uploaded image file.
     * @return List of detected objects.
     */
    public List<DetectedObject> detectObjects(File imageFile) {
        List<DetectedObject> objects = new ArrayList<>();

        if (aiService.isMockMode()) {
            return generateMockObjects(imageFile.getName());
        }

        try {
            byte[] imageBytes = Files.readAllBytes(imageFile.toPath());
            String mimeType = Files.probeContentType(imageFile.toPath());
            if (mimeType == null) {
                mimeType = "image/jpeg";
            }

            String prompt = """
                    Analyze this image and identify all major objects. For each object detected, provide:
                    1. Name of the object
                    2. Confidence score between 0.0 and 1.0 (estimate how sure you are)
                    3. A brief description of the object and its position.
                    4. The predominant color or color palette of the object (e.g. "Red", "Golden Brown", "Lush Green", "Metallic Silver").
                    
                    Return the result ONLY as a valid JSON array without any markdown wrappers (do NOT include ```json or ```).
                    The JSON array must contain objects with keys: "name", "confidence", "description", and "color".
                    Example:
                    [
                      {"name": "Laptop", "confidence": 0.95, "description": "A silver laptop open on a wooden table", "color": "Silver"}
                    ]
                    """;

            String rawResponse = aiService.generateContent(prompt, imageBytes, mimeType);
            String cleanJson = sanitizeJson(rawResponse);

            Type listType = new TypeToken<ArrayList<DetectedObject>>() {}.getType();
            objects = gson.fromJson(cleanJson, listType);

            if (objects == null || objects.isEmpty()) {
                throw new RuntimeException("Empty object list parsed from AI response.");
            }

        } catch (Exception e) {
            throw new RuntimeException("Image recognition API call failed: " + e.getMessage(), e);
        }

        return objects;
    }

    private String sanitizeJson(String raw) {
        String sanitized = raw.trim();
        // Remove markdown code blocks if the AI returned them
        if (sanitized.startsWith("```")) {
            int start = sanitized.indexOf('\n');
            int end = sanitized.lastIndexOf("```");
            if (start != -1 && end != -1 && end > start) {
                sanitized = sanitized.substring(start, end).trim();
            }
        }
        return sanitized;
    }

    private List<DetectedObject> generateMockObjects(String filename) {
        List<DetectedObject> list = new ArrayList<>();
        String lower = filename.toLowerCase();

        if (lower.contains("cat") || lower.contains("kitten") || lower.contains("persian") || lower.contains("siamese") || lower.contains("tabby") || lower.contains("bengal") || lower.contains("maine_coon")) {
            list.add(new DetectedObject("Cat (Feline Subject)", 0.99, "A domestic cat looking directly at the camera with clear facial features.", "Golden Orange"));
            list.add(new DetectedObject("Focus Point", 0.95, "Central focus on the animal subject.", "Orange and White"));
        } else if (lower.contains("scientist") || lower.contains("actor") || lower.contains("actress") || lower.contains("human") || lower.contains("person") || lower.contains("man") || lower.contains("woman") || lower.contains("people") || lower.contains("musk") || lower.contains("einstein") || lower.contains("sedus")) {
            list.add(new DetectedObject("Human Subject (Person)", 0.99, "A portrait focusing on the posture and expressions of the person.", "Multicolor"));
            list.add(new DetectedObject("Indoor Seating", 0.88, "Contemporary seating arrangement where subjects are positioned.", "Warm Tones"));
        } else if (lower.contains("texture") || lower.contains("abstract") || lower.contains("pattern") || lower.contains("art") || lower.contains("paint")) {
            list.add(new DetectedObject("Abstract Texture Pattern", 0.98, "An abstract composition focusing on intricate visual patterns.", "Vibrant Palette"));
        } else if (lower.contains("office") || lower.contains("workplace") || lower.contains("desk") || lower.contains("meeting") || lower.contains("conference") || lower.contains("lounge")) {
            list.add(new DetectedObject("Modern Office Workspace", 0.96, "A professional workstation environment equipped with office assets.", "Neutral Grey/Brown"));
        } else if (lower.contains("nature") || lower.contains("mountain") || lower.contains("beach") || lower.contains("forest") || lower.contains("travel") || lower.contains("landscape") || lower.contains("tree") || lower.contains("river") || lower.contains("sea")) {
            list.add(new DetectedObject("Natural Landscape", 0.97, "A scenic view showcasing elements of natural vegetation and skies.", "Lush Green/Blue"));
        } else if (lower.contains("dog") || lower.contains("beagle") || lower.contains("retriever") || lower.contains("shepherd") || lower.contains("poodle") || lower.contains("lion") || lower.contains("tiger") || lower.contains("bird") || lower.contains("animal")) {
            list.add(new DetectedObject("Animal (Fauna)", 0.99, "An animal subject captured outdoors.", "Brown and White"));
            list.add(new DetectedObject("Outdoor Path", 0.90, "Paved path outdoors surrounding the subject.", "Light Brown"));
        } else if (lower.contains("car") || lower.contains("vehicle")) {
            list.add(new DetectedObject("Sports Car", 0.97, "A modern red sports sedan parked on the side of a street.", "Red"));
            list.add(new DetectedObject("Asphalt Road", 0.90, "Clean dark asphalt road underneath the car.", "Dark Grey"));
        } else {
            // Generic Default Fallback instead of Beagle Dog
            list.add(new DetectedObject("Primary Visual Subject", 0.95, "The central subject of the uploaded image file.", "Multicolor"));
            list.add(new DetectedObject("Composition Frame", 0.80, "The surrounding visual environment of the composition.", "Neutral"));
        }
        return list;
    }

    /**
     * Generates a descriptive analysis of the image context.
     */
    public String analyzeImageDescription(File imageFile) {
        if (aiService.isMockMode()) {
            return generateMockDescription(imageFile.getName());
        }

        try {
            byte[] imageBytes = Files.readAllBytes(imageFile.toPath());
            String mimeType = Files.probeContentType(imageFile.toPath());
            if (mimeType == null) {
                mimeType = "image/jpeg";
            }

            String prompt = """
                    Provide a detailed visual analysis of this image. Describe the main subject, background, any text, colors, shapes, quantities of objects, and any notable features. Be extremely thorough so this description can be used later to answer user questions about the image.
                    """;

            return aiService.generateContent(prompt, imageBytes, mimeType);
        } catch (Exception e) {
            throw new RuntimeException("Image description analysis failed: " + e.getMessage(), e);
        }
    }

    private String generateMockDescription(String filename) {
        String lower = filename.toLowerCase();

        if (lower.contains("cat") || lower.contains("kitten") || lower.contains("persian") || lower.contains("siamese") || lower.contains("tabby") || lower.contains("bengal") || lower.contains("maine_coon")) {
            return "This image features a domestic cat looking directly at the camera with large round eyes. The cat has a soft, long fur coat. The background is simple and clean, making the cat the central focus of the picture.";
        } else if (lower.contains("scientist") || lower.contains("actor") || lower.contains("actress") || lower.contains("human") || lower.contains("person") || lower.contains("man") || lower.contains("woman") || lower.contains("people") || lower.contains("musk") || lower.contains("einstein") || lower.contains("sedus")) {
            return "This image features human subjects. The focus is on the people, their posture, and their face/expressions. The background is simple and supports the focus on the human subjects.";
        } else if (lower.contains("texture") || lower.contains("abstract") || lower.contains("pattern") || lower.contains("art") || lower.contains("paint")) {
            return "An abstract composition focusing on intricate textures, geometric patterns, and complex color palettes. There is no singular physical subject, but rather a rich artistic design.";
        } else if (lower.contains("office") || lower.contains("workplace") || lower.contains("desk") || lower.contains("meeting") || lower.contains("conference") || lower.contains("lounge")) {
            return "A professional modern workspace depicting a contemporary workstation setting. It features office assets, computers, and clean interior design suited for productive collaboration.";
        } else if (lower.contains("nature") || lower.contains("mountain") || lower.contains("beach") || lower.contains("forest") || lower.contains("travel") || lower.contains("landscape") || lower.contains("tree") || lower.contains("river") || lower.contains("sea")) {
            return "A scenic view of a natural landscape, highlighting organic environmental details like vegetation, clear skies, and natural landforms.";
        } else if (lower.contains("dog") || lower.contains("beagle") || lower.contains("retriever") || lower.contains("shepherd") || lower.contains("poodle") || lower.contains("lion") || lower.contains("tiger") || lower.contains("bird") || lower.contains("animal")) {
            return "An animal subject captured in its natural posture. The image details the distinct anatomical features, coat textures, and shape of the animal standing outdoors.";
        } else if (lower.contains("car") || lower.contains("vehicle")) {
            return "A modern red sports sedan parked on the side of a clean dark asphalt street. In the background, there is a tall metallic street lamp standing on the pavement under a clear day sky.";
        } else {
            // Generic Default Fallback instead of Beagle Dog
            return "An uploaded image containing a primary visual subject in the center of the frame. The image has distinct shapes and colors suitable for conversational visual analysis.";
        }
    }
}
