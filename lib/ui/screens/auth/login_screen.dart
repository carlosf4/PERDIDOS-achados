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
  bool _isSignUp = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      if (_isSignUp) {
        await supabase.signUpWithEmail(
          email: _emailController.text.trim(),
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
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        _navigateToHome();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro inesperado: $e")));
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

              GlassBox(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hint: "Seu Email",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "Palavra-passe",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isSignUp ? "Criar Conta" : "Entrar"),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp ? "Já tens conta? Entrar" : "Ainda não tens conta? Regista-te",
                          style: const TextStyle(color: AppColors.accent),
                        ),
                      ),
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
              _buildSocialButton("Google", Icons.g_mobiledata_rounded, Colors.white, Colors.black, onTap: () {
                ref.read(supabaseServiceProvider).signInWithGoogle();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.grey),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
