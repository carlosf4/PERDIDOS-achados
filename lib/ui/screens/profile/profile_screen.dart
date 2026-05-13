import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/supabase_service.dart';
import '../../widgets/glass_box.dart';
import '../chat/chat_list_screen.dart';
import '../welcome/welcome_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Utilizador';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
          child: Column(
            children: [
              // Profile Header with Glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.accent,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                email,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildReputationLevel(),
              const SizedBox(height: 32),
              
              // Stats Grid
              Row(
                children: [
                  Expanded(child: _buildStatCard("Recuperados", "12", Icons.history_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Reputação", "980", Icons.star_rounded)),
                ],
              ),
              const SizedBox(height: 32),
              
              // Gamification / Badges
              _buildSectionTitle("Minhas Conquistas"),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildBadge("Buscador", Icons.search, AppColors.accent),
                    _buildBadge("Salvador", Icons.volunteer_activism, AppColors.success),
                    _buildBadge("Honesto", Icons.shield_rounded, AppColors.warning),
                    _buildBadge("Expert", Icons.workspace_premium, Colors.purpleAccent),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Menu Options
              _buildMenuOption(context, "Meus Pedidos", Icons.list_alt_rounded, onTap: () {}),
              _buildMenuOption(
                context, 
                "Histórico de Chats", 
                Icons.chat_bubble_outline_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatListScreen()),
                ),
              ),
              _buildMenuOption(context, "Configurações", Icons.settings_rounded, onTap: () {}),
              _buildMenuOption(context, "Ajuda e Suporte", Icons.help_outline_rounded, onTap: () {}),
              const SizedBox(height: 20),
              _buildMenuOption(context, "Terminar Sessão", Icons.logout_rounded, isDestructive: true, onTap: () async {
                await ref.read(supabaseServiceProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReputationLevel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text(
            "NÍVEL 5 • GUARDIÃO",
            style: TextStyle(
              color: AppColors.accent, 
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassBox(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(icon, color: AppColors.accent, size: 28),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            Text(
              label.toUpperCase(), 
              style: const TextStyle(color: AppColors.grey, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String name, IconData icon, Color color) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            name, 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), 
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: AppColors.grey,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, String title, IconData icon, {bool isDestructive = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassBox(
        opacity: 0.05,
        child: ListTile(
          leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.white.withOpacity(0.8)),
          title: Text(
            title,
            style: TextStyle(
              color: isDestructive ? AppColors.error : AppColors.white.withOpacity(0.9),
              fontSize: 15,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: AppColors.grey.withOpacity(0.5)),
          onTap: onTap,
        ),
      ),
    );
  }
}
