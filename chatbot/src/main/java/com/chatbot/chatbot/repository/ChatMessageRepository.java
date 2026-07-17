package com.chatbot.chatbot.repository;

import com.chatbot.chatbot.model.ChatMessage;
import com.chatbot.chatbot.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByUserOrderByIdAsc(User user);
    void deleteByUser(User user);
}
