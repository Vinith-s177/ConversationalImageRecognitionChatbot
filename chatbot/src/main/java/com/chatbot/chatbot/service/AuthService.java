package com.chatbot.chatbot.service;

import com.chatbot.chatbot.model.User;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

    // Maps token -> User
    private final ConcurrentHashMap<String, User> tokenStore = new ConcurrentHashMap<>();

    public String generateToken(User user) {
        String token = UUID.randomUUID().toString();
        tokenStore.put(token, user);
        return token;
    }

    public void invalidateToken(String token) {
        if (token != null) {
            tokenStore.remove(token);
        }
    }

    public Optional<User> getUserByToken(String token) {
        if (token == null) return Optional.empty();
        return Optional.ofNullable(tokenStore.get(token));
    }
}
