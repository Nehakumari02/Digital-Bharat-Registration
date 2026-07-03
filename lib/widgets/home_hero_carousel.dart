import 'dart:async';

import 'package:flutter/material.dart';

import 'package:the_digital_registration/theme/app_theme.dart';
import 'package:the_digital_registration/widgets/app_asset_image.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

class HomeCarouselSlide {
  const HomeCarouselSlide({
    required this.imageAsset,
    this.badge,
    this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCtaTap,
  });

  final String imageAsset;
  final String? badge;
  final String? title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
}

/// Swipeable hero images at the top of the home tab.
class HomeHeroCarousel extends StatefulWidget {
  const HomeHeroCarousel({
    super.key,
    required this.slides,
    this.height,
  });

  final List<HomeCarouselSlide> slides;
  final double? height;

  @override
  State<HomeHeroCarousel> createState() => _HomeHeroCarouselState();
}

class _HomeHeroCarouselState extends State<HomeHeroCarousel> {
  final _controller = PageController();
  int _index = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.slides.length <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final nextIndex = (_index + 1) % widget.slides.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    final desktop = Responsive.isDesktop(context);
    final height = widget.height ?? (desktop ? 280.0 : 200.0);
    final radius = desktop ? 16.0 : 0.0;

    return Column(
      children: [
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                // Reset timer on manual swipe so it doesn't jump too soon
                _startAutoScroll();
              },
              itemBuilder: (context, i) => _HeroSlide(
                slide: widget.slides[i],
                desktop: desktop,
              ),
            ),
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.slides.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.slide, required this.desktop});

  final HomeCarouselSlide slide;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: slide.onCtaTap,
      child: AppAssetBackground(
        asset: slide.imageAsset,
        fallbackColor: AppTheme.primary,
        child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.2),
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
                if (slide.badge != null && slide.badge!.isNotEmpty) ...[
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
                      slide.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (slide.title != null)
                  Text(
                    slide.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: desktop ? 26 : 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                if (slide.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    slide.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: desktop ? 14 : 12,
                    ),
                  ),
                ],
                if (slide.ctaLabel != null && slide.onCtaTap != null) ...[
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: slide.onCtaTap,
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
                    child: Text(slide.ctaLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
