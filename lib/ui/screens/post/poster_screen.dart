import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PosterScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  const PosterScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cartaz Gerado"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
            child: Column(
              children: [
                const Text(
                  "ESTÁ PRONTO PARA PARTILHAR!",
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 24),
                
                // The Poster Card
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "PERDIDO",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Photo
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              image: const DecorationImage(
                                image: NetworkImage("https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=400"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title & Price
                        Text(
                          item['title'] ?? "iPhone 13 Pro",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "RECOMPENSA: 50€",
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                        const SizedBox(height: 24),
                        // QR Code Placeholder
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Digitalize para ajudar",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Share Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_rounded),
                        label: const Text("PARTILHAR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(0, 60),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.download_rounded, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
