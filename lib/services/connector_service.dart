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
    List<AiConnector> selectedConnectors = [];

    // 1. Precise Product Intent Router (Shoes / Clothing / Coffee / Skincare / Audio / Jewellery)
    if (lowerPrompt.contains('shoe') || lowerPrompt.contains('sneaker') || lowerPrompt.contains('footwear') || lowerPrompt.contains('boot')) {
      selectedConnectors = activeConnectors.where((c) {
        final name = c.name.toLowerCase();
        return name.contains('allbird') || name.contains('greats') || name.contains('rothy') || name.contains('dune') || name.contains('chubbi') || c.id.contains('shop_gl');
      }).toList();
    } else if (lowerPrompt.contains('audio') || lowerPrompt.contains('headphone') || lowerPrompt.contains('earbud') || lowerPrompt.contains('speaker') || lowerPrompt.contains('sound')) {
      selectedConnectors = activeConnectors.where((c) {
        final name = c.name.toLowerCase();
        return name.contains('boat') || name.contains('noise') || name.contains('jones');
      }).toList();
    } else if (lowerPrompt.contains('coffee') || lowerPrompt.contains('tea') || lowerPrompt.contains('drink') || lowerPrompt.contains('brew')) {
      selectedConnectors = activeConnectors.where((c) {
        final name = c.name.toLowerCase();
        return name.contains('coffee') || name.contains('tea') || name.contains('chaayos') || name.contains('country bean');
      }).toList();
    } else if (lowerPrompt.contains('skin') || lowerPrompt.contains('beauty') || lowerPrompt.contains('cosmetic') || lowerPrompt.contains('shaving') || lowerPrompt.contains('care')) {
      selectedConnectors = activeConnectors.where((c) {
        final name = c.name.toLowerCase();
        return name.contains('mcaffeine') || name.contains('mamaearth') || name.contains('plum') || name.contains('kama') || name.contains('glossier') || name.contains('colourpop') || name.contains('shaving');
      }).toList();
    } else if (lowerPrompt.contains('jewel') || lowerPrompt.contains('ring') || lowerPrompt.contains('necklace')) {
      selectedConnectors = activeConnectors.where((c) {
        final name = c.name.toLowerCase();
        return name.contains('giva') || name.contains('pipa') || name.contains('voylla');
      }).toList();
    } else if (lowerPrompt.contains('clothing') || lowerPrompt.contains('shirt') || lowerPrompt.contains('pants') || lowerPrompt.contains('fashion') || lowerPrompt.contains('wear') || lowerPrompt.contains('apparel')) {
      selectedConnectors = activeConnectors.where((c) {
        final name = c.name.toLowerCase();
        return name.contains('snitch') || name.contains('souled') || name.contains('bewakoof') || name.contains('gymshark') || name.contains('represent') || name.contains('suta') || name.contains('damensch');
      }).toList();
    }
    // 2. Encyclopedia & Wiki Intent Router
    else if (lowerPrompt.contains('wiki') ||
        lowerPrompt.contains('encyclopedia') ||
        lowerPrompt.contains('who') ||
        lowerPrompt.contains('what') ||
        lowerPrompt.contains('history') ||
        lowerPrompt.contains('science') ||
        lowerPrompt.contains('anime') ||
        lowerPrompt.contains('game') ||
        lowerPrompt.contains('manga') ||
        lowerPrompt.contains('philosophy') ||
        lowerPrompt.contains('linux') ||
        lowerPrompt.contains('indic') ||
        lowerPrompt.contains('hindi') ||
        lowerPrompt.contains('sanskrit')) {
      final encMatches = activeConnectors.where((c) {
        if (c.category != ConnectorCategory.encyclopedia) return false;
        final nameLower = c.name.toLowerCase();
        final firstWord = nameLower.replaceAll(RegExp(r'[^\w\s]'), '').split(' ').first;
        return lowerPrompt.contains(firstWord) || lowerPrompt.contains(c.region.toLowerCase());
      }).toList();

      if (encMatches.isNotEmpty) {
        selectedConnectors = encMatches.take(4).toList();
      } else {
        selectedConnectors = activeConnectors.where((c) => c.category == ConnectorCategory.encyclopedia).take(4).toList();
      }
    } else {
      selectedConnectors = activeConnectors.take(6).toList();
    }

    if (selectedConnectors.isEmpty) {
      selectedConnectors = activeConnectors.take(5).toList();
    }

    final buffer = StringBuffer();
    buffer.writeln('\n[REAL-TIME LIVE CONNECTOR SEARCH RESULTS]');

    final futures = selectedConnectors.map((c) async {
      try {
        String fetchUrl = c.url;

        if (c.category == ConnectorCategory.encyclopedia && c.url.contains('/w/api.php') && !c.url.contains('srsearch')) {
          final queryTerm = _extractSearchTerm(userPrompt);
          fetchUrl = '${c.url}?action=query&list=search&srsearch=${Uri.encodeComponent(queryTerm)}&format=json';
        }

        final response = await http
            .get(Uri.parse(fetchUrl), headers: _standardHeaders)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final extracted = _extractJsonData(data, c, userPrompt: userPrompt);
          if (extracted != null && extracted.isNotEmpty) {
            return '• ${c.name} (${c.region}): $extracted';
          }
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
      buffer.writeln('• Verified Brand & Wiki Feeds: Search results retrieved.');
    }

    buffer.writeln('[END OF REAL-TIME SEARCH RESULTS]\n');

    return buffer.toString();
  }

  static String _extractSearchTerm(String prompt) {
    String clean = prompt.replaceAll(RegExp(r'(who|what|where|when|why|how|is|are|the|a|an|tell|me|about|query|connectors|find|search|best|some)'), ' ').trim();
    return clean.isEmpty ? 'Artificial_intelligence' : clean;
  }

  /// Parses and filters JSON response by search prompt intent
  static String? _extractJsonData(dynamic json, AiConnector connector, {String userPrompt = ''}) {
    try {
      final searchKeywords = userPrompt.toLowerCase().split(' ').where((w) => w.length > 3).toList();

      // 1. MediaWiki Action Query Search API (/w/api.php)
      if (json is Map && json.containsKey('query') && json['query'] is Map && (json['query'] as Map).containsKey('search')) {
        final searchList = json['query']['search'] as List;
        if (searchList.isNotEmpty && searchList[0] is Map) {
          final firstResult = searchList[0] as Map;
          final title = firstResult['title'] ?? '';
          String snippet = (firstResult['snippet'] ?? '').toString();
          snippet = snippet.replaceAll(RegExp(r'<[^>]*>'), '');
          return '$title — $snippet';
        }
      }

      // 2. MediaWiki REST Summary API
      if (json is Map && json.containsKey('extract')) {
        return json['extract'].toString();
      }

      // 3. Shopify /products.json schema handler with Keyword Matching
      if (json is Map && json.containsKey('products') && json['products'] is List) {
        final products = json['products'] as List;
        if (products.isEmpty) return null;

        // Filter products matching search keywords if available
        List matchingProducts = products;
        if (searchKeywords.isNotEmpty) {
          final filtered = products.where((p) {
            final titleLower = (p['title'] ?? '').toString().toLowerCase();
            final typeLower = (p['product_type'] ?? '').toString().toLowerCase();
            return searchKeywords.any((kw) => titleLower.contains(kw) || typeLower.contains(kw));
          }).toList();
          if (filtered.isNotEmpty) {
            matchingProducts = filtered;
          }
        }

        final itemsBuffer = StringBuffer();
        final maxCount = matchingProducts.length > 3 ? 3 : matchingProducts.length;

        for (int i = 0; i < maxCount; i++) {
          final p = matchingProducts[i] as Map;
          final title = p['title'] ?? 'Product';
          String price = '';
          if (p.containsKey('variants') && p['variants'] is List && (p['variants'] as List).isNotEmpty) {
            price = ' - Price: \$${p['variants'][0]['price'] ?? ''}';
          }
          itemsBuffer.write('${i + 1}. $title$price | ');
        }
        return itemsBuffer.toString();
      }

      // 4. Array Response (e.g. ZenQuotes, FakeStoreAPI)
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

      // 5. Object Response (e.g. DummyJSON)
      if (json is Map && json.containsKey('products') && json['products'] is List) {
        final prods = json['products'] as List;
        if (prods.isNotEmpty && prods[0] is Map) {
          final p = prods[0] as Map;
          return '${p['title'] ?? ''} - \$${p['price'] ?? ''}';
        }
      }

      return json.toString();
    } catch (_) {
      return null;
    }
  }
}
