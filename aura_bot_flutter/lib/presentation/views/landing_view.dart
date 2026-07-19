import 'package:flutter/material.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';
import 'package:aura_bot_flutter/presentation/views/auth_view.dart';
import 'package:provider/provider.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/auth_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/views/chat_workspace_view.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToApp() {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.currentUser != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatWorkspaceView()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090B13), Color(0xFF131830)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildNavbar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(),
                    _buildFeaturesSection(),
                    _buildFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Row(
        children: [
          Icon(Icons.psychology, color: AntiGravityTheme.neonCyan, size: 28),
          const SizedBox(width: 8),
          const Text("AI Chatbot", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white70), onPressed: () {}),
        TextButton(
          onPressed: _navigateToApp,
          child: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _navigateToApp,
          style: ElevatedButton.styleFrom(
            backgroundColor: AntiGravityTheme.neonPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Register", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: width > 800 ? 100 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Conversational Image Recognition\nChatbot",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 700,
            child: Text(
              "Upload any image and let our AI extract text, recognize objects, and engage in a natural conversation.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.5),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _navigateToApp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  backgroundColor: AntiGravityTheme.neonPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 10,
                  shadowColor: AntiGravityTheme.neonPurple.withOpacity(0.5),
                ),
                child: const Row(
                  children: [
                    Text("Get Started", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  _scrollController.animateTo(
                    MediaQuery.of(context).size.height,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Explore Features", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 80),
          // A modern glassmorphism mock image or illustration could go here
          Container(
            height: 400,
            width: 800,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(color: AntiGravityTheme.neonCyan.withOpacity(0.1), blurRadius: 100, spreadRadius: 10),
              ],
            ),
            child: Center(
              child: Icon(Icons.image_search, size: 100, color: AntiGravityTheme.neonCyan),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: width > 800 ? 100 : 20),
      child: Column(
        children: [
          const Text(
            "Why Choose Our AI",
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(Icons.document_scanner, "Text Extraction", "Extract text from images using advanced OCR technology."),
              _buildFeatureCard(Icons.visibility, "Object Recognition", "Identify objects, people, and scenery within any uploaded image."),
              _buildFeatureCard(Icons.chat_bubble, "Conversational AI", "Ask follow-up questions about the image and get natural responses."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AntiGravityTheme.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AntiGravityTheme.neonCyan, size: 32),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: Colors.white70, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: const Center(
        child: Text(
          "© 2026 Conversational Image Recognition Chatbot.",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
