import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/chat_service.dart';
import '../../widgets/glass_box.dart';
import '../chat/chat_screen.dart';

class ItemDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLost = item['status'] == 'lost';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const GlassBox(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Image with Gradient Overlay
              Stack(
                children: [
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(item['image_url'] ?? "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=1000"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isLost ? AppColors.error : AppColors.success).withOpacity(0.2),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.8),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLost ? AppColors.error : AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isLost ? "PERDIDO" : "ENCONTRADO",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] ?? 'Sem título',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['category'] ?? 'Sem categoria',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildInfoRow(Icons.calendar_today_rounded, "Data", isLost ? (item['date_lost'] ?? 'N/A') : (item['date_found'] ?? 'N/A')),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on_rounded, "Localização", item['location'] ?? "Não especificada"),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.monetization_on_rounded, "Recompensa", "${item['reward'] ?? 0} €", valueColor: AppColors.warning),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle("Descrição"),
                    const SizedBox(height: 12),
                    Text(
                      item['description'] ?? 'Sem descrição.',
                      style: TextStyle(color: AppColors.white.withOpacity(0.8), height: 1.5),
                    ),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle("Matches Encontrados pela IA"),
                    const SizedBox(height: 12),
                    _buildMatchMiniCard(context, "Carteira Semelhante", "95% Match", AppColors.success),
                    const SizedBox(height: 8),
                    _buildMatchMiniCard(context, "Objeto com mesma cor", "82% Match", AppColors.accent),
                    
                    const SizedBox(height: 40),
                    // Contact Button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final chatService = ref.read(chatServiceProvider);
                          final ownerId = item['user_id'];
                          final itemId = item['id'];

                          if (ownerId == null || itemId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro: Dados do item incompletos.")));
                            return;
                          }

                          // Show loading indicator
                          showDialog(
                            context: context, 
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator())
                          );

                          final chat = await chatService.createOrGetChat(itemId: itemId, ownerId: ownerId);
                          
                          if (context.mounted) {
                            Navigator.pop(context); // hide loading
                            if (chat != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(chatId: chat['id'], itemTitle: item['title'] ?? 'Chat'),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // hide loading
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: AppColors.accent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_rounded),
                          const SizedBox(width: 12),
                          Text(
                            isLost ? "Contactar Proprietário" : "Entrar em Contacto",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
            Text(
              value, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: valueColor ?? AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 14, 
        fontWeight: FontWeight.bold, 
        color: AppColors.grey,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMatchMiniCard(BuildContext context, String title, String score, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ItemMatchScreen()),
      ),
      child: GlassBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.compare_arrows_rounded, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text("Baseado na descrição e localização", style: TextStyle(color: AppColors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Text(
                score,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemMatchScreen extends StatelessWidget {
  const ItemMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comparação Inteligente"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Column(
          children: [
            const SizedBox(height: 120),
            const _MatchProbabilityCircle(score: 0.95),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                children: [
                  _buildComparisonHalf("O SEU ITEM", "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=400"),
                  _buildComparisonHalf("ENCONTRADO", "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=401"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60)),
                child: const Text("É O MEU ITEM!"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonHalf(String label, String url) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                border: Border.all(color: AppColors.white.withOpacity(0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchProbabilityCircle extends StatelessWidget {
  final double score;
  const _MatchProbabilityCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: score,
            strokeWidth: 8,
            color: AppColors.success,
            backgroundColor: AppColors.white.withOpacity(0.1),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${(score * 100).toInt()}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("MATCH", style: TextStyle(color: AppColors.grey, letterSpacing: 2)),
          ],
        ),
      ],
    );
  }
}
