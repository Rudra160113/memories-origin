import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhotoViewerDialog extends StatelessWidget {
  final String photoData;

  const PhotoViewerDialog({super.key, required this.photoData});

  Widget _buildImage() {
    if (photoData.startsWith('data:image')) {
      final base64String = photoData.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
      );
    } else if (photoData.startsWith('http://') || photoData.startsWith('https://')) {
      return Image.network(
        photoData,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
      );
    } else {
      if (kIsWeb) {
        // Blob URL for Web
        return Image.network(
          photoData,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
        );
      } else {
        return Image.file(
          File(photoData),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImage(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
