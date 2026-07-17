import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/auth_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/chat_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/widgets/glass_card.dart';
import 'package:aura_bot_flutter/presentation/widgets/glowing_button.dart';
import 'package:aura_bot_flutter/presentation/widgets/particle_field.dart';
import 'package:aura_bot_flutter/presentation/views/settings_view.dart';
import 'package:aura_bot_flutter/presentation/views/camera_view.dart';
import 'package:aura_bot_flutter/domain/entities/chat_message.dart';

class ChatWorkspaceView extends StatefulWidget {
  const ChatWorkspaceView({super.key});

  @override
  State<ChatWorkspaceView> createState() => _ChatWorkspaceViewState();
}

class _ChatWorkspaceViewState extends State<ChatWorkspaceView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().currentUser;
      if (user != null) {
        context.read<ChatViewModel>().fetchMessages(user.id);
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final chatViewModel = context.watch<ChatViewModel>();
    final user = authViewModel.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleField()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, user, authViewModel, chatViewModel),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (MediaQuery.of(context).size.width > 900)
                        _buildSidePanel(context, chatViewModel),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16.0),
                                itemCount: chatViewModel.messages.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return _buildWelcomeMessage();
                                  }
                                  final msg = chatViewModel.messages[index - 1];
                                  return _buildMessageBubble(msg);
                                },
                              ),
                            ),
                            if (chatViewModel.isTyping)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 24),
                                    SpinKitThreeBounce(
                                      color: AntiGravityTheme.neonCyan,
                                      size: 20.0,
                                    ),
                                  ],
                                ),
                              ),
                            if (chatViewModel.messages.isNotEmpty)
                              _buildSuggestedPrompts(user.id, chatViewModel),
                            if (chatViewModel.selectedImage != null)
                              _buildSelectedImagePreview(chatViewModel),
                            _buildInputBar(context, user.id, chatViewModel),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user, authViewModel, chatViewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        borderRadius: 12.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AntiGravityTheme.neonCyan.withOpacity(0.2),
                  child: const Icon(Icons.psychology, color: AntiGravityTheme.neonCyan),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(color: AntiGravityTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AntiGravityTheme.neonCyan),
                  onPressed: () {
                    chatViewModel.clearChat(user.id);
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings, color: AntiGravityTheme.neonCyan),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsView()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                  ),
                  onPressed: () {
                    authViewModel.logout();
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, ChatViewModel viewModel) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16.0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AntiGravityTheme.neonCyan),
                SizedBox(width: 8),
                Text(
                  "AI Vision Insights",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            const Text(
              "Identify details like objects, plants, colors, shapes, text (OCR), and currency by uploading a photo in the chat bar below.",
              style: TextStyle(color: AntiGravityTheme.textMuted),
            ),
            const SizedBox(height: 24),
            if (viewModel.selectedImage != null) ...[
              const Text("Target Image Preview:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(
                        viewModel.selectedImage!.path,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(viewModel.selectedImage!.path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ] else
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48, color: Colors.white24),
                      SizedBox(height: 12),
                      Text("No active photo selected", style: TextStyle(color: AntiGravityTheme.textMuted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: AntiGravityTheme.neonCyan),
                const SizedBox(width: 8),
                Text("Welcome to the Conversational Image Recognition Chatbot!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "I am your visual intelligence assistant. Attach any image using the camera or gallery, then ask me questions about it!",
              style: TextStyle(color: AntiGravityTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isUser ? const Radius.circular(16.0) : const Radius.circular(4.0),
            bottomRight: isUser ? const Radius.circular(4.0) : const Radius.circular(16.0),
          ),
          gradient: isUser ? AntiGravityTheme.neonGradient : null,
          color: isUser ? null : const Color(0x26FFFFFF),
          border: isUser ? null : Border.all(color: AntiGravityTheme.borderOverlay),
          boxShadow: isUser ? AntiGravityTheme.cyanGlow(opacity: 0.1, blur: 8) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  message.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      color: Colors.white10,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white24),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompts(String userId, ChatViewModel viewModel) {
    final prompts = ["What is this?", "Where is it used?", "Give interesting facts", "Is it dangerous?"];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final text = prompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: Colors.white.withOpacity(0.05),
              side: const BorderSide(color: Colors.white10),
              label: Text(text, style: const TextStyle(color: AntiGravityTheme.neonCyan, fontSize: 12)),
              onPressed: () {
                _textController.text = text;
                viewModel.sendMessage(userId: userId, text: text);
                _textController.clear();
                _scrollToBottom();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedImagePreview(ChatViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.all(8.0),
        borderRadius: 12.0,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.network(
                      viewModel.selectedImage!.path,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(viewModel.selectedImage!.path),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Photo selected and ready to analyze",
                style: TextStyle(fontSize: 12, color: AntiGravityTheme.textMuted),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () {
                viewModel.clearSelectedImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, String userId, ChatViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: AntiGravityTheme.neonCyan),
            onPressed: () async {
              final file = await _imagePicker.pickImage(source: ImageSource.gallery);
              if (file != null) {
                viewModel.selectImage(file);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AntiGravityTheme.neonCyan),
            onPressed: () async {
              try {
                final cameras = await availableCameras();
                if (cameras.isNotEmpty && context.mounted) {
                  final file = await Navigator.push<XFile>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraView(cameras: cameras),
                    ),
                  );
                  if (file != null) {
                    viewModel.selectImage(file);
                  }
                } else {
                  final file = await _imagePicker.pickImage(source: ImageSource.camera);
                  if (file != null) {
                    viewModel.selectImage(file);
                  }
                }
              } catch (_) {
                final file = await _imagePicker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  viewModel.selectImage(file);
                }
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              borderRadius: 12.0,
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Ask something about this image...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AntiGravityTheme.neonGradient,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                final txt = _textController.text;
                viewModel.sendMessage(userId: userId, text: txt);
                _textController.clear();
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }
}
