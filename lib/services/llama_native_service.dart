import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../models/memories_data.dart';
import 'connector_service.dart';

class LlamaNativeService {
  static const String customModelPath = r'C:\mmodels\gemma-2b-it-q4_k_m.gguf';
  static const String shardedModelPath = r'C:\mmodels\gemma-2b-shard-00001-of-00006.gguf';
  static const String customLlamaExePath = r'C:\mmodels\llama-cli.exe';

  /// Resolves valid GGUF model path
  static String? getModelPath() {
    if (kIsWeb) return null;

    if (File(customModelPath).existsSync()) {
      return customModelPath;
    }

    if (File(shardedModelPath).existsSync()) {
      return shardedModelPath;
    }

    try {
      final exeDir = path.dirname(Platform.resolvedExecutable);
      final assetPath = path.join(exeDir, 'data', 'flutter_assets', 'assets', 'models', 'gemma-2b-it-q4_k_m.gguf');
      if (File(assetPath).existsSync()) return assetPath;

      final localPath = path.join(Directory.current.path, 'assets', 'models', 'gemma-2b-it-q4_k_m.gguf');
      if (File(localPath).existsSync()) return localPath;
    } catch (_) {}

    return null;
  }

  /// Resolves valid llama-cli executable on disk
  static String? getLlamaExePath() {
    if (kIsWeb) return null;

    if (File(customLlamaExePath).existsSync()) {
      return customLlamaExePath;
    }

    try {
      final exeDir = path.dirname(Platform.resolvedExecutable);
      final assetBin = path.join(exeDir, 'data', 'flutter_assets', 'assets', 'bin', 'llama-cli.exe');
      if (File(assetBin).existsSync()) return assetBin;

      final localBin = path.join(Directory.current.path, 'assets', 'bin', 'llama-cli.exe');
      if (File(localBin).existsSync()) return localBin;
    } catch (_) {}

    return null;
  }

  /// Cleans up model tokens and symbols
  static String cleanTextOutput(String raw) {
    String cleaned = raw;
    cleaned = cleaned.replaceAll('[end of text]', '');
    cleaned = cleaned.replaceAll('<end_of_turn>', '');
    cleaned = cleaned.replaceAll('<eos>', '');
    cleaned = cleaned.replaceAll('<bos>', '');

    cleaned = cleaned.replaceAll('ðŸ''‹', '👋');
    cleaned = cleaned.replaceAll('ðŸ¤"', '🤗');
    cleaned = cleaned.replaceAll('ðŸ''', '✨');
    cleaned = cleaned.replaceAll('ðŸŒ', '🌸');
    cleaned = cleaned.replaceAll('ðŸ’', '💖');
    cleaned = cleaned.replaceAll('ðŸ4', '💡');

    return cleaned.trim();
  }

  /// Executes live GGUF text generation via Llama.cpp with precise product/intent RAG context
  static Future<String?> runLocalInference({
    required String prompt,
    String noteTitle = '',
    String noteContent = '',
    List<AiConnector>? connectors,
  }) async {
    final modelPath = getModelPath();
    final llamaExe = getLlamaExePath();

    if (modelPath == null || llamaExe == null) {
      return null;
    }

    final lowerPrompt = prompt.toLowerCase();
    final isLongRequest = lowerPrompt.contains('long') ||
        lowerPrompt.contains('detail') ||
        lowerPrompt.contains('explain') ||
        lowerPrompt.contains('rewrite') ||
        lowerPrompt.contains('essay') ||
        lowerPrompt.contains('summarize');
    final maxTokens = isLongRequest ? '1024' : '512';

    final contextStr = StringBuffer();

    // Include Note Content if active
    if (noteContent.trim().isNotEmpty) {
      contextStr.writeln('Active User Note Title: "$noteTitle"');
      contextStr.writeln('Active User Note Content:\n"$noteContent"\n');
    }

    // Always fetch active connector JSON results matched with intent
    if (connectors != null && connectors.isNotEmpty) {
      final connectorData = await ConnectorService.fetchActiveConnectorContext(connectors, userPrompt: prompt);
      if (connectorData.isNotEmpty) {
        contextStr.writeln(connectorData);
      }
    }

    final formattedPrompt =
        '<start_of_turn>user\nSystem: You are Ai⁺ by Origin. The real-time brand & academic JSON connectors have searched live sources and provided retrieved data below. Accurately report the retrieved items (do not mislabel headphones or smartwatches as shoes). Summarize and explain these retrieved insights using emojis like 👋, ✨, 🌸, 💡, 💖.\n${contextStr.toString()}\nUser Request: $prompt<end_of_turn>\n<start_of_turn>model\n';

    try {
      final result = await Process.run(
        llamaExe,
        [
          '-m', modelPath,
          '-p', formattedPrompt,
          '-n', maxTokens,
          '-c', '4096',
          '--temp', '0.7',
          '-t', '8',
          '--no-display-prompt',
        ],
        workingDirectory: r'C:\mmodels',
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ).timeout(Duration(seconds: isLongRequest ? 60 : 35));

      if (result.exitCode == 0) {
        String output = result.stdout.toString().trim();

        if (output.contains('<start_of_turn>model\n')) {
          final idx = output.lastIndexOf('<start_of_turn>model\n');
          output = output.substring(idx + '<start_of_turn>model\n'.length);
        } else if (output.contains('n_keep = 1')) {
          final idx = output.lastIndexOf('n_keep = 1');
          output = output.substring(idx + 'n_keep = 1'.length);
        }

        if (output.contains('llama_perf_sampler_print')) {
          final perfIdx = output.indexOf('llama_perf_sampler_print');
          output = output.substring(0, perfIdx);
        }

        output = cleanTextOutput(output);
        if (output.isNotEmpty) {
          return output;
        }
      }
    } catch (e) {
      return '⚠️ Llama.cpp execution error: $e';
    }

    return null;
  }
}
