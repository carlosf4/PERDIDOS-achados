import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/supabase_service.dart';
import '../../widgets/glass_box.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isEmailLogin = true;
  bool _isSignUp = false;
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final supabase = ref.read(supabaseServiceProvider);
      if (_isEmailLogin) {
        if (_isSignUp) {
          await supabase.signUpWithEmail(
            email: _inputController.text.trim(),
            password: _passwordController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Conta criada com sucesso! Podes entrar agora.")),
            );
            setState(() {
              _isSignUp = false;
              _isLoading = false;
            });
          }
        } else {
          await supabase.signInWithEmail(
            email: _inputController.text.trim(),
            password: _passwordController.text,
          );
          _navigateToHome();
        }
      } else {
        if (_inputController.text.isNotEmpty) {
          // Phone login placeholder (needs Supabase OTP config)
          _showOTPDialog();
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro inesperado: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showOTPDialog() {
    setState(() => _isLoading = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBox(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 40, 24, MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Verificação", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Introduza o código enviado para ${_inputController.text}", style: const TextStyle(color: AppColors.grey)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) => _buildOTPBox()),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen())),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text("Confirmar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Pedidos/Achados", style: Theme.of(context).textTheme.displayLarge, textAlign: TextAlign.center),
              const SizedBox(height: 48),
              
              // Selector
              Row(
                children: [
                  _buildTab("Email", _isEmailLogin, () => setState(() => _isEmailLogin = true)),
                  _buildTab("Telemóvel", !_isEmailLogin, () => setState(() => _isEmailLogin = false)),
                ],
              ),
              const SizedBox(height: 24),

              GlassBox(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _inputController,
                        hint: _isEmailLogin ? "Seu Email" : "Número de Telemóvel",
                        icon: _isEmailLogin ? Icons.email_outlined : Icons.phone_android_rounded,
                        isPhone: !_isEmailLogin,
                      ),
                      if (_isEmailLogin) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Palavra-passe",
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isEmailLogin 
                              ? (_isSignUp ? "Criar Conta" : "Entrar") 
                              : "Enviar Código"),
                      ),
                      if (_isEmailLogin) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _isSignUp = !_isSignUp),
                          child: Text(
                            _isSignUp ? "Já tens conta? Entrar" : "Ainda não tens conta? Regista-te",
                            style: const TextStyle(color: AppColors.accent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Social Login Section
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.grey, thickness: 0.2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Ou entre com", style: TextStyle(color: AppColors.grey.withOpacity(0.5), fontSize: 12)),
                  ),
                  const Expanded(child: Divider(color: AppColors.grey, thickness: 0.2)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildSocialButton("Google", Icons.g_mobiledata_rounded, Colors.white, Colors.black, onTap: () {
                    ref.read(supabaseServiceProvider).signInWithGoogle();
                  })),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSocialButton("Apple", Icons.apple_rounded, Colors.black, Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? _navigateToHome,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? AppColors.accent : Colors.transparent, width: 2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPhone = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.grey),
        hintText: isPhone ? "+(Cód. País) Número" : hint,
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
