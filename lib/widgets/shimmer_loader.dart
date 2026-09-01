import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:juslegal/core/core.dart';

/// A shimmer loading widget that displays 3 stacked placeholder cards
/// with a shimmer effect while content is being loaded.
class ShimmerLoader extends StatelessWidget {
  final int numberOfCards;

  const ShimmerLoader({
    super.key,
    this.numberOfCards = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: AppTheme.surface,
        highlightColor: AppTheme.border,
        child: Column(
          children: List.generate(numberOfCards, (index) {
            return Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
            );
          }),
        ),
      ),
    );
  }
}

