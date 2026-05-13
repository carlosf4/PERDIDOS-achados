import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final session = Supabase.instance.client.auth.currentSession;
        final Widget nextScreen = session != null ? const HomeScreen() : const WelcomeScreen();

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder or Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 80,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'PEDIDOS',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  letterSpacing: 8,
                  color: AppColors.white,
                ),
              ),
              Text(
                'ACHADOS',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  letterSpacing: 8,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 60),
              const SpinKitPulse(
                color: AppColors.accent,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
