import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/ai_graphics_config.dart';

class AiGraphicsResult {
  const AiGraphicsResult({
    required this.imageUrl,
    required this.prompt,
    this.bytes,
  });

  final String imageUrl;
  final String prompt;
  final Uint8List? bytes;
}

/// Generates marketing graphics from text prompts.
class AiGraphicsService {
  String buildImageUrl(
    String prompt, {
    required int width,
    required int height,
    int? seed,
  }) {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    final encoded = Uri.encodeComponent(trimmed);
    final s = seed ?? DateTime.now().millisecondsSinceEpoch;
    return '${AiGraphicsConfig.pollinationsBase}/$encoded'
        '?width=$width&height=$height&nologo=true&seed=$s';
  }

  Future<AiGraphicsResult> generate({
    required String prompt,
    required int width,
    required int height,
  }) async {
    final custom = AiGraphicsConfig.customApiUrl?.trim();
    if (custom != null && custom.isNotEmpty) {
      return _generateViaBackend(custom, prompt, width, height);
    }
    return _generateViaPollinations(prompt, width, height);
  }

  Future<AiGraphicsResult> _generateViaPollinations(
    String prompt,
    int width,
    int height,
  ) async {
    final url = buildImageUrl(prompt, width: width, height: height);
    final bytes = await _tryFetchBytes(url);
    return AiGraphicsResult(imageUrl: url, prompt: prompt, bytes: bytes);
  }

  Future<AiGraphicsResult> _generateViaBackend(
    String apiUrl,
    String prompt,
    int width,
    int height,
  ) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'prompt': prompt,
        'width': width,
        'height': height,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMsg = 'AI API failed (HTTP ${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] != null) {
          errorMsg = body['error'].toString();
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('image/')) {
      return AiGraphicsResult(
        imageUrl: apiUrl,
        prompt: prompt,
        bytes: response.bodyBytes,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map && body['image_url'] != null) {
      final imageUrl = body['image_url'].toString();
      final bytes = await _tryFetchBytes(imageUrl);
      return AiGraphicsResult(
        imageUrl: imageUrl,
        prompt: prompt,
        bytes: bytes,
      );
    }

    throw Exception('AI API returned an unexpected response');
  }

  Future<Uint8List?> _tryFetchBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      
      String errorMsg = 'Failed to generate image (HTTP ${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] != null) {
          errorMsg = body['error'].toString();
        }
      } catch (_) {}
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('AiGraphicsService fetch: $e');
      rethrow;
    }
  }

  /// Builds a job-posting prompt from business fields.
  static String jobPostingPrompt({
    required String company,
    required String jobTitle,
    String jobType = 'Internship',
    String location = '',
  }) {
    final loc = location.trim().isEmpty ? 'India' : location.trim();
    return 'Professional hiring poster for $jobTitle at $company, '
        '$jobType position in $loc, modern Indian corporate style, '
        'orange accent colors, clean layout with space for text, digital illustration';
  }
}
