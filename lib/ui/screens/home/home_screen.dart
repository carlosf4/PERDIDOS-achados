import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/glass_box.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/activity_ticker.dart';
import '../post/post_item_screen.dart';
import '../profile/profile_screen.dart';
import '../details/item_list_screen.dart';
import '../../../data/providers/supabase_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lostItemsAsync = ref.watch(itemsProvider('lost'));
    final foundItemsAsync = ref.watch(itemsProvider('found'));

    final lostCountText = lostItemsAsync.maybeWhen(
      data: (items) => "${items.length} itens reportados recentemente",
      orElse: () => "A carregar...",
    );

    final foundCountText = foundItemsAsync.maybeWhen(
      data: (items) => "${items.length} itens esperando pelos donos",
      orElse: () => "A carregar...",
    );

    return Scaffold(
      body: Stack(
        children: [
          // Premium Mock Map Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1E1E1E), Color(0xFF0A0A0A)],
              ),
            ),
            child: Stack(
              children: [
                const _RadarEffect(),
                // Grid lines for tech look
                Opacity(
                  opacity: 0.05,
                  child: GridPaper(
                    color: AppColors.accent,
                    divisions: 1,
                    subdivisions: 1,
                    interval: 100,
                    child: Container(),
                  ),
                ),
                // Custom Animated Pins
                ..._buildMockPins(),
              ],
            ),
          ),

          // Community Pulse Ticker (NEW Premium Widget)
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: const ActivityTicker(),
          ),

          // Header Overlay
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  ),
                  child: const GlassBox(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.accent,
                            child: Icon(Icons.person, size: 16, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Olá",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const GlassBox(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Panel
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: "Perdi Algo",
                        icon: Icons.search_off_rounded,
                        color: AppColors.error,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PostItemScreen(type: PostType.lost)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        label: "Encontrei Algo",
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PostItemScreen(type: PostType.found)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PremiumCard(
                  title: "Objetos Perdidos",
                  subtitle: lostCountText,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemListScreen(title: "Perdidos", showLost: true),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  title: "Objetos Encontrados",
                  subtitle: foundCountText,
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemListScreen(title: "Encontrados", showLost: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMockPins() {
    return [
      const _MapPin(top: 200, left: 100, color: AppColors.error, label: "iPhone"),
      const _MapPin(top: 350, left: 250, color: AppColors.success, label: "Carteira"),
      const _MapPin(top: 500, left: 150, color: AppColors.accent, label: "Chaves"),
    ];
  }
}

class _RadarEffect extends StatefulWidget {
  const _RadarEffect();

  @override
  State<_RadarEffect> createState() => _RadarEffectState();
}

class _RadarEffectState extends State<_RadarEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(3, (index) {
              final progress = (_controller.value + (index / 3)) % 1.0;
              return Container(
                width: 600 * progress,
                height: 600 * progress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.2 * (1 - progress)),
                    width: 2,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final double top;
  final double left;
  final Color color;
  final String label;

  const _MapPin({required this.top, required this.left, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Stack(
            alignment: Alignment.center,
            children: [
              _PulseCircle(color: color),
              Icon(Icons.location_on_rounded, color: color, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseCircle extends StatefulWidget {
  final Color color;
  const _PulseCircle({required this.color});

  @override
  State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 40 * _controller.value,
          height: 40 * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(1 - _controller.value),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: GlassBox(
        opacity: 0.15,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

