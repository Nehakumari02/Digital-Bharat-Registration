import 'package:flutter/material.dart';

import 'package:the_digital_registration/theme/app_theme.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

/// Full-width image banner for the home tab with text overlay.
class HomeImageBanner extends StatelessWidget {
  const HomeImageBanner({
    super.key,
    this.title,
    this.subtitle,
    this.badge,
    this.ctaLabel,
    this.onCtaTap,
    this.imageAsset = 'assets/images/home_banner.jpg',
    this.height,
  });

  final String? title;
  final String? subtitle;
  final String? badge;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
  final String imageAsset;
  final double? height;

  static const _fallbackGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF2196F3), Color(0xFF1E88E5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    final bannerHeight = height ?? (desktop ? 280.0 : 200.0);

    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(desktop ? 16 : 0),
        child: GestureDetector(
          onTap: onCtaTap,
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: _fallbackGradient),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  cacheWidth: desktop ? 1280 : 800,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(desktop ? 28 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (badge != null && badge!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (title != null)
                        Text(
                          title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: desktop ? 26 : 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: desktop ? 14 : 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (ctaLabel != null && onCtaTap != null) ...[
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: onCtaTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(ctaLabel!),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
