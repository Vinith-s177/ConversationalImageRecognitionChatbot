import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aura_bot_flutter/domain/entities/chat_message.dart';
import 'package:aura_bot_flutter/domain/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository chatRepository;

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  XFile? _selectedImage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  XFile? get selectedImage => _selectedImage;

  ChatViewModel({required this.chatRepository});

  Future<void> fetchMessages(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _messages = await chatRepository.getMessages(userId: userId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> sendMessage({required String userId, required String text}) async {
    if (text.trim().isEmpty && _selectedImage == null) return;
    
    _isTyping = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? base64Image;
      String? mimeType;

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
        final ext = _selectedImage!.name.split('.').last.toLowerCase();
        mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      }

      await chatRepository.sendMessage(
        userId: userId,
        userPrompt: text,
        base64Image: base64Image,
        mimeType: mimeType,
        history: _messages,
      );

      await fetchMessages(userId);
      // Removed _selectedImage = null; so the image persists for follow-up questions
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    _isTyping = false;
    notifyListeners();
  }

  Future<void> clearChat(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await chatRepository.clearHistory(userId: userId);
      _messages.clear();
      _selectedImage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
