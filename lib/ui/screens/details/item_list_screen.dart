import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/supabase_provider.dart';
import '../../widgets/premium_card.dart';
import '../details/item_details_screen.dart';

class ItemListScreen extends ConsumerWidget {
  final String title;
  final bool showLost;

  const ItemListScreen({super.key, required this.title, required this.showLost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = showLost ? 'lost' : 'found';
    final itemsAsyncValue = ref.watch(itemsProvider(type));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: itemsAsyncValue.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  "Nenhum item encontrado.",
                  style: TextStyle(color: AppColors.grey, fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: PremiumCard(
                    title: item['title'] ?? 'Sem título',
                    subtitle: item['description'] ?? 'Sem descrição',
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(item['image_url'] ?? "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=100"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ItemDetailsScreen(item: item)),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (error, stackTrace) => Center(
            child: Text(
              "Erro ao carregar itens: $error",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
