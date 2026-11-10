import 'package:flutter/foundation.dart';

class GgufBundledService {
  static const String bundledModelName = 'Gemma 2B Instruct (Q4 GGUF)';
  static const String modelFileName = 'gemma-2b-it-q4_k_m.gguf';
  static const String modelAssetPath = 'assets/models/gemma-2b-it-q4_k_m.gguf';

  /// Returns whether pre-bundled on-device GGUF engine is active.
  /// On native platforms (Android, Windows, Linux, macOS), it is pre-bundled in APK/EXE.
  /// On Web, it returns false to keep web payload small and use Cloud APIs.
  static bool get isBundledModelAvailable => !kIsWeb;

  static String get activeEngineDescription {
    if (kIsWeb) {
      return 'Web Mode: Cloud APIs (Gemini / OpenAI / Anthropic / OpenRouter / Ollama) + 20+ Free Connectors active.';
    } else {
      return 'Native Platform: Pre-bundled Gemma 2B GGUF Q4 engine active on-device via Llama.cpp (Zero download required).';
    }
  }
}
