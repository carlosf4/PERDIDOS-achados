import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Auth
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({required String email, required String password}) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  // Items
  Future<List<Map<String, dynamic>>> getItems({required String type}) async {
    try {
      final response = await _client
          .from('items')
          .select()
          .eq('type', type)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If table doesn't exist or other error, return empty for now or handle accordingly
      print("Error fetching items: $e");
      return [];
    }
  }

  Future<void> createItem(Map<String, dynamic> item) async {
    await _client.from('items').insert(item);
  }

  Future<String?> uploadItemImage(Uint8List fileBytes, String fileName) async {
    try {
      final path = 'public/$fileName';
      await _client.storage.from('item-images').uploadBinary(
            path,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      final publicUrl = _client.storage.from('item-images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}

final supabaseServiceProvider = Provider((ref) => SupabaseService());
