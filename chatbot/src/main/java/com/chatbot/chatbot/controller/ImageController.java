package com.chatbot.chatbot.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/image")
public class ImageController {

    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadImage(
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestParam("image") MultipartFile imageFile) {
            
        Map<String, Object> response = new HashMap<>();

        try {
            if (imageFile.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Please select an image to upload."));
            }

            if (imageFile.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest().body(Map.of("error", "File size exceeds the 10MB limit."));
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
                return ResponseEntity.badRequest().body(Map.of("error", "Unsupported file format. Please upload JPG, JPEG, or PNG images."));
            }

            String uploadDir = System.getProperty("user.dir") + File.separator + "uploads" + File.separator;
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            String uniqueFilename = UUID.randomUUID().toString() + "_" + originalFilename;
            File savedFile = new File(uploadDir + uniqueFilename);

            imageFile.transferTo(savedFile);
            
            // Just return the path, ChatController handles OCR/recognition based on imagePath
            response.put("success", true);
            response.put("imagePath", "/uploads/" + uniqueFilename);
            
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(Map.of("error", "Failed to process image: " + e.getMessage()));
        }
    }
}
