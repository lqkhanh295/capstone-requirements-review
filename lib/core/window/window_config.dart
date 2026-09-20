import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowConfig {
  static const Size minWindowSize = Size(1200, 800);
  static const Size defaultWindowSize = Size(1400, 900);
  static const String appTitle = 'Capstone Requirements Review - IDE';

  /// Setup and initialize Windows desktop window parameters according to NFR-003.
  static Future<void> initializeWindow() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        await windowManager.ensureInitialized();

        await windowManager.setTitle(appTitle);
        await windowManager.setMinimumSize(minWindowSize);
        await windowManager.setSize(defaultWindowSize);
        await windowManager.center();
        await windowManager.show();
        await windowManager.focus();
      } catch (e) {
        debugPrint('Window manager error: $e');
      }
    }
  }
}
