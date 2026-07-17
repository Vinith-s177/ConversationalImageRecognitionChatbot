import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/auth_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/settings_viewmodel.dart';
import 'package:aura_bot_flutter/presentation/widgets/glass_card.dart';
import 'package:aura_bot_flutter/presentation/widgets/glowing_button.dart';
import 'package:aura_bot_flutter/presentation/widgets/particle_field.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _webhookController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final settingsViewModel = context.read<SettingsViewModel>();
      if (authViewModel.currentUser != null) {
        settingsViewModel.loadSettings(authViewModel.currentUser!.id).then((_) {
          _webhookController.text = settingsViewModel.n8nWebhookUrl;
        });
      }
    });
  }

  @override
  void dispose() {
    _webhookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AntiGravityTheme.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ParticleField()),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.palette, color: AntiGravityTheme.neonCyan),
                          SizedBox(width: 8),
                          Text("Appearance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      SwitchListTile(
                        activeColor: AntiGravityTheme.neonCyan,
                        title: const Text("Dark Theme Mode"),
                        subtitle: const Text("Enable a futuristic deep space UI"),
                        value: settingsViewModel.isDarkMode,
                        onChanged: (val) {
                          settingsViewModel.toggleTheme(val);
                        },
                      ),
                      ListTile(
                        title: const Text("Font Size Adjustments"),
                        subtitle: Slider(
                          activeColor: AntiGravityTheme.neonCyan,
                          inactiveColor: Colors.white10,
                          min: 12.0,
                          max: 20.0,
                          divisions: 4,
                          value: settingsViewModel.fontSize,
                          label: "${settingsViewModel.fontSize.toInt()} px",
                          onChanged: (val) {
                            settingsViewModel.updateFontSize(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.settings, color: AntiGravityTheme.neonCyan),
                          SizedBox(width: 8),
                          Text("System & Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      ListTile(
                        title: const Text("Language Selection"),
                        trailing: DropdownButton<String>(
                          value: settingsViewModel.language,
                          dropdownColor: AntiGravityTheme.darkBg,
                          style: const TextStyle(color: Colors.white),
                          underline: Container(height: 1, color: AntiGravityTheme.neonCyan),
                          items: <String>['English', 'Spanish', 'French', 'Hindi', 'Tamil']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              settingsViewModel.changeLanguage(newValue);
                            }
                          },
                        ),
                      ),
                      SwitchListTile(
                        activeColor: AntiGravityTheme.neonCyan,
                        title: const Text("System Alerts"),
                        subtitle: const Text("Receive visual notification triggers"),
                        value: settingsViewModel.notificationsEnabled,
                        onChanged: (val) {
                          settingsViewModel.toggleNotifications(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock_outline, color: AntiGravityTheme.neonCyan),
                          SizedBox(width: 8),
                          Text("Privacy & Security", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      SwitchListTile(
                        activeColor: AntiGravityTheme.neonCyan,
                        title: const Text("Usage Analytics"),
                        subtitle: const Text("Share reports to help optimize vision accuracy"),
                        value: settingsViewModel.shareUsageData,
                        onChanged: (val) {
                          settingsViewModel.togglePrivacyUsage(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_sync_outlined, color: AntiGravityTheme.neonCyan),
                          SizedBox(width: 8),
                          Text("n8n Chatbot Integration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 24),
                      const Text(
                        "Connect your existing n8n AI agent webhook here. If configured, the chatbot will route chat messages directly to n8n instead of OpenRouter.",
                        style: TextStyle(color: AntiGravityTheme.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _webhookController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter n8n Webhook URL",
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(Icons.link, color: AntiGravityTheme.neonCyan),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AntiGravityTheme.neonCyan),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlowingButton(
                        text: "Save Webhook Settings",
                        onPressed: () async {
                          final authViewModel = context.read<AuthViewModel>();
                          if (authViewModel.currentUser != null) {
                            await settingsViewModel.updateN8nWebhookUrl(
                              _webhookController.text.trim(),
                              authViewModel.currentUser!.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("n8n Webhook URL updated successfully."),
                                backgroundColor: AntiGravityTheme.neonCyan,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GlowingButton(
                  text: "Reset Cache & Databases",
                  isSecondary: true,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AntiGravityTheme.darkBg,
                        title: const Text("Clear Cached Logs"),
                        content: const Text("This action will erase local memory resources permanently. Proceed?"),
                        actions: [
                          TextButton(
                            child: const Text("Cancel", style: TextStyle(color: Colors.white30)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text("Clear", style: TextStyle(color: AntiGravityTheme.neonPink)),
                            onPressed: () async {
                              Navigator.pop(context);
                              await settingsViewModel.clearCache();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Cache wiped successfully.")),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
