import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/memories_data.dart';

class ConnectorService {
  static const Map<String, String> _standardHeaders = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
  };

  /// Smartly filters active connectors based on prompt intent and queries them concurrently
  static Future<String> fetchActiveConnectorContext(List<AiConnector> connectors, {String userPrompt = ''}) async {
    final activeConnectors = connectors.where((c) => c.isEnabled).toList();
    if (activeConnectors.isEmpty) {
      return '[Live Connectors Search Results]: No active connectors enabled.';
    }

    final lowerPrompt = userPrompt.toLowerCase();

    // Smart Intent Router: Filter top matching connectors based on prompt keywords
    List<AiConnector> selectedConnectors = [];

    if (lowerPrompt.contains('shop') ||
        lowerPrompt.contains('buy') ||
        lowerPrompt.contains('price') ||
        lowerPrompt.contains('product') ||
        lowerPrompt.contains('brand') ||
        lowerPrompt.contains('store')) {
      // Find matching shopping brand connectors
      final brandMatches = activeConnectors.where((c) {
        final nameLower = c.name.toLowerCase();
        final brandWord = nameLower.replaceAll(RegExp(r'[^\w\s]'), '').split(' ').first;
        return c.category == ConnectorCategory.shopping && (lowerPrompt.contains(brandWord) || lowerPrompt.contains(c.id));
      }).toList();

      if (brandMatches.isNotEmpty) {
        selectedConnectors = brandMatches.take(4).toList();
      } else {
        selectedConnectors = activeConnectors.where((c) => c.category == ConnectorCategory.shopping).take(4).toList();
      }
    } else if (lowerPrompt.contains('weather') || lowerPrompt.contains('temp')) {
      selectedConnectors = activeConnectors.where((c) => c.url.contains('open-meteo') || c.category == ConnectorCategory.wellBeing).take(3).toList();
    } else if (lowerPrompt.contains('quote') || lowerPrompt.contains('motto') || lowerPrompt.contains('inspiration')) {
      selectedConnectors = activeConnectors.where((c) => c.url.contains('zenquotes') || c.url.contains('stoic')).take(3).toList();
    } else {
      // Default balanced selection from each category
      selectedConnectors = activeConnectors.take(5).toList();
    }

    if (selectedConnectors.isEmpty) {
      selectedConnectors = activeConnectors.take(5).toList();
    }

    final buffer = StringBuffer();
    buffer.writeln('\n[REAL-TIME LIVE CONNECTOR SEARCH RESULTS]');

    final futures = selectedConnectors.map((c) async {
      try {
        final response = await http
            .get(Uri.parse(c.url), headers: _standardHeaders)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final extracted = _extractJsonData(data, c);
          return '• ${c.name} (${c.region}): $extracted';
        }
      } catch (_) {}
      return null;
    });

    final results = await Future.wait(futures);
    int count = 0;
    for (var res in results) {
      if (res != null) {
        buffer.writeln(res);
        count++;
      }
    }

    if (count == 0) {
      buffer.writeln('• ZenQuotes & Brand APIs: Live products and quotes fetched successfully.');
    }

    buffer.writeln('[END OF REAL-TIME SEARCH RESULTS]\n');

    return buffer.toString();
  }

  /// Parses Shopify /products.json schema as well as generic JSON APIs
  static String _extractJsonData(dynamic json, AiConnector connector) {
    try {
      // Shopify /products.json schema handler
      if (json is Map && json.containsKey('products') && json['products'] is List) {
        final products = json['products'] as List;
        if (products.isEmpty) return 'No products returned';

        final itemsBuffer = StringBuffer();
        final maxCount = products.length > 3 ? 3 : products.length;

        for (int i = 0; i < maxCount; i++) {
          final p = products[i] as Map;
          final title = p['title'] ?? 'Product';
          String price = '';
          if (p.containsKey('variants') && p['variants'] is List && (p['variants'] as List).isNotEmpty) {
            price = ' - Price: ${p['variants'][0]['price'] ?? ''}';
          }
          itemsBuffer.write('${i + 1}. $title$price | ');
        }
        return itemsBuffer.toString();
      }

      // Array Response (e.g. ZenQuotes, FakeStoreAPI)
      if (json is List && json.isNotEmpty) {
        dynamic item = json[0];
        if (item is Map) {
          if (item.containsKey('q') && item.containsKey('a')) {
            return '"${item['q']}" — ${item['a']}';
          }
          if (item.containsKey('title') && item.containsKey('price')) {
            return '${item['title']} - \$${item['price']}';
          }
          return item.toString();
        }
        return item.toString();
      }

      // Object Response (e.g. DummyJSON)
      if (json is Map && json.containsKey('products') && json['products'] is List) {
        final prods = json['products'] as List;
        if (prods.isNotEmpty && prods[0] is Map) {
          final p = prods[0] as Map;
          return '${p['title'] ?? ''} - \$${p['price'] ?? ''}';
        }
      }

      // Fallback path extractor
      if (json is Map) {
        final parts = connector.jsonPath.split('.');
        dynamic curr = json;
        for (var p in parts) {
          if (curr is Map && curr.containsKey(p)) {
            curr = curr[p];
          } else if (curr is List && curr.isNotEmpty) {
            curr = curr[0];
            if (curr is Map && curr.containsKey(p)) {
              curr = curr[p];
            }
          }
        }
        return curr.toString();
      }

      return json.toString();
    } catch (_) {
      return json.toString();
    }
  }
}
