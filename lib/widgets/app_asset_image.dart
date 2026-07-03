import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Loads a bundled image reliably on mobile and web.
class AppAssetImage extends StatelessWidget {
  const AppAssetImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.expand = false,
    this.cacheWidth,
    this.errorBuilder,
  });

  final String asset;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// When true, fills all space given by the parent (for [Stack] tiles).
  final bool expand;
  final int? cacheWidth;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      fit: fit,
      width: expand ? null : width,
      height: expand ? null : height,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      cacheWidth: kIsWeb ? null : cacheWidth,
      errorBuilder: errorBuilder ??
          (context, error, stack) {
            debugPrint('AppAssetImage failed: $asset ($error)');
            return ColoredBox(
              color: const Color(0xFFD0D0D0),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey.shade600,
                  size: 28,
                ),
              ),
            );
          },
    );

    if (expand) {
      return SizedBox.expand(child: image);
    }
    return image;
  }
}

/// Background photo layer using [DecorationImage] (most reliable on Flutter web).
class AppAssetBackground extends StatelessWidget {
  const AppAssetBackground({
    super.key,
    required this.asset,
    required this.child,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackColor = const Color(0xFFD0D0D0),
  });

  final String asset;
  final Widget child;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fallbackColor,
        borderRadius: borderRadius,
        image: DecorationImage(
          image: AssetImage(asset),
          fit: fit,
        ),
      ),
      child: child,
    );
  }
}
