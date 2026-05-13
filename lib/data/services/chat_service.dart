import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatService {
  final _client = Supabase.instance.client;

  // Retrieve chats for current user
  Future<List<Map<String, dynamic>>> getChats() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('chats')
        .select('*, items(*)')
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Create a new chat or return existing
  Future<Map<String, dynamic>?> createOrGetChat({required String itemId, required String ownerId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    if (userId == ownerId) {
      // User is trying to chat with themselves about their own item
      throw Exception("Não podes iniciar um chat contigo próprio.");
    }

    // Check if chat already exists
    final existing = await _client
        .from('chats')
        .select()
        .eq('item_id', itemId)
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .maybeSingle();

    if (existing != null) {
      return existing;
    }

    // Create new chat
    final newChat = {
      'item_id': itemId,
      'user1_id': userId,
      'user2_id': ownerId,
    };

    final response = await _client.from('chats').insert(newChat).select().single();
    return response;
  }

  // Stream messages for a specific chat
  Stream<List<Map<String, dynamic>>> getMessagesStream(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
  }

  // Send a message
  Future<void> sendMessage({required String chatId, required String text}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'text': text,
    });
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final userChatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final chatService = ref.watch(chatServiceProvider);
  return await chatService.getChats();
});
