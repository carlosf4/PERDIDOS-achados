import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_data.dart';

final lostItemsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => MockData.lostItems);
final foundItemsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => MockData.foundItems);

class LocalAuthService {
  bool get isLoggedIn => true; // Always logged in for simplicity
  String get userName => "João Silva";
}

final authServiceProvider = Provider((ref) => LocalAuthService());
