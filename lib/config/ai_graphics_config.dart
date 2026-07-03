import 'api_config.dart';

/// AI image generation settings and prompt templates.
abstract final class AiGraphicsConfig {
  /// Pollinations.ai — free text-to-image (no API key). Replace with your Laravel
  /// proxy URL when you add `POST /api/ai/generate-image` on the backend.
  static const String pollinationsBase = 'https://image.pollinations.ai/prompt';

  /// Optional custom backend, e.g. `http://127.0.0.1:8000/api/ai/generate-image`.
  /// When set, [AiGraphicsService] POSTs `{ "prompt", "width", "height" }` and
  /// expects `{ "image_url": "..." }` or raw image bytes.
  static String get customApiUrl => '${ApiConfig.baseUrl}/ai/generate-image';

  static const Map<String, ({int width, int height, String label})> sizes = {
    'banner': (width: 1200, height: 400, label: 'Web banner (1200×400)'),
    'square': (width: 1024, height: 1024, label: 'Square (1024×1024)'),
    'story': (width: 1080, height: 1920, label: 'Story / mobile (1080×1920)'),
    'job': (width: 1200, height: 630, label: 'Job post (1200×630)'),
  };

  static const List<({String title, String prompt})> templates = [
    (
      title: 'Job hiring poster',
      prompt:
          'Professional job recruitment poster, modern office, diverse Indian team, '
          'orange and white corporate style, clean typography space, high quality digital art',
    ),
    (
      title: 'Business promo banner',
      prompt:
          'Indian MSME business growth banner, digital India theme, rupee and chart icons, '
          'warm orange gradient, professional marketing graphic, no text',
    ),
    (
      title: 'Scholarship / education',
      prompt:
          'Indian students education scholarship banner, books and graduation cap, '
          'inspiring blue and gold palette, clean illustration style',
    ),
    (
      title: 'Farm & agriculture',
      prompt:
          'Indian farmer green fields harvest banner, mandi and crop theme, '
          'natural colors, hopeful rural India illustration',
    ),
    (
      title: 'Cyber security',
      prompt:
          'Cyber security shield digital lock, dark blue tech background, '
          'safe online banking India, modern flat illustration',
    ),
    (
      title: 'Digital registration portal',
      prompt:
          'Government digital services portal hero image, smartphone verification checkmark, '
          'Indian map subtle, orange yellow gradient, fintech style illustration',
    ),
  ];
}
