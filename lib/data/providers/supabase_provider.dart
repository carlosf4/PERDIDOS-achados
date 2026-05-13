import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

final itemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, type) async {
  final supabase = ref.watch(supabaseServiceProvider);
  return await supabase.getItems(type: type);
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(supabaseServiceProvider).authStateChanges;
});

final recentItemsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Supabase.instance.client
      .from('items')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .limit(5);
});
