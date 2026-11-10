import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/memories_data.dart';

class CloudAiService {
  static Future<String> generateResponse({
    required String prompt,
    required AppSettings settings,
    String noteTitle = '',
    String noteContent = '',
    List<AiConnector>? connectors,
  }) async {
    final systemContext = StringBuffer();
    systemContext.writeln('You are Ai⁺, a warm, intelligent personal companion and diary assistant created by Origin.');
    if (noteContent.trim().isNotEmpty) {
      systemContext.writeln('Active User Note Title: "$noteTitle"');
      systemContext.writeln('Active User Note Content:\n"$noteContent"');
    }

    // 1. Google Gemini API Key (Support latest free tier models: gemini-2.5-flash, gemini-2.0-flash, gemini-1.5-flash)
    if (settings.geminiApiKey.trim().isNotEmpty) {
      final apiKey = settings.geminiApiKey.trim();
      final geminiModels = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];

      for (var modelName in geminiModels) {
        try {
          final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_instruction': {
                'parts': [
                  {'text': systemContext.toString()}
                ]
              },
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ]
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final candidates = data['candidates'] as List?;
            if (candidates != null && candidates.isNotEmpty) {
              final parts = candidates[0]['content']['parts'] as List?;
              if (parts != null && parts.isNotEmpty) {
                return parts[0]['text'].toString().trim();
              }
            }
          } else if (response.statusCode == 404) {
            // Model not found on this endpoint, try next model in fallback list
            continue;
          } else {
            // Fallback request format without system_instruction if older format required
            final fallbackUrl = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey');
            final fbResponse = await http.post(
              fallbackUrl,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': '${systemContext.toString()}\nUser Prompt: $prompt'}
                    ]
                  }
                ]
              }),
            );

            if (fbResponse.statusCode == 200) {
              final data = jsonDecode(fbResponse.body);
              final candidates = data['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final parts = candidates[0]['content']['parts'] as List?;
                if (parts != null && parts.isNotEmpty) {
                  return parts[0]['text'].toString().trim();
                }
              }
            } else {
              final err = jsonDecode(fbResponse.body);
              return '⚠️ Gemini API Error (${fbResponse.statusCode}): ${err['error']?['message'] ?? fbResponse.body}';
            }
          }
        } catch (_) {
          continue;
        }
      }
    }

    // 2. OpenAI API Key
    if (settings.openAiApiKey.trim().isNotEmpty) {
      try {
        final apiKey = settings.openAiApiKey.trim();
        final url = Uri.parse('https://api.openai.com/v1/chat/completions');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o-mini',
            'messages': [
              {'role': 'system', 'content': systemContext.toString()},
              {'role': 'user', 'content': prompt}
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'].toString().trim();
        } else {
          final err = jsonDecode(response.body);
          return '⚠️ OpenAI API Error (${response.statusCode}): ${err['error']?['message'] ?? response.body}';
        }
      } catch (e) {
        return '⚠️ Error contacting OpenAI API: $e';
      }
    }

    // 3. Anthropic Claude API Key
    if (settings.anthropicApiKey.trim().isNotEmpty) {
      try {
        final apiKey = settings.anthropicApiKey.trim();
        final url = Uri.parse('https://api.anthropic.com/v1/messages');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': 'claude-3-haiku-20240307',
            'max_tokens': 1024,
            'messages': [
              {'role': 'user', 'content': '${systemContext.toString()}\n$prompt'}
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final contentList = data['content'] as List?;
          if (contentList != null && contentList.isNotEmpty) {
            return contentList[0]['text'].toString().trim();
          }
        } else {
          final err = jsonDecode(response.body);
          return '⚠️ Anthropic API Error (${response.statusCode}): ${err['error']?['message'] ?? response.body}';
        }
      } catch (e) {
        return '⚠️ Error contacting Anthropic API: $e';
      }
    }

    // 4. OpenRouter API Key (Free tier models)
    if (settings.openRouterApiKey.trim().isNotEmpty) {
      try {
        final apiKey = settings.openRouterApiKey.trim();
        final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'google/gemini-2.0-flash-exp:free',
            'messages': [
              {'role': 'system', 'content': systemContext.toString()},
              {'role': 'user', 'content': prompt}
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['choices'][0]['message']['content'].toString().trim();
        } else {
          final err = jsonDecode(response.body);
          return '⚠️ OpenRouter API Error (${response.statusCode}): ${err['error']?['message'] ?? response.body}';
        }
      } catch (e) {
        return '⚠️ Error contacting OpenRouter API: $e';
      }
    }

    // 5. Ollama Endpoint
    if (settings.ollamaUrl.trim().isNotEmpty && settings.ollamaUrl != 'http://localhost:11434') {
      try {
        final baseUrl = settings.ollamaUrl.trim();
        final url = Uri.parse('$baseUrl/api/generate');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': 'llama3',
            'prompt': '${systemContext.toString()}\nUser: $prompt',
            'stream': false,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['response'].toString().trim();
        }
      } catch (_) {}
    }

    // 6. Zero API Key Mode: Query Live Connectors
    try {
      final zenRes = await http.get(Uri.parse('https://zenquotes.io/api/random')).timeout(const Duration(seconds: 4));
      if (zenRes.statusCode == 200) {
        final quoteData = jsonDecode(zenRes.body);
        if (quoteData is List && quoteData.isNotEmpty) {
          final quote = quoteData[0]['q'];
          final author = quoteData[0]['a'];
          return '💡 Live Companion Reflection (Zero API Key Mode):\n\n"$quote"\n— $author\n\n*(Note: Paste a Google Gemini or OpenAI API key in Settings ➔ Cloud APIs to enable deep generative chat!)*';
        }
      }
    } catch (_) {}

    return '💡 No Cloud API Key configured yet!\n\nPlease paste a **Google Gemini API Key** or **OpenAI API Key** in **Settings ➔ Cloud APIs** and tap "Save API Configurations" to unlock live generative AI responses.';
  }
}
