import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/pwa_manager.dart';
import '../../widgets/activity_ticker.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pwaManager = PWAManager();

  @override
  void initState() {
    super.initState();
    _pwaManager.onInstallableChanged = () {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // --- HERO SECTION ---
                  _buildHero(context),
                  
                  // --- STATS SECTION ---
                  _buildStats(),
                  
                  // --- FEATURES SECTION ---
                  _buildFeatures(),
                  
                  // --- TESTIMONIALS ---
                  _buildTestimonials(),
                  
                  // --- FAQ SECTION ---
                  _buildFAQ(),
                  
                  // --- FOOTER & LINKS ---
                  _buildFooter(context),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
            
            // Community Pulse Ticker (Floating)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: const ActivityTicker(),
            ),
            
            // PWA Install Button (Floating at the top if installable)
            if (_pwaManager.isInstallable)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: _buildInstallButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallButton() {
    return ElevatedButton.icon(
      onPressed: () => _pwaManager.install(),
      icon: const Icon(Icons.download_rounded, size: 18),
      label: const Text("INSTALAR APP", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent.withOpacity(0.9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        shadowColor: AppColors.accent.withOpacity(0.5),
      ),
    );
  }
// ... rest of the file remains same ...


  Widget _buildHero(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Animated Logo
          Hero(
            tag: 'logo',
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.1),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.explore_rounded, size: 80, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            "PEDIDOS\nACHADOS",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, letterSpacing: 4),
          ),
          const SizedBox(height: 16),
          Text(
            "A maior rede de confiança comunitária do país.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white.withOpacity(0.6), fontSize: 18),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              backgroundColor: AppColors.accent,
            ),
            child: const Text("COMEÇAR AGORA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey, size: 30),
          const Text("SAIBA MAIS", style: TextStyle(color: AppColors.grey, fontSize: 12, letterSpacing: 2)),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("12K+", "Itens Devolvidos"),
          _buildStatItem("50K+", "Membros"),
          _buildStatItem("4.9/5", "Confiança"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent)),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RECURSOS PREMIUM", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 24),
          _buildFeatureCard(Icons.auto_awesome_rounded, "Match Inteligente", "A nossa IA cruza dados em tempo real para encontrar o seu objeto."),
          _buildFeatureCard(Icons.map_rounded, "Mapa em Tempo Real", "Visualize objetos perdidos e achados na sua vizinhança."),
          _buildFeatureCard(Icons.verified_user_rounded, "Comunidade Segura", "Todos os membros são verificados para garantir segurança."),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Text("DEPOIMENTOS", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildTestimonialCard("Maria S.", "Recuperei o meu iPhone em 2h graças ao João! Incrível."),
              _buildTestimonialCard("Pedro R.", "O melhor sistema de achados e perdidos que já usei."),
              _buildTestimonialCard("Ana G.", "Segurança total e comunidade muito prestável."),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(String name, String text) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14)),
          const Spacer(),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Text("FAQ", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          _buildFAQItem("É gratuito?", "Sim, as funções básicas de procura e anúncio são totalmente gratuitas."),
          _buildFAQItem("Como garanto a minha segurança?", "Recomendamos encontros em locais públicos ou esquadras de polícia."),
          _buildFAQItem("O que é o Match Inteligente?", "É o nosso algoritmo que compara fotos e descrições para sugerir donos."),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      children: [Padding(padding: const EdgeInsets.all(16), child: Text(a, style: const TextStyle(color: AppColors.grey, fontSize: 13)))],
      iconColor: AppColors.accent,
      collapsedIconColor: AppColors.grey,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Divider(color: Colors.white10),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.facebook),
            _buildSocialIcon(Icons.camera_alt_outlined),
            _buildSocialIcon(Icons.alternate_email),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink("Termos"),
            _buildFooterLink("Privacidade"),
            _buildFooterLink("Documentação"),
          ],
        ),
        const SizedBox(height: 32),
        Text("© 2024 PEDIDOS/ACHADOS. Todos os direitos reservados.", style: TextStyle(color: AppColors.grey.withOpacity(0.5), fontSize: 10)),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(icon, color: AppColors.grey, size: 24),
    );
  }

  Widget _buildFooterLink(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

