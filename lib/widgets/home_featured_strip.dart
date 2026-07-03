import 'package:flutter/material.dart';

import 'package:the_digital_registration/widgets/app_asset_image.dart';
import 'package:the_digital_registration/widgets/responsive_layout.dart';

class FeaturedImageItem {
  const FeaturedImageItem({
    required this.label,
    required this.imageAsset,
    this.onTap,
  });

  final String label;
  final String imageAsset;
  final VoidCallback? onTap;
}

/// Horizontal row of image tiles below the stats card.
class HomeFeaturedStrip extends StatelessWidget {
  const HomeFeaturedStrip({
    super.key,
    required this.items,
  });

  final List<FeaturedImageItem> items;

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    final tileHeight = desktop ? 110.0 : 96.0;
    final tileWidth = desktop ? 200.0 : 160.0;

    return SizedBox(
      height: tileHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: AppAssetBackground(
                  asset: item.imageAsset,
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
