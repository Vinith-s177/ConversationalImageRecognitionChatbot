import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aura_bot_flutter/presentation/viewmodels/auth_viewmodel.dart';
import 'package:aura_bot_flutter/core/theme/anti_gravity_theme.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  void _showSnackbar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final vm = context.read<AuthViewModel>();
    bool success = false;

    if (_isSignUp) {
      if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
        _showSnackbar("Passwords do not match", false);
        return;
      }
      success = await vm.register(
        fullName: _fullNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        mobileNumber: _phoneCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      success = await vm.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    }

    if (success) {
      _showSnackbar(_isSignUp ? "Registration Successful" : "Login Successful", true);
    } else {
      _showSnackbar(vm.errorMessage ?? "Authentication Failed", false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    int step = 1;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          final vm = context.watch<AuthViewModel>();
          return AlertDialog(
            backgroundColor: const Color(0xFF1E243A),
            title: Text(
              step == 1 ? "Forgot Password" : step == 2 ? "Verify OTP" : "Reset Password",
              style: const TextStyle(color: AntiGravityTheme.neonCyan),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (step == 1)
                  TextFormField(
                    controller: emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Email Address", prefixIcon: Icon(Icons.email)),
                  ),
                if (step == 2)
                  TextFormField(
                    controller: otpCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Enter 6-digit OTP", prefixIcon: Icon(Icons.security)),
                  ),
                if (step == 3)
                  TextFormField(
                    controller: newPasswordCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "New Password", prefixIcon: Icon(Icons.lock)),
                  ),
                if (vm.isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                ]
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        if (step == 1) {
                          if (await context.read<AuthViewModel>().forgotPassword(emailCtrl.text.trim())) {
                            setState(() => step = 2);
                          }
                        } else if (step == 2) {
                          if (await context.read<AuthViewModel>().verifyOtp(emailCtrl.text.trim(), otpCtrl.text.trim())) {
                            setState(() => step = 3);
                          }
                        } else if (step == 3) {
                          if (await context.read<AuthViewModel>().resetPassword(emailCtrl.text.trim(), otpCtrl.text.trim(), newPasswordCtrl.text)) {
                            Navigator.pop(context);
                            _showSnackbar("Password reset successful. Please login.", true);
                          }
                        }
                      },
                child: Text(step == 1 ? "Send OTP" : step == 2 ? "Verify" : "Reset"),
              )
            ],
          );
        });
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, Widget? suffix, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        validator: validator ?? (val) => val == null || val.isEmpty ? "Required field" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white54),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AntiGravityTheme.neonCyan),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E17), Color(0xFF1A1F35)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isSignUp ? "Create an Account" : "Welcome Back",
                      style: const TextStyle(
                        color: AntiGravityTheme.neonCyan,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? "Sign up to explore AI image recognition" : "Login to your conversational chatbot",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),

                    if (_isSignUp) ...[
                      _buildTextField(_fullNameCtrl, "Full Name", Icons.person),
                      _buildTextField(_phoneCtrl, "Mobile Number", Icons.phone),
                      _buildTextField(_usernameCtrl, "Username", Icons.alternate_email),
                    ],
                    _buildTextField(_emailCtrl, _isSignUp ? "Email Address" : "Email or Username", Icons.email),
                    
                    _buildTextField(
                      _passwordCtrl,
                      "Password",
                      Icons.lock,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    if (_isSignUp)
                      _buildTextField(
                        _confirmPasswordCtrl,
                        "Confirm Password",
                        Icons.lock_outline,
                        obscure: _obscureConfirmPassword,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),

                    if (!_isSignUp)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (val) => setState(() => _rememberMe = val!),
                                activeColor: AntiGravityTheme.neonCyan,
                              ),
                              const Text("Remember Me", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text("Forgot Password?", style: TextStyle(color: AntiGravityTheme.neonPurple)),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AntiGravityTheme.neonPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: vm.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isSignUp ? "Register" : "Login",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() {
                        _isSignUp = !_isSignUp;
                        _formKey.currentState?.reset();
                      }),
                      child: Text(
                        _isSignUp ? "Already have an account? Login" : "Don't have an account? Register",
                        style: const TextStyle(color: AntiGravityTheme.neonCyan),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
