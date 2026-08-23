import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Dark-theme tuned shimmer used for all skeleton loaders.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF242424),
      highlightColor: const Color(0xFF3A3A3A),
      child: child,
    );
  }
}

/// A rounded placeholder block. Wrap in [AppShimmer] to animate it.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton row with a leading circle/box, text lines and a trailing box.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({
    super.key,
    this.leadingSize = 54,
    this.trailingSize = 28,
  });

  final double leadingSize;
  final double trailingSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(width: leadingSize, height: leadingSize, radius: 40),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 14, radius: 6),
              const SizedBox(height: 8),
              SkeletonBox(width: 120, height: 10, radius: 5),
            ],
          ),
        ),
        SkeletonBox(width: trailingSize, height: trailingSize, radius: trailingSize / 2),
      ],
    );
  }
}
