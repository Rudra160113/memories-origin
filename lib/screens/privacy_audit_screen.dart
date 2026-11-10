import 'package:flutter/material.dart';

import '../models/memories_data.dart';

class PrivacyAuditScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PrivacyAuditScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A2E2B)),
          onPressed: onBack,
        ),
        title: const Text('Origin Privacy Audit & Legal Terms', style: TextStyle(color: Color(0xFF4A2E2B), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF81B29A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF81B29A)),
              ),
              child: Row(
                children: const [
                  Text('🛡️', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('100% Offline & Non-Custodial Verified', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D5A27))),
                        Text('Zero cloud telemetry, zero remote tracking. All data remains exclusively on this device.', style: TextStyle(fontSize: 11, color: Color(0xFF1A3317))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Official Privacy Policy & Legal Covenants',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2E2B)),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                OriginLegal.privacyPolicy,
                style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF5C5552)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
