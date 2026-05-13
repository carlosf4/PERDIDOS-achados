import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PWAManager {
  static final PWAManager _instance = PWAManager._internal();
  factory PWAManager() => _instance;
  PWAManager._internal();

  bool _isInstallable = false;
  bool get isInstallable => _isInstallable;

  VoidCallback? onInstallableChanged;

  void init() {
    if (!kIsWeb) return;

    // Define the callback that JS will call when the app is installable
    js.context['onAppInstallable'] = () {
      _isInstallable = true;
      if (onInstallableChanged != null) {
        onInstallableChanged!();
      }
    };
  }

  void install() {
    if (!kIsWeb) return;
    js.context.callMethod('installPWA');
  }
}
