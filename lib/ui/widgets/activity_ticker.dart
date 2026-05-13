import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/supabase_provider.dart';
import 'glass_box.dart';

class ActivityTicker extends ConsumerStatefulWidget {
  const ActivityTicker({super.key});

  @override
  ConsumerState<ActivityTicker> createState() => _ActivityTickerState();
}

class _ActivityTickerState extends ConsumerState<ActivityTicker> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      
      // We need to know the length of the current activities list to cycle.
      // We will do this carefully in the build method.
      // But we just increment here and let PageView handle snapping or jumping back.
      _currentIndex++;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.elasticOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentItemsAsync = ref.watch(recentItemsStreamProvider);

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassBox(
        borderRadius: BorderRadius.circular(22),
        opacity: 0.1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Pulse Indicator
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.success, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: recentItemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Row(
                        children: [
                          const Text("✨", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Nenhuma atividade recente",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Map real items to ticker format
                    final activities = items.map((item) {
                      final isLost = item['type'] == 'lost';
                      final icon = isLost ? "🚨" : "🎉";
                      final title = item['title'] ?? 'Item';
                      final text = isLost ? "Novo pedido: $title" : "Encontrado: $title";
                      
                      return {"icon": icon, "text": text, "time": "Agora"};
                    }).toList();

                    return PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = activities[index % activities.length];
                        return Row(
                          children: [
                            Text(item['icon']!, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['text']!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Text(
                              item['time']!,
                              style: TextStyle(
                                color: AppColors.grey.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Text("A ligar ao servidor...", style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  error: (_, __) => const Text("Offline", style: TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
