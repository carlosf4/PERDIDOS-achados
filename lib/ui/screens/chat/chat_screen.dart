import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/chat_service.dart';
import '../../widgets/glass_box.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String itemTitle;
  const ChatScreen({super.key, required this.chatId, required this.itemTitle});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    await ref.read(chatServiceProvider).sendMessage(chatId: widget.chatId, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.inventory_2_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.itemTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: ref.read(chatServiceProvider).getMessagesStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text("Nenhuma mensagem ainda. Diz olá!", style: TextStyle(color: AppColors.grey)),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_id'] == currentUserId;
                      return _buildMessageBubble(
                        context,
                        message: msg['text'],
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
            _buildChatInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, {required String message, required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildChatInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.8),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassBox(
              opacity: 0.1,
              child: TextField(
                controller: _msgController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Escreva uma mensagem...",
                  hintStyle: TextStyle(color: AppColors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: AppColors.accent,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
