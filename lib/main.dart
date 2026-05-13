import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/pwa_manager.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  PWAManager().init();
  runApp(
    const ProviderScope(
      child: PedidosAchadosApp(),
    ),
  );
}

class PedidosAchadosApp extends StatelessWidget {
  const PedidosAchadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos/Achados',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
