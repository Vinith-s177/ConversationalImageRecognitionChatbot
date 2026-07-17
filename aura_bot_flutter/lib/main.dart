import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';
import 'package:aura_bot_flutter/core/network/openrouter_client.dart';
import 'package:aura_bot_flutter/domain/repositories/auth_repository.dart';
import 'package:aura_bot_flutter/domain/repositories/chat_repository.dart';
import 'package:aura_bot_flutter/data/repositories/auth_repository_impl.dart';
import 'package:aura_bot_flutter/data/repositories/chat_repository_impl.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/auth_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/chat_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/views/auth_view.dart';
import 'package:aura_bot_flutter/presentation/views/chat_workspace_view.dart';
import 'package:aura_bot_flutter/presentation/views/landing_view.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/settings_viewmodel.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<OpenRouterClient>(() => OpenRouterClient());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(
        openRouterClient: getIt<OpenRouterClient>(),
      ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file. Falling back to default URL.");
  }

  setupDependencyInjection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: getIt<AuthRepository>()),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (_) => ChatViewModel(chatRepository: getIt<ChatRepository>()),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (_) => SettingsViewModel(),
        ),
      ],
      child: const AuraBotApp(),
    ),
  );
}

class AuraBotApp extends StatelessWidget {
  const AuraBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final settingsViewModel = context.watch<SettingsViewModel>();

    return MaterialApp(
      title: 'Conversational Image Recognition Chatbot',
      theme: settingsViewModel.isDarkMode 
          ? AntiGravityTheme.darkTheme 
          : AntiGravityTheme.darkTheme.copyWith(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: AntiGravityTheme.neonCyan,
                secondary: AntiGravityTheme.neonPurple,
                surface: Colors.white,
              ),
            ),
      debugShowCheckedModeBanner: false,
      home: authViewModel.currentUser == null 
          ? const LandingView() 
          : const ChatWorkspaceView(),
    );
  }
}
