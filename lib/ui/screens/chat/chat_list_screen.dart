import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/chat_service.dart';
import '../../widgets/glass_box.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversas", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: chatsAsync.when(
          data: (chats) {
            if (chats.isEmpty) {
              return const Center(child: Text("Ainda não tens mensagens.", style: TextStyle(color: AppColors.grey)));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                // Determine other user's ID
                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                
                final itemData = chat['items'] ?? {};
                final itemTitle = itemData['title'] ?? 'Objeto Desconhecido';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassBox(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                        child: const Icon(Icons.person, color: AppColors.accent),
                      ),
                      title: Text(itemTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("Toca para abrir a conversa", maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chatId: chat['id'], itemTitle: itemTitle),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, st) => Center(child: Text("Erro: $e", style: const TextStyle(color: AppColors.error))),
        ),
      ),
    );
  }
}
